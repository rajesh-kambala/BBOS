using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PRCo.BBS.CRM.PRGeneral
{
    public partial class AssignUnitAllocations : PageBase
    {
        private const string SQL_ALLOCATE_UNITS =
        @"INSERT INTO PRServiceUnitAllocation (prun_ServiceUnitAllocationID, prun_HQID, prun_CompanyID, prun_PersonID, prun_ServiceID, prun_SourceCode, prun_AllocationTypeCode, prun_StartDate, prun_ExpirationDate, prun_UnitsAllocated, prun_UnitsRemaining prun_CreatedBy, prun_CreatedDate, prun_UpdatedBy, prun_UpdatedDate, prun_TimeStamp,)
           VALUES (@ServiceUnitAllocationID, @CompanyID, @CompanyID, @PersonID, @ServiceID, @SourceType, @AllocationType, @StartDate, @EndDate, @Units, @Units, @CRMUserID, GETDATE(), @CRMUserID, GETDATE(), GETDATE());";

        protected void btnSaveClick(object sender, EventArgs e) {


            string companyIDs = txtCompanyIDs.Text;
            DateTime expirationDate = Convert.ToDateTime(txtExpirationDate.Text);
            int units = Convert.ToInt32(txtUnits.Text);

            string[] acompanyIDs = companyIDs.Split(',');

            SqlCommand cmdAllocateUnits = null;
            SqlConnection dbConn = OpenDBConnection();
            try
            {

                foreach (string companyID in acompanyIDs)
                {

                    if (cmdAllocateUnits == null)
                    {
                        cmdAllocateUnits = new SqlCommand("usp_AllocateServiceUnits", dbConn);
                        cmdAllocateUnits.CommandType = System.Data.CommandType.StoredProcedure;
                    }

                    cmdAllocateUnits.Parameters.Clear();
                    cmdAllocateUnits.Parameters.AddWithValue("CompanyID", companyID);
                    cmdAllocateUnits.Parameters.AddWithValue("Unt", companyID);
                    cmdAllocateUnits.Parameters.AddWithValue("CompanyID", companyID);
                    cmdAllocateUnits.Parameters.AddWithValue("CompanyID", companyID);
                }
            }
            finally
            {
                dbConn.Close();
            }
        }
    }
}