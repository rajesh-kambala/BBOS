<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2015

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
    lstMain = eWare.GetBlock(sGridName);
    lstMain.prevURL = eWare.URL(f_value);;
    blkContainer.AddBlock(lstMain);

     // sContinueAction defaults to "PRPerson/PRPersonSummary.asp" in PersonHeaders.asp
     // override in the calling routine for a different location 
    blkContainer.AddButton(eWare.Button("Continue","continue.gif", eWare.Url(sContinueAction) + tabContext));
    if (iTrxStatus == TRX_STATUS_EDIT)
    {
        if (isUserInGroup(sSecurityGroups))
            blkContainer.AddButton( eWare.Button(sNewCaption,"New.gif", eWare.URL(sAddNewPage) + tabContext));
    }
    if (!isEmpty(pers_personid)) 
    {
        szWhere = sEntityPersonIdName + "=" + pers_personid;
        
        if (bIncludeInverseRelationship)  {
            szWhere += " OR " +  sInverseEntityPersonIdName + "=" + pers_personid;
        }

        eWare.AddContent(blkContainer.Execute(szWhere));
    }

    Response.Write(eWare.GetPage('Person'));

%>
<!-- #include file ="../RedirectTopContent.asp" -->
