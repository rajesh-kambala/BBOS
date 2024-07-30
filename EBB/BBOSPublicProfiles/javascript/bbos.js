//***********************************************************************
//***********************************************************************
// Copyright Produce Reporter Co. 2007-2018
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
// Filename: bbos.js
// Description:	
//
// Notes:		
//
//***********************************************************************
//***********************************************************************%>

function replaceNonDigits(v) {
    v.value = v.value.replace(/[^0-9]/g, '');
}        