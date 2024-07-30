using System;
using System.Collections.Generic;
using System.Data;

using PRCo.EBB.BusinessObjects;
using TSI.DataAccess;


namespace PRCo.BBOS.Security
{
    public class SecurityService
    {



        public enum Privilege
        {
            BlueBookReference,
            BlueBpokServices,
            Blueprints,
            ClaimActivitySearch,
            CompanyAnalysis,
            CompanyDetailsBranches,
            CompanyDetailsCSG,
            CompanyDetailsClassifications,
            CompanyDetailsContacts,
            CompanyDetailsCustom,
            CompanyDetailsSummary,
            CompanyDetailsNews,
            CompanyDetailsUpdates,
            BBScore,
            Rating
        }

        private class PrivilgeInternal
        {
            public int AccessLevel;
            public string Role;
        }

        static public bool HasPrivilege(IPRWebUser user, Privilege privilge) {

            LoadData();

            int accessLevel = Convert.ToInt32(user.prwu_AccessLevel);
            bool hasRole = true;

            if (user.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_PRODUCE)
            {
                if (_producePrivileges.ContainsKey(privilge.ToString()))
                {
                    PrivilgeInternal p = _producePrivileges[privilge.ToString()];

                    if (!string.IsNullOrEmpty(p.Role))
                    {
                        hasRole = user.IsInRole(p.Role);
                    }

                    if (hasRole && accessLevel >= p.AccessLevel)
                    {
                        return true;
                    }                
                }
            }

            return false;
        }

        private static Dictionary<string, PrivilgeInternal> _producePrivileges;


        private static string SECURITY_LOCK = "x";

        static private void LoadData()
        {
            if (_producePrivileges != null)
            {
                return;
            }

            lock (SECURITY_LOCK)
            {
                if (_producePrivileges != null)
                {
                    return;
                }

                _producePrivileges = new Dictionary<string, PrivilgeInternal>();


                IDBAccess dbAccess = DBAccessFactory.getDBAccessProvider();
                using (IDataReader reader = dbAccess.ExecuteReader("SELECT IndustryType, AccessLevel, Privilege, Role FROM PRBBOSPrivilege ORDER BY IndustryType, Privilege"))
                {
                    while (reader.Read())
                    {
                        if (reader.GetString(0) == GeneralDataMgr.INDUSTRY_TYPE_PRODUCE)
                        {
                            PrivilgeInternal privilegeInternal = new PrivilgeInternal();
                            privilegeInternal.AccessLevel = reader.GetInt32(1);
                            privilegeInternal.Role = reader.GetString(3);

                            _producePrivileges.Add(reader.GetString(2), privilegeInternal);
                        }
                    }
                }
            }
        }
    }
}
