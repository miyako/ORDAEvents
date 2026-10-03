Case of 
	: (Form event code:C388=On Data Change:K2:15)
		var $column; $row : Integer
		LISTBOX GET CELL POSITION:C971(*; "ListBoxProduct"; $column; $row)
		ProductsSelectedFinal[$row-1].Total:=ProductsSelectedFinal[$row-1].Price*ProductsSelectedFinal[$row-1].valueQTY
		REDRAW:C174(ProductsSelectedFinal)
End case 