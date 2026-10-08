//%attributes = {}
#DECLARE()->$color : Integer

Case of 
	: (This:C1470.Statut="Validate")
		$color:=0x0072D689
	: (This:C1470.Statut="In progress")
		$color:=0x00F7F18B
	: (This:C1470.Statut="Delivered")
		$color:=0x00BDB3B3
End case 