using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.IO;

namespace GenerateSalesOrders
{
    public class SalesOrderHeader
    {
        //public string SalesOrderNo;
        public string ARDivisionNo = "00";
        public string CustomerNo;
        public string CorporateTaxOverrd = "N";
        public string DepositCorporateTaxOverrd = "N";
        public string OrderType = "R";
        public string ShipExpireDate = "12/31/5999";
        public string OrderStatus = "N";
        public string BillToName;
        public string BillToAddress1;
        public string BillToAddress2;
        public string BillToAddress3;
        public string BillToZipCode;
        public string BillToCity;
        public string BillToState;
        public string BillToCountryCode;
        public string ShipToName;
        public string ShipToAddress1;
        public string ShipToAddress2;
        public string ShipToAddress3;
        public string ShipToZipCode;
        public string ShipToCity;
        public string ShipToState;
        public string ShipToCountryCode;
        public string TermsCode = "01";
        public string TaxSchedule;
        public string TaxExemptNo;
        public string CycleCode;
        public string BillToDivisionNo;
        public string BillToCustomerNo;

        

        public string HashKey
        {
            get { return BillToCustomerNo + "-" + CustomerNo; }
        }


        public void Load(SqlDataReader rdrSOHeader)
        {
            CustomerNo = rdrSOHeader["CustomerNo"].ToString();
            BillToName = rdrSOHeader["BillToName"].ToString();
            BillToAddress1 = rdrSOHeader["BillToAddress1"].ToString();
            BillToAddress2 = rdrSOHeader["BillToAddress2"].ToString();
            BillToAddress3 = rdrSOHeader["BillToAddress3"].ToString();
            BillToZipCode = rdrSOHeader["BillToZipCode"].ToString();
            BillToCity = rdrSOHeader["BillToCity"].ToString();
            BillToState = rdrSOHeader["BillToState"].ToString();
            BillToCountryCode = rdrSOHeader["BillToCountryCode"].ToString();
            ShipToName = rdrSOHeader["ShipToName"].ToString();
            ShipToAddress1 = rdrSOHeader["ShipToAddress1"].ToString();
            ShipToAddress2 = rdrSOHeader["ShipToAddress2"].ToString();
            ShipToAddress3 = rdrSOHeader["ShipToAddress3"].ToString();
            ShipToZipCode = rdrSOHeader["ShipToZipCode"].ToString();
            ShipToCity = rdrSOHeader["ShipToCity"].ToString();
            ShipToState = rdrSOHeader["ShipToState"].ToString();
            ShipToCountryCode = rdrSOHeader["ShipToCountryCode"].ToString();
            TaxSchedule = rdrSOHeader["TaxSchedule"].ToString();
            BillToDivisionNo = rdrSOHeader["BillToDivisionNo"].ToString();
            BillToCustomerNo = rdrSOHeader["BillToCustomerNo"].ToString();


            if (rdrSOHeader["prse_NextAnniversaryDate"] == DBNull.Value)
            {
                CycleCode = "02";
            }
            else
            {
                CycleCode = Convert.ToDateTime(rdrSOHeader["prse_NextAnniversaryDate"]).Month.ToString("00");
            }


            //if ((!string.IsNullOrEmpty(BillToCountryCode)) &&
            //    (BillToCountryCode.Length < 3))
            //{
            //    BillToCountryCode = Convert.ToInt32(BillToCountryCode).ToString("000");
            //}

            //if ((!string.IsNullOrEmpty(ShipToCountryCode)) &&
            //    (ShipToCountryCode.Length < 3))
            //{
            //    ShipToCountryCode = Convert.ToInt32(ShipToCountryCode).ToString("000");
            //}

        }

