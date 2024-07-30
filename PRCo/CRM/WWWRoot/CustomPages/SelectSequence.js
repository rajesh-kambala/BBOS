// Moves the selected item in the 
// specified control one spot in the
// specified direction.
function MoveItem(bUp, oControl) {

	var iSelectedIndex;
	var iNewIndexOffset;
	var iLength;
	
	var szTextA;
	var szValueA;
	var szTextB;
	var szValueB;
	
	iSelectedIndex = oControl.selectedIndex;
	if (iSelectedIndex == -1) {
		return;
	}
	
	iLength = oControl.length;

	// Check to see if we're at either end of
	// the list.
	if (bUp) {
		iNewIndexOffet = -1;
		if (iSelectedIndex == 0) {
			return;
		}
	} else {
		iNewIndexOffet = 1;
		if (iSelectedIndex == (iLength - 1)) {
			return;
		}
	}
	
	szTextA	= oControl[iSelectedIndex].text;
	szValueA= oControl[iSelectedIndex].value;

	szTextB	= oControl[iSelectedIndex + iNewIndexOffet].text;
	szValueB= oControl[iSelectedIndex + iNewIndexOffet].value;

	oControl[iSelectedIndex].text	= szTextB;
	oControl[iSelectedIndex].value	= szValueB;
	
	oControl[iSelectedIndex + iNewIndexOffet].text	= szTextA;
	oControl[iSelectedIndex + iNewIndexOffet].value	= szValueA;
	
	oControl.selectedIndex = iSelectedIndex + iNewIndexOffet;
}

// Selects all of the items in the
// specified control.
function SelectAllInList(oControl) {
	for (i=0; i<oControl.length; i++) {
	    if (!oControl[i].disabled) {
			oControl[i].selected = true;
		}
	}
}

// Selects the first item in the
// specified control.
function SelectFirstInList(oControl) {
    if (!oControl[0].disabled) {
			oControl[0].selected = true;
	}
}