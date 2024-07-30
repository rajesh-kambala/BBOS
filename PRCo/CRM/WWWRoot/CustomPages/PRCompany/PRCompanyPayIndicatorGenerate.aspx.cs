/***********************************************************************
 Copyright Blue Book Services, Inc. 2016-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of lue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PRCompanyPayIndicatorGenerate.aspx
 Description:	

 Notes:

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using BBSI.PayIndicator;

namespace PRCo.BBS.CRM
{
    public partial class PRCompanyPayIndicatorGenerate : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            GeneratePayIndicator();

        }

        protected const string SQL_SELECT_ELIGBILE_COMPANIES =
                @"SELECT * FROM vPRPayIndicatorEligibleCompany
                         WHERE SubjectCompanyID=@CompanyID";


        protected const string SQL_SELECT_COMPANY_NO_AR =
                @" SELECT comp_CompanyID as SubjectCompanyId,
                            prcpi_PayIndicatorScore,
                            prcpi_PayIndicator
                        FROM Company WITH (NOLOCK)
                            LEFT OUTER JOIN PRCompanyPayIndicator WITH (NOLOCK) ON comp_CompanyID =  prcpi_CompanyID AND prcpi_Current = 'Y'
                        WHERE comp_CompanyID = @CompanyID";

        protected string msg;
        protected string url;

        protected void GeneratePayIndicator()
        {
            try
            {
                string companyID = Request["comp_CompanyID"];
                if (string.IsNullOrEmpty(companyID))
                {
                    companyID = Request["Key1"];
                }


                PayIndicatorEligibleCompany pieCompany = null;

                SqlConnection dbConn = OpenDBConnection("PayIndicatorGenerat");

                SqlCommand cmdCompanyInfo = new SqlCommand(SQL_SELECT_ELIGBILE_COMPANIES, dbConn);
                cmdCompanyInfo.Parameters.AddWithValue("CompanyID", Convert.ToInt32(companyID));

                using (SqlDataReader reader = cmdCompanyInfo.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        pieCompany = new PayIndicatorEligibleCompany(reader);
                    }
                }

                if (pieCompany == null) {

                    SqlCommand cmdCompanyInfo2 = new SqlCommand(SQL_SELECT_COMPANY_NO_AR, dbConn);
                    cmdCompanyInfo2.Parameters.AddWithValue("CompanyID", Convert.ToInt32(companyID));

                    using (SqlDataReader reader = cmdCompanyInfo2.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            pieCompany = new PayIndicatorEligibleCompany(Convert.ToInt32(companyID));
                            if (reader[1] != DBNull.Value)
                            {
                                pieCompany.PayIndicatorScore = reader.GetDecimal(1);
                            }

                            if (reader[2] != DBNull.Value)
                            {
                                pieCompany.PayIndicator = reader.GetString(2);
                            }
                        }
                    }
                }

                CalculatePayIndicator calculatePayIndcator = new CalculatePayIndicator();
                calculatePayIndcator.Calculate(dbConn, null, pieCompany);

                switch (pieCompany.ActionCode)
                {
                    case "R":
                        msg = "The Pay Indicator has been removed.";
                        break;
                    case "NR":
                        msg = "No Pay Indicator was created.";
                        break;
                    case "C":
                        msg = "The Pay Indicator has been changed.";
                        break;
                    case "UC":
                        msg = "The Pay Indicator has not been changed.";
                        break;
                }


                if (pieCompany.FailedSubmitterCountThreshold)
                {
                    msg += " This company does not have the required number of AR submitters.";
                }

                if (pieCompany.FailedARDetailCountThreshold)
                {
                    msg += " This company does not have the required number of AR detail records.";
                }


                if (pieCompany.FailedARDateThreshold)
                {
                    msg += " This company does not have the required number of AR detail records within the date threshold.";
                }

                if (pieCompany.Nuisance)
                {
                    msg += " The amount of AR on this company is below the nuisance threshold..";
                }

                url = string.Format("PRCompanyRatingListing.asp?SID={0}&Key0=1&Key1={1}", Request["SID"], companyID);
                ClientScript.RegisterStartupScript(this.GetType(), "displayMsg", "displayMsg();", true);

                userMsg.Text = msg;
            } catch (Exception e)
            {
                userMsg.Text = e.Message;
                userMsg.Text += "<p>" + e.StackTrace.Replace("\n", "<br/>");
            }
        }
    }
}