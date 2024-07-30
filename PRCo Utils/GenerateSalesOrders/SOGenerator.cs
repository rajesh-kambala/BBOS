using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;

namespace GenerateSalesOrders
{
    public class SOGenerator
    {

        public void Generate()
        {
            DateTime dtStart = DateTime.Now;

            Console.Clear();
            Console.Title = "MAS Sales Order Generator Utility";
            WriteLine("MAS Sales Order Generator Utility 1.0");
            WriteLine("Copyright (c) 2012 Blue Book Services, Inc.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);
            WriteLine(DateTime.Now.ToString("M/dd/yyyy hh:mm tt"));

            Dictionary<string, SalesOrderHeader> salesOrders = new Dictionary<string, SalesOrderHeader>();

            using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
            {
                sqlConn.Open();


                SqlCommand cmdSOHeader = new SqlCommand(SQL_SO_HEADER, sqlConn);
                cmdSOHeader.CommandTimeout = 600;
                using (SqlDataReader rdrSOHeader = cmdSOHeader.ExecuteReader())
                {
                    while (rdrSOHeader.Read())
                    {
                        SalesOrderHeader soHeader = new SalesOrderHeader();
                        soHeader.Load(rdrSOHeader);


                        if (salesOrders.ContainsKey(soHeader.HashKey))
                        {
                            WriteLine("Duplicate Sales Order Header Key: " + soHeader.HashKey);
                        }
                        else
                        {
                            salesOrders.Add(soHeader.HashKey, soHeader);
                        }
                    }
                }

                LoadKitItems(sqlConn);


                SqlCommand cmdSODetail = new SqlCommand(SQL_SO_DETAILS, sqlConn);
                cmdSODetail.CommandTimeout = 600;
                using (SqlDataReader rdrSODetail = cmdSODetail.ExecuteReader())
                {
                    while (rdrSODetail.Read())
                    {
                        string hashKey = rdrSODetail["BillToCompanyId"].ToString() + "-" + rdrSODetail["DetailCompanyID"].ToString();
                        if (salesOrders.ContainsKey(hashKey))
                        {                        
                            SalesOrderHeader soHeader = salesOrders[hashKey];
                            SalesOrderDetail soDetail = soHeader.AddDetail(rdrSODetail);
                            AddKitItems(soHeader, soDetail);
                        }
                        else
                        {
                            WriteLine("Unable to find Sales Order Header Key: " + hashKey);                            
                        }
                    }
                }

                //int dlCount = 0;
                //int dlFoundCount = 0;
                //int dlNotFoundCount = 0;

                //WriteLine(string.Format(SQL_DL_DETAILS, loadDLCompanyList()));

                //SqlCommand cmdDLDetail = new SqlCommand(string.Format(SQL_DL_DETAILS, loadDLCompanyList()), sqlConn);
                //cmdDLDetail.CommandTimeout = 600;
                //using (SqlDataReader rdrDLDetail = cmdDLDetail.ExecuteReader())
                //{
                //    while (rdrDLDetail.Read())
                //    {
                //        dlCount++;

                //        string hashKey = string.Empty;
                //        if (rdrDLDetail["comp_PRHQID"].ToString() != rdrDLDetail["comp_CompanyID"].ToString())
                //        {
                //            hashKey = rdrDLDetail["comp_PRHQID"].ToString();
                //        }
                //        hashKey += "-" + rdrDLDetail["comp_CompanyID"].ToString();

                //        if (salesOrders.ContainsKey(hashKey))
                //        {
                //            dlFoundCount++;
                //            SalesOrderHeader soHeader = salesOrders[hashKey];
                //            //SalesOrderDetail soDetail = soHeader.AddDetail(rdrSODetail);
                //            //AddKitItems(soHeader, soDetail);
                //        }
                //        else
                //        {
                //            dlNotFoundCount++;
                //            WriteLine("Unable to find Sales Order Header Key for DL: " + hashKey);
                //        }
                //    }
                //}

                //WriteLine(" - " + dlCount.ToString("###,##0") + " DL Companies Found");
                //WriteLine(" - " + dlFoundCount.ToString("###,##0") + " Corresponding Sales Order Headers Found");
                //WriteLine(" - " + dlNotFoundCount.ToString("###,##0") + " Corresponding Sales Order Headers Not Found");
            }




            int salesOrderDetailCount = 0;
            using (StreamWriter outputFile = new System.IO.StreamWriter(ConfigurationManager.AppSettings["OutputFile"]))
            {
                int salesOrderNo = 0;
                foreach (SalesOrderHeader soHeader in salesOrders.Values)
                {
                    if (soHeader.Details.Count >= 0)
                    {
                        salesOrderNo++;
                        salesOrderDetailCount += soHeader.Details.Count;
                        soHeader.WriteExport(outputFile, salesOrderNo.ToString());
                    }                            
                }
            }

            WriteLine(string.Empty);
            WriteLine("Generated: ");
            WriteLine(" - " + salesOrders.Count.ToString("###,##0") + " Sales Orders");
            WriteLine(" - " + salesOrderDetailCount.ToString("###,##0") + " Sales Order Details");
            WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());



            using (StreamWriter sw = new StreamWriter(_szOutputFile))
            {
                foreach (string line in _lszOutputBuffer)
                {
                    sw.WriteLine(line);
                }
            }
        }


