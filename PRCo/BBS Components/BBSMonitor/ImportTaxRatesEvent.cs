/***********************************************************************
 Copyright Blue Book Services, Inc. 2012-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ImportTaxRatesEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    public class ImportTaxRatesEvent : BBSMonitorEvent
    {
        private const string TAX_CLASS_TAXABLE = "TX";
        private const string TAX_CLASS_NON_TAXABLE = "NT";
        private const string TAX_CLASS_INTANGIBLE_TAX = "IT";

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "ImportTaxRatesEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("ImportTaxRatesInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("ImportTaxRates Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("ImportTaxRatesStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("ImportTaxRates Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing ImportTaxRates event.", e);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            List<TaxRate> taxRates = new List<TaxRate>();
            List<TaxRate> taxGoodRates = new List<TaxRate>();

            StringBuilder sbResults = new StringBuilder();
            bool bIssuesFound = false;
            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try
            {
                if (!File.Exists(Utilities.GetConfigValue("ImportTaxRatesFile")))
                    return;

                // Build a list of taxRate objects from
                // the input file
                using (StreamReader sr = File.OpenText(Utilities.GetConfigValue("ImportTaxRatesFile")))
                {
                    String input;
                    while ((input = sr.ReadLine()) != null)
                    {
                        TaxRate taxRate = new TaxRate();
                        taxRate.Zip = input.Substring(0, 5).Trim();
                        taxRate.City = input.Substring(5, 28).Trim();
                        taxRate.County = input.Substring(33, 25).Trim();
                        taxRate.State = input.Substring(58, 2).Trim();
                        taxRate.Rate = input.Substring(88, 8);
                        taxRate.RateDecimal = (Convert.ToDecimal(taxRate.Rate) * 100);
                        taxRate.Indicator = input.Substring(105, 1).Trim();

                        taxRates.Add(taxRate);
                    }
                }

                // Make sure these are sorted in the right order
                var taxRates2 = taxRates.OrderBy(c => c.Zip).ThenBy(c => c.City).ThenBy(c => c.County).ThenBy(c => c.State).ToList();

                // Time for some control break processing.  We may have multiple records for a given
                // geographic location, so use the taxRate's priority attribute to determine which
                // record we want.

                // prime our control variable;
                TaxRate insertTR = taxRates2[0];


                int count = 1;
                foreach (TaxRate taxRate in taxRates2)
                {
                    if (taxRate.State == "IL")
                    {
                        // This is a hard-coded rate.
                        continue;

                        // If we have a new location, then insert the 
                        // previous location.
                    } else if ((taxRate.Zip != insertTR.Zip) ||
                                (taxRate.City != insertTR.City) ||
                                (taxRate.County != insertTR.County) ||
                                (taxRate.State != insertTR.State))
                    {
                        // Now insert the appropriate tax rate
                        insertTR.Code = "Sys" + count.ToString("000000");
                        taxGoodRates.Add(insertTR);
                        count++;

                        insertTR = taxRate;
                    }
                    else
                    {
                        // If we have a "Previous" tax rate, this means
                        // we found records with same geographic location.
                        // In this case, we only store one, and we determine
                        // this by the priority of the Indicator code.
                        if (insertTR != null)
                        {
                            if (taxRate.RateDecimal > insertTR.RateDecimal)
                                insertTR = taxRate;
                        }
                    }
                }

                // Take care of our last record.
                insertTR.Code = "Sys" + count.ToString("000000");
                taxGoodRates.Add(insertTR);
                count++;

                // Now build the flat files for MAS to import
                StringBuilder SY_SalesTaxCode = new StringBuilder();
                StringBuilder SY_SalesTaxSchedule = new StringBuilder();
                StringBuilder SY_SalesTaxCodeDetail = new StringBuilder();
                StringBuilder GL_SalesTax = new StringBuilder();

                foreach (TaxRate taxRate in taxGoodRates)
                {
                    WriteSalesTaxSchedule(SY_SalesTaxSchedule, taxRate);
                    WriteSalesTaxCode(SY_SalesTaxCode, taxRate);
                    WriteSalesTaxCodeDetail(SY_SalesTaxCodeDetail, taxRate, TAX_CLASS_TAXABLE);
                    WriteSalesTaxCodeDetail(SY_SalesTaxCodeDetail, taxRate, TAX_CLASS_NON_TAXABLE);
                    WriteSalesTaxCodeDetail(SY_SalesTaxCodeDetail, taxRate, TAX_CLASS_INTANGIBLE_TAX);
                    WriteSalesTaxCodeDetail(SY_SalesTaxCodeDetail, taxRate, "TF");
                    WriteGLSalesTax(GL_SalesTax, taxRate);
                }

                string outputFolder = Utilities.GetConfigValue("ImportTaxRatesOutputFolder");
                WriteFile(SY_SalesTaxCode, outputFolder, Utilities.GetConfigValue("ITRSalesTaxCodeFileName"));
                WriteFile(SY_SalesTaxCodeDetail, outputFolder, Utilities.GetConfigValue("ITRSalesTaxCodeDetailFileName"));
                WriteFile(SY_SalesTaxSchedule, outputFolder, Utilities.GetConfigValue("ITRSalesTaxScheduleFileName"));
                WriteFile(GL_SalesTax, outputFolder, Utilities.GetConfigValue("ITRGLSalesTaxFileName"));

                oConn.Open();
                if (Utilities.GetBoolConfigValue("ITRImportIntoMAS", true))
                {
                    ExecuteMASImport(oConn, outputFolder, Utilities.GetConfigValue("ITRSalesTaxCodeFileName"), Utilities.GetConfigValue("ITRSalesTaxCodeVIJob"), Utilities.GetConfigValue("ITRSalesTaxCodeMASJob"));
                    ExecuteMASImport(oConn, outputFolder, Utilities.GetConfigValue("ITRSalesTaxCodeDetailFileName"), Utilities.GetConfigValue("ITRSalesTaxCodeDetailVIJob"), Utilities.GetConfigValue("ITRSalesTaxCodeDetailMASJob"));

                    ExecuteMASImport(oConn, outputFolder, Utilities.GetConfigValue("ITRSalesTaxScheduleFileName"), Utilities.GetConfigValue("ITRSalesTaxScheduleVIJob"), Utilities.GetConfigValue("ITRSalesTaxScheduleMASJob"));
                    ExecuteMASImport(oConn, outputFolder, Utilities.GetConfigValue("ITRGLSalesTaxFileName"), Utilities.GetConfigValue("ITRGLSalesTaxVIJob"), Utilities.GetConfigValue("ITRGLSalesTaxMASJob"));
                }

                // Now update the PRTaxRate table in CRM.  Do this before we try to
                // archive the files to give MAS time to finish.  The bat file we execute
                // actually finishes before the MAS process it invokes finishes.
                UpdateCRM(oConn, taxGoodRates);

                if (Utilities.GetBoolConfigValue("ITRArchiveFiles", true))
                {
                    ArchiveFile(outputFolder, Utilities.GetConfigValue("ITRSalesTaxCodeFileName"), Utilities.GetConfigValue("ImportTaxRatesArchiveFolder"), dtExecutionStartDate);
                    ArchiveFile(outputFolder, Utilities.GetConfigValue("ITRSalesTaxCodeDetailFileName"), Utilities.GetConfigValue("ImportTaxRatesArchiveFolder"), dtExecutionStartDate);
                    ArchiveFile(outputFolder, Utilities.GetConfigValue("ITRSalesTaxScheduleFileName"), Utilities.GetConfigValue("ImportTaxRatesArchiveFolder"), dtExecutionStartDate);
                    ArchiveFile(outputFolder, Utilities.GetConfigValue("ITRGLSalesTaxFileName"), Utilities.GetConfigValue("ImportTaxRatesArchiveFolder"), dtExecutionStartDate);
                }

                if (Utilities.GetBoolConfigValue("ITRImportIntoMAS", true))
                {
                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("ITRSalesTaxCodeMASJob"), sbResults))
                        bIssuesFound = true;

                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("ITRSalesTaxCodeDetailMASJob"), sbResults))
                        bIssuesFound = true;

                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("ITRSalesTaxScheduleMASJob"), sbResults))
                        bIssuesFound = true;

                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("ITRGLSalesTaxMASJob"), sbResults))
                        bIssuesFound = true;
                }

                ArchiveFile(Path.GetDirectoryName(Utilities.GetConfigValue("ImportTaxRatesFile")),
                            Path.GetFileName(Utilities.GetConfigValue("ImportTaxRatesFile")),
                            Utilities.GetConfigValue("ImportTaxRatesArchiveFolder"),
                            dtExecutionStartDate);

                if ((Utilities.GetBoolConfigValue("ImportTaxRatesWriteResultsToEventLog", true)) ||
                    (bIssuesFound))
                {
                    string subject = "successfully.";
                    if (bIssuesFound)
                        subject = " with issues.";

                    _oBBSMonitorService.LogEvent("The Import Tax Rates Event completed " + subject + Environment.NewLine + Environment.NewLine + sbResults.ToString());
                }

                if ((Utilities.GetBoolConfigValue("ImportTaxRatesSendResultsToSupport", true)) ||
                    (bIssuesFound))
                {
                    string subject = "Import Tax Rates Success";
                    if (bIssuesFound)
                        subject = "Import Tax Completed with Issues";

                    SendMail(subject,
                             sbResults.ToString());
                }
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing ImportTaxRates Event.", e);
            }
            finally
            {
                if (oConn != null)
                    oConn.Close();

                oConn = null;
            }
        }

        protected const string SQL_PRTAXRATE_INSERT =
            @"INSERT INTO PRTaxRate (prtax_PostalCode, prtax_County, prtax_City, prtax_State, prtax_TaxCode, prtax_TaxRate, prtax_CreatedBy, prtax_UpdatedBy)
          VALUES(@PostalCode, @County, @City, @State, @TaxCode, @TaxRate, @UserID, @UserID)";
        private void UpdateCRM(SqlConnection sqlConn, List<TaxRate> taxGoodRates)
        {
            if (!Utilities.GetBoolConfigValue("ITRUpdateCRM", true))
                return;

            _oLogger.LogMessage("Updating the CRM PRTaxRate table");
            StringBuilder insertTaxRateSQL = new StringBuilder();

            SqlCommand sqlDelete = new SqlCommand("DELETE FROM PRTaxRate WHERE prtax_TaxCode<>'SYS000000'", sqlConn);
            sqlDelete.ExecuteNonQuery();

            SqlCommand sqlInsert = new SqlCommand(SQL_PRTAXRATE_INSERT, sqlConn);
            sqlInsert.CommandTimeout = 120;

            foreach (TaxRate taxRate in taxGoodRates)
            {
                sqlInsert.Parameters.Clear();
                sqlInsert.Parameters.AddWithValue("PostalCode", taxRate.Zip);
                sqlInsert.Parameters.AddWithValue("County", taxRate.County);
                sqlInsert.Parameters.AddWithValue("City", taxRate.City);
                sqlInsert.Parameters.AddWithValue("State", taxRate.State);
                sqlInsert.Parameters.AddWithValue("TaxCode", taxRate.Code);
                sqlInsert.Parameters.AddWithValue("TaxRate", taxRate.GetTaxRate());
                sqlInsert.Parameters.AddWithValue("UserID", -1);

                try
                {
                    sqlInsert.ExecuteNonQuery();
                }
                catch
                {
                    _oLogger.LogMessage("Error inserting tax rate: " + taxRate.Code + " (" + taxRate.City + ", " + taxRate.State + " " + taxRate.Zip + ")");
                    throw;
                }
            }

            // Now make sure the companies in CRM have the
            // correct tax codes.
            _oLogger.LogMessage("Updating the CRM Company Tax Code.");
            SqlCommand sqlUpdateTaxCodes = new SqlCommand("usp_UpdateAllTaxCodes", sqlConn);
            sqlUpdateTaxCodes.CommandType = CommandType.StoredProcedure;
            sqlUpdateTaxCodes.CommandTimeout = Utilities.GetIntConfigValue("ImportTaxRatesUpdateAllTimeout", 1200);
            sqlUpdateTaxCodes.ExecuteNonQuery();

            _oLogger.LogMessage("Finished updating CRM.");
        }

        private void WriteSalesTaxCode(StringBuilder SY_SalesTaxCode, TaxRate taxRate)
        {
            if (SY_SalesTaxCode.Length > 0)
                SY_SalesTaxCode.Append(Environment.NewLine);

            SY_SalesTaxCode.Append(taxRate.Code);
            SY_SalesTaxCode.Append("|");
            SY_SalesTaxCode.Append(taxRate.GetDescription());
            SY_SalesTaxCode.Append("|");
            SY_SalesTaxCode.Append("N");
            SY_SalesTaxCode.Append("|");
            SY_SalesTaxCode.Append(string.Empty);
            SY_SalesTaxCode.Append("|");
            SY_SalesTaxCode.Append(taxRate.Code.Substring(3, 6));
            SY_SalesTaxCode.Append("|");
            SY_SalesTaxCode.Append("N");
            SY_SalesTaxCode.Append("|");
            SY_SalesTaxCode.Append("N");
            SY_SalesTaxCode.Append("|");
            SY_SalesTaxCode.Append("0.00");
        }

        private void WriteSalesTaxSchedule(StringBuilder SY_SalesTaxSchedule, TaxRate taxRate)
        {
            if (SY_SalesTaxSchedule.Length > 0)
                SY_SalesTaxSchedule.Append(Environment.NewLine);

            SY_SalesTaxSchedule.Append(taxRate.Code);
            SY_SalesTaxSchedule.Append("|");
            SY_SalesTaxSchedule.Append(taxRate.GetDescription());
            SY_SalesTaxSchedule.Append("|");
            SY_SalesTaxSchedule.Append("N");
            SY_SalesTaxSchedule.Append("|");
            SY_SalesTaxSchedule.Append("1");
            SY_SalesTaxSchedule.Append("|");
            SY_SalesTaxSchedule.Append(taxRate.Code);
        }

        private void WriteSalesTaxCodeDetail(StringBuilder SY_SalesTaxCodeDetail, TaxRate taxRate, string taxClass)
        {
            string tax;
            string taxable;
            switch (taxClass)
            {
                case TAX_CLASS_TAXABLE:
                    tax = taxRate.GetTaxRate(); //TaxRate
                    taxable = "Y";
                    break;
                case TAX_CLASS_INTANGIBLE_TAX:
                    tax = taxRate.GetIntangibleRate(); //TaxRate
                    taxable = "Y";
                    break;
                default:
                    tax = "0.000"; //TaxRate
                    taxable = "N";
                    break;
            }

            if (SY_SalesTaxCodeDetail.Length > 0)
                SY_SalesTaxCodeDetail.Append(Environment.NewLine);

            SY_SalesTaxCodeDetail.Append(taxRate.Code);
            SY_SalesTaxCodeDetail.Append("|");
            SY_SalesTaxCodeDetail.Append(taxClass); //TaxClass
            SY_SalesTaxCodeDetail.Append("|");
            SY_SalesTaxCodeDetail.Append(taxable); // SalesTaxable
            SY_SalesTaxCodeDetail.Append("|");
            SY_SalesTaxCodeDetail.Append("N"); // PurchasesTaxable
            SY_SalesTaxCodeDetail.Append("|");
            SY_SalesTaxCodeDetail.Append(tax);
            SY_SalesTaxCodeDetail.Append("|");
            SY_SalesTaxCodeDetail.Append("0.000"); //NonRecoverablePercent
        }

        private void WriteCRM_MAS_Tax_Bridge(StringBuilder CRM_MAS_Tax_Bridge, TaxRate taxRate)
        {
            if (CRM_MAS_Tax_Bridge.Length > 0)
                CRM_MAS_Tax_Bridge.Append(Environment.NewLine);

            CRM_MAS_Tax_Bridge.Append(taxRate.Zip);
            CRM_MAS_Tax_Bridge.Append("|");
            CRM_MAS_Tax_Bridge.Append(taxRate.City);
            CRM_MAS_Tax_Bridge.Append("|");
            CRM_MAS_Tax_Bridge.Append(taxRate.County);
            CRM_MAS_Tax_Bridge.Append("|");
            CRM_MAS_Tax_Bridge.Append(taxRate.State);
            CRM_MAS_Tax_Bridge.Append("|");
            CRM_MAS_Tax_Bridge.Append(taxRate.Code);
        }

        private void WriteGLSalesTax(StringBuilder GL_SalesTax, TaxRate taxRate)
        {
            // If we don't have a GL account for this state, then don't 
            // write an entry.
            string glAccount = Utilities.GetConfigValue("ITR_GLACCT_" + taxRate.State, string.Empty);
            if (string.IsNullOrEmpty(glAccount))
                return;

            if (GL_SalesTax.Length > 0)
                GL_SalesTax.Append(Environment.NewLine);

            GL_SalesTax.Append(taxRate.Code);
            GL_SalesTax.Append("|");
            GL_SalesTax.Append(glAccount);
        }

        public class TaxRate
        {
            public string Zip;
            public string City;
            public string County;
            public string State;
            public string Rate;
            public string Indicator;
            public string Code;

            public decimal RateDecimal;

            public string GetTaxRate()
            {
                return RateDecimal.ToString("0.000");
            }

            public string GetIntangibleRate()
            {
                if (State == "CT")
                    return "1.000";

                if ((State == "NY") ||
                    (State == "PA"))
                    return GetTaxRate();

                return "0.000";
            }

            private string _description;
            public string GetDescription()
            {
                if (_description == null)
                {
                    if (City.Length + County.Length <= 20)
                        _description = City + "," + County;
                    else
                    {
                        string tmpCounty = County;
                        if (County.Length > 10)
                            tmpCounty = County.Substring(0, 10).Trim();

                        string tmpCity = City;
                        if (City.Length > (20 - tmpCounty.Length))
                            tmpCity = City.Substring(0, (20 - tmpCounty.Length));

                        _description = tmpCity + "," + tmpCounty;
                    }
                    _description += "," + State + "," + Zip;
                }
                return _description;
            }

            public int GetPriority()
            {
                switch (Indicator)
                {
                    case "I":
                        return 0;
                    case "C":
                        return 1;
                    case "B":
                        return 2;
                    default:
                        return 99;
                }
            }
        }
    }
}
