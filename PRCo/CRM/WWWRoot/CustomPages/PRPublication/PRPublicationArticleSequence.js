/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2007

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/

/********************************************
  Filename: PRPublicationArticleSequence.asp
  Author:           Tad M. Eness
*********************************************/

function RefreshArticleList(url)
{
	// Get the current item from the edition dropdown.
	var edition = '';
	var pe = 'prpbar_PublicationEditionID';
	url = removeKey(url, pe);
	var prbed_edition = document.getElementById('_prbed_edition');
	if (prbed_edition && prbed_edition.selectedIndex > -1) {
		edition = '&' + pe + '=' + prbed_edition[prbed_edition.selectedIndex].value;
	}
	var href = window.location.protocol + '//' + window.location.host + url + edition;
	window.location.href = href;
}
