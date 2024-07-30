/***********************************************************************
 Copyright Produce Reporter Company 2006-2016

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: InvokeStoredProc.aspx
 Description:	

 Notes: 

***********************************************************************
***********************************************************************/
using System;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.IO;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Specialized;


namespace PRCo.BBS.CRM
{
    /// <summary>
    /// This is a generic module invoked by various CRM pages to
    /// execute a stored procedure.  
    /// </summary>
    public partial class StoredProcRedirect : PageBase
    {
        private class DBParam 
        {
            public string SPParamName;
            public SqlDbType Type;
            public string ParamValue;

            public DBParam(string SPParamName, SqlDbType Type)  
            {
                this.SPParamName = SPParamName;
                this.Type = Type;
            }

            public DBParam(string SPParamName, SqlDbType Type, string ParamValue)  
            {
                this.SPParamName = SPParamName;
                this.Type = Type;
                this.ParamValue = ParamValue;
            }
        }

        protected SqlConnection conCRM = null;
        protected String sSID = "";
        protected String sCustomAction = "";

        protected string sAppName; 

        override protected void OnInit(EventArgs e)
        {
            InitializeComponent();
            base.OnInit(e);
        }

        private void InitializeComponent()
        {    

        }

        /// <summary>
        /// This method is essentially a dispatcher looking to see what method to
        /// invoke based on the "customact" parameter.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected override void Page_Load(object sender, System.EventArgs e)
        {
            NameValueCollection appSettings = ConfigurationManager.AppSettings;
            
            this.sAppName = appSettings["AppName"];
            this.sCustomAction = Request.Params.Get("customact");
            this.sSID = Request.Params.Get("SID");

            switch (sCustomAction) {
                case "AssignImportedPACA":
                    ProcessAssignImportedPACA();
                    break;
                case "SaveCompanyTMFM":
                    ProcessSaveCompanyTMFM();
                    break;
                case "ReplicatePhone":
                    ProcessReplicate("usp_ReplicateCompanyPhone");
                    break;
                case "ReplicateAddress":
                    ProcessReplicate("usp_ReplicateCompanyAddress");
                    break;
                case "ReplicateEmailWeb":
                    ProcessReplicate("usp_ReplicateCompanyEmailWeb");
                    break;
                case "ReplicateCommodity":
                    ProcessReplicate("usp_ReplicateCompanyCommodity");
                    break;
                case "ReplicateClassification":
                    ProcessReplicate("usp_ReplicateCompanyClassification");
                    break;
                case "ReplicateProductProvided":
                    ProcessReplicate("usp_ReplicateCompanyProductProvided");
                    break;
                case "ReplicateServiceProvided":
                    ProcessReplicate("usp_ReplicateCompanyServiceProvided");
                    break;
                case "ReplicateSpecie":
                    ProcessReplicate("usp_ReplicateCompanySpecie");
                    break;
                case "ReplicateCompanyBrand":
                    ProcessReplicate("usp_ReplicateCompanyBrand");
                    break;
            }
        }

