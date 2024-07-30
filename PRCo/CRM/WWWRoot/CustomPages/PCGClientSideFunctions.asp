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


<script languange="Javascript">
	function NewWindow(mypage, myname, w, h, scroll, resizable) {
		var winl = (screen.width - w) / 2;
		var wint = (screen.height - h) / 2;
		winprops = 'height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable='+resizable
		win = window.open(mypage, myname, winprops)
		if ((!win||(window.win&&win.closed))==false) {
			if (parseInt(navigator.appVersion) >= 4) { win.window.focus(); }
		}
	}

	function openChild(sPage) {
	   NewWindow(sPage,"child","800","570","Yes","Yes");
	}
</script>
