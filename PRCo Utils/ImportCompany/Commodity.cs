using System.Data.SqlClient;


namespace BBSI.CompanyImport
{
    public class Commodity : ImportBase
    {
        public int CompanyID;
        public int CommodityID;
        public int Sequence;
        public string PublishedDisplay;

        public Commodity(int commodityID, string publishedDisplay, int sequence)
        {
            CommodityID = commodityID;
            PublishedDisplay = publishedDisplay;

            switch(CommodityID) {
                case 37:  // F
                    Sequence = 5000;
                    break;
                case 291: // V
                    Sequence = 5001;
                    break;
                default:
                    Sequence = sequence;
                    break;
            }
        }

        private const string SQL_INSERT =
                    @"INSERT INTO PRCompanyCommodityAttribute (prcca_CompanyCommodityAttributeId,prcca_CompanyId,prcca_CommodityId,prcca_Sequence, prcca_PublishedDisplay, prcca_Publish, prcca_CreatedBy, prcca_CreatedDate, prcca_UpdatedBy, prcca_UpdatedDate, prcca_Timestamp)
                       VALUES (@RecordID, @prcca_CompanyId, @prcca_CommodityId, @prcca_Sequence, @prcca_PublishedDisplay, @prcca_Publish, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp);";

        public void Save(SqlTransaction oTran)
        {
            int recordID = GetPIKSID("PRCompanyCommodityAttribute", oTran);

            SqlCommand sqlCommand = oTran.Connection.CreateCommand();
            sqlCommand.CommandText = SQL_INSERT;
            sqlCommand.Transaction = oTran;

            sqlCommand.Parameters.AddWithValue("RecordID", recordID);
            sqlCommand.Parameters.AddWithValue("prcca_CompanyId", CompanyID);
            sqlCommand.Parameters.AddWithValue("prcca_CommodityId", CommodityID);
            sqlCommand.Parameters.AddWithValue("prcca_PublishedDisplay", PublishedDisplay);
            sqlCommand.Parameters.AddWithValue("prcca_Sequence", Sequence);
            sqlCommand.Parameters.AddWithValue("prcca_Publish", "Y");
            sqlCommand.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            sqlCommand.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            sqlCommand.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            sqlCommand.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            sqlCommand.Parameters.AddWithValue("Timestamp", UPDATED_DATE);

            sqlCommand.ExecuteNonQuery();
        }


        private const string SQL_DELETE_ALL =
                    @"DELETE FROM  PRCompanyCommodityAttribute WHERE prcca_CompanyId = @prcca_CompanyId;";

        public static void DeleteAll(SqlTransaction oTran, int companyID)
        {
            SqlCommand sqlCommand = oTran.Connection.CreateCommand();
            sqlCommand.CommandText = SQL_DELETE_ALL;
            sqlCommand.Transaction = oTran;

            sqlCommand.Parameters.AddWithValue("prcca_CompanyId", companyID);
            sqlCommand.ExecuteNonQuery();
        }
    }
}