        private void ProcessAssignImportedPACA()
        {
            string szAdditionalInfo = string.Empty;
            string spril_ImportedPacaLicenseId = Request.Params.Get("pril_ImportPACALicenseId");
            string szSP_Type = Request.Params.Get("sp_Type");
            try
            {
                SqlParameter parm = null;
                // First we need to determine what type of action to take.  We can 
                // be assigning a company, creating and assigning a new company, or
                // assigning to an existing PACA record.  Each action calls the same 
                // stored procedure.

                // Get the expected fields from the submitted form

               
                                                             
                string sprpa_CompanyId = Request.Params.Get("prpa_companyid");
                string prpa_PACALicenseId = Request.Params.Get("prpa_PACALicenseId");
                string comp_PRTradestyle1 = Request.Params.Get("comp_PRTradestyle1");
                string comp_PRTradestyle2 = Request.Params.Get("comp_PRTradestyle2");
                string comp_PRTradestyle3 = Request.Params.Get("comp_PRTradestyle3");
                string comp_PRTradestyle4 = Request.Params.Get("comp_PRTradestyle4");
                string comp_Name = Request.Params.Get("_HIDDENcomp_Name");
                string comp_PRCorrTradestyle = Request.Params.Get("_HIDDENcomp_prcorrtradestyle");
                string comp_PRBookTradestyle = Request.Params.Get("_HIDDENcomp_prbooktradestyle");

                SqlCommand cmdCreate = OpenSPConnection("usp_CreatePACAFromImport");
                // clear all stored procedure parameters
                cmdCreate.Parameters.Clear();
                // create the return parameter
                parm = cmdCreate.Parameters.Add("ReturnValue", SqlDbType.Int);
                parm.Direction = ParameterDirection.ReturnValue;
                // load the parameters for the company assignment
                if (spril_ImportedPacaLicenseId != null)
                    parm = cmdCreate.Parameters.AddWithValue("@pril_ImportPACALicenseId", int.Parse(spril_ImportedPacaLicenseId));
                if (sprpa_CompanyId != null)
                {
                    if (string.IsNullOrEmpty(sprpa_CompanyId))
                    {
                        szAdditionalInfo = "sprpa_CompanyId: is null or empty";
                    }
                    else
                    {
                        szAdditionalInfo = "sprpa_CompanyId: " + sprpa_CompanyId;
                    }
                    parm = cmdCreate.Parameters.AddWithValue("@comp_CompanyId", int.Parse(sprpa_CompanyId));
                }
                if (szSP_Type != null)
                    parm = cmdCreate.Parameters.AddWithValue("@Type", int.Parse(szSP_Type));
                if (prpa_PACALicenseId != null)
                    parm = cmdCreate.Parameters.AddWithValue("@prpa_PACALicenseId", int.Parse(prpa_PACALicenseId));
                //several parameters have been removed here as they are obsolete

                // parm = cmdCreate.Parameters.Add( "@UserId", SqlDbType.Int );
                parm = cmdCreate.Parameters.AddWithValue("@DeleteImport", 1);

                cmdCreate.ExecuteNonQuery();
                // This return value is the ID of the record inserted
                // We don't use it here.
                string sReturn = Convert.ToString(cmdCreate.Parameters["ReturnValue"].Value);
                string szRedirect = "/" + sAppName + "/CustomPages/PRPACALicense/PRPACALicenseSummary.asp?SID=" +
                    sSID + "&" + "prpa_PACALicenseId=" + sReturn + "&key0=1";
                if(!string.IsNullOrEmpty(sprpa_CompanyId))
                    szRedirect += "&key1=" + sprpa_CompanyId;

                Response.Redirect(szRedirect, false);
            } catch (Exception ex) {
                string sListingAction = "/" + sAppName + "/CustomPages/PRPACALicense/PRImportPACALicenseSummary.asp?SID=" +
                        sSID + "&" + "pril_ImportPACALicenseId=" + spril_ImportedPacaLicenseId;
                Session.Contents.Add("prco_exception", ex);
                Session.Contents.Add("prco_exception_continueurl", sListingAction);
                Session.Contents.Add("prco_additional_info", szAdditionalInfo);

                string szRedirect = "/" + sAppName + "/CustomPages/PRCoErrorPage.aspx?SID=" + sSID;
                Response.Redirect(szRedirect, false);
            }
            finally
            {
                CloseSPConnection();
            }            
        }

