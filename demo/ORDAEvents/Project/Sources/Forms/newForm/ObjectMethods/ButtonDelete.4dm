Case of 
	: (Form event code:C388=On Clicked:K2:4)
		
		If (selectedOrder=Null:C1517)
			ALERT:C41("Please select one order")
		End if 
		selectedOrder.drop()
		Form:C1466.currentSelection:=ds:C1482.Order.all()
End case 