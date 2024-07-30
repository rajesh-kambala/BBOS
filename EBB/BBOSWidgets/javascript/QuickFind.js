//***********************************************************************
//***********************************************************************
// Copyright Blue Book Services, Inc. 2012-2014
//
// The use, disclosure, reproduction, modification, transfer, or  
// transmittal of  this work for any purpose in any form or by any
// means without the written  permission of Blue Book Services, Inc. is 
// strictly prohibited.
//
// Confidential, Unpublished Property of Blue Book Services, Inc.
// Use and distribution limited solely to authorized personnel.
//
// All Rights Reserved.
//
// Notice:  This file was created by Travant Solutions, Inc.  Contact
// by e-mail at info@travant.com
//
// Filename: QuickFind.js
// Description:	
//
// Notes:		
//
//***********************************************************************
//***********************************************************************
function AutoCompleteSelected(source, eventArgs) {

    if (eventArgs.get_value() != null) {
        document.getElementById('txtQuickFind').value = "";
        var url = targetURL + eventArgs.get_value();
        window.open(url, 'BBOS');
    }

    return true;
}


function AutoCompleteSelectedBBSI(source, eventArgs) {

    if (eventArgs.get_value() != null) {
        var url = targetURL + eventArgs.get_value();
        window.parent.parent.window.location = url;
    }

    return true;
}


function acePopulated(sender, e) {

    var target = sender.get_completionList();
    target.className = "AutoCompleteFlyout";

    var children = target.childNodes;
    var searchText = sender.get_element().value;

    for (var i = 0; i < children.length; i++) {
        var child = children[i];
        var arrValue = child.innerHTML.split("|");

        var legalName = "";
        if (arrValue[1] != "") {
            legalName = "(" + arrValue[1] + ")<br/>";
        }

        var NodeText = "";
        NodeText += "<strong>" + arrValue[0] + "</strong> (" + arrValue[2] + ")<br/>" + arrValue[3];

        if (i % 2 == 0) {
            child.className = "AutoCompleteFlyoutItem";
        } else {
            child.className = "AutoCompleteFlyoutShadeItem";
        }

        child.innerHTML = NodeText;

        if (child.childNodes[0].tagName == "STRONG") {
            child.childNodes[0]._value = child._value;
        }
    }
}
