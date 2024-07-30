/***********************************************************************
 Copyright Produce Reporter Company 2006-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ClassificationCountEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data.SqlClient;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{

    /// <summary>
    /// Event handler that calculates the number of companies assigned
    /// to each classficiation and stores the results in the PRClassification
    /// table.  
    /// </summary>
    class ClassificationCountEvent : BBSMonitorEvent
    {

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "ClassificationCountEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("ClassificationCountInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("ClassificationCount Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("ClassificationCountStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("ClassificationCount Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing ClassificationCount event.", e);
                throw;
            }
        }

        const string SQL_UPDATE_CLASSIFICATION_COUNTS =
           @"UPDATE PRClassification
                SET prcl_CompanyCount = T1.CompanyCount 
                    FROM (SELECT prcl_ClassificationID, COUNT(comp_CompanyID) AS CompanyCount 
                            FROM PRClassification
                                 LEFT OUTER JOIN PRCompanyClassification ON prcl_ClassificationID = prc2_ClassificationID
                                 LEFT OUTER JOIN Company WITH (NOLOCK) ON prc2_CompanyID = comp_CompanyID AND comp_PRListingStatus IN ('L', 'H', 'LUV') 
                                                        AND comp_PRLocalSource IS NULL
                        GROUP BY prcl_ClassificationID) T1 
                  WHERE PRClassification.prcl_ClassificationID = T1.prcl_ClassificationID; ";

        const string SQL_UPDATE_CLASSIFICATION_COUNTS_INCLUDING_LOCAL_SOURCE =
                @"UPDATE PRClassification
                SET prcl_CompanyCountIncludeLocalSource = T1.CompanyCount 
                    FROM (SELECT prcl_ClassificationID, COUNT(comp_CompanyID) AS CompanyCount 
                            FROM PRClassification
                                 LEFT OUTER JOIN PRCompanyClassification ON prcl_ClassificationID = prc2_ClassificationID
                                 LEFT OUTER JOIN Company WITH (NOLOCK) ON prc2_CompanyID = comp_CompanyID AND comp_PRListingStatus IN ('L', 'H', 'LUV') 
                        GROUP BY prcl_ClassificationID) T1 
                  WHERE PRClassification.prcl_ClassificationID = T1.prcl_ClassificationID; ";

        const string SQL_UPDATE_SPECIE_COUNTS =
              @"UPDATE PRSpecie
                   SET prspc_CompanyCount = T1.CompanyCount 
                  FROM (SELECT prspc_SpecieID, COUNT(comp_CompanyID) AS CompanyCount 
                            FROM PRSpecie
                                 LEFT OUTER JOIN PRCompanySpecie ON prspc_SpecieID = prcspc_SpecieID
                                 LEFT OUTER JOIN Company WITH (NOLOCK) ON prcspc_CompanyID = comp_CompanyID AND comp_PRListingStatus IN ('L', 'H', 'LUV') 
                        GROUP BY prspc_SpecieID) T1 
                  WHERE PRSpecie.prspc_SpecieID = T1.prspc_SpecieID;";

        const string SQL_UPDATE_SERVICEPROVIDED_COUNTS =
            @"UPDATE PRServiceProvided
                   SET prserpr_CompanyCount = T1.CompanyCount 
                  FROM (SELECT prserpr_ServiceProvidedID, COUNT(comp_CompanyID) AS CompanyCount 
                            FROM PRServiceProvided
                                 LEFT OUTER JOIN PRCompanyServiceProvided ON prserpr_ServiceProvidedID = prcserpr_ServiceProvidedID
                                 LEFT OUTER JOIN Company WITH (NOLOCK) ON prcserpr_CompanyID = comp_CompanyID AND comp_PRListingStatus IN ('L', 'H', 'LUV') 
                        GROUP BY prserpr_ServiceProvidedID) T1 
                  WHERE PRServiceProvided.prserpr_ServiceProvidedID = T1.prserpr_ServiceProvidedID;";


        const string SQL_UPDATE_PRODUCTPROVIDED_COUNTS =
              @"UPDATE PRProductProvided
                   SET prprpr_CompanyCount = T1.CompanyCount 
                  FROM (SELECT prprpr_ProductProvidedID, COUNT(comp_CompanyID) AS CompanyCount 
                            FROM PRProductProvided
                                 LEFT OUTER JOIN PRCompanyProductProvided ON prprpr_ProductProvidedID = prcprpr_ProductProvidedID
                                 LEFT OUTER JOIN Company WITH (NOLOCK) ON prcprpr_CompanyID = comp_CompanyID AND comp_PRListingStatus IN ('L', 'H', 'LUV') 
                        GROUP BY prprpr_ProductProvidedID) T1 
                  WHERE PRProductProvided.prprpr_ProductProvidedID = T1.prprpr_ProductProvidedID;";

        const string SQL_UPDATE_PRIMPORTER_Y =
              @"UPDATE Company 
                    SET comp_PRImporter = 'Y' 
                    FROM PRCompanyClassification
                    WHERE prc2_CompanyId = comp_CompanyID
                        AND prc2_ClassificationId = 220
                        AND comp_PRImporter IS NULL;";

        const string SQL_UPDATE_PRIMPORTER_NULL =
              @"UPDATE Company 
                    SET comp_PRImporter = NULL
                    WHERE comp_PRImporter = 'Y' 
                    AND comp_CompanyID NOT IN (SELECT prc2_CompanyId FROM PRCompanyClassification WHERE prc2_ClassificationId = 220);";

        /// <summary>
        /// Go update the classification company counts.
        /// </summary>
        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try
            {
                oConn.Open();

                SqlCommand oSQLCommand = new SqlCommand(SQL_UPDATE_CLASSIFICATION_COUNTS, oConn);
                oSQLCommand.ExecuteNonQuery();

                //Defect 4104
                oSQLCommand = new SqlCommand(SQL_UPDATE_CLASSIFICATION_COUNTS_INCLUDING_LOCAL_SOURCE, oConn);
                oSQLCommand.ExecuteNonQuery();

                oSQLCommand = new SqlCommand(SQL_UPDATE_SPECIE_COUNTS, oConn);
                oSQLCommand.ExecuteNonQuery();

                oSQLCommand = new SqlCommand(SQL_UPDATE_SERVICEPROVIDED_COUNTS, oConn);
                oSQLCommand.ExecuteNonQuery();

                oSQLCommand = new SqlCommand(SQL_UPDATE_PRODUCTPROVIDED_COUNTS, oConn);
                oSQLCommand.ExecuteNonQuery();

                //International Trade Association Changes
                oSQLCommand = new SqlCommand(SQL_UPDATE_PRIMPORTER_Y, oConn);
                oSQLCommand.ExecuteNonQuery();

                oSQLCommand = new SqlCommand(SQL_UPDATE_PRIMPORTER_NULL, oConn);
                oSQLCommand.ExecuteNonQuery();

                if (Utilities.GetBoolConfigValue("ClassificationCountWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent("ClassificationCount Executed Successfully.");
                }

                if (Utilities.GetBoolConfigValue("ClassificationCountSendResultsToSupport", false))
                {
                    SendMail("Classification Count Success", "ClassificationCount Executed Successfully.");
                }
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing ClassificationCount Event.", e);
            }
            finally
            {
                if (oConn != null)
                {
                    oConn.Close();
                }

                oConn = null;
            }
        }
    }
}
