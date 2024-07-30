using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;

namespace IntlTradeAssociationImport
{
    public class Commodity : EntityBase
    {
        public string Name;
        public int Sequence;

        public int CommodityID;
        public int AttributeID;
        public int GrowingMethodID;
        public int CompanyID;
        public string PublishedDisplay;


        //private const string SQL_SELECT_COMMODITY = @"SELECT prcm_CommodityID FROM PRCommodity WHERE prcm_FullName=@Name";

        private const string SQL_SELECT_COMMODITY =
        @"SELECT DISTINCT prcca_CommodityId, prcca_AttributeID, prcca_GrowingMethodID, prcx_Description, AttributeName, GrowingMethod, prcca_PublishedDisplay
            FROM vListingPRCompanyCommodity
           WHERE prcx_Description = @Name
             AND prcca_CommodityId <> 1";

        private void GetCommodityID(SqlTransaction sqlTrans)
        {
            Name = Name.Trim();
            
            SqlCommand cmdName = new SqlCommand();
            cmdName.Connection = sqlTrans.Connection;
            cmdName.Transaction = sqlTrans;
            cmdName.CommandText = SQL_SELECT_COMMODITY;
            cmdName.Parameters.AddWithValue("Name", Name);

            using (SqlDataReader reader = cmdName.ExecuteReader())
            {
                if (reader.Read())
                {
                    CommodityID = GetIntValue(reader, 0);
                    AttributeID = GetIntValue(reader, 1);
                    GrowingMethodID = GetIntValue(reader, 2);
                    PublishedDisplay = GetStringValue(reader, 6);
                } else
                {

                    // Special handling
                    if (Name.ToLower() == "chinese eggplant")
                    {
                        CommodityID = 549;
                        PublishedDisplay = "Chinep";
                    }
                    else
                    {

                        ParentImporter.AddException(ParentCompany, "Unable to find matching commodity: " + Name);
                        return;
                    }
                }
            }
        }

        private const string SQL_INSERT =
                    @"INSERT INTO PRCompanyCommodityAttribute (prcca_CompanyCommodityAttributeId,prcca_CompanyId,prcca_CommodityId,prcca_GrowingMethodID, prcca_AttributeID, prcca_Sequence, prcca_PublishedDisplay, prcca_Publish, prcca_PublishWithGM, prcca_CreatedBy, prcca_CreatedDate, prcca_UpdatedBy, prcca_UpdatedDate, prcca_Timestamp)
                       VALUES (@RecordID, @prcca_CompanyId, @prcca_CommodityId, @prcca_GrowingMethodID, @prcca_AttributeID, @prcca_Sequence, @prcca_PublishedDisplay, @prcca_Publish, @prcca_PublishWithGM, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp);";

        public void Save(SqlTransaction oTran)
        {
            GetCommodityID(oTran);
            if (CommodityID == 0)
            {
                return;
            }


            ParentImporter.WriteLine(" - Adding commodity: " + Name);

            int recordID = GetPIKSID("PRCompanyCommodityAttribute", oTran);

            SqlCommand sqlCommand = oTran.Connection.CreateCommand();
            sqlCommand.CommandText = SQL_INSERT;
            sqlCommand.Transaction = oTran;

            sqlCommand.Parameters.AddWithValue("RecordID", recordID);
            sqlCommand.Parameters.AddWithValue("prcca_CompanyId", CompanyID);
            sqlCommand.Parameters.AddWithValue("prcca_CommodityId", CommodityID);
            AddParameter(sqlCommand, "prcca_GrowingMethodID", GrowingMethodID);
            AddParameter(sqlCommand, "prcca_AttributeID", AttributeID);
            sqlCommand.Parameters.AddWithValue("prcca_PublishedDisplay", PublishedDisplay);
            sqlCommand.Parameters.AddWithValue("prcca_Sequence", Sequence);
            sqlCommand.Parameters.AddWithValue("prcca_Publish", "Y");

            if (GrowingMethodID > 0)
            {
                sqlCommand.Parameters.AddWithValue("prcca_PublishWithGM", "Y");
            } else
            {
                sqlCommand.Parameters.AddWithValue("prcca_PublishWithGM", DBNull.Value);
            }

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
