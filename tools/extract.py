#!/usr/bin/env python3
"""Disassemble the source PDF into editable parts.

Outputs (never overwrites existing files unless --force):
  src/<src>.md                source body text as Markdown
  figures/fig-NN.png          original figure images
  figures/fig-NN.<src>.txt    OCR'd figure text, one element per line
  figures/layout/fig-NN.json  bounding box of each figure text line

All document-specific thresholds come from technote.json (see tools/config.py
and `make inspect`).
"""
import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

import pymupdf

import config

ROOT = config.ROOT
CFG = config.load()
CODE_COLORS = {int(c.lstrip("#"), 16) for c in CFG["code"]["colors"]}
CODE_FONTS = CFG["code"]["fonts"]
MARKERS = set(CFG["bullets"]["fonts"])
STRIP_FONTS = set(CFG["bullets"]["strip_fonts"])
HEADING_LEVEL_BY_X = {int(k): v for k, v in CFG["heading"]["levels_by_x"].items()}
SRC = CFG["source_lang"]


def write(path: Path, text: str, force: bool):
    if path.exists() and not force:
        print(f"skip (exists): {path.relative_to(ROOT)}")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    print(f"wrote: {path.relative_to(ROOT)}")


def line_items(page, cut_vector_figures=True):
    items = []
    for b in page.get_text("dict")["blocks"]:
        if b["type"] != 0:
            continue
        for l in b["lines"]:
            spans = list(l["spans"])
            x0, y0, x1, y1 = l["bbox"]
            if y0 > CFG["footer_y"] or y0 < CFG["header_y"]:  # running header/footer
                continue
            items.append({"kind": "line", "x": round(x0), "y0": y0, "y1": y1, "x1": x1,
                          "spans": spans, "text": "".join(s["text"] for s in spans)})
    for info in page.get_image_info(xrefs=True):
        x0, y0, x1, y1 = info["bbox"]
        if x1 - x0 < CFG["min_figure_width"]:  # inline glyph images (emoji)
            continue
        items.append({"kind": "image", "y0": y0, "y1": y1, "xref": info["xref"],
                      "width_pt": x1 - x0})
    # A line split by a font change (e.g. an emoji inside a code string): join the fragments.
    lines = sorted((it for it in items if it["kind"] == "line"), key=lambda it: it["x"])
    for frag in lines:
        head = next((it for it in lines if it is not frag and it in items and it["text"].strip()
                     and abs(it["y0"] - frag["y0"]) < 2 and abs(frag["x"] - it["x1"]) < 3), None)
        if head and frag["text"].strip():
            head["spans"] += frag["spans"]
            head["text"] += frag["text"]
            head["x1"] = frag["x1"]
            items.remove(frag)
    # A bullet glyph is often a separate line whose top differs slightly from its text: merge them.
    for m in [it for it in items if it["kind"] == "line" and it["text"].strip()
              and all(font_of(s) in MARKERS for s in it["spans"] if s["text"].strip())]:
        text = [it for it in items if it["kind"] == "line" and it is not m and it["x"] > m["x"]
                and abs(it["y0"] - m["y0"]) < 3 and it["text"].strip()]
        if text:
            t = min(text, key=lambda it: it["x"])
            t["spans"] = m["spans"] + t["spans"]
            t["x"], t["y0"] = m["x"], min(m["y0"], t["y0"])
            items.remove(m)
    if cut_vector_figures:
        for vf in CFG["vector_figures"]:
            if vf["page"] != page.number + 1:
                continue
            clip = pymupdf.Rect(vf["clip"])
            items = [it for it in items if it["kind"] != "line"
                     or not clip.contains(pymupdf.Rect(it["x"], it["y0"], it["x1"], it["y1"]).tl)]
            items.append({"kind": "image", "y0": clip.y0, "y1": clip.y1, "x": clip.x0,
                          "vector": vf, "width_pt": clip.width})
    items.sort(key=lambda it: (it["y0"], it.get("x", 0)))
    return items


