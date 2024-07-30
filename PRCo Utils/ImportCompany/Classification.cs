using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;

namespace BBSI.CompanyImport
{
    public class Classification: ImportBase
    {
        public int CompanyID;
        public int ClassificationID;

        public Classification(int classificationID)
        {
            ClassificationID = classificationID;
        }

        private const string SQL_PRCOMPANY_CLASSIFICATION_INSERT =
            "INSERT INTO PRCompanyClassification (prc2_CompanyClassificationId, prc2_CompanyId, prc2_ClassificationId, prc2_CreatedBy, prc2_CreatedDate, prc2_UpdatedBy, prc2_UpdatedDate, prc2_Timestamp) " +
            "VALUES (@CompanyClassificationId, @CompanyId, @ClassificationId, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        public void Save(SqlTransaction sqlTrans)
        {
            int iCompanyClassificationID = GetPIKSID("PRCompanyClassification", sqlTrans);

            SqlCommand sqlCommand = sqlTrans.Connection.CreateCommand();
            sqlCommand.CommandText = SQL_PRCOMPANY_CLASSIFICATION_INSERT;
            sqlCommand.Transaction = sqlTrans;
            sqlCommand.Parameters.AddWithValue("CompanyClassificationId", iCompanyClassificationID);
            sqlCommand.Parameters.AddWithValue("CompanyID", CompanyID);
            sqlCommand.Parameters.AddWithValue("ClassificationId", ClassificationID);
            sqlCommand.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            sqlCommand.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            sqlCommand.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            sqlCommand.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            sqlCommand.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            sqlCommand.ExecuteNonQuery();
        }

        private const string SQL_DELETE_ALL =
                    @"DELETE FROM  PRCompanyClassification WHERE prc2_CompanyId = @prc2_CompanyId;";

        public static void DeleteAll(SqlTransaction oTran, int companyID)
        {
            SqlCommand sqlCommand = oTran.Connection.CreateCommand();
            sqlCommand.CommandText = SQL_DELETE_ALL;
            sqlCommand.Transaction = oTran;

            sqlCommand.Parameters.AddWithValue("prc2_CompanyId", companyID);
            sqlCommand.ExecuteNonQuery();
        }
    }
}
