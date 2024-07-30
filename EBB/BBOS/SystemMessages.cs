/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: SystemMessages.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Text;
using System.Web;
using TSI.Utils;
using TSI.DataAccess;
using TSI.BusinessObjects;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using System.Collections.Generic;

namespace PRCo.BBOS.UI.Web
{
    public class SystemMessages
    {
        public IPRWebUser WebUser;
        public ILogger Logger;

        protected IDBAccess _oDBAccess;
        protected GeneralDataMgr _oObjectMgr;

        public SystemMessages()
        {
        }

        public SystemMessages(IPRWebUser webUser, ILogger logger)
        {
            WebUser = webUser;
            Logger = logger;
        }

        public GeneralDataMgr GetObjectMgr()
        {
            if (_oObjectMgr == null)
            {
                _oObjectMgr = new GeneralDataMgr(GetLogger(), WebUser);
            }
            return _oObjectMgr;
        }

        protected IDBAccess GetDBAccess()
        {
            if (_oDBAccess == null)
            {
                _oDBAccess = DBAccessFactory.getDBAccessProvider();
                _oDBAccess.Logger = GetLogger();
            }

            return _oDBAccess;
        }

        protected ILogger GetLogger()
        {
            if (Logger == null)
            {
                Logger = LoggerFactory.GetLogger();
                if (WebUser != null)
                {
                    Logger.UserID = WebUser.UserID;
                }
                Logger.RequestName = "SystemMessages";
            }

            return Logger;
        }

        public List<string> GetMessages(string szClass="messages")
        {
            List<string> lstMsgs = new List<string>();

            SystemMessages systemMsg = new SystemMessages(WebUser, Logger);

            string msg = systemMsg.GetSuspensionPendingMessage();
            if (!string.IsNullOrEmpty(msg))
                lstMsgs.Add(msg);

            msg = systemMsg.GetTESMessage(szClass);
            if (!string.IsNullOrEmpty(msg))
                lstMsgs.Add(msg);

            msg = systemMsg.GetJeopardyMessage(szClass);
            if (!string.IsNullOrEmpty(msg))
                lstMsgs.Add(msg);

            msg = systemMsg.GetReferenceListMessage(szClass);
            if (!string.IsNullOrEmpty(msg))
                lstMsgs.Add(msg);

            msg = systemMsg.GetServiceUnitMessage(szClass);
            if (!string.IsNullOrEmpty(msg))
                lstMsgs.Add(msg);

            msg = systemMsg.GetCompanyUpdatesMessage("explicitlink");
            if (!string.IsNullOrEmpty(msg))
                lstMsgs.Add(msg);

            msg = systemMsg.GetCustomMessage("Member");
            if (!string.IsNullOrEmpty(msg))
                lstMsgs.Add(msg);

            return lstMsgs;
        }

        protected const string SQL_SELECT_TES =
            @"SELECT COUNT(DISTINCT prtesr_SubjectCompanyID) As TESCount 
               FROM PRTESRequest WITH (NOLOCK)
              WHERE prtesr_Received IS NULL 
                AND prtesr_CreatedDate > {0} 
                AND prtesr_ResponderCompanyID = {1} 
                AND dbo.ufn_IsEligibleForManualTES(prtesr_ResponderCompanyID, prtesr_SubjectCompanyID) = 1";

        public string GetTESMessage(string szClass = "messages")
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prtf_CreatedDate", DateTime.Now.AddDays(0 - Utilities.GetIntConfigValue("TESSubjectsAgeThreshold", 45))));
            oParameters.Add(new ObjectParameter("prte_ResponderCompanyID", WebUser.prwu_BBID));
            string szSQL = GetObjectMgr().FormatSQL(SQL_SELECT_TES, oParameters);

            int iCount = (int)GetDBAccess().ExecuteScalar(szSQL, oParameters);
            if (iCount > 0)
            {
                return string.Format(Resources.Global.MyMessageCenterTESMsg, iCount.ToString("###,##0"), PageConstants.TES, szClass);
            }

            return null;
        }

        protected const string SQL_SELECT_JEOPARDYDATE =
            @"SELECT comp_PRJeopardyDate 
                FROM Company WITH (NOLOCK) 
               WHERE comp_CompanyID = {0} 
                 AND GETDATE() BETWEEN DATEADD(day, {1}, comp_PRJeopardyDate) AND comp_PRJeopardyDate";