def vector_figure_lines(page, vf, scale):
    """Text lines inside a vector figure, as layout lines in pixel coordinates of its raster."""
    clip = pymupdf.Rect(vf["clip"])
    out = []
    for it in line_items(page, cut_vector_figures=False):
        if it["kind"] != "line" or not it["text"].strip():
            continue
        r = pymupdf.Rect(it["x"], it["y0"], it["x1"], it["y1"])
        if not clip.contains(r.tl):
            continue
        x0, y0 = (r.x0 - clip.x0) * scale, (r.y0 - clip.y0) * scale
        spans = [sp for sp in it["spans"] if sp["text"].strip()]
        out.append({"box": [round(x0), round(y0), round(r.width * scale), round(r.height * scale)],
                    "text": re.sub(r"\s+", " ", it["text"]).strip(),
                    "pdf_rect": [round(v, 2) for v in r],
                    "fg": [*pymupdf.sRGB_to_rgb(spans[-1]["color"]), 255],
                    "size": round(max(sp["size"] for sp in spans) * scale, 1),
                    "weight": "bold" if any("Bold" in font_of(sp) for sp in spans) else "regular"})
    out.sort(key=lambda l: (l["box"][1], l["box"][0]))
    return out


def font_of(span):
    return span["font"].split("+")[-1]


def is_code_font(span):
    return any(f in font_of(span) for f in CODE_FONTS)


def is_code_line(item, body_x):
    if any((s["color"] in CODE_COLORS or is_code_font(s)) and s["text"].strip() for s in item["spans"]):
        return True
    if CFG["code"]["indent"] is None:  # code is recognised by font/colour only
        return False
    return item["x"] >= body_x + CFG["code"]["indent"]


def is_heading(fonts, size):
    h = CFG["heading"]
    return size >= h["min_size"] and any(any(f in font for f in h["fonts"]) for font in fonts)


def is_caption(item):
    spans = [s for s in item["spans"] if s["text"].strip()]
    italic = all(("Italic" in font_of(s) or "Oblique" in font_of(s)) for s in spans)
    return bool(spans) and (italic or not CFG["caption"]["italic"]) and item["x"] > CFG["caption"]["min_x"]


def inline_md(spans):
    out = []
    for s in spans:
        t = s["text"]
        if t.strip() and s["color"] not in CODE_COLORS and "Bold" in font_of(s):
            lead = t[: len(t) - len(t.lstrip())]
            trail = t[len(t.rstrip()):]
            t = f"{lead}**{t.strip()}**{trail}"
        out.append(t)
    return "".join(out)


def join_lines(lines):
    text = ""
    for l in lines:
        l = l.strip()
        if not text:
            text = l
        elif text.endswith("-") and not text.endswith(" -"):
            text += l
        else:
            text += " " + l
    return re.sub(r"\s{2,}", " ", text).strip()


def code_lang(lines):
    """Best guess; the agent should review fences after extraction.
    ```text marks sample values (numbers, output) that may be localised."""
    src = "\n".join(lines)
    if re.match(r"\s*[\[{]", src) and re.search(r'"\s*:', src) and not re.search(r":=", src):
        return "json"
    if re.search(r"^\s*<(!doctype|html|div|script)", src, re.M | re.I):
        return "html"
    if re.search(r"^\s*(var|let|const|function) |=>|\bdocument\.|\bwindow\.", src, re.M) and ":=" not in src:
        return "js"
    if re.fullmatch(r"[\s\d\.\-+\[\],°'\"NSEW:/=×θ]+", src):
        return "text"
    return "4d"


def code_line_text(item, indents):
    """indents: sorted distinct left x positions (±3 pt) of the block; rank = indent level."""
    raw = "".join(s["text"] for s in item["spans"]).rstrip()
    stripped = raw.lstrip(" ")
    spaces = len(raw) - len(stripped)
    rank = max(i for i, x in enumerate(indents) if item["x"] >= x - 3)
    level = spaces // 4 if spaces >= 4 else rank
    return "    " * level + stripped


def indent_positions(items):
    xs = []
    for x in sorted(it["x"] for it in items if it["text"].strip()):
        if not xs or x - xs[-1] > 3:
            xs.append(x)
    return xs