        private void ProcessSaveCompanyTMFM()
        {
            string sRedirectURL = Server.UrlDecode(Request.Params.Get("RedirectURL"));
            bool bError = false;
            try
            {
                SqlParameter parm = null;
                // Get the expected fields from the submitted form
                string comp_companyid = Request.Params.Get("comp_companyid");
                string szReturnValue = "0";

                // Look to see if we only need to update the comment.  The comment
                // can be edited outside of a transaction and does not affect
                // any branches.
                if (Request.Params.Get("CommentOnly") == "Y")
                {
                    conCRM = OpenDBConnection();
                    SqlCommand cmdUpdate = new SqlCommand("UPDATE Company SET comp_prtmfmcomments=@comp_PRTMFMComments WHERE comp_CompanyID=@comp_CompanyId", OpenDBConnection());

                    cmdUpdate.Parameters.AddWithValue("@comp_CompanyId", int.Parse(comp_companyid));
                    string comp_PRTMFMComments = Request.Params.Get("comp_prtmfmcomments");
                    if (string.IsNullOrEmpty(comp_PRTMFMComments))
                    {
                        cmdUpdate.Parameters.AddWithValue("@comp_PRTMFMComments", DBNull.Value);
                    }
                    else
                    {
                        cmdUpdate.Parameters.AddWithValue("@comp_PRTMFMComments", comp_PRTMFMComments);
                    }
                    cmdUpdate.ExecuteNonQuery();
                }
                else
                {

                    SqlCommand cmdCreate = OpenSPConnection("usp_UpdateTMFMStatus");
                    // clear all stored procedure parameters
                    cmdCreate.Parameters.Clear();
                    // create the return parameter
                    parm = cmdCreate.Parameters.Add("ReturnValue", SqlDbType.Int);
                    parm.Direction = ParameterDirection.ReturnValue;
                    // load the parameters for the stored procedure
                    this.lblError.Text += "<br>comp_companyid:" + comp_companyid;
                    this.lblError.Text += "<br>redirect url:" + sRedirectURL;

                    if (comp_companyid != null)
                        parm = cmdCreate.Parameters.AddWithValue("@comp_CompanyId", int.Parse(comp_companyid));

                    string comp_PRTMFMAwarded = Request.Params.Get("comp_prtmfmaward");
                    if (comp_PRTMFMAwarded == "on")
                        parm = cmdCreate.Parameters.AddWithValue("@comp_PRTMFMAwarded", "Y");

                    string comp_PRTMFMAwardedDate = Request.Params.Get("comp_prtmfmawarddate");
                    if (comp_PRTMFMAwardedDate != null && comp_PRTMFMAwardedDate.Length != 0)
                        parm = cmdCreate.Parameters.AddWithValue("@comp_PRTMFMAwardedDate", DateTime.Parse(comp_PRTMFMAwardedDate));

                    string comp_PRTMFMCandidate = Request.Params.Get("comp_prtmfmcandidate");
                    if (comp_PRTMFMCandidate == "on")
                        parm = cmdCreate.Parameters.AddWithValue("@comp_PRTMFMCandidate", "Y");

                    string comp_PRTMFMCandidateDate = Request.Params.Get("comp_prtmfmcandidatedate");
                    if (comp_PRTMFMCandidateDate != null && comp_PRTMFMCandidateDate.Length != 0)
                        parm = cmdCreate.Parameters.AddWithValue("@comp_PRTMFMCandidateDate", DateTime.Parse(comp_PRTMFMCandidateDate));

                    string comp_PRTMFMComments = Request.Params.Get("comp_prtmfmcomments");
                    if (comp_PRTMFMComments != null && comp_PRTMFMComments.Length != 0)
                        parm = cmdCreate.Parameters.AddWithValue("@comp_PRTMFMComments", comp_PRTMFMComments);
                    cmdCreate.CommandTimeout = GetConfigValue("UpdateTMFMStatusTimeout", 180);
                    cmdCreate.ExecuteNonQuery();

                    szReturnValue = Convert.ToString(cmdCreate.Parameters["ReturnValue"].Value);
                }
                    
                // This return value will be -1 (Error), 0 (success- no branch updates), 1 (success branch updates)
                Response.Redirect(sRedirectURL + "&" + "saveval=" + szReturnValue, false );
            }
            catch (Exception ex)
            {
                string sListingAction = sRedirectURL;
                Session.Contents.Add("prco_exception",  ex);
                Session.Contents.Add("prco_exception_continueurl", sListingAction);
                bError = true;
            }
            finally
            {
                CloseSPConnection();
            }            
            if (bError)
                Response.Redirect("/" + sAppName + "/CustomPages/PRCoErrorPage.aspx?SID=" + sSID, false);

        }

