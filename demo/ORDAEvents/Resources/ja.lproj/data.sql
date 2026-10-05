INSERT INTO [Client] ( [ID] , [Name] , [Email] , [Date_Creation] )
VALUES
(295 , '株式会社テックソリューションズ' , 'contact@techsolutions.co.jp' , '2026/03/11 00:00:00:00'),
(296 , '佐藤 美咲' , 'misaki.sato@example.jp' , '2026/03/11 00:00:00:00'),
(297 , 'グローバル工業株式会社' , 'procurement@global-kogyo.co.jp' , '2026/03/11 00:00:00:00'),
(298 , '田中工房' , 'tanaka.kobo@example.jp' , '2026/03/11 00:00:00:00'),
(299 , 'イノベーテック合同会社' , 'hello@innovatech.jp' , '2026/03/11 00:00:00:00');

INSERT INTO [Product] ( [ID] , [Name] , [Description] , [Price] , [Stock] , [minimumStock] )
VALUES
(838 , 'dell xps 15 laptop' , 'プロ向けノートPC - Intel i7-13700H、16GB RAM、512GB SSD、15.6インチ 4Kディスプレイ' , 194900 , 20 , 5),
(839 , 'hp probook 450' , 'ビジネス向けノートPC - Intel i5-12500H、8GB RAM、256GB SSD、14インチ フルHD' , 104900 , 8 , 5),
(840 , 'lenovo ideapad 3' , 'エントリーモデルのノートPC - AMD Ryzen 5、8GB RAM、512GB SSD、15.6インチ HD' , 67400 , 30 , 10),
(841 , 'hp z2 tower workstation' , 'プロ向けワークステーション - Intel Xeon、32GB RAM、1TB SSD、NVIDIA RTX A4000' , 374900 , 8 , 2),
(842 , 'apple macbook pro 14' , 'MacBook Pro 14インチ - M3 Proチップ、18GB RAM、512GB SSD、Liquid Retina XDR' , 299900 , 11 , 3),
(843 , 'dell ultrasharp 27" 4k' , '27インチ 4K UHDモニター - IPSパネル、USB-C、高さ調整可能、sRGB 99%' , 67400 , 20 , 10),
(844 , 'acer 24" full hd monitor' , '24インチ フルHDモニター - IPSパネル、75Hz、AMD FreeSync' , 19400 , 50 , 15),
(845 , 'samsung odyssey 32" curved' , '32インチ 曲面QHDゲーミングモニター - 165Hz、1ms、G-Sync互換' , 59900 , 19 , 5),
(846 , 'lg 34" ultrawide monitor' , '34インチ ウルトラワイドQHDモニター - アスペクト比21:9、HDR10、USB-C' , 89900 , 14 , 5),
(847 , 'logitech mx master 3s' , '高性能ワイヤレスマウス - エルゴノミクスデザイン、8000 DPI、マルチデバイス接続' , 14900 , 54 , 20),
(848 , 'logitech m185 wireless' , 'ワイヤレスマウス - 1000 DPI、プラグアンドプレイのナノレシーバー' , 2300 , 90 , 30),
(849 , 'keychron k8 mechanical' , 'ワイヤレスメカニカルキーボード - ホットスワップ対応スイッチ、RGBバックライト、Mac/PC対応' , 13400 , 39 , 15),
(850 , 'logitech k380 wireless' , 'マルチデバイス対応ワイヤレスキーボード - コンパクトデザイン、電池寿命2年' , 5900 , 65 , 25),
(851 , 'logitech brio 4k webcam' , '4Kウェブカメラ - HDR、オートフォーカス、Windows Hello対応、デュアルマイク' , 29900 , 19 , 10),
(852 , 'jabra evolve2 65 headset' , 'ワイヤレスヘッドセット - アクティブノイズキャンセリング、バッテリー37時間、UC認定' , 37400 , 23 , 10),
(853 , 'hp laserjet pro m404dn' , 'モノクロレーザープリンター - 38ppm、両面印刷、ネットワーク対応' , 52400 , 7 , 3),
(854 , 'epson ecotank et-4850' , 'インクジェット複合機 - プリント、スキャン、コピー、ファクス、カートリッジ不要' , 74900 , 12 , 3),
(855 , 'anker 10-port usb hub' , 'セルフパワーUSB 3.0ハブ - 10ポート、60W電源アダプター、個別スイッチ付き' , 7400 , 35 , 15),
(856 , 'caldigit ts4 thunderbolt 4' , 'Thunderbolt 4ドック - 18ポート、98W充電、8Kディスプレイ対応' , 59900 , 15 , 5),
(857 , 'samsung t7 1tb ssd' , 'ポータブルSSD - 容量1TB、読み込み1050MB/s、USB 3.2 Gen 2' , 14900 , 45 , 20);

INSERT INTO [Order] ( [ID] , [Date_Order] , [Date_Livraison] , [Statut] , [Price] , [Mode_Paiement] , [Comment] , [order_number] , [ID_Client] )
VALUES
(270 , '2026/03/11 00:00:00:00' , '2026/03/18 00:00:00:00' , 'In progress' , 1453000 , 'bank transfer' , '新支店のオフィス一式 - ワークステーション5台' , 'CMD-2026-0001' , 295),
(271 , '2026/03/08 00:00:00:00' , '2026/03/15 00:00:00:00' , 'Validate' , 457100 , 'credit card' , '在宅勤務用の機器' , 'CMD-2026-0002' , 296),
(272 , '2026/03/11 00:00:00:00' , '2026/03/25 00:00:00:00' , 'In progress' , 2135800 , 'bank transfer' , '全社導入 - IT部門の機器更新' , 'CMD-2026-0003' , 297),
(273 , '2026/03/06 00:00:00:00' , '2026/03/13 00:00:00:00' , 'Validate' , 724400 , 'credit card' , 'チーム用の追加アクセサリー' , 'CMD-2026-0004' , 299),
(274 , '2026/03/11 00:00:00:00' , '2026/03/16 00:00:00:00' , 'In progress' , 88200 , 'credit card' , 'ゲーム/配信環境のアップグレード' , 'CMD-2026-0005' , 296);

INSERT INTO [OrderLine] ( [ID] , [ID_Order] , [ID_Product] , [Quantity] )
VALUES
(519 , 270 , 838 , 5),
(520 , 270 , 843 , 5),
(521 , 270 , 847 , 5),
(522 , 270 , 849 , 5),
(523 , 271 , 842 , 1),
(524 , 271 , 846 , 1),
(525 , 271 , 851 , 1),
(526 , 271 , 852 , 1),
(527 , 272 , 840 , 2),
(528 , 272 , 844 , 2),
(529 , 272 , 839 , 10),
(530 , 272 , 843 , 10),
(531 , 272 , 848 , 10),
(532 , 272 , 850 , 10),
(533 , 272 , 853 , 3),
(534 , 273 , 851 , 8),
(535 , 273 , 852 , 8),
(536 , 273 , 855 , 5),
(537 , 273 , 857 , 10),
(538 , 274 , 845 , 1),
(539 , 274 , 849 , 1),
(540 , 274 , 847 , 1);