def extract_body(doc):
    out = []
    cover = CFG["cover"]
    p1 = [it for it in line_items(doc[cover["page"] - 1]) if it["kind"] == "line" and it["text"].strip()]
    title, *rest = (it["text"].strip() for it in p1[:cover["lines"]])
    out.append(f"# {title}\n\n" + "".join(f"{r}\n\n" for r in rest).rstrip("\n") + "\n")

    figures = []
    state = {"para": [], "code": [], "bullets": [], "in_bullet": False, "table": []}
    body_x = 72
    prev = None

    def flush_para():
        if state["para"]:
            out.append(join_lines(state["para"]) + "\n")
            state["para"] = []

    def flush_bullets():
        if state["bullets"]:
            out.append("\n".join(f"- {join_lines(b)}" for b in state["bullets"]) + "\n")
            state["bullets"] = []
        state["in_bullet"] = False

    def flush_code():
        items = state["code"]
        if items:
            # Whitespace-only lines are layout artefacts; a blank line is emitted only where
            # the vertical distance between two code lines leaves room for one.
            items = [it for it in items if it["text"].strip()]
            indents = indent_positions(items)
            lines = []
            for i, it in enumerate(items):
                if i and it["y0"] - items[i - 1]["y0"] > 1.5 * (items[i - 1]["y1"] - items[i - 1]["y0"]):
                    lines.append("")
                lines.append(code_line_text(it, indents))
            while lines and not lines[-1]:
                lines.pop()
            out.append(f"```{code_lang(lines)}\n" + "\n".join(lines) + "\n```\n")
            state["code"] = []

    def flush_table():
        if state["table"]:
            # Physical lines → rows: a vertical jump larger than row_gap starts a new row,
            # so wrapped cell text is joined into one cell. Columns come from the header line.
            gap = CFG["table"].get("row_gap", 15)
            groups = []
            for y0, cells in state["table"]:
                if groups and y0 - groups[-1][-1][0] <= gap:
                    groups[-1].append((y0, cells))
                else:
                    groups.append([(y0, cells)])
            cols = sorted({c["x"] for _, cells in groups[0] for c in cells})
            rows = []
            for g in groups:
                row = [[] for _ in cols]
                for _, cells in g:
                    for c in cells:
                        i = max(k for k, x in enumerate(cols) if c["x"] >= x - 3) if c["x"] >= cols[0] - 3 else 0
                        row[i].append(c["text"].strip())
                rows.append([join_lines(parts) for parts in row])
            md = ["| " + " | ".join(rows[0]) + " |", "|" + "---|" * len(rows[0])]
            md += ["| " + " | ".join(r) + " |" for r in rows[1:]]
            out.append("\n".join(md) + "\n")
            state["table"] = []

    def flush_all():
        flush_para(); flush_bullets(); flush_code(); flush_table()

    skip = {p - 1 for p in CFG["skip_pages"]}
    for pno in (p for p in range(len(doc)) if p not in skip):
        for it in line_items(doc[pno]):
            if it["kind"] == "image":
                flush_all()
                figures.append({"page": pno + 1, "xref": it.get("xref"), "vector": it.get("vector"),
                                "width_pt": it["width_pt"]})
                out.append(f"![](fig-{len(figures):02d})\n")
                prev = None
                continue
            text = it["text"]
            fonts = {font_of(s) for s in it["spans"] if s["text"].strip()}
            size = round(max(s["size"] for s in it["spans"]))

            if not text.strip():
                indent = CFG["code"]["indent"]
                if state["code"] and (indent is None or it["x"] >= body_x + indent):
                    state["code"].append(it)
                else:
                    flush_code()
                prev = None
                continue

            if is_heading(fonts, size) and not is_code_line(it, it["x"] + 1000):
                flush_all()
                near = [x for x in HEADING_LEVEL_BY_X if abs(x - it["x"]) <= 6]
                level = (HEADING_LEVEL_BY_X[min(near, key=lambda x: abs(x - it["x"]))] if near
                         else CFG["heading"]["default_level"])
                out.append(f"{'#' * level} {text.strip()}\n")
                body_x = it["x"]
                prev = None
                continue

            if is_caption(it):
                flush_all()
                caption = text.strip()
                last_fig = max((i for i, o in enumerate(out) if o.startswith("![](fig-")), default=None)
                if last_fig is not None:
                    out[last_fig] = out[last_fig].replace("![]", f"![{caption}]")
                else:
                    out.append(f"*{caption}*\n")
                prev = None
                continue

            italic = all("Italic" in f or "Oblique" in f for f in fonts)
            if CFG["table"]["size"] and size == CFG["table"]["size"] and not italic:  # table cells
                flush_para(); flush_bullets(); flush_code()
                if state["table"] and abs(state["table"][-1][0] - it["y0"]) < 3:
                    state["table"][-1][1].append(it)
                else:
                    state["table"].append((it["y0"], [it]))
                continue
            flush_table()

            if fonts & MARKERS:
                flush_para(); flush_code()
                state["in_bullet"] = True
                rest = inline_md([s for s in it["spans"]
                                  if font_of(s) not in MARKERS | STRIP_FONTS])
                state["bullets"].append([rest] if rest.strip() else [])
                prev = it
                continue

            if state["in_bullet"] and it["x"] > body_x and not any(
                    (s["color"] in CODE_COLORS or is_code_font(s)) and s["text"].strip() for s in it["spans"]):
                state["bullets"][-1].append(inline_md(it["spans"]))
                prev = it
                continue

            if (it["x"] != body_x or CFG["code"]["indent"] is None) and is_code_line(it, body_x):
                flush_para(); flush_bullets()
                state["code"].append(it)
                prev = it
                continue

            flush_bullets(); flush_code()
            para = CFG["paragraph"]
            if prev is not None and state["para"] and (
                    abs(it["y0"] - prev["y1"]) > para["gap"]
                    or (prev["x1"] < para["short_line_x1"] and prev["text"].rstrip().endswith((".", ":")))):
                flush_para()
            body_x = it["x"]
            state["para"].append(inline_md(it["spans"]))
            prev = it
    flush_all()
    return "\n".join(out), figures


