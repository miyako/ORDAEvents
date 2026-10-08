Class extends Entity

// Constructor: Initialize new order
Function constructor()
	
	// Event: When order_number is modified
Function event touched order_number($event : Object)
	// Convert to UPPERCASE
	This:C1470.order_number:=Uppercase:C13(This:C1470.order_number)
	// Event: When Price is modified
Function event touched Price($event : Object)
	// Prevent negative price
	If (This:C1470.Price<0)
		This:C1470.Price:=0
	End if 
	
	// Event: Validation before save
Function event validateSave($event : Object) : Object
	var $status : Object
	// 1. Generate order number if empty
	If (This:C1470.order_number=Null:C1517) | (This:C1470.order_number="")
		This:C1470.order_number:=This:C1470._generateOrderNumber()
	End if 
	// 2. Default status
	If (This:C1470.Statut=Null:C1517) | (This:C1470.Statut="")
		This:C1470.Statut:="In progress"
	End if 
	// 3. Current date
	If (This:C1470.Date_Order=Null:C1517)
		This:C1470.Date_Order:=Current date:C33
	End if 
	// Check if order is validated/delivered with price = 0
	If ((This:C1470.Statut="Validate") | (This:C1470.Statut="Delivered"))
		If (This:C1470.Price=0)
			var $message : Text
			$message:=Replace string(Localized string("Order_PriceZero"); "{number}"; This:C1470.order_number)
			$status:={errCode: 1002; MESSAGE: $message; extraDescription: {info: $message}; seriousError: True:C214}
		End if 
	End if 
	return $status
	
	
	// Private method: Generate unique order number
Function _generateOrderNumber() : Text
	
	var $count : Integer
	var $orderNumber : Text
	
	// Count existing orders
	$count:=ds:C1482.Order.all().length+1
	
	// Format: CMD-YYYY-XXXX
	$orderNumber:="CMD-"+String:C10(Year of:C25(Current date:C33))+"-"+String:C10($count; "0000")
	
	return $orderNumber
	