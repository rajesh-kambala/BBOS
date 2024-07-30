<!-- #include file ="accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2010-2013

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>
<!-- #include file ="PRCoGeneral.asp" -->
<%
    doPage();
    
function doPage() {

    var queryString = new String(Request.QueryString);        

    var originalURL = "/" + sInstallName + "/eware.dll/Do?Act=183&" + queryString
    Response.Write("<p><a href=" + originalURL + ">" + originalURL + "</a>");

    
    Response.Write("<p>" + queryString + "</p>");

    var key0 = new String(Request.QueryString("Key0"));
    var key58 = new String(Request.QueryString("Key58"));
    Response.Write("<p>key58:" + key58 + "</p>");

    var bFound = false;
    var keyValue = null;
    
    if (!isEmpty(key58)) {
        
        for(i=1; i<=10; i++) {
        
            if ((i != 4) &&
                (i != 5)) {
        
                keyValue = new String(Request.QueryString("Key" + i.toString()));
                Response.Write("Key" + i.toString() + ":" + keyValue + "<br/>");

                if (key58.toString() == keyValue.toString()) {
                    bFound = true;
                    queryString = changeKey(queryString, "Key0", i.toString());
                    queryString = removeKey(queryString, "Key58");
                    break;
                }
            }                
        }
    
        if (!bFound) {
            // Look for an Opportunity ID.  If we find it, reset the key
            // parameters to 7.
            value = new String(Request.QueryString("oppo_opportunityId"));
            if (!isEmpty(value)) {
                bFound = true;
                queryString = changeKey(queryString, "Key0", "7");
                queryString = changeKey(queryString, "Key7", value);
                queryString = removeKey(queryString, "Key58");
            }
        }
     
        if (!bFound) {
            // If Key0 is not pointing to Key58 anyway,
            // then just remove Key58
            if (key0 != "58") {
                queryString = removeKey(queryString, "Key58");
                bFound =true;
            }
        }

        if (!bFound) {
            value = new String(Request.QueryString("Comp_CompanyId"));
            if (!isEmpty(value)) {
                bFound = true;
                queryString = changeKey(queryString, "Key0", "1");
                queryString = changeKey(queryString, "Key1", value);
                queryString = removeKey(queryString, "Key58");
            }
        }

     
        if (!bFound) {
            // If we made it here, then something ain't right...
            Response.Write("<p>Exception!<br/>Found Key58, but unable to find Key58's value in any other key parameter value");
            return;
        }
    }

    // Keys 4 & 5 are My CRM and Team CRM contexts.  This gets trickey because it seems if Key0= either of these
    // eWare.dll gets confused and just redirects the user to the Calendar.  So, if we find these keys we'll look
    // for other entity keys and if we find one, we will point Key 0 to that entity key.  The context in the TopContent
    // frame changes, but it is better than nothing.
    if ((key0 == "4") ||
        (key0 == "5")) {
    
        keyValue = new String(Request.QueryString("Key4"));
        if (isEmpty(keyValue)) {
            keyValue = new String(Request.QueryString("Key5"));
        }
        
        if (!isEmpty(keyValue)) {
            
            key = -1;
            for(i=1; i<=10; i++) {
            
                if ((i != 4) &&
                    (i != 5)) {
                    if (!isEmpty(Request.QueryString("Key" + i.toString())))  {
                        key = i;
                        break;
                    }   
                }
            }

            if (key > 0) {
                bFound = true;
                queryString = changeKey(queryString, "Key0", key);
            }
        }
    } 
    
    queryString = removeKey(queryString, "J");
    queryString = removeKey(queryString, "F");
    queryString = removeKey(queryString, "Comp_CompanyId");
    queryString = removeKey(queryString, "Pers_PersonId");
    
    var redirectURL = "/" + sInstallName + "/eware.dll/Do?Act=183&" + queryString
    //Response.Write("<p><a href=" + redirectURL + ">" + redirectURL + "</a>");
    Response.Redirect(redirectURL);
} 

   

%>