Case of 
	: (Form event code:C388=On Load:K2:1)
		Form:C1466.Products:=ds:C1482.Product.all()
		var ProductsSelectedFinal : Collection
		var ProductsSelected : Object
		OBJECT SET FORMAT(*; "Price"; Localized string("Format_Currency"))
End case 