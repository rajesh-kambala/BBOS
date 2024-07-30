/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: SecurityMgr
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using TSI.DataAccess;

namespace PRCo.EBB.BusinessObjects
{
    public class SecurityMgr
    {  

        public enum Privilege
        {
            BBOSTrainingPage,
            BlueprintsPage,
            BusinessReportPurchase,
            BusinessReportSurvey,
            ClaimActivitySearchPage,
            CompanyAnalysisPage,
            CompanyDetailsARReportsPage,
            CompanyDetailsBranchesAffiliationsPage,
            CompanyDetailsChainStoreGuidePage,
            CompanyDetailsClaimActivityPage,
            CompanyDetailsClassificationsCommoditesPage,
            CompanyDetailsClassificationsCommoditesProductSerivcesSpeciesPage,
            CompanyDetailsContactsPage,
            CompanyDetailsCustomPage,
            CompanyDetailsListingPage,
            CompanyDetailsNewPages,
            CompanyDetailsNewsPage,
            CompanyDetailsUpdatesPage,
            CompanyEditFinancialStatementPage,
            CompanyEditListingPage,
            CompanyEditReferenceListPage,
            CompanyListingDownload,
            CompanyReportsPage,
            CompanySearchByBBScore,
            CompanySearchByBrand,
            CompanySearchByClassifications,
            CompanySearchByCommodities,
            CompanySearchByCommodityAttributes,
            CompanySearchByCorporateStructure,
            CompanySearchByCreditWorthRating,
            CompanySearchByEmail,
            CompanySearchByHasEmail,
            CompanySearchByHasFax,
            CompanySearchByHasNotes,
            CompanySearchByIntegrityRating,
            CompanySearchByLicense,
            CompanySearchByListingStatus,
            CompanySearchByMiscListing,
            CompanySearchByNewListings,
            CompanySearchByNumberofRestaraunts,
            CompanySearchByNumberofRetailStores,
            CompanySearchByPayIndicator,
            CompanySearchByPayRating,
            CompanySearchByPayReportCount,
            CompanySearchByPhoneFaxNumber,
            CompanySearchByProducts,
            CompanySearchByRadius,
            CompanySearchBySalvageDistressedProduce,
            CompanySearchByServices,
            CompanySearchBySpecie,
            CompanySearchByTerminalMarket,
            CompanySearchByTMFMMembershipYear,
            CompanySearchByVolume,
            CompanySearchByWatchdogList,
            CompanySearchClassificationsPage,
            CompanySearchCommoditiesPage,
            CompanySearchCustomPage,
            CompanySearchLocationPage,
            CompanySearchPage,
            CompanySearchProductsPage,
            CompanySearchProfilePage,
            CompanySearchRatingPage,
            CompanySearchResultsAutoRedirect1Result,
            CompanySearchServicesPage,
            CompanySearchSpeciePage,
            CompanyUpdatesDownloadPage,
            CompanyUpdatesSearchPage,
            CustomFields,
            DataExportBasicCompanyDataExport,
            DataExportCompanyDataExport,
            DataExportCompanyDataExportWBBScore,
            DataExportContactExportAllContacts,
            DataExportContactExportHeadExecutive,
            DataExportDetailedCompanyDataExport,
            DataExportPage,
            DownloadsPage,
            GetTMFMWidget,
            KnowYourCommodityPage,
            LearningCenterPage,
            ManageMembershipPage,
            MembershipGuidePage,
            MembershipUpgrade,
            NewHireAcademyPage,
            NewsPage,
            Notes,
            PersonAccessListPage,
            PersonDetailsPage,
            PersonReportsPage,
            PersonSearchByIndustry,
            PersonSearchByNotes,
            PersonSearchByRadius,
            PersonSearchByRole,
            PersonSearchByTerminalMarket,
            PersonSearchByWatchdogList,
            PersonSearchCustomPage,
            PersonSearchLocationPage,
            PersonSearchNotes,
            PersonSearchPage,
            PersonvCard,
            PurchasesPage,
            RecentViewsPage,
            ReferenceGuidePage,
            ReportAdCampaign,
            ReportBankruptcy,
            ReportBBScore,
            ReportCompanyAnalysis,
            ReportCompanyAnalysisExport,
            ReportCompanyListing,
            ReportCompanyUpdateList,
            ReportCreditSheet,
            ReportCreditSheetExport,
            ReportFullBlueBookListing,
            ReportMailingLabels,
            ReportNotes,
            ReportPersonnel,
            ReportQuickList,
            ReportRatingComparison,
            RSS,
            SaveSearches,
            SystemAdmin,
            TradeExperienceSurveyPage,
            TradingAssistancePage,
            UserContacts,
            ViewBBScore,
            ViewCompanyListing,
            ViewRating,
            ViewPayIndicator,
            WatchdogListAdd,
            WatchdogListsPage,
            WebServices,
            LocalSourceDataAccess,
			PersonDataExport,
            CompanySearchByFTEmployees,
            CompanySearchByIndustry,
            ViewMap,
            ViewPerformanceIndicators,
            MadisonLumberPagePrint,
            WatchdogListNew,
            ViewBBScoreHistory,
            ViewRatingHistory
        }

