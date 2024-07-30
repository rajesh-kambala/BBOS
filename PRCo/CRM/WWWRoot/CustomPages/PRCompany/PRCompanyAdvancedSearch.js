/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2021

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

function initCompanyAdvancedSearch()
{
	RemoveDropdownItemByName("comp_prtype", "--None--");
	RemoveDropdownItemByName("comp_prlistingstatus", "--None--");

	RemoveDropdownItemByName("legalnameonly", "--None--");
	RemoveDropdownItemByName("legalnameonly", "--All--");

	RemoveDropdownItemByName("SearchNumericOperatorscomp_companyid", "Greater Than");
	RemoveDropdownItemByName("SearchNumericOperatorscomp_companyid", "Less Than");
	RemoveDropdownItemByName("SearchNumericOperatorscomp_companyid", "All");

	document.getElementById("comp_name").focus();
	document.getElementById("comp_name").select();

	//document.all.SearchNumericOperatorscomp_companyid.style.display = 'none';
}