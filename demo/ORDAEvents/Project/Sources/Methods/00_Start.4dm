//%attributes = {}
#DECLARE($option : Integer)
var $pr : Integer
var $ref : Integer

Case of 
	: (Count parameters:C259=0)
		$pr:=New process:C317(Current method name:C684; 0; "interface"; 1; *)
		BRING TO FRONT:C326($pr)
		
	: ($option=1)
		$ref:=Open form window:C675("newForm"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
		DIALOG:C40("newForm")
		CLOSE WINDOW:C154($ref)
		
End case 