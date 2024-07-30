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

//bDebug = true;

    var sDisabled_CreditWorth = " DISABLED=true ";
    var sDisabled_Integrity = " DISABLED=true ";
    var sDisabled_Pay = " DISABLED=true ";
    
    if (isUserInGroup("1,2,10") )
    {
        sDisabled_CreditWorth = " ";
        sDisabled_Integrity = " ";
        sDisabled_Pay = " ";
    }
    
    
    if (recCompany.comp_PRType == "B")
    {
        /*  
        *  This Block checks the rating values for the current company and the HQ company.
        *  Values that are not valid are removed (not presented to the user.  In order to 
        *  use this block properly the following values must be set:
        *      recHQRating: An Accpac record for the PRRating record of this company's HQ
        *      recCompany: An Accpac record for the current Company record (usually set by CompanyHeaders.asp)
        *      sInvalidCWR: a comma seperated list of invalid CWR values; may be empty but must be defined
        *
        *  Upon exit the following strings will be set:
        *      sInvalidCWR: a comma seperated string of invalid credit worth rating values to be passed to an
        *                   IN clause of a sql Select statement
        *
        */        
        // check CreditWorthRating of (62)
        if (recHQRating.prin_Name != "XXX" && recHQRating.prin_Name != "XXXX")
        {
            if (sInvalidCWR != "")
                sInvalidCWR = sInvalidCWR + ",";
            sInvalidCWR = sInvalidCWR + "'(62)'";
        } 
        else 
        {
            if (!recLowPayRating.eof)
            {
                if (sInvalidCWR != "")
                    sInvalidCWR = sInvalidCWR + ",";
                sInvalidCWR = sInvalidCWR + "(62)";
            } 
        }
        // check CreditWorthRating of (68)
        if (recHQRating.prpy_Name == "AA" || 
            recHQRating.prpy_Name == "A" ||
            recHQRating.prpy_Name == "AB" ||
            recHQRating.prpy_Name == "B" ||
            recHQRating.prpy_Name == "C" 
           )
        {
            if (sInvalidCWR != "")
                sInvalidCWR = sInvalidCWR + ",";
            sInvalidCWR = sInvalidCWR + "'(68)'";
        } 
        /*  
        *  End the rating values checks.
        */
    }    

    sNewLine = "<TR ID=\"_tr_RatingValues\">";


    // Set up the Credit Worth Dropdown
    sCaption = eWare.GetTrans("ColNames","prra_CreditWorthId");

    sNewLine = sNewLine + "<TD VALIGN=TOP><SPAN CLASS=VIEWBOXCAPTION>"+sCaption+":</SPAN><br><SPAN>" +
            "<INPUT TYPE=HIDDEN NAME=\"_HIDDENprra_creditworthid\" id=\"_HIDDENprra_creditworthid\">" + 
            "<SELECT " + sDisabled_CreditWorth + " CLASS=EDIT SIZE=1 NAME=\"prra_creditworthid\" id=\"prra_creditworthid\">" + 
            "<OPTION VALUE=\"\" SELECTED >--None--</OPTION> ";
    
        sSQL = "SELECT prcw_CreditWorthRatingId, prcw_Name " +
                 "FROM PRCreditWorthRating WITH (NOLOCK) " +
                "WHERE prcw_IndustryType LIKE '%," + recCompany.comp_PRIndustryType + "%' ";

        if (!isEmpty(recCompany("comp_PRCreditWorthCap")))
            sSQL = sSQL + " AND prcw_CreditWorthRatingId <= " + recCompany("comp_PRCreditWorthCap");

        if (Defined(sInvalidCWR) && sInvalidCWR != "")
            sSQL = sSQL + " AND prcw_Name NOT IN (" + sInvalidCWR + ") ";
                
        sSQL = sSQL + "ORDER BY prcw_Order";
        recCWR = eWare.CreateQueryObj(sSQL,"");
        recCWR.SelectSQL();
        while (!recCWR.eof)
        {
            sSelected = "";
            if (Defined(recRating) && !recRating.eof)
            {
                if (recRating.prra_CreditWorthId == recCWR("prcw_CreditWorthRatingId"))
                    sSelected = "SELECTED ";
            }
            sNewLine = sNewLine + "<OPTION " + sSelected + "VALUE=\""+ recCWR("prcw_CreditWorthRatingId") + "\" >" + recCWR("prcw_Name") + "</OPTION> ";

            recCWR.NextRecord();
        }
    sNewLine = sNewLine + "</SELECT></SPAN></TD>";


    if (recCompany.comp_PRIndustryType != "L") {

        // Set up the Integrity dropdown
        sCaption = eWare.GetTrans("ColNames","prra_IntegrityId");
        sSQL = "SELECT prin_IntegrityRatingId, prin_Name " +
                 "FROM PRIntegrityRating WITH (NOLOCK) " +
             "ORDER BY prin_Order";
        recInt = eWare.CreateQueryObj(sSQL,"");
        recInt.SelectSQL();
            
        sNewLine = sNewLine + "<TD VALIGN=TOP><SPAN CLASS=VIEWBOXCAPTION>"+sCaption+":</SPAN><br><SPAN>" +
                "<INPUT TYPE=HIDDEN NAME=\"_HIDDENprra_integrityid\" id=\"_HIDDENprra_integrityid\">" + 
                "<SELECT " + sDisabled_Integrity + " CLASS=EDIT SIZE=1 NAME=\"prra_integrityid\" id=\"prra_integrityid\">" + 
                "<OPTION VALUE=\"\" SELECTED>--None--</OPTION> ";
        while (!recInt.eof)
        {
            sSelected = "";
            if (Defined(recRating) && !recRating.eof)
            {
                if (recRating.prra_IntegrityId == recInt("prin_IntegrityRatingId"))
                    sSelected = "SELECTED ";
            }
            sNewLine = sNewLine + "<OPTION " + sSelected + "VALUE=\""+ recInt("prin_IntegrityRatingId") + "\" >" + recInt("prin_Name") + "</OPTION> ";

            recInt.NextRecord();
        }
        sNewLine = sNewLine + "</SELECT></SPAN></TD>";

        // Set up the Pay Rating dropdown
        sCaption = eWare.GetTrans("ColNames","prra_PayRatingId");
        sSQL = "SELECT prpy_PayRatingId, prpy_Name " +
                 "FROM PRPayRating WITH (NOLOCK) " +
                "WHERE prpy_Deleted IS NULL " +
             "ORDER BY prpy_Order";             
        recPay = eWare.CreateQueryObj(sSQL,"");
        recPay.SelectSQL();

        DEBUG("sDisabled_Pay: " + sDisabled_Pay);

        sNewLine = sNewLine + "<TD VALIGN=TOP ><SPAN CLASS=VIEWBOXCAPTION>"+sCaption+":</SPAN><br><SPAN>" +
                "<INPUT TYPE=HIDDEN NAME=\"_HIDDENprra_payratingid\" id=\"_HIDDENprra_payratingid\">" + 
                "<SELECT " + sDisabled_Pay + " CLASS=EDIT SIZE=1 NAME=\"prra_payratingid\" id=\"prra_payratingid\">" + 
                "<OPTION VALUE=\"\" SELECTED>--None--</OPTION> ";
        while (!recPay.eof)
        {
            sSelected = "";
            if (Defined(recRating) && !recRating.eof)
            {
                if (recRating.prra_PayRatingId == recPay("prpy_PayRatingId"))
                    sSelected = "SELECTED ";
            }
            sNewLine = sNewLine + "<OPTION " + sSelected + "VALUE=\""+ recPay("prpy_PayRatingId") + "\" >" + recPay("prpy_Name") + "</OPTION> ";

            recPay.NextRecord();
        }
        sNewLine = sNewLine + "</SELECT></SPAN></TD>";
    }
    
    
    sNewLine = sNewLine + "</TR>";
%>