        private void ProcessReplicate(String sUSP)
        {
            SqlParameter parm = null;
            // Get the expected fields from the submitted form
            string sRedirectURL = Server.UrlDecode(Request.Params.Get("RedirectURL"));
            string comp_companyid = Request.Params.Get("comp_companyid");
            string sUserId = Request.Params.Get("UserId");
            string sSourceId = Request.Params.Get("SourceId");
            string sReplicateToIds = Request.Params.Get("ReplicateToIds");

            SqlCommand cmdCreate = OpenSPConnection(sUSP);
            string sReturn = "";
            try
            {
                // clear all stored procedure parameters
                cmdCreate.Parameters.Clear();
                // create the return parameter
                parm = cmdCreate.Parameters.Add( "ReturnValue", SqlDbType.Int );
                parm.Direction = ParameterDirection.ReturnValue;
                // load the parameters for the stored procedure
                this.lblError.Text += "<br>comp_companyid:" + comp_companyid;
                this.lblError.Text += "<br>redirect url:" + sRedirectURL;

                if (comp_companyid != null)
                    parm = cmdCreate.Parameters.AddWithValue("@comp_CompanyId", int.Parse(comp_companyid));

                if (sUserId != null)
                    parm = cmdCreate.Parameters.AddWithValue("@UserId", int.Parse(sUserId));

                if (sSourceId != null)
                    parm = cmdCreate.Parameters.AddWithValue("@SourceId", int.Parse(sSourceId));

                if (sReplicateToIds != null && sReplicateToIds.Length!=0)
                    parm = cmdCreate.Parameters.AddWithValue("@ReplicateToIds", sReplicateToIds);
                try
                {
                    cmdCreate.ExecuteNonQuery();

                    // This return value will be 0 (success- ), any other value Error
                    sReturn = Convert.ToString(cmdCreate.Parameters["ReturnValue"].Value);
                } 
                catch( Exception e)
                {
                    this.lblError.Text += "<br/>" + e.Message;
                    sReturn = "-1";
                }
            }
            catch (Exception e)
            {
                this.lblError.Text += "<br/>" + e.Message;
                sReturn = "-1";
            }
            finally
            {
                CloseSPConnection();
            }
            if (sReturn == "0")
                Response.Redirect(sRedirectURL + "&saveval=" + sReturn);
            else
                this.lblError.Text += "<br/>Update failed. Return Code: " + sReturn;
            
            Response.Write("<br>exec " + sUSP + " @comp_CompanyId=" + comp_companyid +", @UserId=" + sUserId + ", @SourceId=" + sSourceId + ", @ReplicateToIds=" + sReplicateToIds + "<br>");
        }
      
  
        /// <summary>
        /// Opens a stored procedure connection to the database
        /// </summary>
        /// <param name="sStoredProc"></param>
        private SqlCommand OpenSPConnection(string sStoredProc)
        {
            // Prepare for a connection to the DB
            SqlCommand cmdCreate = null;

            try
            {
                /*
                NameValueCollection appSettings =
                   ConfigurationManager.AppSettings;
                //Create the SQL Connection
                // Get the server connection info from a centralized location
                string sServer = appSettings["DBServer"]; 
                string sDB = appSettings["Database"]; 
                string sUID = appSettings["UID"]; 
                string sPWD = appSettings["PWD"]; 
                string sConnect = String.Format("Server={0};database={1};UID={2};PWD={3}",
                    sServer, sDB, sUID, sPWD);
                //this.lblMessage.Text = "Connect = ["+sConnect + "]";
                conCRM = new SqlConnection( sConnect);
                */
                // call the PageBase.OpenDBConnection function instead
                conCRM = OpenDBConnection();
                cmdCreate = new SqlCommand( sStoredProc, conCRM );
                cmdCreate.CommandType = CommandType.StoredProcedure;

                // open the database connection
                //conCRM.Open();
            }  
            catch (Exception e)
            {
                this.lblError.Text += "<br/>" + e.Message;
            }
            return cmdCreate;
        }

        
        private void CloseSPConnection()
        {
            try
            {
                if (conCRM != null)
                    CloseDBConnection(conCRM);
                conCRM = null;
            }
            catch (Exception e)
            {
                this.lblError.Text += "<br/>" + e.Message;
            }
        }
    }        
}
