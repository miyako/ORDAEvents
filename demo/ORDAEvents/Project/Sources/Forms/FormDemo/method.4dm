Case of 
	: (Form event code:C388=On Load:K2:1)
		Form:C1466.products:=ds:C1482.Product.all()
		Form:C1466.orders:=ds:C1482.Order.all()
		Form:C1466.subForm:=New object:C1471
End case 