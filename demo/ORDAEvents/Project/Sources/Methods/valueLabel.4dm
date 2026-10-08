//%attributes = {"invisible":true}
// Display label for a stored status or payment value (the stored values stay in English)
#DECLARE($value : Text) : Text

Case of 
	: ($value="In progress")
		return Localized string("Status_InProgress")
	: ($value="Validate")
		return Localized string("Status_Validate")
	: ($value="Delivered")
		return Localized string("Status_Delivered")
	: ($value="PayPal")
		return Localized string("Payment_PayPal")
	: ($value="credit card")
		return Localized string("Payment_CreditCard")
	: ($value="bank transfer")
		return Localized string("Payment_BankTransfer")
	Else 
		return $value
End case 