        public string GetJeopardyMessage(string szClass = "messages")
        {
            // Look to see if we've already look at the Jeopardy Date.  If so,
            // there's no need for another query.
            if (HttpContext.Current.Session["mcJeopardyCheck"] == null)
            {
                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("comp_CompanyID", WebUser.prwu_BBID));
                oParameters.Add(new ObjectParameter("comp_PRJeopardyDate", (0 - Utilities.GetIntConfigValue("JeopardyDateThreshold", 60))));
                string szSQL = GetObjectMgr().FormatSQL(SQL_SELECT_JEOPARDYDATE, oParameters);

                object oJeopardyValue = GetDBAccess().ExecuteScalar(szSQL, oParameters);
                if (oJeopardyValue != null)
                {
                    DateTime dtJeopardyDate = (DateTime)oJeopardyValue;
                    HttpContext.Current.Session["mcJeopardyMsg"] = string.Format(Resources.Global.MyMessageCenterJeopardyMsg, dtJeopardyDate.ToShortDateString(), PageConstants.EMCW_FINANCIAL_STATEMENT, szClass + " explicitlink");
                }
                HttpContext.Current.Session["mcJeopardyCheck"] = "Y";
            }

            if (HttpContext.Current.Session["mcJeopardyMsg"] != null)
            {
                return (string)HttpContext.Current.Session["mcJeopardyMsg"];
            }

