// MME Compta caracters en una area de texte
// (http://stackoverflow.com/questions/5371089/jquery-count-characters-in-textarea)
 
function charsleft(val)
{ 
	var len = val.value.length;
    if (len >= 140) 
    {
        val.value = val.value.substring(0, 140);
    }
    else 
    {
        $('#charNum').text(140 - len);
    }

}