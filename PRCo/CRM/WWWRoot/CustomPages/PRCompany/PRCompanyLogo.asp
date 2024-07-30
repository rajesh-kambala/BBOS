<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2011

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Blue Book Services, Inc.is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/

    if (eWare.Mode < Edit)
    {
        eWare.Mode = Edit;
    }

    var recCompany = eWare.FindRecord("Company","comp_CompanyId=" + comp_companyid);

    if (eWare.Mode == Save) {
        var logo = getFormValue("logocompanyid");
        if ((logo == "") || (logo == null)) {
            recCompany.comp_PRLogo = "";
        } else {
            recCompany.comp_PRLogo = logo + "\\" + logo + ".jpg";
        }
        
        recCompany.comp_PRLogoChangedBy = user_userid;
        recCompany.comp_PRLogoChangedDate = getDBDateTime();
        
        recCompany.SaveChanges();
        Response.Redirect(eWare.Url("PRCompany/PRCompanySummary.asp"));
    
    } else {
 
        blkMain = eWare.GetBlock("PRLogoSpotlight");
        blkMain.Title = "Logo";
        
        // Normally the publish logo flag is controlled by a service that ensures
        // the company has a LOGO service code and a file exists on disk.  This is 
        // not true, however, for local source companies.
        if (recCompany.comp_PRLocalSource != "Y") {
            blkMain.GetEntry("comp_PRPublishLogo").ReadOnly = true;
        }
    
        
        if (recCompany.comp_PRPublishLogo == "Y") {
            blkMain.GetEntry("comp_PRPublishLogo").DefaultValue = true;
        }
         
        blkMain.GetEntry("comp_PRLogoChangedDate").DefaultValue = recCompany.comp_PRLogoChangedDate;         
        blkMain.GetEntry("comp_PRLogoChangedBy").DefaultValue = recCompany.comp_PRLogoChangedBy;         
      
	    // Add a search select field for AssociatedID (based on the company record)
        var entryLogo = eWare.GetBlock("Entry");
        entryLogo.EntryType = 56;
        entryLogo.LookUpFamily = "Company";
        entryLogo.DefaultType = 1;
        entryLogo.Size = 50;
        entryLogo.FieldName = "logoCompanyID";
        entryLogo.Caption = "Logo BBID";
        entryLogo.CaptionPos = entryLogo.CapTop;
        entryLogo.NewLine = true;
        entryLogo.Required = false;

        var setLogoJS = "";
        var logoBBID = "0";
        
        blkMain.GetEntry("comp_PRLogo").ReadOnly = true;        
        if (recCompany.comp_PRLogo != null) {
            blkMain.GetEntry("comp_PRLogo").DefaultValue = recCompany.comp_PRLogo;
            
            logoBBID = recCompany.comp_PRLogo.substr(0, (recCompany.comp_PRLogo.indexOf("\\")));
            entryLogo.DefaultValue = logoBBID;
            //setLogoJS = "document.getElementById('logoCompanyIDTEXT').value='%" + logoBBID + "%'; NavUrllogoCompanyID();";
        }


        blkMain.AddBlock(entryLogo);    
        blkContainer.AddBlock(blkMain);

        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", eWare.Url("PRCompany/PRCompanySummary.asp")));
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
        eWare.AddContent(blkContainer.Execute("comp_CompanyId=" + comp_companyid));

        Response.Write("<script type=\"text/javascript\" src=\"PRCompanyLogo.js\"></script>");
        Response.Write(eWare.GetPage('Company'));
        Response.Write("<script type=\"text/javascript\">var saveLogoCompanyID='" + logoBBID + "';" + setLogoJS + "</script>");
    }
%>
<!-- #include file="CompanyFooters.asp" -->