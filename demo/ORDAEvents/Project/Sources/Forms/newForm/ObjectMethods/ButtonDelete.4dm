Case of 
	: (Form event code:C388=On Clicked:K2:4)
		
		If (selectedOrder=Null:C1517)
			ALERT:C41(Localized string("AlertSelectOrder"))
		Else 
			selectedOrder.drop()
		End if 
		Form:C1466.currentSelection:=ds:C1482.Order.all()
End case 