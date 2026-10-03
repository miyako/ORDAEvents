Case of 
	: (Form event code:C388=On Clicked:K2:4)
		ProductsSelectedFinal:=ProductsSelected.toCollection()
		var $item : Object
		For each ($item; ProductsSelectedFinal)
			$item.valueQTY:=1
			$item.Total:=$item.valueQTY*$item.Price
		End for each 
		
End case 