        private string delimiter = "|";
        public void WriteExport(StreamWriter outputFile, string SalesOrderNo)
        {

            foreach (SalesOrderDetail soDetail in details)
            {
                outputFile.Write(SalesOrderNo);
                outputFile.Write(delimiter);
                outputFile.Write(ARDivisionNo);
                outputFile.Write(delimiter);
                outputFile.Write(CustomerNo);
                outputFile.Write(delimiter);
                outputFile.Write(CorporateTaxOverrd);
                outputFile.Write(delimiter);
                outputFile.Write(DepositCorporateTaxOverrd);
                outputFile.Write(delimiter);
                outputFile.Write(OrderType);
                outputFile.Write(delimiter);
                outputFile.Write(ShipExpireDate);
                outputFile.Write(delimiter);
                outputFile.Write(CustomerNo);
                outputFile.Write(delimiter);
                outputFile.Write(OrderStatus);
                outputFile.Write(delimiter);
                outputFile.Write(BillToName);
                outputFile.Write(delimiter);
                outputFile.Write(BillToAddress1);
                outputFile.Write(delimiter);
                outputFile.Write(BillToAddress2);
                outputFile.Write(delimiter);
                outputFile.Write(BillToAddress3);
                outputFile.Write(delimiter);

                if (BillToCountryCode == "001")
                {
                    outputFile.Write(BillToZipCode.Substring(0, 5));
                }
                else
                {
                    outputFile.Write(BillToZipCode);
                }

                
                outputFile.Write(delimiter);
                outputFile.Write(BillToCity);
                outputFile.Write(delimiter);
                outputFile.Write(BillToState);
                outputFile.Write(delimiter);

                if (BillToCountryCode == "000")
                {
                    outputFile.Write(string.Empty);
                }
                else
                {
                    outputFile.Write(BillToCountryCode);
                }
                
                
                outputFile.Write(delimiter);
                outputFile.Write(ShipToName);
                outputFile.Write(delimiter);
                outputFile.Write(ShipToAddress1);
                outputFile.Write(delimiter);
                outputFile.Write(ShipToAddress2);
                outputFile.Write(delimiter);
                outputFile.Write(ShipToAddress3);
                outputFile.Write(delimiter);

                if (ShipToCountryCode == "001")
                {
                    outputFile.Write(ShipToZipCode.Substring(0, 5));
                }
                else
                {
                    outputFile.Write(ShipToZipCode);
                }                

                outputFile.Write(delimiter);
                outputFile.Write(ShipToCity);
                outputFile.Write(delimiter);
                outputFile.Write(ShipToState);
                outputFile.Write(delimiter);
                outputFile.Write(ShipToCountryCode);
                outputFile.Write(delimiter);
                outputFile.Write(TermsCode);
                outputFile.Write(delimiter);
                outputFile.Write(TaxSchedule);
                outputFile.Write(delimiter);
                outputFile.Write(TaxExemptNo);
                outputFile.Write(delimiter);
                outputFile.Write(CycleCode);
                outputFile.Write(delimiter);
                outputFile.Write(BillToDivisionNo);
                outputFile.Write(delimiter);
                outputFile.Write(BillToCustomerNo);
                outputFile.Write(delimiter);


                outputFile.Write(soDetail.ItemCode);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.ItemType);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.ItemCodeDesc);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.Discount);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.SubjectToExemption);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.PriceLevel);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.UnitOfMeasure);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.SalesKitLineKey);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.CostOfGoodsSoldAcctKey);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.SalesAcctKey);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.ExplodedKitItem);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.TaxClass);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.QuantityOrdered);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.UnitPrice);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.ExtensionAmt);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.SkipPrintCompLine);
                outputFile.Write(delimiter);
                outputFile.Write(soDetail.LineDiscountPercent);

                outputFile.Write(Environment.NewLine);
            }
        }

        private List<SalesOrderDetail> details = new List<SalesOrderDetail>();
        public SalesOrderDetail AddDetail(SqlDataReader rdrSODetail)
        {
            SalesOrderDetail soDetail = new SalesOrderDetail();
            soDetail.Load(rdrSODetail);
            details.Add(soDetail);

            // Now see if we should explode this.
            //AddKitItems(soDetail);

            return soDetail;
        }

        public List<SalesOrderDetail> Details
        {
            get { return details; }
        }


        private const string SQL_KIT_ITEMS =
            @"SELECT [ComponentItemCode] As ItemCode, 
                   IM_SalesKitDetail.ItemType ,
	               CI_Item.ItemCodeDesc,
	               CI_Item.StandardUnitOfMeasure,
	               '' As SalesKitLineKey,
	               '' As CostOfGoodsSoldAcctKey,
	               '' As SalesIncomeAcctKey,
	               CI_Item.TaxClass,
	               ({1} * QuantityPerAssembly) AS QuantityOrdered,
	               0 as StandardUnitPrice,
	               0 As ExtensionAmt,
	               'Y' As SkipPrintCompLine
              FROM MAS_PRC.dbo.IM_SalesKitDetail
                   INNER JOIN MAS_PRC.dbo.CI_Item ON ComponentItemCode = CI_Item.ItemCode	    
             WHERE  SalesKitNo = '{0}'";
        private void AddKitItems(SalesOrderDetail soDetail)
        {
            using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
            {
                sqlConn.Open();
                SqlCommand cmdKitItems = new SqlCommand(string.Format(SQL_KIT_ITEMS, soDetail.ItemCode, soDetail.QuantityOrdered), sqlConn);
                using (SqlDataReader rdrKitItems = cmdKitItems.ExecuteReader())
                {
                    while (rdrKitItems.Read())
                    {
                        soDetail.ExplodedKitItem = "Y";

                        SalesOrderDetail soKitItem = new SalesOrderDetail();
                        soKitItem.Load(rdrKitItems);
                        details.Add(soKitItem);
                    }
                }
            }
        }
    }

    public class SalesOrderDetail
    {
        public string ItemCode;
        public string ItemType;
        public string ItemCodeDesc;
        public string Discount;
        public string SubjectToExemption = "Y";
        public string PriceLevel;
        public string UnitOfMeasure;
        public string SalesKitLineKey;
        public string CostOfGoodsSoldAcctKey;
        public string SalesAcctKey;
        public string ExplodedKitItem = "N";
        public string TaxClass;
        public string QuantityOrdered;
        public string UnitPrice;
        public string ExtensionAmt;
        public string SkipPrintCompLine;
        public string SalesKitNdx = "0";
        public string LineDiscountPercent;

        public void Load(SqlDataReader rdrSODetail)
        {
            ItemCode = rdrSODetail["ItemCode"].ToString();
            ItemType = rdrSODetail["ItemType"].ToString();
            ItemCodeDesc = rdrSODetail["ItemCodeDesc"].ToString();
            UnitOfMeasure = rdrSODetail["StandardUnitOfMeasure"].ToString();
            //SalesKitLineKey = rdrSODetail["SalesKitLineKey"].ToString();
            CostOfGoodsSoldAcctKey = rdrSODetail["CostOfGoodsSoldAcctKey"].ToString();
            SalesAcctKey = rdrSODetail["SalesIncomeAcctKey"].ToString();
            //ExplodedKitItem = rdrSODetail["ExplodedKitItem"].ToString();
            TaxClass = rdrSODetail["TaxClass"].ToString();
            QuantityOrdered = rdrSODetail["QuantityOrdered"].ToString();
            UnitPrice = rdrSODetail["StandardUnitPrice"].ToString();
            ExtensionAmt = rdrSODetail["ExtensionAmt"].ToString();
            SkipPrintCompLine = rdrSODetail["SkipPrintCompLine"].ToString();
            LineDiscountPercent = rdrSODetail["prse_DiscountPct"].ToString();
        }
    }


    public class KitItem
    {
        public string SalesKitNo;
        public string ItemCode;
        public string ItemType;
        public string ItemCodeDesc;
        public string UnitOfMeasure;
        public string TaxClass;
        public string QuantityPerAssembly;

        public void Load(SqlDataReader rdrKitItems)
        {
            SalesKitNo = rdrKitItems["SalesKitNo"].ToString();
            ItemCode = rdrKitItems["ItemCode"].ToString();
            ItemType = rdrKitItems["ItemType"].ToString();
            ItemCodeDesc = rdrKitItems["ItemCodeDesc"].ToString();
            UnitOfMeasure = rdrKitItems["StandardUnitOfMeasure"].ToString();
            TaxClass = rdrKitItems["TaxClass"].ToString();
            QuantityPerAssembly = rdrKitItems["QuantityPerAssembly"].ToString();

        }
    }
}
