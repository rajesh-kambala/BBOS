using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

namespace PRCo.BBS.CRM
{
    public partial class PRCoWorkflowTransition : PageBase
    {
        protected override void Page_Load(object sender, EventArgs e)
        {
            ProcessWorkflowTransition();
        }

        private void ProcessWorkflowTransition()
        {
            SqlParameter parm = null;
            // Get the expected fields from the submitted form
            string sRedirectURL = Server.UrlDecode(Request.Params.Get("RedirectURL"));
            string sURL = Request.Url.ToString();
            string sSID = Request.Params.Get("SID");
            string sWkIn_InstanceId = Request.Params.Get("Key50");
            string sWkTr_TransitionId = Request.Params.Get("trid");

            SqlConnection conCRM = null;
            SqlCommand cmdCreate = null;

            lblError.Text += "<BR>QueryString: " + Request.QueryString;
            string sReturn = null;
            try
            {
                lblError.Text += "<BR>WkIn_InstanceId: " + sWkIn_InstanceId;
                lblError.Text += "<BR>WkTr_TransitionId: " + sWkTr_TransitionId;
                conCRM = OpenDBConnection();
                cmdCreate = new SqlCommand("usp_TransitionWorkflow", conCRM);
                cmdCreate.CommandType = CommandType.StoredProcedure;
                // clear all stored procedure parameters
                cmdCreate.Parameters.Clear();
                // create the return parameter
                parm = cmdCreate.Parameters.Add("ReturnValue", SqlDbType.VarChar);
                parm.Direction = ParameterDirection.ReturnValue;
                // add the required parameters
                cmdCreate.Parameters.AddWithValue("@WorkflowInstanceId", int.Parse(sWkIn_InstanceId));
                cmdCreate.Parameters.AddWithValue("@WorkflowTransitionId", int.Parse(sWkTr_TransitionId));
                parm = cmdCreate.Parameters.Add("@WorkflowCustomFile", SqlDbType.VarChar);
                parm.Direction = ParameterDirection.Output;
                parm.Size = 200;

                // the stored procedure will raise exceptions if there is an error
                cmdCreate.ExecuteNonQuery();
                
                // This return value will be the url of the screen to navigate to; if there isn't on,
                // just return to where we came from
                if (cmdCreate.Parameters["@WorkflowCustomFile"].Value != null)
                    sReturn = Convert.ToString(cmdCreate.Parameters["@WorkflowCustomFile"].Value);
                if (sReturn == null || sReturn.Trim() == "")
                {
                    lblError.Text += "<BR>sRedirectURL: " + sRedirectURL;
                    // return to where we came from
                    Response.Redirect(sRedirectURL, false);
                }
                else
                {
                    lblError.Text += "<BR>Custom Redirect: " + "/CRM/CustomPages/" + sReturn.Trim() + "?SID=" + sSID + "&" + "Key50=" + sWkIn_InstanceId;
                    // navigate to the provided page.
                    Response.Redirect("/CRM/CustomPages/" + sReturn.Trim() + "?SID=" + sSID + "&" + "Key50=" + sWkIn_InstanceId, false);

                }
 
            }
            catch (Exception ex)
            {
                string sListingAction = sRedirectURL;
                Session.Contents.Add("prco_exception", ex);
                Session.Contents.Add("prco_exception_continueurl", sListingAction);
                // need the false param to bail from within the catch block
                Response.Redirect("/CRM/CustomPages/PRCoErrorPage.aspx?SID=" + sSID, false);
            }
            finally
            {
                if (conCRM != null)
                    CloseDBConnection(conCRM);
                conCRM = null;
            }
            //Response.Write("<br>exec " + sUSP + " @comp_CompanyId=" + comp_companyid +
            //        ", @UserId=" + sUserId + ", @SourceId=" + sSourceId + ", @ReplicateToIds=" + sReplicateToIds + "<br>");
        }

    }
}
