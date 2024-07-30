/***********************************************************************
 Copyright Blue Book Services, Inc. 2010-2016

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyARAging.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

using TSI.Utils;

namespace BBSI.PayIndicator
{
    /// <summary>
    /// Helper class used to calculate the amounts and counts taking 
    /// into account the age of the AR data.
    /// </summary>
    public class CompanyARAging
    {
        public int SubmitterCompanyID;
        public int SubjectCompanyID;
        public DateTime ARDate;
        public decimal AmountCurrent;
        public decimal Amount1to30;
        public decimal Amount31to60;
        public decimal Amount61to90;
        public decimal Amount91Plus;
        public decimal OriginalTotal;
        public decimal WorkingTotal;
        public decimal DiscountedTotal;
        public decimal CreditBalance;
        public decimal CurrentCount;
        public decimal TotalCount;

        public decimal Discount;
        public bool IsValid = true;

        public CompanyARAging(IDataReader oDataReader)
        {
            SubmitterCompanyID = oDataReader.GetInt32(0);
            SubjectCompanyID = oDataReader.GetInt32(1);
            ARDate = oDataReader.GetDateTime(2);

            if (oDataReader[3] != DBNull.Value)
            {
                AmountCurrent = oDataReader.GetDecimal(3);
            }
            if (oDataReader[4] != DBNull.Value)
            {
                Amount1to30 = oDataReader.GetDecimal(4);
            }
            if (oDataReader[5] != DBNull.Value)
            {
                Amount31to60 = oDataReader.GetDecimal(5);
            }
            if (oDataReader[6] != DBNull.Value)
            {
                Amount61to90 = oDataReader.GetDecimal(6);
            }
            if (oDataReader[7] != DBNull.Value)
            {
                Amount91Plus = oDataReader.GetDecimal(7);
            }

            Calcuate();
        }


        /// <summary>
        /// This method determines if the ARAging detail is eligible to be included in
        /// calculating the subject company’s pay indicator.  If so, calculates the 
        /// discounted amounts and counts.
        /// </summary>
        public void Calcuate()
        {

            OriginalTotal = AmountCurrent +
                            Amount1to30 +
                            Amount31to60 +
                            Amount61to90 +
                            Amount91Plus;

            // Check to make sure we're above our threshold.  This check is done a second time below,
            // but we do it here to avoid unnecessary processing as the amounts only get lower, not
            // higher, as we go.
            if (OriginalTotal < GetDecimalConfigValue("CalculatePayIndicatorTotalThreshold", 50))
            {
                IsValid = false;
                return;
            }

            // Now handle any negative values by cascading the amount down through 
            // the buckets from oldest to newest.
            Amount91Plus = ProcessCredit(Amount91Plus);
            Amount61to90 = ProcessCredit(Amount61to90); 
            Amount31to60 = ProcessCredit(Amount31to60);
            Amount1to30 = ProcessCredit(Amount1to30);
            AmountCurrent = ProcessCredit(AmountCurrent);

            // If we still have a credit balance, then apply it in reverse order.
            // The idea is that none of the buckets end up with a negative value.
            // If that happens, this means the total amount of the record is negative 
            // and that is dealt with below.
            if (CreditBalance < 0)
            {
                Amount1to30 = ProcessCredit(Amount1to30);
                Amount31to60 = ProcessCredit(Amount31to60);
                Amount61to90 = ProcessCredit(Amount61to90);
                
                // If we still have a credit balance, the result
                // of this operation will set the Amount91Plus to
                // zero.  This is desired.
                Amount91Plus = ProcessCredit(Amount91Plus);
            }

            // Zero out any individual fiels whose percentage of our total amount is 
            // less than our threshold.
            AmountCurrent = ApplyFieldPctThreshold(AmountCurrent);
            Amount1to30 = ApplyFieldPctThreshold(Amount1to30);
            Amount31to60 = ApplyFieldPctThreshold(Amount31to60);
            Amount61to90 = ApplyFieldPctThreshold(Amount61to90);
            Amount91Plus = ApplyFieldPctThreshold(Amount91Plus);

            WorkingTotal = AmountCurrent +
                           Amount1to30 +
                           Amount31to60 +
                           Amount61to90 +
                           Amount91Plus;

            // Now that we've processed the individual values, make sure the total
            // dollar value > than a configured threshold.
            if (WorkingTotal < GetDecimalConfigValue("CalculatePayIndicatorTotalThreshold", 50))
            {
                IsValid = false;
                return;
            }

            // The Discount is calculated by taking our discount amount and raising it
            // to the power of (the number of months between today and the AR Aging date).
            // The number of months is calculated by taking the difference in days and dividing
            // by 30.
            TimeSpan tsDiff = DateTime.Today - ARDate;
            Double dPower = Math.Floor(Convert.ToDouble((Convert.ToDecimal(tsDiff.TotalDays) / GetDecimalConfigValue("CalculatePayIndicatorDaysInMonth", 30M))));

            Discount = Convert.ToDecimal(Math.Pow(Convert.ToDouble(GetDecimalConfigValue("CalculatePayIndicatorDiscount", 0.9M)),
                                                  dPower));

            // Apply the aging discount to our amounts.
            AmountCurrent = Math.Round(AmountCurrent * Discount, 6);
            Amount1to30 = Math.Round(Amount1to30 * Discount, 6);
            Amount31to60 = Math.Round(Amount31to60 * Discount, 6);
            Amount61to90 = Math.Round(Amount61to90 * Discount, 6);
            Amount91Plus = Math.Round(Amount91Plus * Discount, 6);


            // Apply Late Balance Penalty
            Amount1to30 = Amount1to30 * GetDecimalConfigValue("CalculatePayIndicator1to30AmountWeight", 0.6M);
            Amount31to60 = Amount31to60 * GetDecimalConfigValue("CalculatePayIndicator31to60AmountWeight", 1.0M);
            Amount61to90 = Amount61to90 * GetDecimalConfigValue("CalculatePayIndicator61to90AmountWeight", 1.5M);
            Amount91Plus = Amount91Plus * GetDecimalConfigValue("CalculatePayIndicator91PlusAmountWeight", 3.0M);



            DiscountedTotal = AmountCurrent +
                              Amount1to30 +
                              Amount31to60 +
                              Amount61to90 +
                              Amount91Plus;

            // Even the count is discounted.
            if (AmountCurrent > 0)
            {
                CurrentCount = Discount;
            }

            // Determine the total count
            AddToTotalCount(AmountCurrent, 1M);
            AddToTotalCount(Amount1to30, GetDecimalConfigValue("CalculatePayIndicator1to30CountWeight", 0.6M));
            AddToTotalCount(Amount31to60, GetDecimalConfigValue("CalculatePayIndicator31to60CountWeight", 1.0M));
            AddToTotalCount(Amount61to90, GetDecimalConfigValue("CalculatePayIndicator61to90CountWeight", 1.5M));
            AddToTotalCount(Amount91Plus, GetDecimalConfigValue("CalculatePayIndicator91PlusCountWeight", 2.0M));
        }

        #region Helper Methods
        private decimal ApplyFieldPctThreshold(decimal dAmount) {
            if ((dAmount / OriginalTotal) < GetDecimalConfigValue("CalcualtePayIndicatorFieldThresholdPrec", 0.02M))
            {
                return 0;
            }

            return dAmount;
        }

        private decimal ProcessCredit(decimal dAmount)
        {
            // If we already have a credit balance, apply it
            // to our current field and reset the CreditBalance
            if (CreditBalance < 0) {
                dAmount += CreditBalance;
                CreditBalance = 0M;
            }

            if (dAmount < 0 ) {
                CreditBalance = dAmount;
                return 0M;
            }

            return dAmount;
        }

        private void AddToTotalCount(decimal dAmount, decimal lateBalancePenalty)
        {
            if (dAmount > 0)
            {
                TotalCount += (Discount * lateBalancePenalty);
            }
        }


        private decimal GetDecimalConfigValue(string ValueName, decimal dDefaultValue)
        {
            int iValue =Utilities.GetIntConfigValue(ValueName, -123);

            if (iValue == -123)
            {
                return dDefaultValue;
            }

            return Convert.ToDecimal(iValue);
        }
        #endregion
    }
}
