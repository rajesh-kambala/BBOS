<%
    ///***********************************************************************
    // ***********************************************************************
    //  Copyright Produce Report Company 2019-2023
    //
    //  The use, disclosure, reproduction, modification, transfer, or  
    //  transmittal of  this work for any purpose in any form or by any 
    //  means without the written permission of Produce Report Company is 
    //  strictly prohibited.
    // 
    //  Confidential, Unpublished Property of Produce Report Company.
    //  Use and distribution limited solely to authorized personnel.
    // 
    //  All Rights Reserved.
    // 
    //  Notice:  This file was created by Travant Solutions, Inc.  Contact
    //  by e-mail at info@travant.com.
    // 
    // 
    //***********************************************************************
    //***********************************************************************/
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");

    var FILETYPECODE_PRINT_IMAGE = "PI";
    var FILETYPECODE_DIGITAL_IMAGE = "DI";
    var FILETYPECODE_DIGITAL_IMAGE_MOBILE = "DIM";
    var FILETYPECODE_VIDEO = "V";

    var FILETYPECODE_DIGITAL_IMAGE_EMAIL = "DIE";
    var FILETYPECODE_DIGITAL_IMAGE_PDF = "DIPDF";


    function DeleteAdCampaign(AdCampaignID) {
        //Perform a physical delete of the record
        sql = "SELECT pradc_AdCampaignHeaderID FROM PRAdCampaign WHERE pradc_AdCampaignID = " + AdCampaignID;
        qrySelectHeaderID = eWare.CreateQueryObj(sql);
        qrySelectHeaderID.SelectSQL();
        AdCampaignHeaderID = qrySelectHeaderID("pradc_AdCampaignHeaderID");
            
        sql = "EXEC usp_DeleteAdCampaign " + AdCampaignID + ", 1";
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();

        UpdateAdCampaignHeaderCost(AdCampaignHeaderID);
    }

    function UpdateAdCampaignHeaderCost(AdCampaignHeaderID) {
        //Update the total cost on the AdCampaignHeader record
        sql = "UPDATE PRAdCampaignHeader SET pradch_Cost = (SELECT SUM(pradc_Cost) FROM PRAdCampaign WHERE pradc_AdCampaignHeaderID="+AdCampaignHeaderID+"), pradch_Discount = (SELECT SUM(pradc_Discount) FROM PRAdCampaign WHERE pradc_AdCampaignHeaderID="+AdCampaignHeaderID+") WHERE pradch_AdCampaignHeaderID = "+AdCampaignHeaderID;
        qryUpdate = eWare.CreateQueryObj(sql);
        qryUpdate.ExecSql();
    }

    function ProcessAdImage(pracf_FileTypeCode, pracf_FileName, pracf_FileName_disk) {
        ProcessAdImage2(pracf_FileTypeCode, pracf_FileName, pracf_FileName_disk, "");
    }

    function ProcessAdImage2(pracf_FileTypeCode, pracf_FileName, pracf_FileName_disk, controlIndex) {
        var filename = pracf_FileName;
        if ((pracf_FileTypeCode == FILETYPECODE_DIGITAL_IMAGE) ||
            (pracf_FileTypeCode == FILETYPECODE_DIGITAL_IMAGE_MOBILE) ||
            (pracf_FileTypeCode == FILETYPECODE_DIGITAL_IMAGE_EMAIL) ||
            (pracf_FileTypeCode == FILETYPECODE_DIGITAL_IMAGE_PDF))
        {
            filename = pracf_FileName_disk;
        }
        
        if (filename.length > 0 && filename != 'undefined')
        {
            var sImgUrl = "";
            var sImgLbl = "";

            if ((pracf_FileTypeCode == FILETYPECODE_DIGITAL_IMAGE) ||
                (pracf_FileTypeCode == FILETYPECODE_DIGITAL_IMAGE_MOBILE) ||
                (pracf_FileTypeCode == FILETYPECODE_DIGITAL_IMAGE_EMAIL) ||
                (pracf_FileTypeCode == FILETYPECODE_DIGITAL_IMAGE_PDF))
            {
                var bbos_url = "";
                // get the bbos url path from custom captions
                qry = eWare.CreateQueryObj("Select Capt_US From Custom_Captions Where Capt_FamilyType = 'Choices' And Capt_Family = 'BBOS' And Capt_Code = 'URL'");
                qry.SelectSQL();
                bbos_url = qry("Capt_US");

                sImgURL = bbos_url + (bbos_url.search("/$") >= 0 ? "" : "/") + "Campaigns/" + Server.URLEncode(filename).replace(/\+/g,"%20");
                if(pracf_FileTypeCode == FILETYPECODE_DIGITAL_IMAGE) {sImgLbl = "Desktop";}
                else if(pracf_FileTypeCode == FILETYPECODE_DIGITAL_IMAGE_MOBILE) {sImgLbl = "Mobile";}
                else if(pracf_FileTypeCode == FILETYPECODE_DIGITAL_IMAGE_EMAIL) {sImgLbl = "Email";}
                else if(pracf_FileTypeCode == FILETYPECODE_DIGITAL_IMAGE_PDF) {sImgLbl = "PDF";}

    
			    // We'll need to get this from the bbos site (which is where we stored it).
                // Set max-width in case it's too big for page
                blkContent.Contents += "<table><tr><td id='tdAdImage" + controlIndex + "' rowspan=20 style='vertical-align:top'><span class='VIEWBOXCAPTION'>" + sImgLbl + ":</span><br><br><img id='img_AdImage" + controlIndex + "' src = '" + sImgURL + "' style='height:auto;max-width:500px;' /></td></tr></table>";
            }
            else
            {
                sImgURL = "/BBSUtils/GetLibraryDoc.aspx?File=" + Server.URLEncode(filename).replace(/\+/g,"%20");

			    // We'll need to get this from the bbos site (which is where we stored it).
                // Set max-width in case it's too big for page
                blkContent.Contents += "<table><tr><td id=tdAdImage2 rowspan=20 style='vertical-align:top'><img id='img_AdImage2' src = '" + sImgURL + "' style='height:auto;max-width:500px;' /></td></tr></table>";
            }
        }
    }

    function BillingDate_BP(recPRAdCampaign)
    {
        var bpe = recPRAdCampaign.pradc_blueprintsedition;
        var year = bpe.substr(0,4);
        var month = bpe.substr(4,2);

        //Blueprints:  Invoice on the 10th of the month of the blueprint edition month and year
        return month + "/10/" + year;
    }
    
    function BillingDate_TT(recPRAdCampaign)
    {
        //rules are that the year on the billing date would be the year prior to the edition noted (ex: 2021 Edition would go on 11/10/2019)
        var bpe = recPRAdCampaign.pradc_ttedition;
        var year = bpe.substr(0,4);

        //TT: 11/10 of the year prior to the edition date
        return "11/10/" + (Number(year) - 1);
    }

    function BillingDate_KYC(recPRAdCampaign)
    {
        if(recPRAdCampaign.pradc_Premium=="Y")
        {
            //rules are that the year on the billing date would be the year prior to the edition noted (ex: 2021 Edition would go on 11/10/2019)
            var bpe = recPRAdCampaign.pradc_kycedition;
            var year = bpe.substr(0,4);

            //KYC premium ads: 11/10 of the year prior to the edition date
            return "11/10/" + (Number(year) - 1);
        }
        else
        {
            // Send invoice two days after the digital ad start date and both the print and digital ads are approved by customer.
            return BillingDate_2DaysAfterDigitalAdStart(recPRAdCampaign);
        }

        return null;
    }

    function BillingDate_Digital(recPRAdCampaign)
    {
        // Send invoice two days after the digital ad start date and ad is approved by customer.
        return BillingDate_2DaysAfterDigitalAdStart(recPRAdCampaign);
    }

    function BillingDate_Next10thOfMonth()
    {
	    var dtToday = new Date();
	    var dtMonth = dtToday.getMonth() + 1; //0-based
        var dtDay = dtToday.getDate();
        var dtYear = dtToday.getFullYear();

        if(dtDay <= 10)
	        dtDay = 10;
        else
        {
            //Next months 10th
            dtDay=10;
            dtMonth = dtMonth + 1;
            if(dtMonth > 12)
            {
                dtMonth = 1;
                dtYear = dtYear + 1;
            }
        }

	    return dtMonth + "/" + dtDay + "/" + dtYear;
    }

 function BillingDate_NextNov10()
    {
        // Invoice Premium ads on the 10th of November after the print KYC Guide is mailed. 
        var newDate = new Date();

	    var dtMonth = newDate.getMonth() + 1; //0-based
        var dtDay = newDate.getDate();
	    var dtYear = newDate.getFullYear();

        if(dtMonth < 11)
        {
            //Current Year Nov 10
            dtMonth = 11;
            dtDay = 10;
        }
        else if(dtMonth == 11)
        {
            if(dtDay <= 10)
            {  
                //Current Year Nov 10
                dtMonth = 11;
                dtDay = 10;
            }
            else
            {
                //Next year Nov 10
                dtMonth = 11;
                dtDay = 10;
                dtYear = dtYear + 1;
            }
        }
        else
        {
            //Next year Nov 10
            dtMonth = 11;
            dtDay = 10;
            dtYear = dtYear + 1;
        }

	    return dtMonth + "/" + dtDay + "/" + dtYear;
    }

    function BillingDate_2DaysAfterDigitalAdStart(recPRAdCampaign)
    {
        // Send invoice two days after the digital ad start date
        if(recPRAdCampaign.ItemAsString("pradc_StartDate") != "")
        {
            var newDate = new Date(recPRAdCampaign.pradc_StartDate);
            newDate.setDate(newDate.getDate() + 2); //add 2 days

	        var dtMonth = newDate.getMonth() + 1; //0-based
            var dtDay = newDate.getDate();
	        var dtYear = newDate.getFullYear();

	        return dtMonth + "/" + dtDay + "/" + dtYear;
        }

        return null;
    }

    function InsertAdCampaignTermsRecord(AdCampaignID, AdCampaignHeaderID, recPRAdCampaign, billingDate)
    {
        var qry = eWare.CreateQueryObj("SELECT dbo.ufn_AdCampaignTermsInvoiceDescription(" + AdCampaignID + ") InvoiceDescription");
        qry.SelectSQL();
        var InvoiceDescription = qry("InvoiceDescription");

        recPRAdCampaignTerms = eWare.CreateRecord("PRAdCampaignTerms");
        recPRAdCampaignTerms.pract_AdCampaignID = AdCampaignID;
        recPRAdCampaignTerms.pract_BlueprintsEdition = recPRAdCampaign("pradc_BluePrintsEdition");
        recPRAdCampaignTerms.pract_TermsAmount = recPRAdCampaign("pradc_Cost");
        
        if(billingDate != null)
            recPRAdCampaignTerms.pract_BillingDate = billingDate;

        recPRAdCampaignTerms.pract_InvoiceDescription = InvoiceDescription;
        recPRAdCampaignTerms.pract_TermsAmount_CID = 1;
        recPRAdCampaignTerms.SaveChanges();

        UpdateAdCampaignHeaderCost(AdCampaignHeaderID);
    }

    function GetHiddenFileBlock(recordSet, sequence) {
        var fileValue = "";
        if ((recordSet != null) && (!recordSet.eof))
            fileValue = recordSet.pracf_FileName;

         return "<input id='_HIDDENpracf_filename" + sequence + "' name='_HIDDENpracf_filename" + sequence + "' type='hidden' value='" + fileValue + "'/>"; 
    }

    function InsertImageFile(CompanyID, AdCampaignID, AdCampaignHeaderID, recPRAdCampaign, fileTypeCode, RootDir, sequence) {
    
        var formValue = getFormValue("_HIDDENpracf_filename" + sequence);
        if(formValue == "" || formValue == "undefined" )
            return;
    
        var recPRAdCampaignFile = eWare.FindRecord("PRAdCampaignFile", "pracf_AdCampaignID=" + AdCampaignID + " AND pracf_FileTypeCode='" + fileTypeCode + "'");
        var szFileName = RootDir+"\\"+formValue;

        if(existsFile(szFileName) == true)
        {
            if(recPRAdCampaignFile.eof)
            {
                //Not found - create record
                recPRAdCampaignFile = eWare.CreateRecord("PRAdCampaignFile");
                recPRAdCampaignFile.pracf_AdCampaignID = AdCampaignID;
                recPRAdCampaignFile.pracf_FileTypeCode = fileTypeCode;
                recPRAdCampaignFile.pracf_Sequence = sequence;
                recPRAdCampaignFile.pracf_Language = "E";
            }

            var fileNameModifier = "";
            if (fileTypeCode != FILETYPECODE_DIGITAL_IMAGE)
                fileNameModifier = "_" + fileTypeCode + "_";

            recPRAdCampaignFile.pracf_filename_disk = getDiskFilename2(CompanyID, AdCampaignID, formValue, fileNameModifier);
            recPRAdCampaignFile.pracf_filename = formValue; 
            recPRAdCampaignFile.SaveChanges();

            //Copy image file to new disk name.  This is a random name to default the ad blockers.
            file1=szFileName;
            file2=RootDir+"\\"+recPRAdCampaignFile.pracf_filename_disk;
            copyFile(file1, file2);

            deleteFile(file1);
        }
    }

    function DeleteImageFile(AdCampaignID, checkboxControl, fileTypeCode) {
        //Delete mobile file if checkbox is checked
        if (getFormValue(checkboxControl) != "undefined") 
        {
            recPRAdCampaignFileMobile = eWare.FindRecord("PRAdCampaignFile", "pracf_AdCampaignID=" + AdCampaignID + " AND pracf_FileTypeCode='" + fileTypeCode + "'");
            file2_mobile=RootDir+"\\"+recPRAdCampaignFileMobile.pracf_filename_disk;
            deleteFile(file2_mobile);
            var sql = "DELETE FROM PRAdCampaignFile WHERE pracf_AdCampaignID = " + AdCampaignID + " AND pracf_FileTypeCode='" + fileTypeCode +"'";
            var qryDelete = eWare.CreateQueryObj(sql);
            qryDelete.ExecSql();
        }
    }
%>