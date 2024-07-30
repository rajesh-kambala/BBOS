using System;
using System.Collections;
using System.Linq;
using System.Text;

using TSI.BusinessObjects;
using TSI.DataAccess;

namespace PRCo.EBB.BusinessObjects
{
    [Serializable]
    public class PRWebUserCustomFieldSearchCriteria
    {
        public int CustomFieldID;
        public int CustomFieldLookupID;
        public string SearchValue;
        public bool MustHaveValue;


        private const string SQL_BASE =
            @"SELECT prwucd_AssociatedID
                FROM PRWebUserCustomData WITH (NOLOCK)
               WHERE prwucd_WebUserCustomFieldID = {0}";

        private const string SQL_LOOKUP_VALUE = "  AND prwucd_WebUserCustomFieldLookupID = {1}";
        private const string SQL_VALUE = " AND prwucd_Value LIKE {1}";
        private const string SQL_MUST_HAVE_VALUE = " AND (prwucd_Value IS NOT NULL OR IsNull(prwucd_WebUserCustomFieldLookupID, 0) > 0)";

        public string GetSearchSQL(IList oParameters, IDBAccess dbAccess)
        {
            string sql = SQL_BASE;
            string fieldIDParmName = "CustomFieldID" + oParameters.Count.ToString();
            string fieldValueParmName = "CustomValue" + (oParameters.Count + 1).ToString();
            oParameters.Add(new ObjectParameter(fieldIDParmName, CustomFieldID));

            if (MustHaveValue)
            {
                sql += SQL_MUST_HAVE_VALUE;
                sql = string.Format(sql, "@" + fieldIDParmName);
            }
            else
            {
                if (CustomFieldLookupID > 0)
                {
                    sql += SQL_LOOKUP_VALUE;
                    oParameters.Add(new ObjectParameter(fieldValueParmName, CustomFieldLookupID));
                }
                else
                {
                    sql += SQL_VALUE;
                    oParameters.Add(new ObjectParameter(fieldValueParmName, dbAccess.TranslateWildCards("*" + SearchValue + "*")));
                }
                sql = string.Format(sql, "@" + fieldIDParmName, "@" + fieldValueParmName);
            }
            return sql;
        }
    }
}
