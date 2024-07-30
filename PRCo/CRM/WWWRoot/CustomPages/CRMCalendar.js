function calendar_onclick(ctrl, popupwindow)
{
	var dtNow = new Date();
	if(event){
		event.returnValue=false;
	}
	var s = ctrl.value;	
	var q = s.split('/');
	var vMonth=q[0];
	var vDay=q[1];
	var vYear=q[2];
	if (vYear < 100)
	{
		if (vYear < 10)
		{
			if (vYear.charAt(0) != '0') 
				vYear = '0' + vYear;
		}
		var dtDate = new Date();
		var sYear = new String(dtDate.getFullYear());
		sYear = sYear.slice(0, 2);
		vYear = sYear + vYear;
	}
	var testdate= new Date(vYear,vMonth,vDay,12,12);
	if (isNaN(testdate.getTime()))
	{
		var vDay = new String(dtNow.getDate());
		var vMonth = new String(dtNow.getMonth()+1);
		var vYear = new String(dtNow.getFullYear());
	}
	document.EntryForm.yearEntry.value = parseInt(vYear);
	if (vMonth.charAt(0) == '0') 
		vMonth = vMonth.charAt(1);
	document.EntryForm.monthEntry.value = parseInt(vMonth);
	
	if (vDay.charAt(0) == '0') 
		vDay = vDay.charAt(1);
	document.EntryForm.dayEntry.value = parseInt(vDay);
	DropDown_Date(ctrl, popupwindow);
	return;
}

function DropDown_Date(ctrl, popupwin)
{
	if(parent&&parent.frames['EWARE_MENU'])
		fn=parent;
	else 
		fn=opener.parent;
	popupwin.document.body.innerHTML = fn.frames[3].DrawCalForField(ctrl.id,document.EntryForm);
	popupwin.show(01,20, 205, 150, ctrl);
}