def ocr_lines(png: Path):
    ocr = CFG["ocr"]
    tsv = subprocess.run(["tesseract", str(png), "-", "--psm", str(ocr["psm"]), "tsv"],
                         capture_output=True, text=True, check=True).stdout
    groups = {}
    for row in tsv.splitlines()[1:]:
        f = row.split("\t")
        if len(f) < 12 or not f[11].strip() or float(f[10]) < ocr["min_conf"]:
            continue
        key = (int(f[2]), int(f[3]), int(f[4]))
        groups.setdefault(key, []).append(
            {"x": int(f[6]), "y": int(f[7]), "w": int(f[8]), "h": int(f[9]), "text": f[11]})
    lines = []
    for ws in groups.values():
        ws.sort(key=lambda w: w["x"])
        x0 = min(w["x"] for w in ws); y0 = min(w["y"] for w in ws)
        x1 = max(w["x"] + w["w"] for w in ws); y1 = max(w["y"] + w["h"] for w in ws)
        text = " ".join(w["text"] for w in ws).strip(" |—-~_")
        if not re.search(r"[A-Za-z]{3}|\d", text) or re.search(ocr["noise"], text):
            continue  # arrows, borders and other OCR noise
        lines.append({"box": [x0, y0, x1 - x0, y1 - y0], "text": text})
    lines.sort(key=lambda l: (l["box"][1] // 10, l["box"][0]))
    return lines


def extract_figures(doc, figures, force):
    figdir = ROOT / "figures"
    (figdir / "layout").mkdir(parents=True, exist_ok=True)
    for n, fig in enumerate(figures, 1):
        name = f"fig-{n:02d}"
        png = figdir / f"{name}.png"
        vf = fig.get("vector")
        scale = vf.get("dpi", 600) / 72 if vf else 1
        if vf and (force or not png.exists()):
            doc[vf["page"] - 1].get_pixmap(dpi=vf.get("dpi", 600), clip=vf["clip"]).save(png)
            print(f"wrote: {png.relative_to(ROOT)} (rasterised vector figure)")
        elif force or not png.exists():
            pix = pymupdf.Pixmap(doc, fig["xref"])
            smask = doc.xref_get_key(fig["xref"], "SMask")
            if smask[0] == "xref":
                pix = pymupdf.Pixmap(pix, pymupdf.Pixmap(doc, int(smask[1].split()[0])))
            pix.save(png)
            print(f"wrote: {png.relative_to(ROOT)}")
        layout_path = figdir / "layout" / f"{name}.json"
        if force or not layout_path.exists():
            lines = vector_figure_lines(doc[vf["page"] - 1], vf, scale) if vf else ocr_lines(png)
            layout = {"source": f"{name}.png", "page": fig["page"],
                      "width_pt": round(fig["width_pt"], 1), "localize": True,
                      "items": [{"box": l["box"], "align": "center",
                                 **{k: l[k] for k in ("size", "weight", "fg", "pdf_rect") if k in l}}
                                for l in lines]}
            if vf:
                layout["vector"] = vf
            write(layout_path, json.dumps(layout, indent=1) + "\n", True)
            write(figdir / f"{name}.{SRC}.txt", "\n".join(l["text"] for l in lines) + "\n", True)


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--force", action="store_true", help="overwrite existing extracted files")
    args = ap.parse_args()
    doc = pymupdf.open(CFG["source_path"])
    body, figures = extract_body(doc)
    write(ROOT / "src" / f"{SRC}.md", body, args.force)
    extract_figures(doc, figures, args.force)


if __name__ == "__main__":
    sys.exit(main())
