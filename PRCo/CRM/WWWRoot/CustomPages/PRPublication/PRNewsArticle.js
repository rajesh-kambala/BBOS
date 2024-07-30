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
/* **************************************************************************************
 *  function: save
 *  Description: performs the validate and save 
 *
 ***************************************************************************************/
function openBBOS(BBOS_Url)
{
    window.open(BBOS_Url);
}

function previewArticle(sArticleURL)
{
    window.open(sArticleURL);
    return;
}

function confirmDelete()
{
    return confirm("Are you sure you want to delete this news article?");
}

function NewsArticleFormUpdates()
{
    // Modify the abstract caption for new wording.
    AppendRow("_Captprpbar_abstract", "IndustryCode", true);
    AppendRow("_Captprpbar_abstract", "LinkMsg", true);
}

function save() {

    if (validate()) {
        document.EntryForm.submit();
    }

}

function validate() {

    if ((!document.getElementById('cbBBOS').checked) &&
        (!document.getElementById('cbBBOSLumber').checked)) {
        alert("The 'Display in BBOS', 'Display in BBOS Lumber' or both must be checked in order to save this news article.");
        return false;
    }

    return true;
}

function toggleRSS() {
    if (document.getElementById('cbBBOS').checked) {
        document.getElementById('_IDprpbar_rss').disabled = false;
    } else {
        if (document.getElementById('cbBBOSLumber').checked) {
            document.getElementById('_IDprpbar_rss').disabled = true;
        }            
    }
}