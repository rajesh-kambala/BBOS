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

    
    // Define this value for the RedirectTopContent,asp functionality
    var sTopContentUrl = "PersonTopContent.asp";

    // Define a defult security profile for Person screens; yo ucan override this
    // on any particular screen
    var sDefaultPersonSecurity = "1,2,3,4,5,6,10";
        

    //Establish Context and retrieve records from tables
    var recPerson = '';
    
    var pers_personid = new String(Request.Querystring("pers_personid"));
    
    if (isEmpty(pers_personid))
    {
        pers_personid = new String(Request.Querystring("Key2"));
    }
    if (isEmpty(pers_personid))
    {
        pers_personid = new String(Request.Form.Item("pers_personid"));
    }
    if (isEmpty(pers_personid))
    {
        pers_personid = new String(eWare.GetContextInfo("person","pers_personid"));
    }
    // this is a one-off added for handling peli_personlinkid which can translate
    // indirectly to a person id
    if (isEmpty(pers_personid)){
        peliId = String(Request.Querystring("peli_personlinkid"));
        if (!isEmpty(peliId)){
            // look up the peli record and get the personid
            recPELI = eWare.FindRecord("Person_Link", "peli_PersonLinkId="+peliId);
            if (!recPELI.eof)
                pers_personid = recPELI("peli_PersonId");
            recPELI = null;
        }
    }
    
    
    
    if (isEmpty(pers_personid))
        pers_personid = new String("-1");
    else
    {
        var arr = pers_personid.split(",");
        pers_personid = arr[0].valueOf();
        recPerson = eWare.FindRecord("person","pers_personid=" + pers_personid);
        //sTopContentUrl += "&pers_personid="+pers_personid;
    }
%>