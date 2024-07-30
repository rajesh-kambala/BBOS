using System;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IntlTradeAssociationImport
{
    public class Phone : EntityBase
    {
        public string CountryCode;
        public string Number;
        public string Type;
        private string TypeCode;
        public string Description;

        public int CompanyID;
        public int PersonID;
        public int EmailID;
        public int PhoneID;

        public void SetTypeCode ()
        {
            switch (Type.ToLower())
            {
                case "c":
                case "cell":
                    TypeCode = "C";
                    break;

                case "f":
                case "fax":
                    TypeCode = "F";
                    break;

                default:
                    TypeCode = "P";
                    break;
            }
        }

        public void Save(SqlTransaction oTran)
        {
            if (string.IsNullOrEmpty(Number))
            {
                return;
            }

            if (Number.Length != 10)
            {
                return;
            }

            PhoneID = GetPhoneID(oTran);
            if (PhoneID > 0)
            {
                return;
            }

            string areaCode = Number.Substring(0, 3);
            string phoneNumber = Number.Substring(3, 3) + "-" + Number.Substring(6, 4);

            
            SqlCommand cmdSave = oTran.Connection.CreateCommand();
            cmdSave.CommandText = "usp_InsertPhone";
            cmdSave.Transaction = oTran;
            cmdSave.CommandTimeout = 300;
            cmdSave.CommandType = System.Data.CommandType.StoredProcedure;

            switch (TypeCode)
            {
                case "P":
                    cmdSave.Parameters.AddWithValue("Description", "Phone");
                    break;
                case "F":
                    cmdSave.Parameters.AddWithValue("Description", "FAX");
                    break;
                case "PF":
                    cmdSave.Parameters.AddWithValue("Description", "Phone or FAX");
                    break;
                case "C":
                    cmdSave.Parameters.AddWithValue("Description", "Cell");
                    break;
            }

            cmdSave.Parameters.AddWithValue("AreaCode", areaCode);
            cmdSave.Parameters.AddWithValue("Number", phoneNumber);
            cmdSave.Parameters.AddWithValue("Extension", DBNull.Value);
            cmdSave.Parameters.AddWithValue("International", DBNull.Value);
            cmdSave.Parameters.AddWithValue("CityCode", DBNull.Value);
            cmdSave.Parameters.AddWithValue("Disconnected", DBNull.Value);
            cmdSave.Parameters.AddWithValue("CountryCode", CountryCode);
            cmdSave.Parameters.AddWithValue("Publish", "Y");
            cmdSave.Parameters.AddWithValue("Type", TypeCode);
            cmdSave.Parameters.AddWithValue("UserID", UPDATED_BY);

            // Only save this comnpany ID on person phone
            // records.
            if (PersonID > 0)
            {
                cmdSave.Parameters.AddWithValue("CompanyID", CompanyID);
                cmdSave.Parameters.AddWithValue("EntityID", 13);
                cmdSave.Parameters.AddWithValue("RecordID", PersonID);
            }
            else
            {
                if (ParentCompany.HasPhonePreferrePublished)
                {
                    cmdSave.Parameters.AddWithValue("PreferredPublish", DBNull.Value);
                }
                else
                {
                    cmdSave.Parameters.AddWithValue("PreferredPublish", "Y");
                    ParentCompany.HasPhonePreferrePublished = true;
                }

                if (ParentCompany.HasPhonePreferredInternal)
                {
                    cmdSave.Parameters.AddWithValue("PreferredInternal", DBNull.Value);
                }
                else
                {
                    cmdSave.Parameters.AddWithValue("PreferredInternal", "Y");
                    ParentCompany.HasPhonePreferredInternal = true;
                }

                cmdSave.Parameters.AddWithValue("CompanyID", DBNull.Value);
                cmdSave.Parameters.AddWithValue("EntityID", 5);
                cmdSave.Parameters.AddWithValue("RecordID", CompanyID);
            }

            cmdSave.ExecuteNonQuery();
            PhoneID = GetPhoneID(oTran);
        }

        private const string SQL_SELECT_PHONE =
                   "SELECT phon_PhoneID FROM vPRPhone WITH (NOLOCK) WHERE plink_RecordID=@RecordID AND plink_EntityID=@EntityID AND phon_PhoneMatch=dbo.ufn_GetLowerAlpha(@Phone)";


        protected int GetPhoneID(SqlTransaction sqlTrans)
        {
            SqlCommand cmdPhone = new SqlCommand();
            cmdPhone.Connection = sqlTrans.Connection;
            cmdPhone.Transaction = sqlTrans;
            cmdPhone.CommandText = SQL_SELECT_PHONE;

            if (PersonID > 0)
            {
                cmdPhone.Parameters.AddWithValue("EntityID", 13);
                cmdPhone.Parameters.AddWithValue("RecordID", PersonID);
            }
            else
            {
                cmdPhone.Parameters.AddWithValue("EntityID", 5);
                cmdPhone.Parameters.AddWithValue("RecordID", CompanyID);
            }

            cmdPhone.Parameters.AddWithValue("Phone", Number);

            object result = cmdPhone.ExecuteScalar();
            if ((result == null) ||
                (result == DBNull.Value))
            {
                return 0;
            }

            return Convert.ToInt32(result);
        }

        public static bool HasPhoneFlag(SqlTransaction sqlTrans, int companyID, string phoneTypeFlag, string flagType)
        {
            SqlCommand cmdFlagCheck = sqlTrans.Connection.CreateCommand();
            cmdFlagCheck.Transaction = sqlTrans;
            cmdFlagCheck.Parameters.AddWithValue("CompanyID", companyID);
            cmdFlagCheck.CommandText = string.Format("SELECT 'x' FROM vPRCompanyPhone WHERE plink_RecordID=@CompanyID AND  {0} = 'Y' AND {1} = 'Y'", phoneTypeFlag, flagType);

            object result = cmdFlagCheck.ExecuteScalar();
            if ((result == null) ||
                (result == DBNull.Value))
            {
                return false;
            }

            return true;
        }
    }
}
