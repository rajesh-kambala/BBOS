<!-- #include file ="../accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006

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
%>

<!-- #include file ="PersonHeaders.asp" -->

<%
    var sSecurityGroups = "1,2,3,4,5,6,7,10";
	var sAbbrEntityName = "PersonRelationship";
	var sEntityPrefix = "prpr";
    var sEntityPersonIdName = "prpr_LeftPersonId";
    var sNewEntryBlockTitle = "Person Relationship";
    tabContext = "&T=Person&Capt=Relationships"
  
%>

<!-- #include file ="PersonSummaryPageInclude.asp" -->