function validate()
{
	var today = document.forms["submission"]["today"].value;
	
	if(today == "")
	{
		window.alert('Surely you feel something!');
		return false;
	}
	return true;
}
	