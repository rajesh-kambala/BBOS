/***********************************************************************
 Copyright Blue Book Services, Inc. 2016-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CalculatePayIndicator.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;

using TSI.Utils;

namespace BBSI.PayIndicator
{
    public class CalculatePayIndicator
    {
        protected const string AR_DETAIL_MSG = "{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}\t{8}\t{9}\t{10}\t{11}\t{12}";

        protected const string SQL_SELECT_COMPANY_AR_DETAILS =
           @"SELECT * 
               FROM vPRPayIndicatorCompanyDetail 
              WHERE praa_Date >= DATEADD(month, @DateThreshold, GETDATE()) 
                AND SubjectCompanyID = @SubjectCompanyID ORDER BY praa_Date DESC";

        protected const string SQL_INSERT_PAY_INDICATOR =
            @"INSERT INTO PRCompanyPayIndicator (prcpi_CompanyID, prcpi_TotalCount, prcpi_CurrentCount, prcpi_CurrentAmount, prcpi_TotalAmount, prcpi_PayIndicatorScore, prcpi_PayIndicator, prcpi_Current, prcpi_CreatedBy, prcpi_CreatedDate, prcpi_UpdatedBy, prcpi_UpdatedDate, prcpi_TimeStamp) 
              VALUES (@CompanyID, @TotalCount, @CurrentCount, @CurrentAmount, @TotalAmount, @PayIndicatorScore, @PayIndicator, @Current, -1, GETDATE(), -1, GETDATE(), GETDATE())";



        public void Calculate(SqlConnection oConn, SqlTransaction oTran, PayIndicatorEligibleCompany oPIECompany)
        {
            bool bCalcPayIndicator = true;
            bool bFoundNuisance = false;
            decimal dCurrentCount = 0;
            decimal dTotalCount = 0;
            decimal dCurrentAmount = 0;
            decimal dTotalDollars = 0;
            decimal dScore = 0;
            int iARDetailCount = 0;

            int iMinThresholdDetailCount1 = 0;
            int iMinThresholdDetailCount2 = 0;

            // Define all of our per company variables here so that we can reuse them
            // in each iteration of the loop, instead of allocating more and more memory
            // on the heap.
            DateTime dtCompanyStartDate = DateTime.Now;
            DateTime dtCompanyEndDate = DateTime.Now;

            oPIECompany.ActionCode = "UC";  // Unchanged;


            decimal dCountWeight = Utilities.GetDecimalConfigValue("CalculatePayIndicatorCountWeight", 0.4M);
            decimal dAmountWeight = Utilities.GetDecimalConfigValue("CalculatePayIndicatorAmountWeight", 0.6M);

            string szScore01Code = Utilities.GetConfigValue("CalculatePayIndicatorScore01Code", "A");
            decimal dScore01MinValue = Utilities.GetDecimalConfigValue("CalculatePayIndicatorScore01MinValue", 0.9M);
            string szScore02Code = Utilities.GetConfigValue("CalculatePayIndicatorScore02Code", "B");
            decimal dScore02MinValue = Utilities.GetDecimalConfigValue("CalculatePayIndicatorScore02MinValue", 0.8M);
            string szScore03Code = Utilities.GetConfigValue("CalculatePayIndicatorScore03Code", "C");
            decimal dScore03MinValue = Utilities.GetDecimalConfigValue("CalculatePayIndicatorScore03MinValue", 0.7M);
            string szScore04Code = Utilities.GetConfigValue("CalculatePayIndicatorScore04Code", "D");
            decimal dScore04MinValue = Utilities.GetDecimalConfigValue("CalculatePayIndicatorScore04MinValue", 0.6M);
            string szScore05Code = Utilities.GetConfigValue("CalculatePayIndicatorScore05Code", "E");
            decimal dScore05MinValue = Utilities.GetDecimalConfigValue("CalculatePayIndicatorScore05MinValue", 0.0M);

            int iMinThresholdDays1 = Utilities.GetIntConfigValue("CalculatePayIndicatorMinThresholdDate1", 100);
            int iMinThresholdCount1 = Utilities.GetIntConfigValue("CalculatePayIndicatorMinhresholdCount1", 3);

            int iMinThresholdDays2 = Utilities.GetIntConfigValue("CalculatePayIndicatorMinThresholdDate2", 70);
            int iMinThresholdCount2 = Utilities.GetIntConfigValue("CalculatePayIndicatorMinhresholdCount2", 1);

            SqlCommand oSQLCommandDetails = new SqlCommand(SQL_SELECT_COMPANY_AR_DETAILS, oConn, oTran);
            SqlCommand oSQLCommandInsert = new SqlCommand(SQL_INSERT_PAY_INDICATOR, oConn, oTran);

            List<Int32> lSubmitterIDs = new List<int>();
            int iValidARDetailCount = 0;


            //iEligibleCompanyCount++;

            // This threshold gets checked a second time below after the AR Details are processed.  We do it here to avoid
            // the detail processing because if they don't meet the threshold before processing, they certainly won't afterwords.
            if (oPIECompany.SubmitterCount < Utilities.GetIntConfigValue("CalculatePayIndicatorSubmitterCountThreshold", 2))
            {
                bCalcPayIndicator = false;
                oPIECompany.FailedSubmitterCountThreshold = true;
                //iFailedSubmitterCountThreshold++;
            }

            // This threshold gets checked a second time below after the AR Details are processed.  We do it here to avoid
            // the detail processing because if they don't meet the threshold before processing, they certainly won't afterwords.
            if (oPIECompany.ARDetailCount < Utilities.GetIntConfigValue("CalculatePayIndicatorARDetailCountThreshold", 5))
            {
                bCalcPayIndicator = false;
                oPIECompany.FailedARDetailCountThreshold = true;
                //iFailedARDetailCountThreshold++;
            }

            // Only process the AR Details if the company currently meets the thresholds.
            if (bCalcPayIndicator)
            {

                oSQLCommandDetails.Parameters.Clear();
                oSQLCommandDetails.Parameters.AddWithValue("SubjectCompanyID", oPIECompany.SubjectCompanyID);
                oSQLCommandDetails.Parameters.AddWithValue("DateThreshold", 0 - Utilities.GetIntConfigValue("CalculatePayIndicatorARDetailAgeThreshold", 12));

                SqlDataReader oReader = oSQLCommandDetails.ExecuteReader();
                List<CompanyARAging> lARAgingDetails = new List<CompanyARAging>();
                try
                {
                    while (oReader.Read())
                    {
                        lARAgingDetails.Add(new CompanyARAging(oReader));
                    }
                }
                finally
                {
                    oReader.Close();
                }

                iARDetailCount += lARAgingDetails.Count;

                lSubmitterIDs.Clear();
                iValidARDetailCount = 0;


                // Now calculate our totals for all of the submitted AR
                // for this subject company
                foreach (CompanyARAging oARAging in lARAgingDetails)
                {
                    object[] aARArgs = {oARAging.SubjectCompanyID.ToString(),
                                            oARAging.ARDate.ToString(),
                                            oARAging.AmountCurrent.ToString(),
                                            oARAging.DiscountedTotal.ToString(),
                                            oARAging.CurrentCount.ToString(),
                                            oARAging.TotalCount.ToString(),
                                            oARAging.Discount.ToString(),
                                            oARAging.IsValid.ToString(),
                                            oARAging.AmountCurrent.ToString(),
                                            oARAging.Amount1to30.ToString(),
                                            oARAging.Amount31to60.ToString(),
                                            oARAging.Amount61to90.ToString(),
                                            oARAging.Amount91Plus.ToString()};

                    oPIECompany.ARDetails.Add(string.Format(AR_DETAIL_MSG, aARArgs) + Environment.NewLine);


                    if (oARAging.IsValid)
                    {
                        TimeSpan tsAge = DateTime.Today.Subtract(oARAging.ARDate);
                        if (tsAge.TotalDays <= iMinThresholdDays1)
                        {
                            iMinThresholdDetailCount1++;
                        }

                        if (tsAge.TotalDays <= iMinThresholdDays2)
                        {
                            iMinThresholdDetailCount2++;
                        }


                        iValidARDetailCount++;
                        if (!lSubmitterIDs.Contains(oARAging.SubmitterCompanyID))
                        {
                            lSubmitterIDs.Add(oARAging.SubmitterCompanyID);
                        }

                        dCurrentCount += oARAging.CurrentCount;
                        dTotalCount += oARAging.TotalCount;
                        dCurrentAmount += oARAging.AmountCurrent;
                        dTotalDollars += oARAging.DiscountedTotal;
                    }
                    else
                    {
                        bFoundNuisance = true;
                    }
                }

                if (dTotalCount == 0)
                {
                    bCalcPayIndicator = false;
                }

                if (iMinThresholdDetailCount1 < iMinThresholdCount1)
                {
                    bCalcPayIndicator = false;
                    oPIECompany.FailedARDateThreshold = true;
                }

                if (iMinThresholdDetailCount2 < iMinThresholdCount2)
                {
                    bCalcPayIndicator = false;
                    oPIECompany.FailedARDateThreshold = true;
                }

                if (lSubmitterIDs.Count < Utilities.GetIntConfigValue("CalculatePayIndicatorSubmitterCountThreshold", 2))
                {
                    bCalcPayIndicator = false;
                    oPIECompany.FailedSubmitterCountThreshold = true;
                }

                if (iValidARDetailCount < Utilities.GetIntConfigValue("CalculatePayIndicatorARDetailCountThreshold", 5))
                {
                    bCalcPayIndicator = false;
                    oPIECompany.FailedARDetailCountThreshold = true;
                }
            }

            if (!bCalcPayIndicator)
            {
                if (bFoundNuisance)
                {
                    oPIECompany.Nuisance = true;
                }

                // If this company used to have a pay indicator we now need to remove
                // the current flag.
                if (oPIECompany.PayIndicator != null)
                {
                    oSQLCommandInsert.Parameters.Clear();
                    oSQLCommandInsert.Parameters.AddWithValue("CompanyID", oPIECompany.SubjectCompanyID);
                    oSQLCommandInsert.Parameters.AddWithValue("TotalCount", DBNull.Value);
                    oSQLCommandInsert.Parameters.AddWithValue("CurrentCount", DBNull.Value);
                    oSQLCommandInsert.Parameters.AddWithValue("CurrentAmount", DBNull.Value);
                    oSQLCommandInsert.Parameters.AddWithValue("TotalAmount", DBNull.Value);
                    oSQLCommandInsert.Parameters.AddWithValue("PayIndicatorScore", DBNull.Value);
                    oSQLCommandInsert.Parameters.AddWithValue("PayIndicator", DBNull.Value);
                    oSQLCommandInsert.Parameters.AddWithValue("Current", "Y");
                    oSQLCommandInsert.ExecuteNonQuery();

                    oPIECompany.ActionCode = "R";  //Removed
                }
                else
                {
                    oPIECompany.ActionCode = "NR";
                }


            }
            else
            {
                // Now calculate our score and translate it into the appropriate
                // indicator
                dScore = Math.Round((dCountWeight * (dCurrentCount / dTotalCount)) +
                                    (dAmountWeight * (dCurrentAmount / dTotalDollars)), 6);

                // We only want to create a new PayIndicator record
                // if the indicator score has changed.
                if (dScore != oPIECompany.PayIndicatorScore)
                {
                    if (dScore >= dScore01MinValue)
                    {
                        oPIECompany.PayIndicator = szScore01Code;

                    }
                    else if (dScore >= dScore02MinValue)
                    {
                        oPIECompany.PayIndicator = szScore02Code;

                    }
                    else if (dScore >= dScore03MinValue)
                    {
                        oPIECompany.PayIndicator = szScore03Code;

                    }
                    else if (dScore >= dScore04MinValue)
                    {
                        oPIECompany.PayIndicator = szScore04Code;

                    }
                    else if (dScore >= dScore05MinValue)
                    {
                        oPIECompany.PayIndicator = szScore05Code;
                    }

                    oSQLCommandInsert.Parameters.Clear();
                    oSQLCommandInsert.Parameters.AddWithValue("CompanyID", oPIECompany.SubjectCompanyID);
                    oSQLCommandInsert.Parameters.AddWithValue("TotalCount", dTotalCount);
                    oSQLCommandInsert.Parameters.AddWithValue("CurrentCount", dCurrentCount);
                    oSQLCommandInsert.Parameters.AddWithValue("CurrentAmount", dCurrentAmount);
                    oSQLCommandInsert.Parameters.AddWithValue("TotalAmount", dTotalDollars);
                    oSQLCommandInsert.Parameters.AddWithValue("PayIndicatorScore", dScore);
                    oSQLCommandInsert.Parameters.AddWithValue("PayIndicator", oPIECompany.PayIndicator);
                    oSQLCommandInsert.Parameters.AddWithValue("Current", "Y");
                    oSQLCommandInsert.ExecuteNonQuery();

                    oPIECompany.ActionCode = "C"; // Changed
                }
            }
        }

        //public void RemovePayIndicator(comp_CompanyID) {
        //    oSQLCommandInsert.Parameters.Clear();
        //    oSQLCommandInsert.Parameters.AddWithValue("CompanyID", oPIECompany.SubjectCompanyID);
        //    oSQLCommandInsert.Parameters.AddWithValue("TotalCount", DBNull.Value);
        //    oSQLCommandInsert.Parameters.AddWithValue("CurrentCount", DBNull.Value);
        //    oSQLCommandInsert.Parameters.AddWithValue("CurrentAmount", DBNull.Value);
        //    oSQLCommandInsert.Parameters.AddWithValue("TotalAmount", DBNull.Value);
        //    oSQLCommandInsert.Parameters.AddWithValue("PayIndicatorScore", DBNull.Value);
        //    oSQLCommandInsert.Parameters.AddWithValue("PayIndicator", DBNull.Value);
        //    oSQLCommandInsert.Parameters.AddWithValue("Current", "Y");
        //    oSQLCommandInsert.ExecuteNonQuery();

        //    oPIECompany.ActionCode = "R";  //Removed
        //}
    }
}
