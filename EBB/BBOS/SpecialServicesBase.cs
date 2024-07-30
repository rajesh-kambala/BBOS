/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: SpecialServicesBase
 Description: This class implements base functionality for certain 
              Special Service files. The class defines common SQL,
              general function for uploading SSFile documents, and 
              helper methods for saving SSFile and related records.

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public class CourtesyContactInvoice
    {
        public decimal amount { get; set; }
        public DateTime invoicedate { get; set; }
        public string invoicenum { get; set; }
    }

    public class SpecialServicesBase : PageBase
    {
        // SQL to retrieve the company name and location
        protected const string SQL_GET_COMPANY = "SELECT comp_PRBookTradestyle + '<br/>'+ CityStateCountryShort " +
            " FROM Company WITH (NOLOCK) " +
            " INNER JOIN vPRLocation ON comp_PRListingCityId = prci_CityId " +
            " WHERE comp_CompanyID = {0} ";
        protected const string SQL_GET_COMPANY_SHORT = "SELECT comp_PRBookTradestyle " +
            " FROM Company WITH (NOLOCK) " +
            " INNER JOIN vPRLocation ON comp_PRListingCityId = prci_CityId " +
            " WHERE comp_CompanyID = {0} ";

        protected const string SQL_GET_PERSON_FORMATTED_NAME = "SELECT dbo.ufn_FormatPersonById({0}) as FullName; ";

        protected const string SQL_GET_COMPANY_CONTACTINFO =
            @"SELECT DefaultPhone = ISNULL(dbo.ufn_FormatPhone(pphone.phon_CountryCode, pphone.phon_AreaCode, pphone.phon_Number, pphone.phon_PRExtension), dbo.ufn_FormatPhone(cphone.phon_CountryCode, cphone.phon_AreaCode, cphone.phon_Number, cphone.phon_PRExtension)), 
                     DefaultFax= ISNULL(dbo.ufn_FormatPhone(pfax.phon_CountryCode, pfax.phon_AreaCode, pfax.phon_Number, pfax.phon_PRExtension), dbo.ufn_FormatPhone(cfax.phon_CountryCode, cfax.phon_AreaCode, cfax.phon_Number, cfax.phon_PRExtension)), 
                     addr_Address1, addr_Address2, addr_Address3, prci_city, prst_Abbreviation, addr_PostCode 
                FROM Person_Link 
                     INNER JOIN vPRAddress ON peli_CompanyID = adli_CompanyID 
                     LEFT OUTER JOIN vPRCompanyPhone cphone WITH (NOLOCK) ON peli_CompanyId = cphone.PLink_RecordID AND cphone.phon_PRIsPhone='Y' AND cphone.phon_PRPreferredPublished='Y' 
                     LEFT OUTER JOIN vPRCompanyPhone cfax WITH (NOLOCK) ON peli_CompanyId = cfax.PLink_RecordID AND cfax.phon_PRIsFax='Y' AND cfax.phon_PRPreferredPublished='Y' 
                     LEFT OUTER JOIN vPRPersonPhone pphone WITH (NOLOCK) ON peli_PersonID = pphone.PLink_RecordID AND pphone.phon_PRIsPhone='Y' AND pphone.phon_PRPreferredPublished='Y' 
                     LEFT OUTER JOIN vPRPersonPhone pfax WITH (NOLOCK) ON peli_PersonID = pfax.PLink_RecordID AND pfax.phon_PRIsFax='Y' AND pfax.phon_PRPreferredPublished='Y' 
               WHERE adli_PRDefaultMailing = 'Y'  
                 AND peli_CompanyId = {0} 
                 AND peli_PersonId = {1} 
                 AND peli_PRStatus = '1'";

        protected const string SQL_GET_COMPANY_CONTACTINFO2 =
            @"SELECT addr_Address1, addr_Address2, addr_Address3, prci_city, prst_StateID, prcn_CountryID, addr_PostCode, 
                     ISNULL(dbo.ufn_FormatPhone(pphone.phon_CountryCode, pphone.phon_AreaCode, pphone.phon_Number, pphone.phon_PRExtension), dbo.ufn_FormatPhone(cphone.phon_CountryCode, cphone.phon_AreaCode, cphone.phon_Number, cphone.phon_PRExtension)),  
                     ISNULL(dbo.ufn_FormatPhone(pfax.phon_CountryCode, pfax.phon_AreaCode, pfax.phon_Number, pfax.phon_PRExtension), dbo.ufn_FormatPhone(cfax.phon_CountryCode, cfax.phon_AreaCode, cfax.phon_Number, cfax.phon_PRExtension))  
                FROM Person_Link 
                     INNER JOIN vPRAddress ON peli_CompanyID = adli_CompanyID 
                     LEFT OUTER JOIN vPRCompanyPhone cphone WITH (NOLOCK) ON peli_CompanyId = cphone.PLink_RecordID AND cphone.phon_PRIsPhone='Y' AND cphone.phon_PRPreferredPublished='Y' 
                     LEFT OUTER JOIN vPRCompanyPhone cfax WITH (NOLOCK) ON peli_CompanyId = cfax.PLink_RecordID AND cfax.phon_PRIsFax='Y' AND cfax.phon_PRPreferredPublished='Y' 
                     LEFT OUTER JOIN vPRPersonPhone pphone WITH (NOLOCK) ON peli_PersonID = pphone.PLink_RecordID AND pphone.phon_PRIsPhone='Y' AND pphone.phon_PRPreferredPublished='Y' 
                     LEFT OUTER JOIN vPRPersonPhone pfax WITH (NOLOCK) ON peli_PersonID = pfax.PLink_RecordID AND pfax.phon_PRIsFax='Y' AND pfax.phon_PRPreferredPublished='Y' 
               WHERE adli_PRDefaultMailing = 'Y'  
                 AND peli_CompanyId = {0} 
                 AND peli_PersonId = {1} 
                 AND peli_PRStatus = '1'";

        protected const string SQL_INSERT_PRSSCONTACT = "INSERT INTO PRSSContact " +
            "(prssc_CreatedBy, prssc_CreatedDate, prssc_UpdatedBy, prssc_UpdatedDate, prssc_TimeStamp, " +
            "prssc_SSFileId, prssc_CompanyId, prssc_PersonId, prssc_ContactAttn, prssc_IsPrimary, " +
            "prssc_Address1, prssc_Address2, prssc_Address3, prssc_CityStateZip, prssc_Telephone, " +
            "prssc_Fax, prssc_Email, prssc_SSContactId ) " +
            "VALUES " +
            "({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17} )";



        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.TradingAssistancePage).HasPrivilege;
        }

        protected string getCompanyName(string szCompanyID)
        {
            // Format SQL to retrieve the Current company info
            string szSQL = string.Format(SQL_GET_COMPANY, szCompanyID);

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                if (oReader.Read())
                    return oReader[0].ToString();
                else
                    return "";
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

        }

        protected string getCompanyNameShort(string szCompanyID)
        {
            // Format SQL to retrieve the Current company info
            string szSQL = string.Format(SQL_GET_COMPANY_SHORT, szCompanyID);

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                if (oReader.Read())
                    return oReader[0].ToString();
                else
                    return "";
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        protected void simulateSageFileUpload(string sSSFileId, string szSourceFile, string szFileName, int iAssignedToId, IDbTransaction oTran)
        {
            base.simulateSageFileUpload(sSSFileId, szSourceFile, szFileName, iAssignedToId, string.Format(Resources.Global.SpecialServicesClaimFileTaskNotes, ""), "Special Services File was created through BBOS.", 0, null, oTran);
        }

        protected string createEmailCommunicationRecord(string sSSFileId, string subject, string sTaskNotes, int iAssignedToId, IDbTransaction oTran)
        {
            return base.createEmailCommunicationRecord(sSSFileId, subject, sTaskNotes, iAssignedToId, "SS", "CC", oTran); //Special Services, Courtesy Contact
        }

        protected void insertSSContact(int iSSFileId, IDbTransaction oTran)
        {
            IDataReader oReader = null;

            string sContactAttn = null;
            string sDefaultPhone = null;
            string sDefaultFax = null;
            string sAddress1 = null;
            string sAddress2 = null;
            string sAddress3 = null;
            string sCity = null;
            string sStateAbbr = null;
            string sPostCode = null;
            string sCSZ = null;
            string sIsPrimary = "Y";

            oReader = GetDBAccess().ExecuteReader(String.Format(SQL_GET_PERSON_FORMATTED_NAME, _oUser.peli_PersonID), CommandBehavior.CloseConnection);
            try
            {
                if(oReader.Read())
                    sContactAttn = oReader[0].ToString();
                else
                    sContactAttn = "";
            }
            finally
            {
                if (oReader != null)
                    oReader.Close();
            }

            oReader = GetDBAccess().ExecuteReader(String.Format(SQL_GET_COMPANY_CONTACTINFO, _oUser.prwu_BBID, _oUser.peli_PersonID), CommandBehavior.CloseConnection);
            try
            {
                if (oReader.Read() == true)
                {
                    if (oReader[0] != null)
                        sDefaultPhone = oReader[0].ToString();
                    if (oReader[1] != null)
                        sDefaultFax = oReader[1].ToString();
                    if (oReader[2] != null)
                        sAddress1 = oReader[2].ToString();
                    if (oReader[3] != null)
                        sAddress2 = oReader[3].ToString();
                    if (oReader[4] != null)
                        sAddress3 = oReader[4].ToString();
                    if (oReader[5] != null)
                        sCity = oReader[5].ToString();
                    if (oReader[6] != null)
                        sStateAbbr = oReader[6].ToString();
                    if (oReader[7] != null)
                        sPostCode = oReader[7].ToString();

                    if (sCity != null)
                        sCSZ = sCity + ", " + sStateAbbr + " " + sPostCode;
                }
            }
            finally
            {
                if (oReader != null)
                    oReader.Close();
            }

            // Create a PRSSContact record
            ArrayList oParameters = new ArrayList();

            GetObjectMgr().AddAuditTrailParametersForInsert(oParameters, "prssc");

            oParameters.Add(new ObjectParameter("prssc_SSFileId", iSSFileId));
            oParameters.Add(new ObjectParameter("prssc_CompanyId", _oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("prssc_PersonId", _oUser.peli_PersonID));
            oParameters.Add(new ObjectParameter("prssc_ContactAttn", sContactAttn));
            oParameters.Add(new ObjectParameter("prssc_IsPrimary", sIsPrimary));
            oParameters.Add(new ObjectParameter("prssc_Address1", sAddress1));
            oParameters.Add(new ObjectParameter("prssc_Address2", sAddress2));
            oParameters.Add(new ObjectParameter("prssc_Address3", sAddress3));
            oParameters.Add(new ObjectParameter("prssc_CityStateZip", sCSZ));
            oParameters.Add(new ObjectParameter("prssc_Telephone", sDefaultPhone));
            oParameters.Add(new ObjectParameter("prssc_Fax", sDefaultFax));
            oParameters.Add(new ObjectParameter("prssc_Email", _oUser.Email));

            oParameters.Add(new ObjectParameter("prssc_SSContactId", GetObjectMgr().GetRecordID("PRSSContact", oTran)));

            string szSQL = GetObjectMgr().FormatSQL(SQL_INSERT_PRSSCONTACT, oParameters);
            GetObjectMgr().ExecuteInsert("PRSSContact", szSQL, oParameters, oTran);
        }

        protected void insertSSContact(int iSSFileId,
                                       string sAddress1,
                                       string sAddress2,
                                       string sAddress3,
                                       string sCity,
                                       string sStateAbbr,
                                       string sPostCode,
                                       string sDefaultPhone,
                                       string sDefaultFax,
                                       string sDefaultEmai,
                                       IDbTransaction oTran)
        {
            IDataReader oReader = null;

            string sContactAttn = null;
            string sCSZ = null;
            string sIsPrimary = "Y";

            oReader = GetDBAccess().ExecuteReader(String.Format(SQL_GET_PERSON_FORMATTED_NAME, _oUser.peli_PersonID), CommandBehavior.CloseConnection);
            try
            {
                if(oReader.Read())
                    sContactAttn = oReader[0].ToString();
                else
                    sContactAttn = "";
            }
            finally
            {
                if (oReader != null)
                    oReader.Close();
            }

            if (sCity != null)
            {
                sCSZ = sCity + ", " + sStateAbbr + " " + sPostCode;
            }

            // Create a PRSSContact record
            ArrayList oParameters = new ArrayList();

            GetObjectMgr().AddAuditTrailParametersForInsert(oParameters, "prssc");
            oParameters.Add(new ObjectParameter("prssc_SSFileId", iSSFileId));
            oParameters.Add(new ObjectParameter("prssc_CompanyId", _oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("prssc_PersonId", _oUser.peli_PersonID));
            oParameters.Add(new ObjectParameter("prssc_ContactAttn", GetObjectMgr().GetStringForParamter(sContactAttn)));
            oParameters.Add(new ObjectParameter("prssc_IsPrimary", sIsPrimary));
            oParameters.Add(new ObjectParameter("prssc_Address1", GetObjectMgr().GetStringForParamter(sAddress1)));
            oParameters.Add(new ObjectParameter("prssc_Address2", GetObjectMgr().GetStringForParamter(sAddress2)));
            oParameters.Add(new ObjectParameter("prssc_Address3", GetObjectMgr().GetStringForParamter(sAddress3)));
            oParameters.Add(new ObjectParameter("prssc_CityStateZip", GetObjectMgr().GetStringForParamter(sCSZ)));
            oParameters.Add(new ObjectParameter("prssc_Telephone", GetObjectMgr().GetStringForParamter(sDefaultPhone)));
            oParameters.Add(new ObjectParameter("prssc_Fax", GetObjectMgr().GetStringForParamter(sDefaultFax)));
            oParameters.Add(new ObjectParameter("prssc_Email", GetObjectMgr().GetStringForParamter(sDefaultEmai)));

            oParameters.Add(new ObjectParameter("prssc_SSContactId", GetObjectMgr().GetRecordID("PRSSContact", oTran)));

            string szSQL = GetObjectMgr().FormatSQL(SQL_INSERT_PRSSCONTACT, oParameters);
            GetObjectMgr().ExecuteInsert("PRSSContact", szSQL, oParameters, oTran);
        }

        /// <summary>
        /// Notifies a SS User that a new file was opened (overloaded).
        /// </summary>
        /// <param name="iFileID"></param>
        /// <param name="iUserID"></param>
        /// <param name="emailTo"></param>
        /// <param name="subject"></param>
        /// <param name="oTran"></param>
        protected void NotifyUser(int iFileID, int iUserID, string emailTo, string subject, IDbTransaction oTran)
        {
            string szEmail = String.IsNullOrEmpty(emailTo) ? GetObjectMgr().GetPRCoUserEmail(iUserID, oTran) : emailTo;

            string szSubject = Utilities.GetConfigValue("SpecialServicesNotifyNewFileEmailSubject", "New Special Services File Created via BBOS");
            StringBuilder szBody = new StringBuilder("Special services file ID " + iFileID.ToString() + " was created via BBOS.");
            
            //Defect 6973 - emails via stored proc
            GetObjectMgr().SendEmail_Text(szEmail, szSubject, szBody.ToString(), 
                    "SpecialServicesBase.cs",
                    oTran);

            if ((Session["RespondentCompanyID"] != null) &&
                (((string)Session["RespondentCompanyID"]) == "-1"))
            {
                CompanySubmission oCompany = ((CompanySubmission)Session["SelectCompanyManualCompany"]);

                szBody.Append(Environment.NewLine + Environment.NewLine);
                szBody.Append("Manually Specified Company" + Environment.NewLine);
                szBody.Append("==========================" + Environment.NewLine);

                AppendText(szBody, string.Empty, oCompany.CompanyName);

                if (oCompany.Addresses.Count == 1)
                {
                    szBody.Append(Environment.NewLine);
                    AppendText(szBody, string.Empty, oCompany.Addresses[0].Address1);
                    AppendText(szBody, string.Empty, oCompany.Addresses[0].Address2);
                    AppendText(szBody, string.Empty, oCompany.Addresses[0].Address3);
                    AppendText(szBody, string.Empty, oCompany.Addresses[0].Address4);

                    szBody.Append(oCompany.Addresses[0].City);
                    szBody.Append(", ");
                    szBody.Append(GetObjectMgr().GetStateAbbr(oCompany.Addresses[0].StateID, oTran));
                    szBody.Append(" ");
                    szBody.Append(oCompany.Addresses[0].PostalCode);
                    szBody.Append(Environment.NewLine);

                    AppendText(szBody, string.Empty, GetObjectMgr().GetCountryName(oCompany.Addresses[0].CountryID, oTran));
                }

                szBody.Append(Environment.NewLine);

                foreach (Person person in oCompany.Personnel)
                {
                    AppendText(szBody, "Contact: ", person.LastName);
                }

                foreach (Phone phone in oCompany.Phones)
                {
                    string label = GetReferenceValue("Phon_TypeCompany", phone.Type);

                    string number = string.Empty;
                    if (!string.IsNullOrEmpty(phone.AreaCode))
                    {
                        number = phone.AreaCode + " ";
                    }

                    if (!string.IsNullOrEmpty(phone.Number))
                    {
                        number += phone.Number;
                    }

                    AppendText(szBody, label + ": ", number);
                }

                foreach (InternetAddress email in oCompany.Emails)
                {
                    AppendText(szBody, "Email: ", email.Address);
                }

            }

            GetObjectMgr().CreateTask(iUserID,
                                      "Pending",
                                      szBody.ToString(),
                                      Utilities.GetConfigValue("SpecialServicesFileCategory", "Special Services"),
                                      Utilities.GetConfigValue("SpecialServicesFileSubcategory", ""),
                                      _oUser.prwu_BBID,
                                      _oUser.peli_PersonID,
                                      iFileID,
                                      "ToDo",
                                      subject,
                                      oTran);

        }

        protected void NotifyContact(string szEmail, string szCulture)
        {
            //Defect 6871 - When a user places a collection online we would like them to get an automated email
            string szSubject = null;
            string szEmailBody = null;

            if(szCulture == SPANISH_CULTURE)
                szSubject = Utilities.GetConfigValue("SpecialServicesNotifyContactEmailSubject_Spanish", "Gracias por enviar su colección - No responda");
            else
                szSubject = Utilities.GetConfigValue("SpecialServicesNotifyContactEmailSubject", "Thank you for submitting your collection - Do Not Reply");

            
            using (StreamReader srEmail = new StreamReader(Server.MapPath(UIUtils.GetTemplateURL("SpecialServicesCollectionNotification.htm"))))
            {
                szEmailBody = srEmail.ReadToEnd();
            }

            string email = GetObjectMgr().GetFormattedEmail(0, 0, 0, szSubject, szEmailBody.ToString(), szCulture, null);

            //Send email via SQL server method
            GeneralDataMgr oMgr = new GeneralDataMgr(LoggerFactory.GetLogger(), null);
            oMgr.SendEmail(szEmail,
                            EmailUtils.GetFromAddress(),
                            szSubject,
                            email,
                            true,
                            null,
                            "SpecialServicesBase.cs",
                            null);
        }

        protected void NotifyCourtesyContactAllParties(string szClaimantCompanyName, string szContactName, string szContactEmail, List<CourtesyContactInvoice> invoices, string szCulture)
        {
            //Defect 7258 - When a user places a courtesy contact, send them an automated email
            string szSubject = null;
            string szSubjectClean = null;
            string szEmailBody = null;

            if (szCulture == SPANISH_CULTURE)
            {
                szSubject = Utilities.GetConfigValue("SpecialServicesNotifyCourtesyContactEmailSubject_Spanish", "Contacto de cortes&iacute;a sobre facturas vencidas");
                szSubjectClean = Utilities.GetConfigValue("SpecialServicesNotifyCourtesyContactEmailSubject_Spanish", "Contacto de cortesía sobre facturas vencidas");
            }
            else
            {
                szSubject = Utilities.GetConfigValue("SpecialServicesNotifyCourtesyContactEmailSubject_English", "Courtesy Contact on Past due invoice(s)");
                szSubjectClean = szSubject;
            }

            using (StreamReader srEmail = new StreamReader(Server.MapPath(UIUtils.GetTemplateURL("SpecialServicesCourtesyContactNotification_Top.htm"))))
            {
                szEmailBody = srEmail.ReadToEnd();
            }
            using (StreamReader srEmail = new StreamReader(Server.MapPath(UIUtils.GetTemplateURL("SpecialServicesCourtesyContactNotification_Bottom.htm"))))
            {
                szEmailBody += srEmail.ReadToEnd();
            }

            szEmailBody = szEmailBody.Replace("{0}", szContactName);
            szEmailBody = szEmailBody.Replace("{1}", szClaimantCompanyName);
            
            string szInvoice = "";
            string szInvoiceDates = "";
            foreach(CourtesyContactInvoice invoice in invoices)
            {
                if (invoice == null)
                    continue;

                szInvoice += invoice.invoicenum + ", ";
                szInvoiceDates += invoice.invoicedate.ToShortDateString() + ", ";
            }
            if (szInvoice.EndsWith(", "))
                szInvoice = szInvoice.Substring(0, szInvoice.Length - 2);
            if (szInvoiceDates.EndsWith(", "))
                szInvoiceDates = szInvoiceDates.Substring(0, szInvoiceDates.Length - 2);

            szEmailBody = szEmailBody.Replace("{2}", szInvoice);
            szEmailBody = szEmailBody.Replace("{3}", szInvoiceDates);

            string email = GetObjectMgr().GetFormattedEmail(0, 0, 0, szSubject, szEmailBody.ToString(), szCulture, null);

            szContactEmail += "; " + _oUser.Email;

            //Send email via SQL server method
            GeneralDataMgr oMgr = new GeneralDataMgr(LoggerFactory.GetLogger(), null);
            oMgr.SendEmail(szContactEmail,
                            "tradingassist@bluebook.com",
                            szSubjectClean,
                            email,
                            true,
                            null,
                            "SpecialServicesBase.cs",
                            null);
        }

        protected void NotifyCourtesyContactPreClaimant(string szClaimantCompanyName, string szCulture)
        {
            //Defect 7258 - When a user places a courtesy contact, send them an automated email
            string szSubject = null;
            string szSubjectClean = null;
            string szEmailBody = null;

            if (szCulture == SPANISH_CULTURE)
            {
                szSubject = Utilities.GetConfigValue("SpecialServicesNotifyCourtesyContactEmailSubject_Spanish", "Contacto de cortes&iacute;a sobre facturas vencidas");
                szSubjectClean = Utilities.GetConfigValue("SpecialServicesNotifyCourtesyContactEmailSubject_Spanish", "Contacto de cortesía sobre facturas vencidas");
            }
            else
            {
                szSubject = Utilities.GetConfigValue("SpecialServicesNotifyCourtesyContactEmailSubject_English", "Courtesy Contact on Past due invoice(s)");
                szSubjectClean = szSubject;
            }

            using (StreamReader srEmail = new StreamReader(Server.MapPath(UIUtils.GetTemplateURL("SpecialServicesCourtesyContactPreClaimantNotification.htm"))))
            {
                szEmailBody = srEmail.ReadToEnd();
            }

            szEmailBody = szEmailBody.Replace("{0}", _oUser.FirstName);
            szEmailBody = szEmailBody.Replace("{1}", szClaimantCompanyName);

            string email = GetObjectMgr().GetFormattedEmail(0, 0, 0, szSubject, szEmailBody.ToString(), szCulture, null);

            //Send email via SQL server method
            GeneralDataMgr oMgr = new GeneralDataMgr(LoggerFactory.GetLogger(), null);
            oMgr.SendEmail(_oUser.Email,
                            "tradingassist@bluebook.com",
                            szSubjectClean,
                            email,
                            true,
                            null,
                            "SpecialServicesBase.cs",
                            null);
        }

        protected void AppendText(StringBuilder sbText, string szLabel, string szValue)
        {
            if (!string.IsNullOrEmpty(szValue))
            {
                sbText.Append(szLabel);
                sbText.Append(szValue);
                sbText.Append(Environment.NewLine);
            }
        }
    }
}