<script for=window event=onload> 
if (document.EntryForm) { 
	for (var i = 0; i < document.all.length; i++) { 
		document.all[i].onkeydown = DoKeyPress; 
	} 
} 

function DoKeyPress() { 
	var i = event.keyCode; 
	if (i == 13) { 
		document.EntryForm.submit(); 
	} 
	
	event.cancelBubble=true; 
} 
</script>
