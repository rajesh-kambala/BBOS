using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using PRCo.EBB.BusinessObjects;

using TSI.Arch;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using TSI.Security;

namespace PRCo.EBB.BusinessObjects
{
    public class AdUtils 
    {

        public IPRWebUser WebUser;
        public ILogger Logger;

        

        public AdUtils()
        {

        }

        public AdUtils(ILogger logger, IPRWebUser webUser)
        {
            Logger = logger;
            WebUser = webUser;
        }

        public AdUtils(ILogger logger, int intWebUserID)
        {
            Logger = logger;

            PRWebUserMgr oWebUserMgr = new PRWebUserMgr(logger, null);

            if (oWebUserMgr.IsObjectExistByKey(intWebUserID))
            {
                WebUser = (IPRWebUser)oWebUserMgr.GetObjectByKey(intWebUserID);
            }
            else
            {
                WebUser = null;
            }
        }

        protected const string SQL_ADAUDITTRAIL_INSERT =
            @"INSERT INTO PRAdCampaignAuditTrail (pradcat_AdCampaignID, pradcat_AdEligiblePageID, pradcat_WebUserID, pradcat_CompanyID, pradcat_Rank, pradcat_SponsoredLinkType, pradcat_SearchAuditTrailID, pradcat_PageRequestID, pradcat_CreatedBy, pradcat_CreatedDate, pradcat_UpdatedBy, pradcat_UpdatedDate, pradcat_TimeStamp) 
                    VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12})";

        public int InsertAdAuditTrail(int iAdCampaignID,
                                      int iEligiblePageID,
                                      int iRank,
                                      string szLinkType,
                                      int iSearchAuditTrailID,
                                      IDbTransaction oTran)
        {
            return InsertAdAuditTrail(iAdCampaignID, iEligiblePageID, iRank, szLinkType, iSearchAuditTrailID, null, oTran);
        }

        /// <summary>
        /// Inserts the Ad Audit Trail record for the specified campaign.
        /// </summary>
        public int InsertAdAuditTrail(int iAdCampaignID,
                                      int iEligiblePageID,
                                      int iRank,
                                      string szLinkType,
                                      int iSearchAuditTrailID,
                                      string szPageRequestID,
                                      IDbTransaction oTran)
        {

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("pradcat_AdCampaignID", iAdCampaignID));
            oParameters.Add(new ObjectParameter("pradcat_AdEligiblePageID", iEligiblePageID));

            if (WebUser == null)
            {
                oParameters.Add(new ObjectParameter("pradcat_WebUserID", null));
                oParameters.Add(new ObjectParameter("pradcat_CompanyID", null));
            }
            else
            {
                oParameters.Add(new ObjectParameter("pradcat_WebUserID", WebUser.prwu_WebUserID));
                oParameters.Add(new ObjectParameter("pradcat_CompanyID", WebUser.prwu_BBID));
            }

            oParameters.Add(new ObjectParameter("pradcat_Rank", iRank));
            oParameters.Add(new ObjectParameter("pradcat_SponsoredLinkType", szLinkType));
            oParameters.Add(new ObjectParameter("pradcat_SearchAuditTrailID", iSearchAuditTrailID));

            if (string.IsNullOrEmpty(szPageRequestID))
            {
                oParameters.Add(new ObjectParameter("pradcat_PageRequestID", null));
            }
            else
            {
                oParameters.Add(new ObjectParameter("pradcat_PageRequestID", szPageRequestID));
            }


            GetObjectMgr().AddAuditTrailParametersForInsert(oParameters, "pradcat");
            int iAuditTrailID = GetObjectMgr().ExecuteIdentityInsert("PRAdCampaignAuditTrail", SQL_ADAUDITTRAIL_INSERT, oParameters, oTran);

            return iAuditTrailID;
        }


        protected const string SQL_UPDATE_IMPRESSION_COUNT = "UPDATE PRAdCampaign SET pradc_ImpressionCount = ISNULL(pradc_ImpressionCount, 0) + 1, pradc_PeriodImpressionCount = ISNULL(pradc_PeriodImpressionCount, 0) + 1 WHERE pradc_AdCampaignID IN ({0})";
        protected const string SQL_UPDATE_TOP_SPOT_COUNT = "UPDATE PRAdCampaign SET pradc_TopSpotCount = ISNULL(pradc_TopSpotCount, 0) + 1 WHERE pradc_AdCampaignID IN ({0})";
        /// <summary>
        /// Updates the Impression count for all ads that were displayed
        /// on this page.
        /// </summary>
        /// <param name="lCampaignIDs"></param>
        public void UpdateImpressionCount(List<Int32> lCampaignIDs, IDbTransaction oTrans)
        {
            if (lCampaignIDs.Count == 0)
            {
                return;
            }

            //// Exclude the PRCo company from any auditing
            //if (IsPRCoUser())
            //{
            //    return;
            //}

            string szInClause = string.Empty;

            foreach (int iCampaignID in lCampaignIDs)
            {
                if (szInClause.Length > 0)
                {
                    szInClause += ",";
                }
                szInClause += iCampaignID.ToString();
            }

            string szSQL = string.Format(SQL_UPDATE_IMPRESSION_COUNT, szInClause);
            if(oTrans == null)
                GetDBAccess().ExecuteNonQuery(szSQL);
            else
            {
                ArrayList oParameters = new ArrayList();
                GetDBAccess().ExecuteNonQuery(szSQL, oParameters, oTrans);
            }
        }

        public void UpdateTopSpotCount(List<Int32> lTopSpotCampaignIDs, IDbTransaction oTrans)
        {
            if (lTopSpotCampaignIDs.Count == 0)
            {
                return;
            }

            //// Exclude the PRCo company from any auditing
            //if (IsPRCoUser())
            //{
            //    return;
            //}

            string szInClause = string.Empty;

            foreach (int iCampaignID in lTopSpotCampaignIDs)
            {
                if (szInClause.Length > 0)
                {
                    szInClause += ",";
                }
                szInClause += iCampaignID.ToString();
            }
            
            string szSQL = string.Format(SQL_UPDATE_TOP_SPOT_COUNT, szInClause);

            if (oTrans == null)
                GetDBAccess().ExecuteNonQuery(szSQL);
            else
            {
                ArrayList oParameters = new ArrayList();
                GetDBAccess().ExecuteNonQuery(szSQL, oParameters, oTrans);
            }
        }

        private const string SQL_SELECT_IMAGE_AD =
            @"SELECT TOP {0} pradc_AdCampaignID
	            FROM PRAdCampaign WITH (NOLOCK) 
               WHERE pradc_AdCampaignTypeDigital = @CampaignType 
	             AND GETDATE() BETWEEN pradc_StartDate AND ISNULL(pradc_EndDate, DATEADD(day, 1, GETDATE())) 
            ORDER BY ISNULL(pradc_AlwaysDisplay, 'Z'), pradc_PeriodImpressionCount";

        /// <summary>
        /// The critiera used to determine if an image ad is displayed on a page, from a
        /// SQL perspective, conflicts with the criteria used to order the Ads. So we have
        /// to break this into a two-step process.
        /// </summary>
        /// <param name="oParameters"></param>
        /// <returns></returns>
        public string GetAdCampaignList(ArrayList oParameters)
        {
            StringBuilder sbAdCampaignIDs = new StringBuilder();
            using (IDataReader oReader = GetDBAccess().ExecuteReader(string.Format(SQL_SELECT_IMAGE_AD, 1), oParameters, CommandBehavior.CloseConnection, null))
            {
                while (oReader.Read())
                {
                    if (sbAdCampaignIDs.Length > 0)
                    {
                        sbAdCampaignIDs.Append(",");
                    }
                    sbAdCampaignIDs.Append(oReader.GetInt32(0).ToString());
                }
            }

            return sbAdCampaignIDs.ToString();
        }



        protected GeneralDataMgr _oObjectMgr;
        /// <summary>
        /// Helper method that returns an EBBObjectMgr object.  This is
        /// cached in a member variable.
        /// </summary>
        /// <returns></returns>
        public GeneralDataMgr GetObjectMgr()
        {
            if (_oObjectMgr == null)
            {
                _oObjectMgr = new GeneralDataMgr(Logger, WebUser);
            }
            return _oObjectMgr;
        }

        protected IDBAccess _oDBAccess;
        protected IDBAccess GetDBAccess()
        {
            if (_oDBAccess == null)
            {
                _oDBAccess = DBAccessFactory.getDBAccessProvider();
                _oDBAccess.Logger = Logger;
            }

            return _oDBAccess;
        }
    }
}