    private class PrivilgeInternal
        {
            public int AccessLevel;
            public string Role;
            public bool Visible;
            public bool Enabled;
        }

        public class SecurityResult
        {
            public Privilege Privilege;
            public bool HasPrivilege = false;
            public bool Visible = false;
            public bool Enabled = false;
        }

        static public SecurityResult HasPrivilege(IPRWebUser user, Privilege privilege)
        {

            LoadData();

            int accessLevel = Convert.ToInt32(user.prwu_AccessLevel);
            bool hasRole = true;

            SecurityResult result = new SecurityResult();
            result.Privilege = privilege;

            string key = GenerateKey(user.prwu_IndustryType, privilege.ToString());
            if (_privileges.ContainsKey(key))
            {
                PrivilgeInternal p = _privileges[key];

                result.Visible = p.Visible;
                result.Enabled = p.Enabled;

                if (!string.IsNullOrEmpty(p.Role))
                {
                    hasRole = user.IsInRole(p.Role);
                }

                if (hasRole && accessLevel >= p.AccessLevel)
                {
                    result.HasPrivilege = true;
                    result.Visible = true;
                    result.Enabled = true;
                }
                else if(privilege == Privilege.ViewBBScore && accessLevel == PRWebUser.SECURITY_LEVEL_TRADE_ASSOCIATION_ACCESS)
                {
                    result.HasPrivilege = true;
                    result.Visible = true;
                    result.Enabled = true;
                }
            }

            return result;
        }


        static public SecurityResult HasLocalSourceDataAccess(IPRWebUser user, int regionID)
        {
            SecurityResult result = HasPrivilege(user, Privilege.LocalSourceDataAccess);

            return result;
        }


        static public List<SecurityResult> GetPrivileges(IPRWebUser user)
        {
            List<SecurityResult> privileges = new List<SecurityResult>();

            foreach (Privilege privilege in Enum.GetValues(typeof(Privilege)))
            {
                privileges.Add(HasPrivilege(user, privilege));
            }

            return privileges;
        }


        private static Dictionary<string, PrivilgeInternal> _privileges;


        private static object SECURITY_LOCK = new Object();

        static private void LoadData()
        {
            if (_privileges != null)
            {
                return;
            }

            lock (SECURITY_LOCK)
            {
                if (_privileges != null)
                {
                    return;
                }

                _privileges = new Dictionary<string, PrivilgeInternal>();


                IDBAccess dbAccess = DBAccessFactory.getDBAccessProvider();
                using (IDataReader reader = dbAccess.ExecuteReader("SELECT IndustryType, Privilege, AccessLevel, Role, Visible, Enabled FROM PRBBOSPrivilege ORDER BY IndustryType, Privilege", CommandBehavior.CloseConnection))
                {
                    while (reader.Read())
                    {
                        PrivilgeInternal privilegeInternal = new PrivilgeInternal();
                        privilegeInternal.AccessLevel = reader.GetInt32(2);

                        if (reader[3] != DBNull.Value)
                        {
                            privilegeInternal.Role = reader.GetString(3);
                        }

                        privilegeInternal.Visible = reader.GetBoolean(4);
                        privilegeInternal.Enabled = reader.GetBoolean(5);

                        _privileges.Add(GenerateKey(reader.GetString(0), reader.GetString(1)), privilegeInternal);
                    }
                }
            }
        }

        static private string GenerateKey(string industry, string privilege)
        {
            return industry + ":" + privilege;
        }
    }
}