        private void AddKitItems(SalesOrderHeader soHeader, SalesOrderDetail soDetail)
        {
            // This assumes our kit was just added
            string salesKitLineKey = (soHeader.Details.Count * 100000000).ToString();
            int quantity = Convert.ToInt32(soDetail.QuantityOrdered);

            foreach (KitItem kitItem in kitItems)
            {
                if (kitItem.SalesKitNo == soDetail.ItemCode)
                {
                    soDetail.ExplodedKitItem = "Y";
                    soDetail.SalesKitLineKey = salesKitLineKey;
                    SalesOrderDetail soKitDetailItem = new SalesOrderDetail();

                    soKitDetailItem.ItemCode = kitItem.ItemCode;
                    soKitDetailItem.ItemType = kitItem.ItemType;
                    soKitDetailItem.ItemCodeDesc = kitItem.ItemCodeDesc;
                    soKitDetailItem.UnitOfMeasure = kitItem.UnitOfMeasure;
                    soKitDetailItem.TaxClass = kitItem.TaxClass;
                    soKitDetailItem.ExtensionAmt = "0";
                    soKitDetailItem.UnitPrice = "0";
                    soKitDetailItem.SalesKitLineKey = salesKitLineKey;
                    soKitDetailItem.SkipPrintCompLine = "Y";
                    soKitDetailItem.SubjectToExemption = "N";

                    int kitQuantity = Convert.ToInt32(Convert.ToDecimal(kitItem.QuantityPerAssembly));

                    soKitDetailItem.QuantityOrdered = (quantity * kitQuantity).ToString();
                    
                    soHeader.Details.Add(soKitDetailItem);
                }
            }




        }

        private List<KitItem> kitItems = new List<KitItem>();
        private void LoadKitItems(SqlConnection sqlConn)
        {

            SqlCommand cmdKitItems = new SqlCommand(SQL_KIT_ITEMS, sqlConn);
            using (SqlDataReader rdrKitItems = cmdKitItems.ExecuteReader())
            {
                while (rdrKitItems.Read())
                {
                    KitItem kitItem = new KitItem();
                    kitItem.Load(rdrKitItems);
                    kitItems.Add(kitItem);
                }
            }
        }

        private const string SQL_KIT_ITEMS =
            @"SELECT SalesKitNo,
                   [ComponentItemCode] As ItemCode, 
                   IM_SalesKitDetail.ItemType ,
	               CI_Item.ItemCodeDesc,
	               CI_Item.StandardUnitOfMeasure,
	               CI_Item.TaxClass,
	               QuantityPerAssembly
              FROM MAS_PRC.dbo.IM_SalesKitDetail
                   INNER JOIN MAS_PRC.dbo.CI_Item ON ComponentItemCode = CI_Item.ItemCode";

