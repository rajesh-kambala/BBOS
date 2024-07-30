/***********************************************************************
 Copyright Produce Reporter Company 2010-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: GenerateAddressLists.aspx
 Description:	

 Notes:

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;

namespace PRCo.BBS.CRM.CustomPages.PRGeneral
{
    /// <summary>
    /// This page generates the mass shipment lists used for the
    /// Book and Blueprints shipments
    /// </summary>
    public partial class GenerateAddressLists : PageBase
    {
        protected string sSID = string.Empty;
        protected int _iUserID;
        protected const char DELIMITER = ',';
        
        protected SqlConnection _dbConn = null;
        protected SqlConnection _dbAuditConnection = null;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            Server.ScriptTimeout = 300;

            lblMsg.Text = string.Empty;

            if (!IsPostBack)
            {
                hidUserID.Text = Request["user_userid"];
                hidSID.Text = Request.Params.Get("SID");

                _dbConn = OpenDBConnection("GenerateAddressList");
                try
                {
                    SqlCommand sqlCompanies = new SqlCommand("SELECT RTRIM(capt_code) as capt_code, capt_us FROM Custom_Captions WITH (NOLOCK) WHERE capt_family='BookAddressListType'", _dbConn);

                    ddlBookType.DataTextField = "capt_US";
                    ddlBookType.DataValueField = "capt_code";
                    ddlBookType.DataSource = sqlCompanies.ExecuteReader(CommandBehavior.CloseConnection);
                    ddlBookType.DataBind();

                }
                finally
                {
                    CloseDBConnection(_dbConn);
                }

                int iMonth = DateTime.Today.Month;
                if ((iMonth > 4) && (iMonth < 11))
                {
                    ddlBookType.SelectedValue = "BOOK-OCT";
                }
                else
                {
                    ddlBookType.SelectedValue = "BOOK-APR";
                }
            }

        }


        protected void btnGenerateDeliveryFilesOnClick(object sender, EventArgs e) {
            GenerateBookAddressFiles(false);
        }

        protected void btnGeneratePreviewFilesOnClick(object sender, EventArgs e)
        {
            GenerateBookAddressFiles(true);
        }


        protected void btnGenerateBPrintFilesOnClick(object sender, EventArgs e)
        {
            GenerateBPrintAddressFiles(false);
        }

        protected void btnGeneratePreviewBPrintFilesOnClick(object sender, EventArgs e)
        {
            GenerateBPrintAddressFiles(true);
        }

        protected void btnGenerateKYCGFilesOnClick(object sender, EventArgs e)
        {
          GenerateKYCGAddressFiles(false);
        }

        protected void btnGeneratePreviewKYCGFilesOnClick(object sender, EventArgs e)
        {
          GenerateKYCGAddressFiles(true);
        }

        protected const string SQL_GENERATE_EXECEPTION_FILE =
           @"SELECT vPRCompanyAttentionLine.*, 
	               comp_PRCorrTradestyle As CompanyName, 
	               ISNULL(RTRIM(addr_Address1),'') As Address1, 
                   ISNULL(RTRIM(addr_Address2),'') As Address2, 
	               prci_City As City, 
	               ISNULL(prst_Abbreviation, prst_State) As State, 
	               ISNULL(prcn_Country,'') As Country, 
                   ISNULL(RTRIM(Addr_PostCode),'') As PostalCode, 
                   dbo.ufn_FormatPhone(phone.phon_CountryCode, phone.phon_AreaCode, phone.phon_Number, phone.phon_PRExtension) As Phone, 
                   prci2_Suspended, 
                   prattn_Disabled, 
                   addr_Address3 
              FROM vPRCompanyAttentionLine 
                   INNER JOIN Company WITH (NOLOCK) on prattn_CompanyID = comp_CompanyID 
                   INNER JOIN vPRAddress on prattn_AddressID = addr_AddressID 
                   LEFT OUTER JOIN vPRCompanyPhone phone WITH (NOLOCK) ON prattn_CompanyID = phone.plink_RecordID AND phone.phon_PRIsPhone = 'Y' AND phone.phon_PRPreferredInternal = 'Y' 
                   LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prattn_CompanyID = prci2_CompanyID
             WHERE prattn_ItemCode = '{0}' 
                {1} {2}
               AND (prci2_Suspended IS NOT NULL 
                    OR prattn_Disabled IS NOT NULL 
                    OR addr_Address3 IS NOT NULL) 
          ORDER BY prattn_CompanyID;";


        protected void btnGenerateExceptionFilesOnClick(object sender, EventArgs e)
        {
            GenerateExceptionFile("BOOK", 
                                  string.Format(GetConfigValue("BookAddressListExceptionsFile", "BookAddressExceptions_{0}.csv"), ddlBookType.SelectedValue),
                                  false);
        }


        protected void btnGenerateBPExceptionFilesOnClick(object sender, EventArgs e)
        {
            GenerateExceptionFile("BPRINT",
                                  GetConfigValue("BPrintsAddressListExceptionsFile", "BPrintsAddressExceptions.csv"),
                                  false);
        }

        protected void btnGenerateKYCGExceptionFilesOnClick(object sender, EventArgs e)
        {
          GenerateExceptionFile("KYCG",
                                GetConfigValue("KYCGAddressListExceptionsFile", "KYCGAddressExceptions.csv"),
                                false);
        }

        /// <summary>
        /// Generates a file of the addresses that cannot be processed so that
        /// end users can go fix them, or handle them manually.
        /// </summary>
        protected void GenerateExceptionFile(string szItemCode, string szFileName, bool membersOnly) {

                StringBuilder sbExceptionFile = new StringBuilder();
                int iCount = 0;

                _dbConn = OpenDBConnection("GenerateAddressLists");
                try
                {
                    string szPath = GetConfigValue("AddressListFolder", @"D:\Temp\");
                    string szFile = Path.Combine(szPath, szFileName);

                    using (TextWriter twAddressFile = new StreamWriter(szFile))
                    {

                        twAddressFile.WriteLine("\"BBID\",\"Contact\",\"Company\",\"Address1\",\"Address2\",\"City\",\"State/Province\",\"Zip/Postal Code\",\"Country\",\"Phone Number\",\"Exception Reason\"");

                        string szAddlClause = string.Empty;
                        if (szItemCode == "BOOK")
                        {
                            szItemCode = ddlBookType.SelectedValue;
                            szAddlClause = string.Empty;
                        }

                        if (szItemCode == "BPRINT")
                        {
                            if (!cbIncludeInternational.Checked)
                            {
                                szAddlClause = " AND prcn_CountryID = 1 ";
                            }
                        }

                        string memberClause = string.Empty;
                        if (membersOnly)
                        {
                          memberClause = " AND comp_CompanyID IN (SELECT prse_CompanyID FROM PRService WHERE prse_Primary = 'Y')";
                        }

                        string szSQL = string.Format(SQL_GENERATE_EXECEPTION_FILE,
                                                                   szItemCode,
                                                                   szAddlClause,
                                                                   memberClause);

                        
                        
                        //lblMsg.Text = szSQL + "<br/>";
                        SqlCommand cmdExceptions = new SqlCommand(szSQL, _dbConn);
                        cmdExceptions.CommandTimeout = 300;
                        using (SqlDataReader drExceptions = cmdExceptions.ExecuteReader())
                        {
                            while (drExceptions.Read())
                            {
                                iCount++;

                                AddField(drExceptions["prattn_CompanyID"].ToString(), sbExceptionFile);
                                AddStandardFields(drExceptions, sbExceptionFile);

                                if (drExceptions["prci2_Suspended"] != DBNull.Value)
                                {
                                    AddField("Company Suspended", sbExceptionFile);
                                }
                                else if (drExceptions["prattn_Disabled"] != DBNull.Value)
                                {
                                    AddField("Item Disabled", sbExceptionFile);
                                }
                                else if (drExceptions["addr_Address3"] != DBNull.Value)
                                {
                                    AddField("Address Exceeds Two Lines", sbExceptionFile);
                                }

                                twAddressFile.WriteLine(sbExceptionFile.ToString());
                                sbExceptionFile.Length = 0;
                            }
                        }
                    }

                    DisplayUserMessage(iCount.ToString("###,##0") + " address exceptions written to file " + szFile);
                }
                catch (Exception eX)
                {
                    lblMsg.Text += eX.Message;
                    lblMsg.Text += "<br/><pre>" + eX.StackTrace + "</pre>";
                } 
                finally
                {
                    CloseDBConnection(_dbConn);
                }
            }

        protected const string FILE_BOOK_COL_HEADERS = "\"Recipient Contact\"," +
            "\"Recipient Company\"," +
            "\"Recipient Address 1\"," +
            "\"Recipient Address 2\"," +
            "\"Recipient City\"," +
            "\"Recipient State/Province\"," +
            "\"Recipient Zip Code\"," +
            "\"Recipient Country\"," +
            "\"Recipient Phone Number\"," +
            "\"Ship Service\"," +
            "\"Ship Date (MM/DD/YYYY)\"," +
            "\"Package Type\"," +
            "\"Number of Labels\"," +
            "\"Weight\"," +
            "\"Payor Account Number\"," +
            "\"Ref 1 (Reference)\"," +
            "\"EIN / Tax ID Number\"," +
            "\"Commodity/Document Description\"," +
            "\"Country of Manufacture\"," +
            "\"Commodity Quantity\"," +
            "\"Commercial Invoices Needed? (Y for Commodity, N for Document)\"," +
            "\"Individual Commodity Value\"," +
            "\"Total Customs Value\"," +
            "\"Bill to account # for Duties/Taxes\"";

        protected const string FILE_BOOK_COL_HEADERS_OLD = "Contact,Company,Address1,Address2,City,State/Province,Zip/Postal Code,Phone Number,References,Package/Shipment Weight,Service,Country Code,Package Type,Package Length,Package Width,Package Height,Quantity";
        protected const string FILE_BOOK_COL_HEADERS_OLD2 = "\"Recipient Contact\",\"Recipient Company\",\"Recipient Address 1\",\"Recipient Address 2\",\"Recipient City\",\"Recipient State/Province\",\"Recipient Zip Code\",\"Recipient Country\",\"Recipient Phone Number\",\"Ship Service\",\"Ship Date (MM/DD/YYYY)\",\"Package Type\",\"Number of Labels\",\"Weight\",\"Length\",\"Width\",\"Height\",\"Declared Value\",\"Payor Account Number\",\"Ref 1 (Reference)\",\"Ref 2 (Invoice#)\",\"Ref 3 (PO#)\",\"Ref 4 (Dept Notes)\",\"Residential (Y)/Commercial (N)\",\"Alcohol (Y/N)\",\"Dry Ice (Y/N)\",\"Dry Ice Weight\",\"Sat. Delivery (Y/N)\",\"No Signature\",\"Indirect Signature\",\"Direct Signature\",\"Adult Signature\",\"EIN / Tax ID Number\",\"Commodity/Document Description\",\"Country of Manufacture\",\"Commodity Quantity\",\"Commercial Invoices Needed? (Y for Commodity, N for Document)\",\"Unit of Measure\",\"Individual Commodity Value\",\"Total Customs Value\",\"Bill to account # for Duties/Taxes\",\"Harmonized Code (optional)\",\"Shipper Email Address\",\"Shipper Package Delivery Notification\",\"Shipper Delivery Exception Notification\",\"Shipper Shipment Notification\"";
        protected const string FILE_BOOK_COL_HEADERS_CA = "Recipient Contact,Recipient Company,Recipient Address 1,Recipient Address 2,Recipient City,Recipient State/Province,Recipient Zip Code,Recipient Country,Recipient Phone Number,EIN / Tax ID Number,Commodity/Document Description,Country of Manufacture,Commodity Quantity,Individual Commodity Value,Total Customs Value,Bill to account # for Duties/Taxes,Harmonized Code (optional),\"Commercial Invoices Needed? (Y for Commodity, N for Document)\",Ship Service,Number of Labels,Weight,Length,Width,Height,Declared Value,Ref 1 (Reference),Ref 2 (Invoice#),Ref 3 (PO#),Ref 4 (Dept Notes),Residential (Y)/Commercial (N),Alcohol (Y/N),Dry Ice (Y/N),Dry Ice Weight,Sat. Delivery (Y/N),No Signature,Indirect Signature,Direct Signature,Adult Signature,Shipper Email Address,Shipper Package Pick-up Notification,Shipper Package Delivery Notification,Shipper Delivery Exception Notification,Shipper Shipment Upload Notification,Recipient Email Address,Recipient Package Pick-up Notification,Recipient Package Delivery Notification,Recipient Delivery Exception Notification,Recipient Shipment Upload Notification";

        protected const string SQL_GENERATE_BOOK_ADDRESS_FILE =
            @"SELECT vPRCompanyAttentionLine.*, 
                   comp_PRCorrTradestyle As CompanyName, 
                   ISNULL(RTRIM(addr_Address1),'') As Address1, 
                   ISNULL(RTRIM(addr_Address2),'') As Address2, 
                   prci_City As City, 
                   ISNULL(prst_Abbreviation, prst_State) As State, 
                   ISNULL(prcn_Country,'') As Country, 
                   ISNULL(RTRIM(Addr_PostCode),'') As PostalCode, 
                   dbo.ufn_FormatPhone(phone.phon_CountryCode, phone.phon_AreaCode, phone.phon_Number, phone.phon_PRExtension) As Phone, 
                   dbo.ufn_IsAddressPOBox(addr_Address1, addr_Address2) As IsPOBox, 
                   prcn_CountryID 
              FROM vPRCompanyAttentionLine 
                   INNER JOIN Company WITH (NOLOCK) on prattn_CompanyID = comp_CompanyID 
                   INNER JOIN vPRAddress on prattn_AddressID = addr_AddressID 
                   LEFT OUTER JOIN vPRCompanyPhone phone WITH (NOLOCK) ON prattn_CompanyID = phone.plink_RecordID AND phone.phon_PRIsPhone = 'Y' AND phone.phon_PRPreferredInternal = 'Y' 
                   LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prattn_CompanyID = prci2_CompanyID
             WHERE prattn_ItemCode = '{0}' 
               AND prci2_Suspended IS NULL 
               AND prattn_Disabled IS NULL 
               AND addr_Address3 IS NULL 
          ORDER BY prattn_CompanyID;";

        /// <summary>
        /// Generates the shipment address list for the book code.
        /// Optionally skips creating the shipment log entries if 
        /// this is for a preview only.
        /// </summary>
        /// <param name="bPreview"></param>
        protected void GenerateBookAddressFiles(bool bPreview)
        {
            StringBuilder sbAddressFile = new StringBuilder();
            int iCount = 0;

            _dbConn = OpenDBConnection("GenerateAddressLists");
            _dbAuditConnection = OpenDBConnection("GenerateAddressListsAudit");


            //TextWriter twUSFile = null;
            //TextWriter twCanadaFile = null;
            //TextWriter twInternationalFile = null;
            TextWriter twUSCanIntlFile = null; //Defect 4348 - merge US/Canada/Intl into one file

            TextWriter twUSPOBoxFile = null;
            TextWriter twCanadaPOBoxFile = null;

            try
            {
                string szPath = GetConfigValue("AddressListFolder", @"D:\Temp\");
                
                //twUSFile = new StreamWriter(Path.Combine(szPath, string.Format(GetConfigValue("BookAddressListUSFile", "AddressUS_{0}.csv"), ddlBookType.SelectedValue)));
                //twCanadaFile = new StreamWriter(Path.Combine(szPath, string.Format(GetConfigValue("BookAddressListCanadaFile", "AddressCanada_{0}.csv"), ddlBookType.SelectedValue)));
                //twInternationalFile = new StreamWriter(Path.Combine(szPath, string.Format(GetConfigValue("BookAddressListInternationalFile", "AddressInternational_{0}.csv"), ddlBookType.SelectedValue)));
                twUSCanIntlFile = new StreamWriter(Path.Combine(szPath, string.Format(GetConfigValue("BookAddressListUSCanIntlFile", "AddressUSCanIntl_{0}.csv"), ddlBookType.SelectedValue)));

                twUSPOBoxFile = new StreamWriter(Path.Combine(szPath, string.Format(GetConfigValue("BookAddressListUSPOBoxFile", "AddressUSPOBox_{0}.csv"), ddlBookType.SelectedValue)));
                twCanadaPOBoxFile = new StreamWriter(Path.Combine(szPath, string.Format(GetConfigValue("BookAddressListCanadaPOBoxFile", "AddressCanadaPOBox_{0}.csv"), ddlBookType.SelectedValue)));
                
                TextWriter twWork = null;

                //twUSFile.WriteLine(FILE_BOOK_COL_HEADERS);
                //twCanadaFile.WriteLine(FILE_BOOK_COL_HEADERS);
                //twInternationalFile.WriteLine(FILE_BOOK_COL_HEADERS);
                twUSCanIntlFile.WriteLine(FILE_BOOK_COL_HEADERS);

                twUSPOBoxFile.WriteLine(FILE_BOOK_COL_HEADERS);
                twCanadaPOBoxFile.WriteLine(FILE_BOOK_COL_HEADERS);

                string szSQL = string.Format(SQL_GENERATE_BOOK_ADDRESS_FILE, ddlBookType.SelectedValue);
                //lblMsg.Text = szSQL + "<br/>";
                SqlCommand cmdExceptions = new SqlCommand(szSQL, _dbConn);

                int shipmentLogID = 0;
                string shipService = null;
                using (SqlDataReader drAddressess = cmdExceptions.ExecuteReader())
                {
                    while (drAddressess.Read())
                    {
                        iCount++;

                        if (!bPreview)
                        {
                            shipmentLogID = InsertAuditRecord(drAddressess);
                        }

                        switch (Convert.ToInt32(drAddressess["prcn_CountryID"]))
                        {
                            case 1:  // USA
                                shipService = GetConfigValue("BookAddressShipServiceUS", "FedEx Ground");
                                if (drAddressess["IsPOBox"] == DBNull.Value)
                                {
                                    twWork = twUSCanIntlFile;
                                }
                                else
                                {
                                    twWork = twUSPOBoxFile;
                                }
                                break;
                            case 2: // Canada
                                shipService = GetConfigValue("BookAddressShipServiceCA", "International Ground (Canada)");
                                if (drAddressess["IsPOBox"] == DBNull.Value)
                                {
                                    twWork = twUSCanIntlFile;
                                }
                                else
                                {
                                    twWork = twCanadaPOBoxFile;
                                }
                                break;

                            default: // International
                                shipService = GetConfigValue("BookAddressShipServiceIntl", "International Priority");
                                twWork = twUSCanIntlFile;
                                break;
                        }

                        AddStandardFields(drAddressess, sbAddressFile, true);

                        AddField(shipService, sbAddressFile);
                        AddField(DateTime.Today.ToString("MM/dd/yyyy"), sbAddressFile);
                        AddField(GetConfigValue("BookAddressPackageType", "FedEx Pak"), sbAddressFile);
                        AddField(GetConfigValue("BookAddressListNumberLabels", "1"), sbAddressFile);
                        AddField(GetConfigValue("BookAddressListWeight", "5"), sbAddressFile);

                        AddField(GetConfigValue("BookAddressListPayorAccountNumber", "1169-5510-5"), sbAddressFile);
                        AddField(shipmentLogID.ToString(), sbAddressFile); // Ref1
                        AddField(GetConfigValue("BookAddressListEIN", "36-1647610"), sbAddressFile);
                        AddField(GetConfigValue("BookAddressListCommodity", "Book"), sbAddressFile);
                        AddField(GetConfigValue("BookAddressListECountryOfManufacture", "US"), sbAddressFile);
                        AddField(GetConfigValue("BookAddressListCommodityQuantity", "1"), sbAddressFile);
                        AddField(GetConfigValue("BookAddressListCommercialInvoices", "Y"), sbAddressFile);
                        AddField(GetConfigValue("BookAddressListCommodityValue", "17"), sbAddressFile);
                        AddField(GetConfigValue("BookAddressListCustomsValue", "17"), sbAddressFile);
                        AddField(GetConfigValue("BookAddressListBillToAcctTaxes", "1169-5510-5"), sbAddressFile);

                        twWork.WriteLine(sbAddressFile.ToString().TrimStart());
                        sbAddressFile.Length = 0;
                    }
                }

                DisplayUserMessage(iCount.ToString("###,##0") + " address record written to file " + szPath);
            }
            catch (Exception eX)
            {
                lblMsg.Text += eX.Message;
                lblMsg.Text += "<br/><pre>" + eX.StackTrace + "</pre>";
            }
            finally
            {
                CloseDBConnection(_dbConn);
                CloseDBConnection(_dbAuditConnection);

                /*
                if (twUSFile != null)
                {
                    twUSFile.Close();
                }
                if (twCanadaFile != null)
                {
                    twCanadaFile.Close();
                }
                if (twInternationalFile != null)
                {
                    twInternationalFile.Close();
                }
                */
                if (twUSCanIntlFile != null)
                {
                    twUSCanIntlFile.Close();
                }

                if (twUSPOBoxFile != null)
                {
                    twUSPOBoxFile.Close();
                }
                if (twCanadaPOBoxFile != null)
                {
                    twCanadaPOBoxFile.Close();
                }

            }
        }


        protected const string FILE_COL_HEADERS = "Contact,Company,Address1,Address2,City,State/Province,Country,Zip/Postal Code,References";
        protected const string SQL_GENERATE_ADDRESS_FILE =
            @"SELECT vPRCompanyAttentionLine.*, 
                   comp_PRCorrTradestyle As CompanyName, 
                   ISNULL(RTRIM(addr_Address1),'') As Address1, 
                   ISNULL(RTRIM(addr_Address2),'') As Address2, 
                   prci_City As City, 
                   ISNULL(prst_Abbreviation, prst_State) As State, 
                   ISNULL(prcn_Country,'') As Country, 
                   ISNULL(RTRIM(Addr_PostCode),'') As PostalCode, 
                   dbo.ufn_IsAddressPOBox(addr_Address1, addr_Address2) As IsPOBox, 
                   prcn_CountryID 
              FROM vPRCompanyAttentionLine 
                   INNER JOIN Company WITH (NOLOCK) on prattn_CompanyID = comp_CompanyID 
                   INNER JOIN vPRAddress on prattn_AddressID = addr_AddressID 
                   LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prattn_CompanyID = prci2_CompanyID
             WHERE prattn_ItemCode = '{0}'
                   {1} {2}
               AND prci2_Suspended IS NULL 
               AND prattn_Disabled IS NULL 
               AND addr_Address3 IS NULL 
          ORDER BY prattn_CompanyID;";

          /// <summary>
          /// Generates the shipment address list for the book code.
          /// Optionally skips creating the shipment log entries if 
          /// this is for a preview only.
          /// </summary>
          /// <param name="bPreview"></param>
          protected void GenerateBPrintAddressFiles(bool bPreview)
          {
              GenerateAddressFiles("BPRINT", GetConfigValue("BPrintAddressListFile", "BPrint_Address.csv"), false, bPreview);
          }


          protected void GenerateKYCGAddressFiles(bool bPreview)
          {
            GenerateAddressFiles("KYCG", GetConfigValue("KYCGAddressListFile", "KYCG_Address.csv"), false, bPreview);
          }

    /// <summary>
    /// Generates the shipment address list for the book code.
    /// Optionally skips creating the shipment log entries if 
    /// this is for a preview only.
    /// </summary>
    protected void GenerateAddressFiles(string itemCode, string fileName, bool membersOnly, bool bPreview)
        {
            StringBuilder sbAddressFile = new StringBuilder();
            int iCount = 0;

            _dbConn = OpenDBConnection("GenerateAddressLists");
            _dbAuditConnection = OpenDBConnection("GenerateAddressListsAudit");

            TextWriter twFile = null;

            try
            {
                string szPath = GetConfigValue("AddressListFolder", @"D:\Temp\");

                twFile = new StreamWriter(Path.Combine(szPath, fileName));
                twFile.WriteLine(FILE_COL_HEADERS);


                string szInternationalClause = string.Empty;
                if (!cbIncludeInternational.Checked)
                {
                    szInternationalClause = " AND prcn_CountryID IN (1, 2) ";
                }

                string memberClause = string.Empty;
                if (membersOnly)
                {
                    memberClause = " AND comp_CompanyID IN (SELECT prse_CompanyID FROM PRService WHERE prse_Primary = 'Y')";
                }

                string szSQL = string.Format(SQL_GENERATE_ADDRESS_FILE, itemCode, szInternationalClause, memberClause);

                SqlCommand cmdExceptions = new SqlCommand(szSQL, _dbConn);
                cmdExceptions.CommandTimeout = 300;
                int shipmentLogID = 0;

                using (SqlDataReader drAddressess = cmdExceptions.ExecuteReader())
                {
                    while (drAddressess.Read())
                    {
                        iCount++;
                        if (!bPreview)
                        {
                            shipmentLogID = InsertAuditRecord(drAddressess);
                        }

                        AddField(drAddressess["Addressee"].ToString(), sbAddressFile);
                        // This accounts for empty "Addressee" values
                        if (sbAddressFile.Length == 0)
                        {
                            sbAddressFile.Append(" ");
                        }

                        AddField(drAddressess["CompanyName"].ToString(), sbAddressFile);
                        AddField(drAddressess["Address1"].ToString(), sbAddressFile);
                        AddField(drAddressess["Address2"].ToString(), sbAddressFile);
                        AddField(drAddressess["City"].ToString(), sbAddressFile);
                        AddField(drAddressess["State"].ToString(), sbAddressFile);
                        AddField(drAddressess["Country"].ToString(), sbAddressFile);
                        AddField(drAddressess["PostalCode"].ToString(), sbAddressFile);
                        AddField(shipmentLogID.ToString(), sbAddressFile);

                        twFile.WriteLine(sbAddressFile.ToString().TrimStart());
                        sbAddressFile.Length = 0;
                    }
                }

                DisplayUserMessage(iCount.ToString("###,##0") + " address record written to file " + szPath);
            }
            catch (Exception eX)
            {
                lblMsg.Text += eX.Message;
                lblMsg.Text += "<br/><pre>" + eX.StackTrace + "</pre>";
            }
            finally
            {
                CloseDBConnection(_dbConn);
                CloseDBConnection(_dbAuditConnection);

                if (twFile != null)
                {
                    twFile.Close();
                }

            }
        }


        protected const string SQL_INSERT_SHIPMENT_LOG =
            @"INSERT INTO PRShipmentLog (prshplg_AttentionLineID, prshplg_CompanyID, prshplg_Type, prshplg_PersonID, prshplg_Addressee, prshplg_AddressID, prshplg_DeliveryAddress, prshplg_CreatedBy, prshplg_CreatedDate, prshplg_UpdatedBy, prshplg_UpdatedDate, prshplg_Timestamp) 
              VALUES (@AttentionLineID, @CompanyID, @Type, @PersonID, @Addressee, @AddressID, @DeliveryAddress, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp);
              SELECT SCOPE_IDENTITY();";

        protected const string SQL_INSERT_SHIPMENT_LOG_DETAIL =
            @"INSERT INTO PRShipmentLogDetail (prshplgd_ShipmentLogID, prshplgd_ItemCode, prshplgd_CreatedBy, prshplgd_CreatedDate, prshplgd_UpdatedBy, prshplgd_UpdatedDate, prshplgd_Timestamp)
                VALUES (@ShipmentLogID, @ItemCode, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        SqlCommand cmdShipmentLog = null;
        SqlCommand cmdShipmentLogDetail = null;
        DateTime dtCreatedDate;

        /// <summary>
        /// Helper method that inserts audit records into the
        /// ShipmentLog file.
        /// </summary>
        /// <param name="drShipment"></param>
        protected int InsertAuditRecord(SqlDataReader drShipment)
        {
            if (cmdShipmentLog == null)
            {
                cmdShipmentLog = new SqlCommand(SQL_INSERT_SHIPMENT_LOG, _dbAuditConnection);
                dtCreatedDate = DateTime.Now;
            }
            cmdShipmentLog.Parameters.Clear();

            cmdShipmentLog.Parameters.AddWithValue("AttentionLineID", drShipment["prattn_AttentionLineID"]);
            cmdShipmentLog.Parameters.AddWithValue("CompanyID", drShipment["prattn_CompanyID"]);
            cmdShipmentLog.Parameters.AddWithValue("Type", "Mass");
            cmdShipmentLog.Parameters.AddWithValue("PersonID", drShipment["prattn_PersonID"]);
            cmdShipmentLog.Parameters.AddWithValue("Addressee", drShipment["Addressee"]);
            cmdShipmentLog.Parameters.AddWithValue("AddressID", drShipment["prattn_AddressID"]);
            cmdShipmentLog.Parameters.AddWithValue("DeliveryAddress", drShipment["DeliveryAddress"]);
            cmdShipmentLog.Parameters.AddWithValue("CreatedBy", Convert.ToInt32(hidUserID.Text));
            cmdShipmentLog.Parameters.AddWithValue("CreatedDate", dtCreatedDate);
            cmdShipmentLog.Parameters.AddWithValue("UpdatedBy", Convert.ToInt32(hidUserID.Text));
            cmdShipmentLog.Parameters.AddWithValue("UpdatedDate", dtCreatedDate);
            cmdShipmentLog.Parameters.AddWithValue("Timestamp", dtCreatedDate);

            int shipmentLogID = Convert.ToInt32(cmdShipmentLog.ExecuteScalar());

            if (cmdShipmentLogDetail == null)
            {
                cmdShipmentLogDetail = new SqlCommand(SQL_INSERT_SHIPMENT_LOG_DETAIL, _dbAuditConnection);
            }
            cmdShipmentLogDetail.Parameters.Clear();

            cmdShipmentLogDetail.Parameters.AddWithValue("ShipmentLogID", shipmentLogID);
            cmdShipmentLogDetail.Parameters.AddWithValue("ItemCode", drShipment["prattn_ItemCode"]);
            cmdShipmentLogDetail.Parameters.AddWithValue("CreatedBy", Convert.ToInt32(hidUserID.Text));
            cmdShipmentLogDetail.Parameters.AddWithValue("CreatedDate", dtCreatedDate);
            cmdShipmentLogDetail.Parameters.AddWithValue("UpdatedBy", Convert.ToInt32(hidUserID.Text));
            cmdShipmentLogDetail.Parameters.AddWithValue("UpdatedDate", dtCreatedDate);
            cmdShipmentLogDetail.Parameters.AddWithValue("Timestamp", dtCreatedDate);
            cmdShipmentLogDetail.ExecuteNonQuery();

            return shipmentLogID;
        }

        /// <summary>
        /// Helper method used by the book methods to add data fields
        /// to the output file.
        /// </summary>
        /// <param name="drShipment"></param>
        /// <param name="sbFile"></param>
        protected void AddStandardFields(SqlDataReader drShipment, StringBuilder sbFile)
        {
            AddStandardFields(drShipment, sbFile, true);
        }

        /// <summary>
        /// Helper method used by the book methods to add data fields
        /// to the output file.
        /// </summary>
        /// <param name="drShipment"></param>
        /// <param name="sbFile"></param>
        /// <param name="includePhone"></param>
        protected void AddStandardFields(SqlDataReader drShipment, StringBuilder sbFile, bool includePhone)
        {
            AddField(drShipment["Addressee"].ToString(), sbFile);

            // This accounts for empty "Addressee" values
            if (sbFile.Length == 0)
            {
                sbFile.Append(" ");
            }


            AddField(drShipment["CompanyName"].ToString(), sbFile);
            AddField(drShipment["Address1"].ToString(), sbFile);
            AddField(drShipment["Address2"].ToString(), sbFile);
            AddField(drShipment["City"].ToString(), sbFile);
            AddField(drShipment["State"].ToString(), sbFile);
            AddField(drShipment["PostalCode"].ToString(), sbFile);
            AddField(drShipment["Country"].ToString(), sbFile);

            if (includePhone) {
                AddField(drShipment["Phone"].ToString(), sbFile);
            }
        }

        protected void AddField(string value, StringBuilder sbFile)
        {
            if (sbFile.Length > 0)
            {
                sbFile.Append(DELIMITER);
            }

            if (!string.IsNullOrEmpty(value))
            {
                sbFile.Append("\"" + value + "\"");
            }
        }
    }
}
