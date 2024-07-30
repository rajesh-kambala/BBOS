/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ContactTradingAssistance.aspx (formerly called SpecialServicesGetAdvice.aspx)
 Description: This class provides the interface for the user to enter 
              a Special Service Advice File.

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Collections;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class ContactTradingAssistance : SpecialServicesBase
    {
        protected const string SQL_INSERT_PRSSFILE_ADVICE = "INSERT INTO PRSSFile " +
            "(prss_CreatedBy, prss_CreatedDate, prss_UpdatedBy, prss_UpdatedDate, prss_TimeStamp, " +
            "prss_IssueDescription, prss_ClaimantCompanyId, prss_AssignedUserId, prss_Type, prss_Status, prss_SSFileId, prss_ChannelId) " +
            "VALUES " +
            "({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11})";

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.TradingAssistance, Resources.Global.AskAQuestion);
            //AddDoubleClickPreventionJS(btnSubmit);
            EnableFormValidation();
            btnCancel.OnClientClick = "bEnableValidation=false;";
        }

        /// <summary>
        /// All users can view this data.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        /// <summary>
        /// Returns the user to the specified ReturnURL
        /// parameter.  If not specified, then the user is returned
        /// to the special services listing.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancelOnClick(object sender, EventArgs e)
        {
            Response.Redirect(GetReturnURL(PageConstants.SPECIAL_SERVICES));
        }

        protected void btnSubmitOnClick(object sender, EventArgs e)
        {
            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                // get any default lookup values
                int sAssignedToId = Utilities.GetIntConfigValue("SpecialServicesGetAdviceAssignedToUserID", 127);

                // Create the PRSSFile record
                ArrayList oParameters = new ArrayList();

                oParameters.Add(new ObjectParameter("prss_CreatedBy", _oUser.prwu_WebUserID));
                oParameters.Add(new ObjectParameter("prss_CreatedDate", DateTime.Now));
                oParameters.Add(new ObjectParameter("prss_UpdatedBy", _oUser.prwu_WebUserID));
                oParameters.Add(new ObjectParameter("prss_UpdatedDate", DateTime.Now));
                oParameters.Add(new ObjectParameter("prss_TimeStamp", DateTime.Now));

                oParameters.Add(new ObjectParameter("prss_IssueDescription", txtIssueQuestion.Text));
                oParameters.Add(new ObjectParameter("prss_ClaimantCompanyId", _oUser.prwu_BBID));
                oParameters.Add(new ObjectParameter("prss_AssignedUserId", sAssignedToId));

                oParameters.Add(new ObjectParameter("prss_Type", "A"));
                oParameters.Add(new ObjectParameter("prss_Status", "P"));

                int iSSFileId = GetObjectMgr().GetRecordID("PRSSFile", oTran);
                oParameters.Add(new ObjectParameter("prss_SSFileId", iSSFileId));

                oParameters.Add(new ObjectParameter("prss_ChannelId", Utilities.GetIntConfigValue("SpecialServicesChannelID", 8)));

                string szSQL = GetObjectMgr().FormatSQL(SQL_INSERT_PRSSFILE_ADVICE, oParameters);
                GetObjectMgr().ExecuteInsert("PRSSFile", szSQL, oParameters, oTran);

                // Add the PRSSContact record
                insertSSContact(iSSFileId, oTran);

                string emailTo = Utilities.GetConfigValue("SpecialServicesAdviceEmail", "advice@bluebookservices.com");

                NotifyUser(iSSFileId, sAssignedToId, emailTo, "BBOS - Contact Trading Assistance", oTran);

                oTran.Commit();
            }
            catch
            {
                if (oTran != null)
                {
                    oTran.Rollback();
                }
                throw;
            }

            // Display message to user informing them that the data has been saved
            AddUserMessage(String.Format(Resources.Global.SaveMsgSpecialServices, "Advice Request"));

            // redirect back to the ss file listing page
            Response.Redirect(GetReturnURL(PageConstants.SPECIAL_SERVICES));
        }
    }
}
