<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2024

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

        // re-calculate all the ratios
        // Get the required values
        nCurrentAssets = parseInt(recFinancial("prfs_totalcurrentassets"));
        nCashEquivalents = parseInt(recFinancial("prfs_cashequivalents"));
        nARTrade = parseInt(recFinancial("prfs_artrade"));
        nNetFixedAssets = parseInt(recFinancial("prfs_netfixedassets"));
        nTotalAssets = parseInt(recFinancial("prfs_totalassets"));
        nWorkingCapital = parseInt(recFinancial("prfs_workingcapital"));

        nCurrentLiabilities = parseInt(recFinancial("prfs_totalcurrentliabilities"));
        nAccountsPayable = parseInt(recFinancial("prfs_accountspayable"));
        nLongTermDebt = parseInt(recFinancial("prfs_longtermdebt"));
        nTotalLiabilities = nCurrentLiabilities + 
            parseInt(recFinancial("prfs_totallongliabilities"))+
            parseInt(recFinancial("prfs_othermiscliabilities"));
        nTotalEquity = parseInt(recFinancial("prfs_totalequity"));
        nRetainedEarnings = parseInt(recFinancial("prfs_retainedearnings"));

        nSales = parseInt(recFinancial("prfs_sales"));
        nCostOfGoods = parseInt(recFinancial("prfs_costgoodssold"));
        nOperatingExpenses = parseInt(recFinancial("prfs_operatingexpenses"));
        nOperatingIncome = parseInt(recFinancial("prfs_operatingincome"));
        nNetIncome = parseInt(recFinancial("prfs_netincome"));

        nDepreciation = parseInt(recFinancial("prfs_depreciation"));
        nAmortization = parseInt(recFinancial("prfs_amortization"));

        nCurrentMaturity = parseInt(recFinancial("prfs_CurrentMaturity"));

        nInterimMonth = parseInt(recFinancial("prfs_InterimMonth"));

        // current ratio
        if (isNaN(nCurrentAssets) || isNaN(nCurrentLiabilities) || nCurrentLiabilities == 0)
            recFinancial.prfs_currentratio = "";
        else
            recFinancial.prfs_CurrentRatio = (nCurrentAssets / nCurrentLiabilities).toFixed(2);
        
        // quick ratio
        if (isNaN(nCashEquivalents) || isNaN(nARTrade) || isNaN(nCurrentLiabilities) || nCurrentLiabilities == 0)
            recFinancial.prfs_QuickRatio = "";
        else
            recFinancial.prfs_QuickRatio = ( (nCashEquivalents + nARTrade) / nCurrentLiabilities).toFixed(2);
        
        // AR Turnover
        if (isNaN(nSales) || isNaN(nARTrade) || nARTrade==0)
            recFinancial.prfs_ARTurnover = "";
        else
            recFinancial.prfs_ARTurnover = (nSales / nARTrade).toFixed(2);
        
        // Days Payable Outstanding
        if (isNaN(nAccountsPayable) || isNaN(nCostOfGoods) || nCostOfGoods==0)
            recFinancial.prfs_DaysPayableOutstanding = "";
        else
        {
            iMonth = 12;
            if((recFinancial("prfs_type") == "I") && !isNaN(nInterimMonth))
                iMonth = nInterimMonth;
        
            recFinancial.prfs_DaysPayableOutstanding = ( (nAccountsPayable*365*iMonth/12) / nCostOfGoods).toFixed(2);
        }
        
        // Debt to Equity
        if (isNaN(nTotalLiabilities) || isNaN(nTotalEquity) || nTotalEquity==0)
            recFinancial.prfs_DebtToEquity = "";
        else
            recFinancial.prfs_DebtToEquity = (nTotalLiabilities / nTotalEquity).toFixed(2);

        // Fixed Assets to Net Worth
        if (isNaN(nNetFixedAssets) || isNaN(nTotalEquity) || nTotalEquity == 0)
            recFinancial.prfs_FixedAssetsToNetWorth = "";
        else
            recFinancial.prfs_FixedAssetsToNetWorth= (nNetFixedAssets / nTotalEquity).toFixed(2);

        //Debt Service Ability
        if ((isNaN(nNetIncome) && isNaN(nDepreciation) && isNaN(nAmortization) && isNaN(nCurrentMaturity))
            || nCurrentMaturity == 0)
            recFinancial.prfs_DebtServiceAbility = "";
        else {

            if (isNaN(nNetIncome)) {
                nNetIncome = 0;
            }

            if (isNaN(nDepreciation)) {
                nDepreciation = 0;
            }

            if (isNaN(nAmortization)) {
                nAmortization = 0;
            }

            if ((nDepreciation == 0) &&
                (nAmortization == 0)) {
                recFinancial.prfs_DebtServiceAbility = "";
            } else {
                recFinancial.prfs_DebtServiceAbility = ((nNetIncome + nDepreciation + nAmortization) / nCurrentMaturity).toFixed(2);
            }
        }

        // Operating Ratio
        if (isNaN(nCostOfGoods) || isNaN(nOperatingExpenses) || isNaN(nSales) || nSales==0)
            recFinancial.prfs_OperatingRatio = "";
        else
            recFinancial.prfs_OperatingRatio = ( (nCostOfGoods + nOperatingExpenses) / nSales).toFixed(2);
        
        // ZScore
        if ((recFinancial("prfs_type") == "I") || isNaN(nTotalAssets) || isNaN(nOperatingIncome) ||
            isNaN(nSales) || isNaN(nTotalEquity) || isNaN(nWorkingCapital) || isNaN(nTotalLiabilities) ||
            isNaN(nRetainedEarnings) || nTotalAssets==0 || nTotalLiabilities==0
           ) 
        {
            recFinancial.prfs_zscore = "";
        } 
        else 
        {
            recCompanyExchange = eWare.FindRecord("PRCompanyStockExchange","prc4_companyid=" + comp_companyid);
            if (!recCompanyExchange.eof)
            {
                var lZScore = (3.3 * (nOperatingIncome / nTotalAssets)) 
                            + (.99 * (nSales / nTotalAssets))
                            + (.6 * (nTotalEquity / nTotalLiabilities))
                            + (1.2 * (nWorkingCapital / nTotalAssets))
                            + (1.4 * (nRetainedEarnings / nTotalAssets));
            } 
            else 
            {
                var lZScore = (6.72 * (nOperatingIncome / nTotalAssets))
                            + (1.05 * (nTotalEquity / nTotalLiabilities))
                            + (6.56 * (nWorkingCapital / nTotalAssets))
                            + (3.26 * (nRetainedEarnings / nTotalAssets));
            }
            recFinancial.prfs_zscore = lZScore.toFixed(2);
        }
%>