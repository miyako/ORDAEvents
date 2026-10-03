Case of 
	: (Form event code:C388=On Load:K2:1)
		Form:C1466.currentSelection:=ds:C1482.Order.all()
		Form:C1466.subForm:=New object:C1471
		Form:C1466.products:=ds:C1482.Product.all()
		var selectedOrder : Object
		var Status : Object
		Status:=New object:C1471
End case 