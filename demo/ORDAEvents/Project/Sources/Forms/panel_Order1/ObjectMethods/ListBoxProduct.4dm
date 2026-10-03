Case of 
	: (Form event code:C388=On Data Change:K2:15)
		var $test : Object
		$test:=ProductsSelected
		LISTBOX SELECT ROWS:C1715(*; "listbox1"; $test; lk replace selection:K53:1)
End case 