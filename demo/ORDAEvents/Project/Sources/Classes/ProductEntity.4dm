
// ============================================
// CLASS 2: ProductEntity
// File: Project/Sources/Classes/ProductEntity.4dm
// ============================================

Class extends Entity

// Constructor: Initialization when creating new product
Function constructor()
	// Event: When Stock is modified
Function event touched Stock($event : Object)
	// 1. Prevent negative stock
	// 2. Check minimum stock level
	If (This:C1470.Stock<=This:C1470.minimumStock)
		var $message : Text
		If (This:C1470.Stock=0)
			// Out of stock - Critical
			$message:=Localized string("Stock_OutOfStock")+Char(Carriage return)+Char(Carriage return)
			$message:=$message+Replace string(Localized string("Stock_Product"); "{name}"; This:C1470.Name)+Char(Carriage return)
			$message:=$message+Localized string("Stock_Zero")
			BEEP:C151
		Else 
			// Low stock - Warning
			$message:=Localized string("Stock_Low")+"  "
			$message:=$message+Replace string(Localized string("Stock_Product"); "{name}"; This:C1470.Name)+"  "
			$message:=$message+Replace string(Localized string("Stock_Current"); "{n}"; String:C10(This:C1470.Stock))+"  "
			$message:=$message+Replace string(Localized string("Stock_Minimum"); "{n}"; String:C10(This:C1470.minimumStock))
		End if 
		// Display alert (or create entry in Alerts table)
		ALERT:C41($message)
	End if 
	
Function event validateSave($event : Object)->$result : Object
	
	If (This:C1470.Stock<0)
		$result:={errCode: 1002; MESSAGE: Localized string("Stock_Negative"); extraDescription: {info: Localized string("Stock_Negative")}; seriousError: True:C214}
		return $result
	End if 
	