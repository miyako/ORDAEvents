Case of 
	: (Form event code:C388=On Load:K2:1)
		ProductsSelectedFinal:=New collection:C1472
		var sumProduct : Integer
		sumProduct:=0
		If (Form:C1466.currentItem=Null:C1517)
			Form:C1466.currentItem:=New object:C1471
		End if 
		Form:C1466.client:=New object:C1471()
		Form:C1466.client.values:=ds:C1482.Client.all().toCollection("Name").extract("Name")
		Form:C1466.client.index:=-1
		Form:C1466.client.currentValue:="Select client"
		
		
		Form:C1466.Mode_Paiement:=New object:C1471()
		Form:C1466.Mode_Paiement.values:=New collection:C1472("PayPal"; "credit card"; "tranfer bank")
		Form:C1466.Mode_Paiement.currentValue:="Select method"
		Form:C1466.Mode_Paiement.index:=-1
		
		Form:C1466.Statut:=New object:C1471()
		Form:C1466.Statut.values:=New collection:C1472("In progress"; "Validate"; "Delivered")
		Form:C1466.Statut.currentValue:="Select Status"
		Form:C1466.Statut.index:=-1
		
		
End case 