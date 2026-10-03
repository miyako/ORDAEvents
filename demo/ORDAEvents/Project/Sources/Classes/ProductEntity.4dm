
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
			$message:="🔴 OUT OF STOCK!\\r\\r"
			$message:=$message+"Product: "+This:C1470.Name+"\\r"
			$message:=$message+"Stock: 0"
			BEEP:C151
		Else 
			// Low stock - Warning
			$message:="⚠️ LOW STOCK  "
			$message:=$message+"Product: "+This:C1470.Name+"  "
			$message:=$message+"Current stock: "+String:C10(This:C1470.Stock)+"  "
			$message:=$message+"Minimum stock: "+String:C10(This:C1470.minimumStock)
		End if 
		// Display alert (or create entry in Alerts table)
		ALERT:C41($message)
	End if 
	
Function event validateSave($event : Object)->$result : Object
	
	If (This:C1470.Stock<0)
		$result:={errCode: 1002; MESSAGE: "THe stock can not be negative"; extraDescription: {info: "The stock can not be negative"}; seriousError: True:C214}
		return $result
	End if 
	