        private const string SQL_SO_HEADER =
            @"SELECT DISTINCT
              CustomerNo = '0' + CAST(prse_CompanyId as varchar(6)),
	           'BillToName' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE SUBSTRING(bill.comp_PRCorrTradestyle, 1, 30) END
	        , 'BillToAddress1' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE RTRIM(bl.Addr_Address1) END
	        , 'BillToAddress2' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE ISNULL(RTRIM(bl.Addr_Address2), '') END
	        , 'BillToAddress3' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE ISNULL(RTRIM(bl.Addr_Address3), '') END
	        , 'BillToCity' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE bl.prci_City END
	        , 'BillToState' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE ISNULL(bl.prst_Abbreviation,'') END
	        , 'BillToZipCode' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE ISNULL(bl.Addr_PostCode,'') END
	        , 'BillToCountryCode' = RIGHT('00'+ CONVERT(VARCHAR,CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE bl.prcn_CountryId END),3)
	        , 'ShipToName' = ship.comp_PRCorrTradestyle
	        , 'ShipToAddress1' = RTRIM(tx.Addr_Address1)
	        , 'ShipToAddress2' = ISNULL(RTRIM(tx.Addr_Address2), '')
	        , 'ShipToAddress3' = ISNULL(RTRIM(tx.Addr_Address3), '')
	        , 'ShipToCity' = tx.prci_City
	        , 'ShipToState' = ISNULL(tx.prst_Abbreviation,'')
	        , 'ShipToZipCode' = ISNULL(tx.addr_PostCode,'')
	        , 'ShipToCountryCode' = RIGHT('00'+ CONVERT(VARCHAR, tx.prcn_CountryId),3)
	        , 'TaxSchedule' = dbo.ufn_GetTaxCode(bl.addr_AddressID)
	        --, 'CycleCode' = LEFT(CONVERT(NVARCHAR(10), ISNULL(prse_NextAnniversaryDate,110),2)
            --, prse_NextAnniversaryDate
            , dbo.ufn_GetPrimaryServiceDate(prse_HQID) As prse_NextAnniversaryDate
	        , 'BillToDivisionNo' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE '00' END
	        , 'BillToCustomerNo' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE '0' + CAST(prse_BillToCompanyId as varchar(6)) END
	        , bl.addr_PRCounty,
	        tx.addr_PRCounty
         FROM PRService_Backup WITH (NOLOCK)
              INNER JOIN Company bill WITH (NOLOCK) ON bill.comp_CompanyID = prse_BillToCompanyId
              INNER JOIN Company ship WITH (NOLOCK) ON ship.Comp_CompanyId = prse_CompanyId
              INNER JOIN PRAttentionLine WITH (NOLOCK) ON prattn_CompanyID = prse_BillToCompanyId AND prattn_ItemCode = 'Bill'
              INNER JOIN vPRAddress bl WITH (NOLOCK) ON prattn_AddressID = bl.Addr_AddressId
              INNER JOIN vPRAddress tx WITH (NOLOCK) ON tx.adli_CompanyId = prse_CompanyId AND tx.adli_PRDefaultTax = 'Y'
        WHERE prse_CancelCode IS NULL
          --AND prse_NextAnniversaryDate IS NOT NULL
          AND prse_ServiceCode IN ('ADVLIC', 'BBS100', 'BBS135', 'BBS150', 'BBS200', 'BBS300', 'BBS350','BBS355',
                                   'BBS375', 'BBS395', 'BBS50', 'BBS75', 'BOOK', 'BPRINT', 'INTLIC', 'CSUPD',
	                               'EXUPD', 'FEDEX1', 'FEDEX3', 'FEDEX5', 'L200', 'L225', 'LMBLIC',
                                   'DL', 'LOGO',
	                               'LP', 'LTDLIC', 'PRMLIC', 'TMPUB', 'WEBSVC')
        ORDER BY CustomerNo;";

        private const string SQL_SO_DETAILS =
            @"SELECT * FROM (
            SELECT '0' + CAST(prse_CompanyId as varchar(6)) As DetailCompanyID,
                   BillToCompanyId = CASE WHEN prse_CompanyId = prse_BillToCompanyId THEN '' ELSE '0' + CAST(prse_BillToCompanyId as varchar(6)) END,
	               prse_ServiceCode As ItemCode,
	               ItemType,
	               ItemCodeDesc,
	               CI_Item.StandardUnitOfMeasure,
	               IM_ProductLine.CostOfGoodsSoldAcctKey,
	               IM_ProductLine.SalesIncomeAcctKey,
	               CI_Item.TaxClass,
	               COUNT(1) AS QuantityOrdered,
	               StandardUnitPrice,
	               (COUNT(1) * StandardUnitPrice) As ExtensionAmt,
                   'N' As SkipPrintCompLine,
                   CASE ISNULL(prse_DiscountPct, 0) WHEN 0 THEN '' ELSE prse_DiscountPct END as prse_DiscountPct,
                   CAST(Category1 as Int) as SortOrder
              FROM CRM.dbo.PRService_Backup
                   INNER JOIN MAS_PRC.dbo.CI_Item ON prse_ServiceCode = ItemCode
                   INNER JOIN MAS_PRC.dbo.IM_ProductLine ON CI_Item.ProductLine = IM_ProductLine.ProductLine
             WHERE prse_CancelCode IS NULL
               AND prse_ServiceCode IN ('ADVLIC', 'BBS100', 'BBS135', 'BBS150', 'BBS200', 'BBS300', 'BBS350','BBS355',
                                        'BBS375', 'BBS395', 'BBS50', 'BOOK', 'BPRINT', 'INTLIC', 'CSUPD',
	                                    'EXUPD', 'FEDEX1', 'FEDEX3', 'FEDEX5', 'L200', 'L225', 'LMBLIC',
                                        'LOGO',
	                                    'LP', 'LTDLIC', 'PRMLIC', 'TMPUB', 'WEBSVC')
               AND UseInSO = 'Y'	
               AND prse_ServiceSubCode <> 'BKUNV'
            GROUP BY prse_CompanyId, prse_BillToCompanyId, prse_NextAnniversaryDate, prse_ServiceCode,
                     ItemType, ItemCodeDesc,
                     CI_Item.StandardUnitOfMeasure,IM_ProductLine.CostOfGoodsSoldAcctKey,
	                 IM_ProductLine.SalesIncomeAcctKey,CI_Item.TaxClass,StandardUnitPrice, CASE ISNULL(prse_DiscountPct, 0) WHEN 0 THEN '' ELSE prse_DiscountPct END,
                     Category1
            UNION
                SELECT '0' + CAST(prse_CompanyId as varchar(6)) As DetailCompanyID,
                   BillToCompanyId = CASE WHEN prse_CompanyId = prse_BillToCompanyId THEN '' ELSE '0' + CAST(prse_BillToCompanyId as varchar(6)) END,
	               prse_ServiceCode As ItemCode,
	               ItemType,
	               ItemCodeDesc,
	               CI_Item.StandardUnitOfMeasure,
	               IM_ProductLine.CostOfGoodsSoldAcctKey,
	               IM_ProductLine.SalesIncomeAcctKey,
	               CI_Item.TaxClass,
	               dbo.ufn_GetListingDLLineCount(prse_CompanyID) As QuantityOrdered,
	               StandardUnitPrice,
	               (dbo.ufn_GetListingDLLineCount(prse_CompanyID) * StandardUnitPrice) As ExtensionAmt,
                   'N' As SkipPrintCompLine,
                   CASE ISNULL(prse_DiscountPct, 0) WHEN 0 THEN '' ELSE prse_DiscountPct END as prse_DiscountPct,
                   CAST(Category1 as Int) as SortOrder
              FROM CRM.dbo.PRService_Backup
                   INNER JOIN Company ON prse_CompanyId = comp_CompanyID
                   INNER JOIN MAS_PRC.dbo.CI_Item ON prse_ServiceCode = ItemCode
                   INNER JOIN MAS_PRC.dbo.IM_ProductLine ON CI_Item.ProductLine = IM_ProductLine.ProductLine
             WHERE prse_CancelCode IS NULL
               AND prse_ServiceCode IN ('DL')
               AND UseInSO = 'Y'	
               AND comp_PRListingStatus IN ('L', 'H')
               AND dbo.ufn_GetListingDLLineCount(prse_CompanyID) > 0
            GROUP BY prse_CompanyId, prse_BillToCompanyId, prse_NextAnniversaryDate, prse_ServiceCode,
                     ItemType, ItemCodeDesc,
                     CI_Item.StandardUnitOfMeasure,IM_ProductLine.CostOfGoodsSoldAcctKey,
	                 IM_ProductLine.SalesIncomeAcctKey,CI_Item.TaxClass,StandardUnitPrice, CASE ISNULL(prse_DiscountPct, 0) WHEN 0 THEN '' ELSE prse_DiscountPct END,
                     Category1
            ) T1
            ORDER BY DetailCompanyID, SortOrder";

