Class extends Entity

Function event saving($event : Object) : Object
	
	var $status : Object
	
	If (This:C1470.Quantity>This:C1470.product.Stock)
		var $info : Text
		$info:=Replace string(Localized string("Stock_InsufficientInfo"); "{name}"; This:C1470.product.Name)
		$info:=Replace string($info; "{qty}"; String:C10(This:C1470.Quantity))
		$status:={errCode: 1; message: Localized string("Stock_Insufficient"); \
			extraDescription: {info: $info}; seriousError: False:C215}
		return $status
	End if 
	// Recalculate order total price
	//$status:=New object("success"; True)
	This:C1470._updateOrderPrice()
	return $status
	
	
	
	
	
	// Private method: Update order price
Function _updateOrderPrice()
	
	var $order : cs:C1710.OrderEntity
	
	// Get order via relation
	// $order:=This.ID_Order_Relation  // Use your relation name
	
	// If no automatic relation, do:
	$order:=Form:C1466.subForm.currentItem
	//$order:=ds.Order.get(This.ID_Order)
	
	If ($order#Null:C1517)
		This:C1470._recalculateOrderPrice($order)
	End if 
	
	
	// Private method: Recalculate total price
Function _recalculateOrderPrice($order : cs:C1710.OrderEntity)
	
	var $total : Real
	var $orderLines : cs:C1710.OrderLineSelection
	var $line : cs:C1710.OrderLineEntity
	var $product : cs:C1710.ProductEntity
	
	$total:=This:C1470.Quantity*This:C1470.product.Price
	
	// Get all lines for this order
	$orderLines:=ds:C1482.OrderLine.query("ID_Order = :1"; $order.ID)
	
	// Calculate total
	For each ($line; $orderLines)
		
		// Get product
		$product:=ds:C1482.Product.get($line.ID_Product)
		
		If ($product#Null:C1517)
			$total:=$total+($product.Price*$line.Quantity)
		End if 
		
	End for each 
	
	// Update order price
	$order.Price:=$total
	$product:=ds:C1482.Product.get(This:C1470.ID_Product)
	$product.Stock:=$product.Stock-This:C1470.Quantity
	$product.save()
	$order.save()
	
	