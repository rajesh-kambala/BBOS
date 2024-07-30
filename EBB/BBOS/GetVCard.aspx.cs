/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: GetVCard
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Text;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page generates a VCard file for the specified
    /// company and person and streams it to the client as
    /// an attachment with the appropriate MIME type.
    /// </summary>
    public partial class GetVCard : PageBase
    {
        private StringBuilder _sbVCard = new StringBuilder();
        private bool isLocalSource = false;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            int iCompanyID = Convert.ToInt32(GetRequestParameter("CompanyID"));
            int iPersonID = Convert.ToInt32(GetRequestParameter("PersonID"));

            _sbVCard.Append("BEGIN:VCARD" + Environment.NewLine);
            _sbVCard.Append("VERSION:2.1" + Environment.NewLine);

            // Save off the Person's name so we can use it for the
            // VCard filename.
            string szName = AddPersonToVCard(iCompanyID, iPersonID);
            AddAddressVCard(iCompanyID);
            AddContactInfoToVCard(iCompanyID, iPersonID);

            string companyDetailsURL = GetURLProtocol() +
                                       Request.ServerVariables["SERVER_NAME"] +
                                       PageControlBaseCommon.GetVirtualPath() +
                                       string.Format(PageConstants.COMPANY_DETAILS_SUMMARY, iCompanyID).Replace("=", "=3D");

            // Add a comment that says who generated this
            // VCard and when.
            _sbVCard.Append("NOTE;ENCODING=QUOTED-PRINTABLE:");
            _sbVCard.Append(companyDetailsURL);
            _sbVCard.Append("=0D=0A");
            _sbVCard.Append("=0D=0A");
            _sbVCard.Append(string.Format(Resources.Global.VCardComment,
                                          GetCompanyName(),
                                          GetApplicationName(),
                                          DateTime.Now.ToString()) + Environment.NewLine);

            _sbVCard.Append("END:VCARD");

            Response.ClearContent();
            Response.ClearHeaders();

            Response.AddHeader("Content-Disposition", "attachment; filename=\"" + szName + ".vcf\"");
            Response.ContentType = "text/x-vCard";

            Response.Write(_sbVCard.ToString());
        }

        protected const string SQL_SELECT_VCARD1 =
               @"SELECT comp_PRCorrTradestyle, 
                        dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickname1, pers_Suffix) As PersonName, 
                        dbo.ufn_FormatPerson2(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickname1, pers_Suffix, 1) As PersonName2, 
                        peli_PRTitle, RTRIM(pers_FirstName) as pers_FirstName, RTRIM(pers_LastName) as pers_LastName, RTRIM(Pers_MiddleName) as Pers_MiddleName, 
                        RTRIM(Pers_Suffix) as Pers_Suffix, comp_PRLocalSource
                  FROM Company WITH (NOLOCK) 
                       INNER JOIN Person_Link WITH (NOLOCK) ON comp_CompanyID = peli_CompanyID 
                       INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID 
                 WHERE comp_CompanyID = {0} 
                       AND pers_PersonID = {1} 
                       AND peli_PRStatus IN ('1', '2')
                       AND comp_PRListingStatus IN ('L', 'H', 'N3', 'N5', 'N6', 'LUV') 
                       AND peli_PREBBPublish = 'Y'";

        /// <summary>
        /// Adds the person and company data to the
        /// vCard
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="iPersonID"></param>
        protected string AddPersonToVCard(int iCompanyID, int iPersonID)
        {
            string szName = null;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("comp_CompanyID", iCompanyID));
            oParameters.Add(new ObjectParameter("pers_PersonID", iPersonID));

            string szSQL = GetObjectMgr().FormatSQL(SQL_SELECT_VCARD1, oParameters);

            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (!oReader.Read())
                {
                    throw new ObjectNotFoundException("Person not found.");
                }
                szName = oReader.GetString(1);

                StringBuilder sbName = new StringBuilder();
                sbName.Append(oReader.GetString(5) + ";");  // Last Name
                sbName.Append(oReader.GetString(4) + ";");  // First Name
                if (oReader[6] != DBNull.Value)             // Middle Name
                {
                    sbName.Append(oReader.GetString(6) + ";");
                }
                else
                {
                    sbName.Append(";");
                }
                sbName.Append(";");  // Additional Name

                if (oReader[7] != DBNull.Value)             // Suffix
                {
                    string szTemp = oReader.GetString(7);
                    if (szTemp.StartsWith(", "))
                    {
                        szTemp = szTemp.Substring(2);
                    }
                    sbName.Append(szTemp + ";");
                }

                _sbVCard.Append("N:" + sbName.ToString() + Environment.NewLine);
                //_sbVCard.Append("N:" + oReader.GetString(2) + Environment.NewLine);
                _sbVCard.Append("FN:" + oReader.GetString(1) + Environment.NewLine);
                _sbVCard.Append("ORG:" + oReader.GetString(0) + Environment.NewLine);


                if (!string.IsNullOrEmpty(GetDBAccess().GetString(oReader, 3)))
                {
                    _sbVCard.Append("TITLE:" + oReader.GetString(3) + Environment.NewLine);
                }

                if (oReader[8] != DBNull.Value)
                {
                    isLocalSource = true;
                }

                return szName;
            }
        }

        protected const string SQL_VCARD_ADDRESS =
            @"SELECT RTRIM(addr_Address1), RTRIM(addr_Address2), prci_City, ISNULL(prst_Abbreviation, prst_State) as State, prcn_Country, addr_PostCode 
                FROM Address_Link WITH (NOLOCK)
                     INNER JOIN Address ON adli_AddressID = addr_AddressID 
                     INNER JOIN vPRLocation ON addr_PRCityID = prci_CityID 
               WHERE addr_AddressID IN (SELECT TOP 1 adli_AddressID 
                                          FROM Address_Link WITH (NOLOCK)
                                               INNER JOIN Address WITH (NOLOCK) ON adli_AddressID = addr_AddressID 
                                         WHERE adli_CompanyID = {0} 
                                           AND addr_PRPublish = 'Y' 
                                      ORDER BY dbo.ufn_GetVCardAddressListSeq(adli_type), addr_AddressID DESC);";

        /// <summary>
        /// Address the company address to the VCard.  The address types
        /// are looked at in a particular order.  See ufn_GetVCardAddressListSeq
        /// for more details.
        /// </summary>
        /// <param name="iCompanyID"></param>
        protected void AddAddressVCard(int iCompanyID)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("adli_CompanyID", iCompanyID));

            string szSQL = GetObjectMgr().FormatSQL(SQL_VCARD_ADDRESS, oParameters);

            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                {

                    _sbVCard.Append("ADR;WORK;ENCODING=QUOTED-PRINTABLE:;;");
                    if (oReader[0] != DBNull.Value)
                    {
                        _sbVCard.Append(oReader.GetString(0));
                    }

                    if (oReader[1] != DBNull.Value)
                    {
                        _sbVCard.Append("=0D=0A" + oReader.GetString(1));
                    }
                    _sbVCard.Append(";");
                    _sbVCard.Append(oReader.GetString(2) + ";");
                    if (oReader[3] != DBNull.Value)
                    { 
                        _sbVCard.Append(oReader.GetString(3) + ";");
                    }

                    if (oReader[5] != DBNull.Value)
                    {
                        _sbVCard.Append(oReader.GetString(5) + ";");
                    }
                    _sbVCard.Append(";");

                    _sbVCard.Append(oReader.GetString(4) + Environment.NewLine);
                }
            }
        }

        // {0} = CompanyID
        // {1} = PersonID
        protected const string SQL_VCARD_EMAIL =
            @"SELECT RTRIM(Emai_EmailAddress) AS Emai_EmailAddress 
                FROM vPersonEmail WITH (NOLOCK) 
               WHERE ELink_RecordID = {1} 
                 AND emai_CompanyID = {0}
                 AND ELink_Type = 'E' 
                 AND emai_PRPreferredPublished='Y'";

        protected const string SQL_VCARD_WEB =
            @"SELECT RTRIM(emai_PRWebAddress) AS emai_PRWebAddress 
                FROM vCompanyEmail WITH (NOLOCK) 
               WHERE ELink_RecordID = {0} 
                 AND ELink_Type = 'W' 
                 AND emai_PRPublish='Y'";

        /// <summary>
        /// Adds the person's contact info to the VCard.
        /// EMail, Web, Phone, and Fax.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="iPersonID"></param>
        protected void AddContactInfoToVCard(int iCompanyID, int iPersonID)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", iCompanyID));
            oParameters.Add(new ObjectParameter("PersonID", iPersonID));

            // Query for the Person's Email address.
            string szSQL = GetObjectMgr().FormatSQL(SQL_VCARD_EMAIL, oParameters);
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.Default, null))
            {
                if (oReader.Read())
                {
                    if (oReader.GetString(0) != null)
                    {
                        _sbVCard.Append("EMAIL;PREF;INTERNET:" + oReader.GetString(0) + Environment.NewLine);
                    }
                }
            }

            // Query for the Company Web Site
            szSQL = GetObjectMgr().FormatSQL(SQL_VCARD_WEB, oParameters);
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.Default, null))
            {
                if (oReader.Read())
                {
                    if (oReader.GetString(0) != null)
                    {
                        _sbVCard.Append("URL;WORK:" + oReader.GetString(0) + Environment.NewLine);
                    }
                }
            }

            // Go get the phone
            string szPhone = GetPhone(iCompanyID, iPersonID, "'P','PF','S','TP','TF'", true);
            string szPersonPhone = GetPersonPhone(iCompanyID, iPersonID, "'P','PF','S','TP','TF'", false);

            if (!string.IsNullOrEmpty(szPhone))
            {
                _sbVCard.Append("TEL;WORK;VOICE:" + szPhone + Environment.NewLine); //Business1 in vCard
            }

            if (!string.IsNullOrEmpty(szPersonPhone) && szPersonPhone != szPhone)
            {
                _sbVCard.Append("TEL;WORK;VOICE:" + szPersonPhone + Environment.NewLine); //Business2 in vCard
            }

            // Go get the fax
            if (!isLocalSource)
            {
                string szFax = GetPhone(iCompanyID, iPersonID, "'F', 'PF', 'SF'", true);
                if (szFax != null)
                {
                    _sbVCard.Append("TEL;WORK;FAX:" + szFax + Environment.NewLine);
                }
            }

            // Go get the cell
            string szCell = GetPhone(iCompanyID, iPersonID, "'C'", false);
            if (szCell != null)
            {
                _sbVCard.Append("TEL;CELL:" + szCell + Environment.NewLine);
            }
        }

        protected const string SQL_VCARD_PHONE = "SELECT dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension) FROM {0} WITH (NOLOCK) WHERE PLink_RecordID ={1} AND phon_PRPublish='Y' ";
        protected const string SQL_VCARD_PHONE_PERSON = "  AND phon_CompanyID ={2}";
        protected const string SQL_VCARD_PHONE_TYPE = " AND PLink_Type IN ({0})";
        protected const string SQL_VCARD_PHONE_PREFERRED_PUBLISHED = " AND phon_PRPreferredPublished='Y'";

        /// <summary>
        /// Queries for the specified phone type associated with the person and
        /// company.  If nothing is found, then queries for the same phone types
        /// that are only associated with the company.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="iPersonID"></param>
        /// <param name="szType">Used in an IN clause: "'P', 'PF'"</param>
        /// <returns></returns>
        protected string GetPhone(int iCompanyID, int iPersonID, string szType, bool preferredPublished)
        {
            string szPhone = GetPersonPhone(iCompanyID, iPersonID, szType, preferredPublished);
            if (!string.IsNullOrEmpty(szPhone))
                return szPhone;
            else
                return GetCompanyPhone(iCompanyID, iPersonID, szType, preferredPublished);
        }

        protected string GetPersonPhone(int iCompanyID, int iPersonID, string szType, bool preferredPublished)
        {
            ArrayList oParameters = new ArrayList();

            string szSQL = string.Format(SQL_VCARD_PHONE + SQL_VCARD_PHONE_PERSON, "vPRPersonPhone", iPersonID, iCompanyID) + string.Format(SQL_VCARD_PHONE_TYPE, szType);
            if (preferredPublished)
            {
                szSQL += SQL_VCARD_PHONE_PREFERRED_PUBLISHED;
            }

            szSQL = GetObjectMgr().FormatSQL(szSQL, oParameters);

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.Default, null);
            try
            {
                if (oReader.Read())
                {
                    if (oReader.GetString(0) != null)
                    {
                        return oReader.GetString(0);
                    }
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            return null;
        }

        protected string GetCompanyPhone(int iCompanyID, int iPersonID, string szType, bool preferredPublished)
        {
            ArrayList oParameters = new ArrayList();

            string szSQL = string.Format(SQL_VCARD_PHONE, "vPRCompanyPhone", iCompanyID) + string.Format(SQL_VCARD_PHONE_TYPE, szType);
            if (preferredPublished)
            {
                szSQL += SQL_VCARD_PHONE_PREFERRED_PUBLISHED;
            }

            szSQL = GetObjectMgr().FormatSQL(szSQL, oParameters);

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.Default, null);
            try
            {
                if (oReader.Read())
                {
                    if (oReader.GetString(0) != null)
                    {
                        return oReader.GetString(0);
                    }
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            return null;
        }

        /// <summary>
        /// Though a company ID is a required parameter, this action
        /// is more associated with a Person so make sure the Person
        /// ID is logged.
        /// </summary>
        /// <returns></returns>
        protected override string GetWebAuditTrailAssociatedID()
        {
            return GetRequestParameter("PersonID");
        }

        /// <summary>
        /// Though a company ID is a required parameter, this action
        /// is more associated with a Person so make sure the Person
        /// Type is logged.
        /// </summary>
        /// <returns></returns>
        protected override string GetWebAuditTrailAssociatedType()
        {
            return "P";
        }

        /// <summary>
        /// Only members level 4 or greater can access
        /// this page.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.PersonvCard).HasPrivilege;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        public override void PreparePageFooter()
        {
            // Do nothing
        }
    }
}

