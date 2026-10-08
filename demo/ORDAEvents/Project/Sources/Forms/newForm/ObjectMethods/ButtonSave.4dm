Case of 
	: (Form event code:C388=On Clicked:K2:4)
		var $idClient : Integer
		var $client : Object
		var $test : Object
		
		$client:=ds:C1482.Client.query("Name = :1"; Form:C1466.subForm.client.currentValue).first()
		
		If ($client#Null:C1517)
			$idClient:=$client.ID
			Form:C1466.subForm.currentItem.ID_Client:=$idClient
			If (Form:C1466.subForm.Statut.index#-1)
				Form:C1466.subForm.currentItem.Statut:=Form:C1466.subForm.Statut.codes[Form:C1466.subForm.Statut.index]
			End if 
			If (Form:C1466.subForm.Mode_Paiement.index#-1)
				Form:C1466.subForm.currentItem.Mode_Paiement:=Form:C1466.subForm.Mode_Paiement.codes[Form:C1466.subForm.Mode_Paiement.index]
			End if 
			
			Try
				var $product : Object
				var $status : Object
				var $Message : Text
				For each ($product; ProductsSelectedFinal)
					var $orderLine : cs:C1710.OrderLineEntity
					$orderLine:=ds:C1482.OrderLine.new()
					$orderLine.Quantity:=$product.valueQTY
					$orderLine.ID_Product:=$product.ID
					$orderLine.ID_Order:=Form:C1466.subForm.currentItem.ID
					$status:=$orderLine.save()
				End for each 
				
				$status:=Form:C1466.subForm.currentItem.save()
				$test:=ProductsSelected
				LISTBOX SELECT ROWS:C1715(*; "listbox1"; $test; lk replace selection:K53:1)
				Form:C1466.currentSelection:=ds:C1482.Order.all()
				Status:=$status
				
				OBJECT SET VISIBLE:C603(*; "panelSubform"; False:C215)
				OBJECT SET ENABLED:C1123(*; "ButtonAdd"; True:C214)
				OBJECT SET ENABLED:C1123(*; "ButtonDelete"; True:C214)
				OBJECT SET VISIBLE:C603(*; "ButtonSave"; False:C215)
			Catch
				$Message:=Replace string(Replace string(Localized string("AlertSaveError"); "{message}"; $status.errors[0].message); "{info}"; $status.errors[0].extraDescription.info)
				ALERT:C41($Message)
				$test:=ProductsSelected
				If ($test#Null:C1517)
					LISTBOX SELECT ROWS:C1715(*; "listbox1"; $test; lk replace selection:K53:1)
				End if 
				Status:=$status.errors[0]
			End try
			
		Else 
			ALERT:C41(Localized string("AlertEnterClient"))
		End if 
		
		
		
End case 