            return null;
        }

        protected const string SQL_SELECT_CLDATE =
            @"SELECT comp_PRConnectionListDate 
                FROM Company WITH (NOLOCK) 
               WHERE comp_CompanyID = {0} 
                 AND comp_PRConnectionListDate < DATEADD(month, {1}, GETDATE())";

        public string GetReferenceListMessage(string szClass = "messages")
        {
            // Look to see if we've already look at the Connection List Date.  If so,
            // there's no need for another query.
            if (HttpContext.Current.Session["mcCLCheck"] == null)
            {
                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("comp_CompanyID", WebUser.prwu_BBID));
                oParameters.Add(new ObjectParameter("comp_PRConnectionListDate", (0 - Utilities.GetIntConfigValue("ConnectionListThreshold", 12))));
                string szSQL = GetObjectMgr().FormatSQL(SQL_SELECT_CLDATE, oParameters);

                object oCLValue = GetDBAccess().ExecuteScalar(szSQL, oParameters);
                if (oCLValue != null)
                {
                    //DateTime dtCLDate = (DateTime)oCLValue;
                    HttpContext.Current.Session["mcCLMsg"] = string.Format(Resources.Global.MyMessageCenterCLMsg, PageConstants.EMCW_REFERENCELIST, szClass + " explicitlink");
                }
                HttpContext.Current.Session["mcCLCheck"] = "Y";
            }

            if (HttpContext.Current.Session["mcCLMsg"] != null)
            {
                return (string)HttpContext.Current.Session["mcCLMsg"];
            }

            return null;
        }

        public string GetCustomMessage(string type)
        {
            string prefix = string.Empty;
            if (!string.IsNullOrEmpty(type))
            {
                prefix = type;
            }

            string sessionVarName = "mc" + prefix + "CustomMsg";

            // Look to see if we've already determined if we need to display
            // the custom message.  
            if (HttpContext.Current.Session[sessionVarName + "Check"] == null)
            {
                int maxLoginCount = 0;
                string customMsg = null;

                IBusinessObjectSet osRefData = PageBase.GetReferenceData(type + "MessageCenterMsg", WebUser.prwu_Culture);
                foreach (ICustom_Caption oLC in osRefData)
                {
                    if (oLC.Code == "MaxLoginCount")
                    {
                        maxLoginCount = Convert.ToInt32(oLC.Meaning);
                    }

                    if (oLC.Code == "Message")
                    {
                        customMsg = oLC.Meaning;
                    }
                }

                // We have 3 different types of messages.  See which login
                // count we need to compare to the max login count
                int loginCount = 0;
                switch (type)
                {
                    case "":
                        loginCount = WebUser.MessageLoginCount;
                        break;
                    case "Member":
                        loginCount = WebUser.MemberMessageLoginCount;
                        break;
                    case "NonMember":
                        loginCount = WebUser.NonMemberMessageLoginCount;
                        break;
                    case "ITA":
                        loginCount = WebUser.MemberMessageLoginCount;
                        break;
                }
                if (loginCount <= maxLoginCount)
                {
                    HttpContext.Current.Session[sessionVarName] = customMsg;
                }

                HttpContext.Current.Session[sessionVarName + "Check"] = "Y";
            }

            if (HttpContext.Current.Session[sessionVarName] != null)
            {
                return (string)HttpContext.Current.Session[sessionVarName];
            }
            return null;
        }

        protected const string SQL_SELECT_UPDATE_COUNT =
            @"SELECT COUNT(1) 
                FROM PRCreditSheet WITH (NOLOCK) 
                     INNER JOIN vPRBBOSCompanyList ON prcs_CompanyId = comp_CompanyID 
               WHERE prcs_Status = 'P' 
                 AND {0} 
                 {1}
                 AND prcs_PublishableDate >= @DateThreshold";

        public string GetCompanyUpdatesMessage(string szHyperlinkClass = "messages")
        {
            double dateThrehsold = Configuration.CompanyUpdateDaysOld;
            if (WebUser.prwu_CompanyUpdateDaysOld != null)
            {
                dateThrehsold = Convert.ToDouble(WebUser.prwu_CompanyUpdateDaysOld);
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("DateThreshold", DateTime.Today.AddDays(0 - dateThrehsold)));
            oParameters.Add(new ObjectParameter("IndustryType", GeneralDataMgr.INDUSTRY_TYPE_LUMBER));

            string industryClause = null;
            if (WebUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                industryClause = "comp_PRIndustryType = @IndustryType";
            }
            else
            {
                industryClause = "comp_PRIndustryType <> @IndustryType";
            }

            string keyCaluse = string.Empty;
            string keyMsg = string.Empty;
            string keyURLParm = "&amp;NonKey=Y";
            if (WebUser.prwu_CompanyUpdateMessageType == "Key")
            {
                keyCaluse = " AND prcs_KeyFlag = 'Y' ";
                keyMsg = Resources.Global.Key;
                keyURLParm = "&amp;Key=Y";
            }

            string szSQL = string.Format(SQL_SELECT_UPDATE_COUNT, industryClause, keyCaluse);

            object oUpdateCount = GetDBAccess().ExecuteScalar(szSQL, oParameters);
            int iUpdateCount = (int)oUpdateCount;

            if (iUpdateCount == 0)
            {
                return null;
            }

            bool bHyperlink = WebUser.HasPrivilege(SecurityMgr.Privilege.CompanyUpdatesSearchPage).HasPrivilege;

            StringBuilder updateMsg = new StringBuilder();

            if (dateThrehsold == 1)
            {
                updateMsg.Append(Resources.Global.InLastDay);
            }
            else
            {
                updateMsg.Append(Resources.Global.InLastDays);
            }

            updateMsg.Append(", ");

            if (bHyperlink)
            {
                updateMsg.Append("<a href='" + PageConstants.COMPANY_UPDATE_SEARCH + "?Action=Search" + keyURLParm + "' class='"+ szHyperlinkClass + "'>");
            }

            updateMsg.Append(" {1} ");

            if (iUpdateCount == 1)
            {
                if (string.IsNullOrEmpty(keyMsg))
                {
                    updateMsg.Append(Resources.Global.Change);
                }
                else
                {
                    updateMsg.Append(Resources.Global.KeyChange);
                }
            }
            else
            {
                if (string.IsNullOrEmpty(keyMsg))
                {
                    updateMsg.Append(Resources.Global.Changes);
                }
                else
                {
                    updateMsg.Append(Resources.Global.KeyChanges);
                }
            }

            if (bHyperlink)
            {
                updateMsg.Append("</a> ");
            }

            if (iUpdateCount > 1)
            {
                updateMsg.Append(Resources.Global.havebeenreported);
            }
            else
            {
                updateMsg.Append(Resources.Global.hasbeenreported);
            }

            updateMsg.Append(".");
            return string.Format(updateMsg.ToString(), dateThrehsold, iUpdateCount);
        }

        protected const string SQL_SELECT_AVAIL_BRS =
            @"SELECT dbo.ufn_GetAvailableUnits({0}) As AvailBRs";
        public string GetServiceUnitMessage(string szHyperlinkClass = "messages")
        {
            // Ignore the year portion of the config value as we need to apply the day/month to
            // every year.
            int Threshold_Month = Utilities.GetIntConfigValue("MsgCenterBusinsesReportDisplayThreshold_Month", 9);
            int Threshold_Day = Utilities.GetIntConfigValue("MsgCenterBusinsesReportDisplayThreshold_Day", 1);
            DateTime displayThreshold = new DateTime(DateTime.Today.Year, Threshold_Month, Threshold_Day);

            if (DateTime.Today < displayThreshold)
            {
                return null;
            }

            string szSQL = string.Format(SQL_SELECT_AVAIL_BRS, WebUser.prwu_BBID);
            int availBRCount = (int)GetDBAccess().ExecuteScalar(szSQL);

            if (availBRCount <= 0)
            {
                return null;
            }

            if (WebUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                if (WebUser.prwu_Culture == PageBase.SPANISH_CULTURE)
                    return string.Format(Utilities.GetConfigValue("MsgCenterBusinessReportMsgL_ES"), availBRCount);
                else
                    return string.Format(Utilities.GetConfigValue("MsgCenterBusinessReportMsgL"), availBRCount);
            }
            else
            {
                if (WebUser.prwu_Culture == PageBase.SPANISH_CULTURE)
                    return string.Format(Utilities.GetConfigValue("MsgCenterBusinessReportMsg_ES"), availBRCount);
                else
                    return string.Format(Utilities.GetConfigValue("MsgCenterBusinessReportMsg"), availBRCount);
                
            }
        }

        public string GetSuspensionPendingMessage()
        {
            if (!Utilities.GetBoolConfigValue("EnterpriseSuspensionPendingMsgEnabled", false))
            {
                return null;
            }

            if (!WebUser.prci2_SuspensionPending)
            {
                return null;
            }

            return Resources.Global.MyMessageCenterEnterpriseSuspensionPendingMsg;
        }
    }
}