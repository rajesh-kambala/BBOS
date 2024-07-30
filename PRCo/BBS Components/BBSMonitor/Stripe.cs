/***********************************************************************
 Copyright Produce Reporter Company 2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Stripe
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using Stripe;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using TSI.Utils;

namespace PRCo.BBS.CRM
{
    public class Stripe
    {
        public const string PRINV_SENT_METHOD_CODE_EMAIL = "E";
        public const string PRINV_SENT_METHOD_CODE_FAX = "F";
        public const string PRINV_SENT_METHOD_CODE_MAIL = "M";

        public const string PRINV_PAYMENT_METHOD_CODE_CHECK = "C";
        public const string PRINV_PAYMENT_METHOD_CODE_CREDIT_CARD_STRIPE = "SCC";
        public const string PRINV_PAYMENT_METHOD_CODE_ACH_STRIPE = "SACH";
        public const string PRINV_PAYMENT_METHOD_CODE_CREDIT_CARD = "BBSCC";

        #region "CRM"
        protected const string SQL_GET_STRIPE_CUSTOMER_ID =
            @"SELECT prci2_StripeCustomerId
                FROM PRCompanyIndicators WITH (NOLOCK)
                WHERE prci2_CompanyID = @CompanyID";

        public static string StripeCustomerId_Get(string szCompanyID, SqlConnection conn)
        {
            //Get Stripe Customer Id from PRCompanyIndicators
            SqlCommand cmdStripeCustomerId = new SqlCommand(SQL_GET_STRIPE_CUSTOMER_ID, conn);
            cmdStripeCustomerId.Parameters.AddWithValue("CompanyID", szCompanyID);
            object resultStripeCustomerId = cmdStripeCustomerId.ExecuteScalar();
            if (resultStripeCustomerId == null || resultStripeCustomerId == DBNull.Value)
                return null;
            else
                return resultStripeCustomerId.ToString();
        }

        public static void StripeCustomerId_Update(string szCompanyID, string szStripeCustomerId, int intUserId, SqlConnection conn)
        {
            SqlCommand cmd = new SqlCommand("usp_UpdateStripeCustomerId", conn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("CompanyID", szCompanyID);
            cmd.Parameters.AddWithValue("StripeCustomerId", szStripeCustomerId);
            cmd.Parameters.AddWithValue("UserID", intUserId);
            cmd.ExecuteNonQuery();
        }

        public static string GeneratePaymentURLKey(string szCompanyID)
        {
            string key = $"{szCompanyID}{RandomString(9)}";
            return key.ToString();
        }

        public static string RandomString(int length)
        {
            var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            var stringChars = new char[length];
            var random = new Random();

            for (int i = 0; i < stringChars.Length; i++)
            {
                stringChars[i] = chars[random.Next(chars.Length)];
            }

            return new String(stringChars);
        }

        public static void PRInvoice_Insert(string szCompanyID, string szInvoiceNbr, string szSentMethodCode, DateTime dtSentDateTime, string szStripePaymentURL, string szStripeInvoiceId, int intUserId, SqlConnection conn)
        {
            string szPaymentURLKey = GeneratePaymentURLKey(szCompanyID);

            SqlCommand cmd = new SqlCommand("usp_InsertPRInvoice", conn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("CompanyID", szCompanyID);
            cmd.Parameters.AddWithValue("InvoiceNbr", szInvoiceNbr);
            cmd.Parameters.AddWithValue("SentMethodCode", szSentMethodCode);
            cmd.Parameters.AddWithValue("SentDateTime", dtSentDateTime);
            cmd.Parameters.AddWithValue("StripePaymentURL", szStripePaymentURL);
            cmd.Parameters.AddWithValue("StripeInvoiceId", szStripeInvoiceId);
            cmd.Parameters.AddWithValue("PaymentURLKey", szPaymentURLKey);
            cmd.Parameters.AddWithValue("UserID", intUserId);
            cmd.ExecuteNonQuery();
        }

        //public static DataTable PRInvoice_Details_Get(string szMASInvoiceNo, SqlConnection conn)
        //{
        //    DataSet ds = new DataSet();

        //    SqlCommand cmd = new SqlCommand(SQL_GET_MAS_INVOICE_DETAILS, conn);
        //    cmd.CommandType = System.Data.CommandType.Text;
        //    cmd.Parameters.AddWithValue("InvoiceNo", szMASInvoiceNo);

        //    var adapter = new SqlDataAdapter(cmd);
        //    adapter.Fill(ds);

        //    return ds.Tables[0];
        //}
        #endregion

        #region "Stripe"
        public static Customer Customer_Create(string szBBID, string CustName, string Address1, string Address2, string AddressCity, string AddressState, string AddressPostalCode, string CustPhone, string CustEmail, out StripeError stripeError)
        {
            Dictionary<string, string> metaData = new Dictionary<string, string>();

            metaData.Add("BBID", szBBID);

            var address = new AddressOptions();
            address.Line1 = Address1;
            address.Line2 = Address2;
            address.City = AddressCity;
            address.State = AddressState;
            address.PostalCode = AddressPostalCode;

            var options = new CustomerCreateOptions
            {
                Description = CustName,
                Email = CustEmail,
                Metadata = metaData,
                Name = CustName,
                Phone = CustPhone,
                Address = address
            };

            var stripeClient = new StripeClient(Utilities.GetConfigValue("Stripe_Secret_Key"));
            stripeError = null;

            Customer stripeCustomer;
            var customerService = new CustomerService(stripeClient);

            try
            {
                stripeCustomer = customerService.Create(options);
            }
            catch (StripeException ex)
            {
                stripeCustomer = null;
                stripeError = ex.StripeError;
            }

            return stripeCustomer;
        }

        public static Invoice Invoice_Create(string szStripeCustomerId, string szBBID, string szMASInvoice, DateTime? dtNextAnniv, decimal SalesTaxAmt,
                                            DataRowView[] drvDetails, out StripeError stripeError)
        {
            Dictionary<string, string> metaData = new Dictionary<string, string>();
            metaData.Add("BBID", szBBID);
            metaData.Add("BB INVOICE", szMASInvoice);

            List<InvoiceCustomFieldOptions> customFields = new List<InvoiceCustomFieldOptions>();
            customFields.Add(new InvoiceCustomFieldOptions { Name = "BBID", Value = szBBID });
            customFields.Add(new InvoiceCustomFieldOptions { Name = "BB Invoice", Value = szMASInvoice });

            var options = new InvoiceCreateOptions
            {
                Customer = szStripeCustomerId,
                Description = $"{szMASInvoice} {szBBID}",
                Metadata = metaData,
                Currency = "USD",
                CustomFields = customFields
            };

            var stripeClient = new StripeClient(Utilities.GetConfigValue("Stripe_Secret_Key"));
            stripeError = null;

            //Create Invoice
            Invoice stripeInvoice;
            var invoiceService = new InvoiceService(stripeClient);

            try
            {
                stripeInvoice = invoiceService.Create(options);
            }
            catch (StripeException ex)
            {
                stripeError = ex.StripeError;
                return null;
            }

            StripeError stripeInvoiceItemError;
            foreach (DataRowView dr in drvDetails)
            {
                int intQuantity = Convert.ToInt32(dr["QuantityOrdered"]);
                decimal ExtensionAmt = (decimal)dr["ExtensionAmt"];
                string szItemCodeDesc = Convert.ToString(dr["ItemCodeDesc"]);
                string szServiceLocation = Convert.ToString(dr["ServiceLocation"]);
                string szServiceLocationPrev = Convert.ToString(dr["ServiceLocation_Prev"]);
                string szCustomerNo = Convert.ToString(dr["CustomerNo"]).Substring(1); //remove leading 0
                string szIsRecognition = Convert.ToString(dr["IsRecognition"]);

                string szDescription;
                if (szServiceLocation != szServiceLocationPrev)
                    szDescription = $"{szServiceLocation} - {szItemCodeDesc}";
                else
                    szDescription = $"{szItemCodeDesc}";

                if (intQuantity > 1)
                    szDescription += $" (Qty {intQuantity})";

                //Add periods for Revenue Recognition items (memberships, logo, and DL).  Add periods based on the anniversary date.If the anniversary date is April, then I believe the membership runs 4 / 1 through 3 / 31
                if (szIsRecognition=="Y" && dtNextAnniv.HasValue)
                {
                    DateTime dtStart = dtNextAnniv.Value.AddMonths(-12);
                    DateTime dtEnd = dtNextAnniv.Value.AddDays(-1);
                    szDescription += $" - {dtStart.Month}/{dtStart.Day}-{dtEnd.Month}/{dtEnd.Day}";
                }
                
                InvoiceItem_Add(szStripeCustomerId, stripeInvoice.Id, 1, Convert.ToInt32(ExtensionAmt * 100), szDescription, out stripeInvoiceItemError);
            }

            decimal salesTaxAmt = Convert.ToDecimal(SalesTaxAmt);
            InvoiceItem_Add(szStripeCustomerId, stripeInvoice.Id, 1, Convert.ToInt32(salesTaxAmt* 100), "Tax", out stripeInvoiceItemError);

            //Finalize invoice
            Invoice stripeInvoiceFinalized;
            stripeInvoiceFinalized = invoiceService.FinalizeInvoice(stripeInvoice.Id);

            return stripeInvoiceFinalized;
        }

        public static InvoiceItem InvoiceItem_Add(string szStripeCustomerId, string szStripeInvoiceId, int intQuantity, int intExtensionAmt, string szDescription, out StripeError stripeError)
        {
            InvoiceItem stripeInvoiceItem;
            var stripeClient = new StripeClient(Utilities.GetConfigValue("Stripe_Secret_Key"));
            stripeError = null;

            var invoiceItemService = new InvoiceItemService(stripeClient);

            var itemOptions = new InvoiceItemCreateOptions
            {
                Customer = szStripeCustomerId,
                Invoice = szStripeInvoiceId,
                Quantity = intQuantity,
                UnitAmount = intExtensionAmt,
                Description = szDescription
            };

            try
            {
                stripeInvoiceItem = invoiceItemService.Create(itemOptions);
            }
            catch (StripeException ex)
            {
                stripeError = ex.StripeError;
                return null;
            }

            return stripeInvoiceItem;
        }
        #endregion
    }
}