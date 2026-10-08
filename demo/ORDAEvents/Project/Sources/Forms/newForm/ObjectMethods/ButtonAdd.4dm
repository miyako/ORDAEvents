Case of 
	: (Form event code:C388=On Clicked:K2:4)
		Form:C1466.subForm.currentItem:=ds:C1482.Order.new()
		OBJECT SET VISIBLE:C603(*; "panelSubform"; True:C214)
		OBJECT SET SUBFORM:C1138(*; "panelSubform"; "panel_Order1")
		OBJECT SET ENABLED:C1123(*; "ButtonAdd"; False:C215)
		OBJECT SET ENABLED:C1123(*; "ButtonDelete"; False:C215)
		OBJECT SET VISIBLE:C603(*; "ButtonSave"; True:C214)
		OBJECT SET VISIBLE:C603(*; "ButtonCancel"; True:C214)
		Status:=New object:C1471
		
End case 