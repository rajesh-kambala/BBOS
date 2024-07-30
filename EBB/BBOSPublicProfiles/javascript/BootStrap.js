//***********************************************************************
//***********************************************************************
// Copyright Travant Solutions, Inc. 2019-2019
//
// The use, disclosure, reproduction, modification, transfer, or  
// transmittal of  this work for any purpose in any form or by any 
// means without the written  permission of Travant Solutions is 
// strictly prohibited.
//
// Confidential, Unpublished Property of Travant Solutions, Inc.
// Use and distribution limited solely to authorized personnel.
//
// All Rights Reserved.
//
// Notice:  This file was created by Travant Solutions, Inc.  Contact
// by e-mail at info@travant.com
//
// Filename:		BootStrap.js
// Description:	
//
// Notes:		
//
//***********************************************************************
//***********************************************************************%>

function resizeIFrame() {

    try {
        if (window.parent == null || window.parent.document == null)
            return;
    }
    catch (err) {
        return;
    }

    var iframe = null;
    iframe = window.parent.document.getElementsByTagName("iframe")[0];
    if (iframe != null) {
        var a = document.getElementsByTagName("article")[0];
        var mh = window.parent.document.getElementById("masthead");

        if (a != null) {
            var h = a.scrollHeight;

            if (mh != null) {
                var mhh = mh.scrollHeight;
                h += mh.scrollHeight;
            }

            iframe.height = h;
        }
    }
}