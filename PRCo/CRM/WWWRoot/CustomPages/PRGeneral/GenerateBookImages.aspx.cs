/***********************************************************************
 Copyright Produce Reporter Company 2009-2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: GeneraetBookImages.aspx
 Description:	

 Notes: 

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web.UI.WebControls;

namespace PRCo.BBS.CRM
{

    /// <summary>
    /// This page allows the user to select which book image files to create
    /// and then, well, creates them.  :)
    /// </summary>
    public partial class GenerateBookImages : PageBase {

        protected string sSID = string.Empty;
        protected int _iUserID;
        protected const char DELIMITER = '\t';

        override protected void Page_Load(object sender, EventArgs e) {

            Server.ScriptTimeout = 60 * 180;
            base.Page_Load(sender, e);

            if (!IsPostBack) {

                hidUserID.Text = Request["user_userid"];
                hidSID.Text = Request.Params.Get("SID");

                BindLookupValues();
                PopulateRemoveNumerals();
            }

            _iUserID = Int32.Parse(hidUserID.Text);
            sSID = hidSID.Text;


            imgbtnGenerate.ImageUrl = "/" + _szAppName + "/img/Buttons/continue.gif";

            imgbtnRemoveInterimNumerals.ImageUrl = "/" + _szAppName + "/img/Buttons/cancel.gif";
            trRemoveInterimNumerals.Visible = IsAuthorizedForRatingNumeralRemoval();

            lblMsg.Text = string.Empty;
            lblOutput.Text = string.Empty;
        }

        protected const string SQL_SELECT_BOOKIMAGE_OPTIONS =
            @"SELECT prbif_FileName, prbif_Description 
                FROM PRBookImageFile 
            ORDER BY prbif_Order;";
          
        /// <summary>
        /// Build our checkbox list of book image options.
        /// </summary>
        protected void BindLookupValues() {

            GetDBConnnection();
            SqlCommand sqlCompanies = new SqlCommand(SQL_SELECT_BOOKIMAGE_OPTIONS, GetDBConnnection());

            cblBookImages.DataTextField = "prbif_Description";
            cblBookImages.DataValueField = "prbif_FileName";
            cblBookImages.DataSource = sqlCompanies.ExecuteReader(CommandBehavior.Default);
            cblBookImages.DataBind();
            CloseDBConnection();
        }


        protected const string SQL_SELECT_BOOKIMAGE_FILES =
            "SELECT prbif_FileName, prbif_Criteria, prbif_FileType " +
              "FROM PRBookImageFile " +
             "WHERE prbif_FileName  IN ({0}) " +
          "ORDER BY prbif_Order;";

        
        /// <summary>
        /// Generates the mainbook image tab delimited files.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnGenerateBookImages(object sender, EventArgs e) {
            DateTime dtStart = DateTime.Now;
        
            StringBuilder sbWhereClause = new StringBuilder();

            // Build a WHERE clause containing the selected
            // book image files.
            foreach (ListItem oItem in cblBookImages.Items) {
                if (oItem.Selected) {
                    if (sbWhereClause.Length > 0) {
                        sbWhereClause.Append(",");
                    }

                    sbWhereClause.Append("'" + oItem.Value + "'");
                }
            }

            try {
                GetDBConnnection();

                List<BookImageFile> lBookImageFiles = new List<BookImageFile>();

                // Query custom_captions for the selected book image files to 
                // get the necessary processing values.  Put them into a list
                // of BookImageFile objects because we cannot have multiple
                // readers open at the same time.
                SqlCommand sqlBookImageFiles = new SqlCommand(string.Format(SQL_SELECT_BOOKIMAGE_FILES, sbWhereClause.ToString()), GetDBConnnection());
                using (IDataReader drBookImages = sqlBookImageFiles.ExecuteReader(CommandBehavior.Default))
                {
                    while (drBookImages.Read()) {
                        BookImageFile oBookImageFile = new BookImageFile();
                        oBookImageFile.FileName = drBookImages.GetString(0);
                        oBookImageFile.WhereClause = drBookImages.GetString(1);
                        oBookImageFile.FileType = drBookImages.GetString(2);
                        
                        lBookImageFiles.Add(oBookImageFile);
                    }
                }

                //int iRecordCount = 0;

                // Iterate through the selected book image files and
                // generate them.
                foreach(BookImageFile oBookImageFile in lBookImageFiles) {
                    switch (oBookImageFile.FileType) {
                        case "BI":
                            GenerateBookImageFile(oBookImageFile.WhereClause, oBookImageFile.FileName);
                            break;
                        case "NI":
                            GenerateNameIndexFile(oBookImageFile.WhereClause, oBookImageFile.FileName);
                            break;
                        case "PI":
                            GenerateProductIndexFile(oBookImageFile.WhereClause, oBookImageFile.FileName);
                            break;
                    }
                }
                
                lblMsg.Text = "Processed " + lBookImageFiles.Count.ToString() + " Files.  They are saved to the " + GetConfigValue("BookImagesFolder", @"C:\Temp\") + " folder.";
                lblOutput.Text = DateTime.Now.Subtract(dtStart).ToString();
                
            } catch (Exception eX) {
                lblMsg.Text = eX.Message;
                lblOutput.Text = eX.StackTrace;
            } finally {
                CloseDBConnection();
            }

            PopulateRemoveNumerals();
        }
        
        
        private const string SQL_GET_LISTINGS =
            @"SELECT comp_PRIndustryType, prcn_Country, prst_State,  prst_Abbreviation, prci_City, comp_CompanyID, 
                     comp_PRLogo, 
                     dbo.ufn_GetListingTradestyle(comp_PRBookTradestyle, comp_PRPublishLogo, char(9), NULL) As TradeName, 
	                 dbo.ufn_GetBookImageListingBody(comp_CompanyID) As ListingBody, 
                     dbo.ufn_GetTradingMember(CASE WHEN comp_PRTMFMAward = 'Y' THEN DATEPART(YEAR, comp_PRTMFMAwardDate) ELSE NULL END, comp_PRIndustryType) As TradingMembership, 
                     LTRIM(dbo.ufn_GetListingClassVolCommBlock(comp_CompanyID, 3)) as ClassVolCommBlock, 
                     dbo.ufn_GetListingRatingBlock(comp_CompanyID, comp_PRIndustryType, 2, char(9)) As RatingBlock, 
                     comp_PRPublishLogo 
                FROM Company WITH (NOLOCK) 
                     INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
               WHERE comp_PRListingStatus = 'L' 
                 AND comp_PROnlineOnly IS NULL
                 {0} 
            ORDER BY prcn_BookOrder, prst_BookOrder , prci_City, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(comp_Name, '.', ''), ',', ''), '''', ''), ':', ''), ';', '')";
        
        
        /// <summary>
        /// Generates the Book Image tab delimited file
        /// </summary>
        /// <param name="szCriteria"></param>
        /// <param name="szFileName"></param>
        protected void GenerateBookImageFile(string szCriteria,
                                             string szFileName) {

            int iRecordCount = 0;

            string szBookImageFile = Path.Combine(GetConfigValue("BookImagesFolder", @"C:\Temp\"), szFileName);
            string szSQL = string.Format(SQL_GET_LISTINGS, szCriteria);
            
            StringBuilder sbBookImage = new StringBuilder();
        
            using (TextWriter twBookImageFile = new StreamWriter(szBookImageFile)) {
            
                SqlCommand sqlCompanies = new SqlCommand(szSQL, GetDBConnnection());
                sqlCompanies.CommandTimeout = 60 * 60;
                using (IDataReader drCompanies = sqlCompanies.ExecuteReader(CommandBehavior.Default))
                {
    

                    while (drCompanies.Read())
                    {
                        // Industry Type
                        sbBookImage.Append(drCompanies.GetString(0));
                        sbBookImage.Append(DELIMITER);

                        // Country
                        sbBookImage.Append(drCompanies.GetString(1).ToUpper());
                        sbBookImage.Append(DELIMITER);

                        // State

                        sbBookImage.Append(PrepareString(drCompanies[2]).ToUpper());
                        sbBookImage.Append(DELIMITER);

                        // State Abbreviation
                        sbBookImage.Append(PrepareString(drCompanies[3]).ToUpper());
                        sbBookImage.Append(DELIMITER);

                        // City
                        sbBookImage.Append(drCompanies.GetString(4).ToUpper());
                        sbBookImage.Append(DELIMITER);

                        // Some placeholder
                        sbBookImage.Append(DELIMITER);

                        // BB ID
                        sbBookImage.Append("BB # " + drCompanies.GetInt32(5).ToString());
                        sbBookImage.Append(DELIMITER);
                        
                        // Logo (6) & Publish Logo (12)
                        if (drCompanies[12] != DBNull.Value) {
                            // We know the logo image file ends with four character
                            // so just take the six characters before that
                            string szLogo = drCompanies.GetString(6);
                            sbBookImage.Append(szLogo.Substring(szLogo.Length-10, 6) + ".eps");
                        }
                        sbBookImage.Append(DELIMITER);

                        // Tradename
                        sbBookImage.Append(PadWithDelimiters(drCompanies.GetString(7), 3));
                        sbBookImage.Append(DELIMITER);

                        // Listing Body
                        sbBookImage.Append(PadWithDelimiters(PrepareString(drCompanies.GetString(8)), 159));
                        sbBookImage.Append(DELIMITER);
                        
                        if (drCompanies.GetString(0) == "S") {
                            // Trading Membership
                            sbBookImage.Append(DELIMITER);

                            // ClassVolComm 
                            sbBookImage.Append(PadWithDelimiters(drCompanies.GetString(10), 39)); //
                        } else {
                        
                            // Trading Membership
                            sbBookImage.Append(PrepareString(drCompanies[9]));
                            sbBookImage.Append(DELIMITER);
        
                            // ClassVolComm 
                            sbBookImage.Append(PadWithDelimiters(drCompanies.GetString(10), 15));
                            sbBookImage.Append(DELIMITER);

                            // Rating
                            // This field actually returns two fields: label and rating
                            // so if it's NULL, make sure we add a delimiter for the
                            // second field.
                            if (drCompanies[10] != DBNull.Value) {
                                sbBookImage.Append(drCompanies.GetString(11));
                            } else {
                                sbBookImage.Append(DELIMITER);
                            }                            
                        }            
            
                        twBookImageFile.WriteLine(sbBookImage.ToString());
                        sbBookImage.Length = 0;

                        iRecordCount++;
                    }
                }
            }

            UpdateBookImageCount(szFileName, iRecordCount);
        }

        protected const string SQL_GET_NAME_INDEX =
            @"SELECT CASE comp_PRTMFMAward WHEN 'Y' THEN 'BD' ELSE NULL END As TradingMember,  
                   dbo.ufn_ApplyListingLineBreaks(comp_PRBookTradestyle, CHAR(9)) As TradeName,  
                   comp_PRIndustryType,   
                   CityStateCountryShort, 
                   comp_Name 
              FROM Company WITH (NOLOCK)  
                   INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID  
             WHERE comp_CompanyID IN 
	            (SELECT comp_CompanyID 
	               FROM Company WITH (NOLOCK)  
	              WHERE comp_PRListingStatus = 'L' 
                    AND comp_PROnlineOnly IS NULL
                     {0} 
		            AND comp_PRType = 'H') 
                    OR comp_CompanyID IN 
	            (SELECT comp_CompanyID 
	              FROM Company WITH (NOLOCK)  
                       INNER JOIN (SELECT comp_CompanyID as HQID, comp_PRBookTradestyle As HQName FROM Company WITH (NOLOCK) WHERE comp_PRType = 'H' AND comp_PRListingStatus = 'L' AND comp_PROnlineOnly IS NULL {0} ) tblHQ ON comp_PRHQID = HQID 
	              WHERE comp_PRListingStatus = 'L'  
                    AND comp_PROnlineOnly IS NULL
                     {0} 
                    AND comp_PRType = 'B' 
                    AND comp_PRBookTradestyle != HQName) 
            ORDER BY REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(comp_Name, '.', ''), ',', ''), '''', ''), ':', ''), ';', '')";

        /// <summary>
        /// Generates the Name Index tab delimited file.
        /// </summary>
        /// <param name="szCriteria"></param>
        /// <param name="szFileName"></param>
        protected void GenerateNameIndexFile(string szCriteria,
                                             string szFileName) {

            int iRecordCount = 0;

            string szNameIndexFile = Path.Combine(GetConfigValue("BookImagesFolder", @"C:\Temp\"), szFileName);
            string szSQL = string.Format(SQL_GET_NAME_INDEX, szCriteria);

            StringBuilder sbNameIndex = new StringBuilder();

            using (TextWriter twNameIndexFile = new StreamWriter(szNameIndexFile)) {
            
                SqlCommand sqlCompanies = new SqlCommand(szSQL, GetDBConnnection());
                sqlCompanies.CommandTimeout = 60 * 60;
                using (IDataReader drCompanies = sqlCompanies.ExecuteReader(CommandBehavior.Default))
                {
                    while (drCompanies.Read())
                    {
                        string szIndustryType = drCompanies.GetString(2);
                    
                        // Trading Member Indicator
                        if (szIndustryType != "S") {
                            sbNameIndex.Append(PrepareString(drCompanies[0]));
                            sbNameIndex.Append(DELIMITER);
                        }
                        
                        // Tradename
                        sbNameIndex.Append(PadWithDelimiters(drCompanies.GetString(1), 3));
                        sbNameIndex.Append(DELIMITER);
                        
                        // Industry Type + Location
                        if (szIndustryType != "S") {
                            sbNameIndex.Append("(" + szIndustryType + ") ");
                        }
                        sbNameIndex.Append(drCompanies.GetString(3).ToUpper());
                        
                        twNameIndexFile.WriteLine(sbNameIndex.ToString());
                        sbNameIndex.Length = 0;

                        iRecordCount++;
                    }
                }
            }

            UpdateBookImageCount(szFileName, iRecordCount);
        }
        
        
        protected const string SQL_GET_PRODUCT_INDEX2 =
            @"SELECT prcl_Line1, prcl_Line2, prcl_Line3, prcl_Line4, 
                     dbo.ufn_ApplyListingLineBreaks(comp_PRBookTradestyle, CHAR(9)) As TradeName, 
                     CityStateCountryShort 
                FROM Company WITH (NOLOCK) 
                     INNER JOIN PRCompanyClassification WITH (NOLOCK) ON comp_CompanyID = prc2_CompanyId
                     INNER JOIN PRClassification WITH (NOLOCK) ON prc2_ClassificationId = prcl_ClassificationId 
                     INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
               WHERE comp_PRListingStatus = 'L' 
                 AND comp_PROnlineOnly IS NULL
                 {0} 
             ORDER BY prcl_Line1, prcl_Line2, prcl_Line3, prcl_Line4, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(comp_Name, '.', ''), ',', ''), '''', ''), ':', ''), ';', '')";

        protected const string SQL_GET_PRODUCT_INDEX =
            @"SELECT prcl_Line1, prcl_Line2, prcl_Line3, prcl_Line4, 
                    dbo.ufn_ApplyListingLineBreaks(comp_PRBookTradestyle, CHAR(9)) As TradeName, 
                    CityStateCountryShort,
		            Parenthetical
            FROM Company WITH (NOLOCK) 
                    INNER JOIN PRCompanyClassification WITH (NOLOCK) ON comp_CompanyID = prc2_CompanyId
                    INNER JOIN PRClassification WITH (NOLOCK) ON prc2_ClassificationId = prcl_ClassificationId 
                    INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
		            LEFT OUTER JOIN (SELECT prc2_CompanyID, '{1} ' as Parenthetical
		                               FROM PRCompanyClassification WITH (NOLOCK) 
						              WHERE prc2_ClassificationID = 1245) T1 ON comp_CompanyID = T1.prc2_CompanyId
            WHERE comp_PRListingStatus = 'L' 
                AND comp_PROnlineOnly IS NULL
                {0} 
            ORDER BY prcl_Line1, prcl_Line2, prcl_Line3, prcl_Line4, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(comp_Name, '.', ''), ',', ''), '''', ''), ':', ''), ';', '')";


        /// <summary>
        /// Generates the Product Index tab delimited file.
        /// </summary>
        /// <param name="szCriteria"></param>
        /// <param name="szFileName"></param>
        protected void GenerateProductIndexFile(string szCriteria, string szFileName) {

            int iRecordCount = 0;
            
            string szProductIndexFile = Path.Combine(GetConfigValue("BookImagesFolder", @"C:\Temp\"), szFileName);


            string szGovernmentText = GetConfigValue("BookImagesProductIndexGovernmentParenthetical", "(See Government & Reference Section)");

            string szSQL = string.Format(SQL_GET_PRODUCT_INDEX, szCriteria, szGovernmentText);

            StringBuilder sbProductIndex = new StringBuilder();

            using (TextWriter twProductIndexFile = new StreamWriter(szProductIndexFile)) {

                SqlCommand sqlCompanies = new SqlCommand(szSQL, GetDBConnnection());
                sqlCompanies.CommandTimeout = 60 * 60;
                using (IDataReader drCompanies = sqlCompanies.ExecuteReader(CommandBehavior.Default)) {
                    while (drCompanies.Read()) {
                    
                        // Product Name (i.e. classification)
                        sbProductIndex.Append(PrepareString(drCompanies[0]));
                        sbProductIndex.Append(DELIMITER);
                        sbProductIndex.Append(PrepareString(drCompanies[1]));
                        sbProductIndex.Append(DELIMITER);
                        sbProductIndex.Append(PrepareString(drCompanies[2]));
                        sbProductIndex.Append(DELIMITER);
                        sbProductIndex.Append(PrepareString(drCompanies[3]));
                        sbProductIndex.Append(DELIMITER);


                        // Tradename
                        sbProductIndex.Append(PadWithDelimiters(drCompanies.GetString(4), 3));
                        sbProductIndex.Append(DELIMITER);

                        // Location
                        sbProductIndex.Append(drCompanies.GetString(5).ToUpper());

                        // Parenthetical
                        sbProductIndex.Append(DELIMITER);
                        sbProductIndex.Append(PrepareString(drCompanies[6]));


                        twProductIndexFile.WriteLine(sbProductIndex.ToString());
                        sbProductIndex.Length = 0;

                        iRecordCount++;
                    }
                }
            }

            UpdateBookImageCount(szFileName, iRecordCount);
        }

        protected const string SQL_UPDATE_BOOK_IMAGE_COUNT =
               @"UPDATE PRBookImageFile 
                    SET prbif_CompanyCount = {0} 
                  WHERE prbif_FileName = '{1}'";

        /// <summary>
        /// Updates the book image record to indicate how many companies were
        /// included in the last generation of the file.
        /// </summary>
        /// <param name="szFileName"></param>
        /// <param name="iCount"></param>
        protected void UpdateBookImageCount(string szFileName, int iCount)
        {
            string szSQL = string.Format(SQL_UPDATE_BOOK_IMAGE_COUNT, iCount, szFileName);
            SqlCommand sqlUpdate = new SqlCommand(szSQL, GetDBConnnection());
            sqlUpdate.ExecuteNonQuery();
        }


        /// <summary>
        /// Helper method that prepares the string
        /// for Quark
        /// </summary>
        /// <param name="oValue"></param>
        /// <returns></returns>
        private string PrepareString(object oValue) {
            if (oValue == DBNull.Value) {
                return string.Empty;
            }
            
            string szValue = Convert.ToString(oValue);

            if (szValue.IndexOf('@') != -1) {
                szValue = szValue.Replace("@", @"@"); //previously was <\@> but changed on 8/24/2023 to just @ per Keith
            }

            return szValue.Trim();
        }

        StringBuilder _sbPad = null;
        /// <summary>
        /// Helper method that returns the specified
        /// value padded with enough delimters to 
        /// meet the required count.
        /// </summary>
        /// <param name="szValue"></param>
        /// <param name="iMaxCount"></param>
        /// <returns></returns>
        private string PadWithDelimiters(string szValue,
                                         int iMaxCount) {

                                         
            int iCount = GetDelimeterCount(szValue);
            
            if (iCount < iMaxCount) {
                if (_sbPad == null) {
                    _sbPad = new StringBuilder();
                }

                _sbPad.Length = 0;
                _sbPad.Append(szValue);
            
                while (iCount < iMaxCount) {
                    _sbPad.Append(DELIMITER);
                    iCount++;
                }
                
                return _sbPad.ToString();
            } else {
                return szValue;
            }                                         
        }                                        

        /// <summary>
        /// Helper method determines how many delimiters are
        /// already contained within the value.s
        /// </summary>
        /// <param name="szValue"></param>
        /// <returns></returns>
        private int GetDelimeterCount(string szValue) {
 
            int iCount = 0;
                       
            foreach (char curChar in szValue) {
                if (DELIMITER == curChar) {
                    iCount++;
                }
            }
            
            return iCount;
        }

        private SqlConnection _dbConn = null;

        /// <summary>
        /// Returns an open DB Connection
        /// </summary>
        /// <returns></returns>
        private SqlConnection GetDBConnnection() {
            if (_dbConn == null) {
                _dbConn = OpenDBConnection("GenerateBookImages");
            }

            return _dbConn;
        }

        protected void CloseDBConnection()
        {
            CloseDBConnection(_dbConn);
            _dbConn = null;
        }


        protected void btnRemoveInterimNumeralsClick(object sender, EventArgs e)
        {
            try {
                GetDBConnnection();

                SqlCommand cmdAutoRemoveNumerals = new SqlCommand("usp_AutoRemoveRatingNumerals", _dbConn);
                cmdAutoRemoveNumerals.CommandType = CommandType.StoredProcedure;
                cmdAutoRemoveNumerals.CommandTimeout = 300;
                cmdAutoRemoveNumerals.Parameters.AddWithValue("@UserId", _iUserID);
                cmdAutoRemoveNumerals.ExecuteNonQuery();
            }
            catch (Exception eX)
            {
                lblMsg.Text = eX.Message;
                lblOutput.Text = eX.StackTrace;
            }
            finally
            {
                CloseDBConnection();
            }

            PopulateRemoveNumerals();

            lblMsg.Text = "Successfully removed the interim rating numerals.";
        }

        protected bool IsAuthorizedForRatingNumeralRemoval() 
        {
            string logon = null;
            try
            {
                GetDBConnnection();

                SqlCommand cmdUser = new SqlCommand("SELECT RTRIM(user_logon) FROM users WHERE user_userid = @UserId", _dbConn);
                cmdUser.Parameters.AddWithValue("@UserId", _iUserID);
                logon = (string)cmdUser.ExecuteScalar();
            }
            finally
            {
                CloseDBConnection();
            }

            logon = logon.ToLower();
            if ((logon == "chw") ||
                (logon == "amm") ||
                (logon == "ncm") ||
                (logon == "bmz") ||
                (logon == "kws") ||
                (logon == "mde"))
            {
                return true;
            }

            return false;
        }

        protected void PopulateRemoveNumerals()
        {
            try
            {
                GetDBConnnection();
            
                SqlCommand cmd = new SqlCommand("SELECT dbo.ufn_GetCustomCaptionValue('AutoRemoveRatingNumerals', 'User', 'en-us')", _dbConn);
                litLastExecutedBy.Text = (string)cmd.ExecuteScalar();

                cmd = new SqlCommand("SELECT dbo.ufn_GetCustomCaptionValue('AutoRemoveRatingNumerals', 'Date', 'en-us')", _dbConn);
                litLastExecutionDate.Text = (string)cmd.ExecuteScalar();
            }
            finally
            {
                CloseDBConnection();
            }
        }

        private class BookImageFile {
            public string FileName;
            public string WhereClause;
            public string FileType;
        }        
    }
}
