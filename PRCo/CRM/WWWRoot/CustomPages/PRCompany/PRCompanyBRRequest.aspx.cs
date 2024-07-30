using System;
using System.Data.SqlClient;
using System.IO;

namespace PRCo.BBS.CRM.CustomPages.PRCompany
{
    public partial class PRCompanyBRRequest : PageBase
    {
        protected string UserID;
        protected string SID;

        override protected void Page_Load(object sender, EventArgs e)
        {

            base.Page_Load(sender, e);
            UserID = Request["user_userid"];
            SID = Request["SID"];

            SendBusinessReport();
        }

        public void SendBusinessReport()
        {
            string sErrorContent = string.Empty;

            string subjectListingStatus = null;
            string subjectConfidentialFS = null;
            string subjectCompanyName = null;

            int subjectCompanyID = Convert.ToInt32(Request["prbr_requestedcompanyid"]);
            SqlCommand cmdSubject = new SqlCommand("SELECT comp_PRListingStatus, comp_PRConfidentialFS, comp_Name FROM Company WITH (NOLOCK) WHERE comp_CompanyID=@CompanyID", GetDBConnnection());
            cmdSubject.Parameters.AddWithValue("CompanyID", subjectCompanyID);
            using(SqlDataReader reader = cmdSubject.ExecuteReader()) {
                if (reader.Read()) {
                    subjectListingStatus = reader.GetString(0);
                    subjectCompanyName = reader.GetString(2);

                    if (reader[1] != DBNull.Value)
                    {
                        subjectConfidentialFS = reader.GetString(1);
                    }

                }
            }
            

            //if ("L,H,N3,N5,N6".IndexOf(subjectListingStatus) == -1)
            //{
            //    sErrorContent = "Business reports can only be generated for companies with a status of Listed, Hold, or Not Listed (Previously Listed-Reported Closed/Inactive/Not A Factor).";
            //    bError = true;
            //}            
            
            //if (bError) {
            //    return;
            //}



            int requesterCompanyID = Convert.ToInt32(Request["comp_companyid"]);
            if (requesterCompanyID == 0)
            {
                requesterCompanyID = Convert.ToInt32(Request["Key1"]);
            }

            int requesterHQID = 0;
            string requesterIndustryType = null;
            string requesterCompanyName = null;

            SqlCommand cmdRequester = new SqlCommand("SELECT comp_PRIndustryType, comp_PRHQID, comp_Name FROM Company WITH (NOLOCK) WHERE comp_CompanyID=@CompanyID", GetDBConnnection());
            cmdRequester.Parameters.AddWithValue("CompanyID", requesterCompanyID);
            using (SqlDataReader reader = cmdRequester.ExecuteReader())
            {
                if (reader.Read())
                {
                    requesterIndustryType = reader.GetString(0);
                    requesterHQID = reader.GetInt32(1);
                    requesterCompanyName = reader.GetString(2);
                }
            }



            // if we can generate the report, determine if we need a balance sheet and a survey
            bool bIncludeBalance = false;
            bool bIncludeSurvey = false;

            // determine "Include Balance Sheet"
            if ((string.IsNullOrEmpty(subjectConfidentialFS)) &&
                (requesterIndustryType == "S"))
            {
                bIncludeBalance = true;
            }
                
                
            // determine "Include Survey"
            SqlCommand cmdSurvey = new SqlCommand("SELECT dbo.ufn_IsEligibleForBRSurvey(@RequesterCompanyID) as bEligible", GetDBConnnection());
            cmdSurvey.Parameters.AddWithValue("RequesterCompanyID", requesterCompanyID);
            if (Convert.ToInt32(cmdSurvey.ExecuteScalar()) == 1)
            {
                bIncludeSurvey = true;
            }


            string filepath_local = GetLookupCodeMeaning(GetDBConnnection(), "TempReports", "Local");
            string filepath_share = GetLookupCodeMeaning(GetDBConnnection(), "TempReports", "Share");

            string szReportName = "BusinessReportOn" + subjectCompanyID.ToString() + "For" + requesterCompanyID.ToString();
            string sBRFileVersion = Request["hdn_brfileversion"];
            if (string.IsNullOrEmpty(sBRFileVersion))
            {
                sBRFileVersion = DateTime.Now.Ticks.ToString();
            }
            string filename_local = filepath_local + "\\" + szReportName + "_" + sBRFileVersion + ".pdf";
            string filename_share = filepath_share + "\\" + szReportName + "_" + sBRFileVersion + ".pdf";

            _oRI = new ReportInterface();
            byte[] abReport = _oRI.GenerateBusinessReport(subjectCompanyID.ToString(), 3, bIncludeBalance, bIncludeSurvey, requesterCompanyID);

            File.WriteAllBytes(filename_share, abReport);


            string usageType = Convert.ToString(Request["prbr_methodsent"]);

            int productID = 47;    // defaults to a level 3
            if (Request["prbr_productid"] != null) {
                productID = Convert.ToInt32(Request["prbr_productid"]);
            }

            int sPricingListId = 0;
            switch(usageType) {
                case "EBR":
                    sPricingListId = 16013;
                    break;
                case "FBR":
                    sPricingListId = 16011;
                    break;
                case "OBR":
                    sPricingListId = 16010;
                    break;
                case "VBR":
                    sPricingListId = 16012;
                    break;
                default:
                    sPricingListId = 16002;
                    break;
            }

            LogMessage("ConsumeServiceUnits");
            SqlCommand consumeServiceUnits = new SqlCommand("usp_ConsumeServiceUnits", GetDBConnnection());
            consumeServiceUnits.CommandType = System.Data.CommandType.StoredProcedure;
            consumeServiceUnits.Parameters.AddWithValue("CompanyID", requesterCompanyID);
            consumeServiceUnits.Parameters.AddWithValue("PersonID", Request["prbr_requestingpersonid"]);
            consumeServiceUnits.Parameters.AddWithValue("UsageType", usageType);
            consumeServiceUnits.Parameters.AddWithValue("SourceType", "C");
            consumeServiceUnits.Parameters.AddWithValue("ProductID", productID);
            consumeServiceUnits.Parameters.AddWithValue("PricingListID", sPricingListId);
            consumeServiceUnits.Parameters.AddWithValue("RegardingCompanyID", subjectCompanyID);
            consumeServiceUnits.Parameters.AddWithValue("RequestorInfo", Request["prbr_requestorinfo"]);
            consumeServiceUnits.Parameters.AddWithValue("AddressLine1", Request["prbr_addressline1"]);
            consumeServiceUnits.Parameters.AddWithValue("AddressLine2", Request["prbr_addressline2"]);
            consumeServiceUnits.Parameters.AddWithValue("CityStateZip", Request["prbr_citystatezip"]);
            consumeServiceUnits.Parameters.AddWithValue("Country", Request["prbr_country"]);
            consumeServiceUnits.Parameters.AddWithValue("Fax", Request["prbr_fax"]);
            consumeServiceUnits.Parameters.AddWithValue("EmailAddress", Request["prbr_emailaddress"]);
            consumeServiceUnits.Parameters.AddWithValue("NoCharge", Request["prbr_donotchargeunits"]);
            consumeServiceUnits.Parameters.AddWithValue("CRMUserID", UserID);
            consumeServiceUnits.Parameters.AddWithValue("HQID", requesterHQID);
            consumeServiceUnits.ExecuteNonQuery();

           
            if (usageType == "EBR" || usageType == "FBR")
            {

                string sCommAction = null;
                string sTo = null;
                if (usageType == "EBR") {
                    sTo = Convert.ToString(Request["prbr_emailaddress"]);
                    sCommAction = "EmailOut";
                }


                if (usageType == "FBR"){
                    sTo = Convert.ToString(Request["prbr_fax"]);;
                    sCommAction = "FaxOut";
                }

                string sSubject = GetLookupCodeMeaning(GetDBConnnection(), "SendBR", "Subject");
                string sEmailBody = GetLookupCodeMeaning(GetDBConnnection(), "SendBR", "Body");

                LogMessage("sendBR");
                SqlCommand sendBR = new SqlCommand("usp_CreateEmail", GetDBConnnection());
                sendBR.CommandType = System.Data.CommandType.StoredProcedure;
                sendBR.Parameters.AddWithValue("CreatorUserId", UserID);
                sendBR.Parameters.AddWithValue("To", sTo);
                sendBR.Parameters.AddWithValue("Subject", sSubject);
                sendBR.Parameters.AddWithValue("Content", sEmailBody);
                sendBR.Parameters.AddWithValue("Action", sCommAction);
                sendBR.Parameters.AddWithValue("RelatedCompanyId", requesterCompanyID);
                sendBR.Parameters.AddWithValue("RelatedPersonId", Request["prbr_requestingpersonid"]);
                sendBR.Parameters.AddWithValue("AttachmentDir", filename_local);
                sendBR.Parameters.AddWithValue("AttachmentFileName", filename_local);
                sendBR.Parameters.AddWithValue("Source", "CRM BR Request");
                sendBR.Parameters.AddWithValue("Content_Format", "HTML");
                sendBR.ExecuteNonQuery();
            }
            else
            {
                LogMessage("createTask");
                SqlCommand createTask = new SqlCommand("usp_CreateTask", GetDBConnnection());
                createTask.CommandType = System.Data.CommandType.StoredProcedure;
                createTask.Parameters.AddWithValue("CreatorUserId", UserID);
                createTask.Parameters.AddWithValue("AssignedToUserId", UserID);
                createTask.Parameters.AddWithValue("TaskNotes", "Provided Business Report to " + requesterCompanyName + " on " + subjectCompanyName);
                createTask.Parameters.AddWithValue("RelatedCompanyId", requesterCompanyID);
                createTask.Parameters.AddWithValue("RelatedPersonId", Request["prbr_requestingpersonid"]);
                createTask.Parameters.AddWithValue("Action", "LetterOut");
                createTask.ExecuteNonQuery();
            }

            LogMessage("survey");
            SqlCommand survey = new SqlCommand("usp_SendBusinessReportSurvey", GetDBConnnection());
            survey.CommandType = System.Data.CommandType.StoredProcedure;
            survey.Parameters.AddWithValue("PersonID", Request["prbr_requestingpersonid"]);
            survey.Parameters.AddWithValue("CompanyID", requesterCompanyID);
            survey.ExecuteNonQuery();

            string sListingAction = "PRCompanySummary.asp?SID=" + SID + "&Key0=1&Key1=" + requesterCompanyID.ToString();
            LogMessage(sListingAction);
            Response.Redirect(sListingAction);
        }


        protected ReportInterface _oRI;

        private SqlConnection _dbConn = null;
        private SqlConnection GetDBConnnection()
        {
            if (_dbConn == null)
            {
                _dbConn = OpenDBConnection("BusinessReportRequest");
            }

            return _dbConn;
        }

        private void LogMessage(string text)
        {

            msg.Text += text + "<br/>";
        }
    }
}