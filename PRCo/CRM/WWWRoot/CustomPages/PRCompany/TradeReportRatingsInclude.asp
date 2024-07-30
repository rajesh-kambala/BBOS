<%
        sRatingFields = "<TABLE ID=\"tblRatingValues\"><TR ID=\"_tr_RatingValues\">";
        // Set up the Integrity dropdown
        sCaption = eWare.GetTrans("ColNames","prin_Name");
        sRatingFields = sRatingFields + "<TD ID=\"td_prtr_integrityid\" VALIGN=TOP>" + 
                "<SPAN ID=\"_Captprtr_integrityid\" CLASS=VIEWBOXCAPTION>"+sCaption+":</SPAN><br><SPAN>" +
                "<INPUT TYPE=HIDDEN NAME=\"_HIDDENprtr_integrityid\">" ; 
        
        if (eWare.Mode == Edit)
        {
            sRatingFields = sRatingFields + "<SELECT CLASS=EDIT SIZE=1 NAME=\"prtr_integrityid\">" ;
            sSQL = "SELECT prin_IntegrityRatingId, prin_TradeReportDescription FROM PRIntegrityRating WITH (NOLOCK) " +
                "WHERE prin_TradeReportDescription IS NOT NULL ORDER BY prin_Order";
            recInt = eWare.CreateQueryObj(sSQL,"");
            recInt.SelectSQL();
            bFoundSelected = false;
            while (!recInt.eof)
            {
                sSelected = "";
                if (Defined(recTradeReport) && !recTradeReport.eof && !bFoundSelected )
                {
                    if (recTradeReport("prtr_IntegrityId") == recInt("prin_IntegrityRatingId"))
                    {
                        bFoundSelected = true;
                        sSelected = "SELECTED ";
                    }
                }
                sRatingFields = sRatingFields + "<OPTION " + sSelected + "VALUE=\""+ recInt("prin_IntegrityRatingId") + "\" >" + recInt("prin_TradeReportDescription") + "</OPTION> ";

                recInt.NextRecord();
            }
            sSelected = "";
            if (!bFoundSelected)
                sSelected = "SELECTED";
            sRatingFields = sRatingFields + "<OPTION VALUE=\"\" " + sSelected + ">--None--</OPTION> ";
            sRatingFields = sRatingFields + "</SELECT></SPAN>";
        }
        else
        {
            prin_tradereportdescription = "&nbsp;";
            if (!isEmpty(recTradeReport.prtr_IntegrityId))
            {
                recInt = eWare.FindRecord("PRIntegrityRating", "prin_IntegrityRatingId=" + recTradeReport.prtr_IntegrityId);
                if (!isEmpty(recInt.prin_TradeReportDescription))
                    prin_tradereportdescription = recInt.prin_TradeReportDescription;
            }
            sRatingFields = sRatingFields + "<SPAN CLASS=VIEWBOX>" + prin_tradereportdescription + "</SPAN>";
        }
        sRatingFields = sRatingFields + "</TD>";

        // Set up the Pay Rating dropdown
        sCaption = eWare.GetTrans("ColNames","prpy_Name");
        sRatingFields = sRatingFields + "<TD  ID=\"td_prtr_payratingid\" VALIGN=TOP >" + 
                "<SPAN ID=\"_Captprtr_payratingid\" CLASS=VIEWBOXCAPTION>"+sCaption+":</SPAN><br><SPAN>" ;

        if (eWare.Mode == Edit)
        {
            var sABAlert = "";
            var currentPayRatingID = recTradeReport.prtr_PayRatingId;
            if (currentPayRatingID == 7) {
                currentPayRatingID = -1;
                sABAlert = "<script type=text/javascript>alert('This trade report record has a pay rating of \"AB\".  This option is no longer available.  Please select a new value before saving this record.');</script>";
            }
        
            sSQL = "SELECT prpy_PayRatingId, prpy_TradeReportDescription " +
                     "FROM PRPayRating WITH (NOLOCK) " +
                    "WHERE prpy_TradeReportDescription IS NOT NULL " +
                      "AND prpy_Deleted IS NULL " +
                 "ORDER BY prpy_Order";
            recPay = eWare.CreateQueryObj(sSQL,"");
            recPay.SelectSQL();
            sRatingFields = sRatingFields + "<INPUT TYPE=HIDDEN NAME=\"_HIDDENprtr_payratingid\">" + 
                    "<SELECT CLASS=EDIT SIZE=1 NAME=\"prtr_payratingid\">"; 
            bFoundSelected = false;
            while (!recPay.eof)
            {
                sSelected = "";
                if (Defined(recTradeReport) && !recTradeReport.eof && !bFoundSelected)
                {
                    if (currentPayRatingID == recPay("prpy_PayRatingId"))
                    {
                        bFoundSelected = true;
                        sSelected = "SELECTED ";
                    }
                }
                sRatingFields = sRatingFields + "<OPTION " + sSelected + "VALUE=\""+ recPay("prpy_PayRatingId") + "\" >" + recPay("prpy_TradeReportDescription") + "</OPTION> ";
                recPay.NextRecord();
            }
            sSelected = "";
            if (!bFoundSelected)
                sSelected = "SELECTED";
            sRatingFields = sRatingFields + "<OPTION VALUE=\"\" " + sSelected + ">--None--</OPTION> ";
            sRatingFields = sRatingFields + "</SELECT></SPAN>";
            sRatingFields = sRatingFields + sABAlert;
        }
        else
        {
            prpy_tradereportdescription = "&nbsp;";
            if (!isEmpty(recTradeReport.prtr_PayRatingId))
            {
                recInt = eWare.FindRecord("PRPayRating", "prpy_PayRatingId=" + recTradeReport.prtr_PayRatingId);
                if (!isEmpty(recInt.prpy_TradeReportDescription))
                    prpy_tradereportdescription = recInt.prpy_TradeReportDescription;
            }    
            sRatingFields = sRatingFields + "<SPAN CLASS=VIEWBOX>" + prpy_tradereportdescription + "</SPAN>";
        }
        sRatingFields = sRatingFields + "</TD>";

        sRatingFields = sRatingFields + "</TR></TABLE>";

        Response.Write(sRatingFields);

%>