        protected string _szOutputFile;
        protected List<string> _lszOutputBuffer = new List<string>();

        private void WriteLine(string msg)
        {
            if (_szOutputFile == null)
            {
                _szOutputFile = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                _szOutputFile = Path.Combine(_szOutputFile, "SOGenerator.txt");
            }

            Console.WriteLine(msg);
            _lszOutputBuffer.Add(msg);
        }

        private const string SQL_DL_DETAILS =
            @"SELECT comp_CompanyID, comp_PRHQID, dbo.ufn_GetListingDLLineCount(comp_CompanyID) As DLCount
                FROM Company WITH (NOLOCK)
               WHERE comp_CompanyID IN ({0})";

        private string loadDLCompanyList()
        {
            StringBuilder companyIDs = new StringBuilder();

            using (StreamReader srData = new StreamReader(ConfigurationManager.AppSettings["DLFile"]))
            {
                string inputLine = null;
                int companyID = 0;

                while ((inputLine = srData.ReadLine()) != null)
                {
                    string[] aszInputFields = inputLine.Split(',');

                    if (int.TryParse(aszInputFields[0], out companyID))
                    {
                        if (companyIDs.Length > 0)
                        {
                            companyIDs.Append(", ");
                        }
                        companyIDs.Append(aszInputFields[0]);
                    }
                }
            }

            return companyIDs.ToString();
        }
    }
}
