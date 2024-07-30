/***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BBScoreImageEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    public class BBScoreImageEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "BBScoreImageEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("BBScoreImageInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("BBScoreImage Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("BBScoreImageStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("BBScoreImage Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing BBScoreImage event.", e);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        override public void ProcessEvent()
        {

            if (!IsBusinessHours("BBScoreImageBusinessHoursOnly"))
            {
                return;
            }

            DateTime dtExecutionStartDate = DateTime.Now;
            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try
            {
                string targetFolder = Utilities.GetConfigValue("BBScoreImageFolder");

                oConn.Open();

                DateTime dtLastExecutionDate = GetDateTimeCustomCaption(oConn, "BBScoreImageLastRunDate", new DateTime(2014, 7, 1));

                SqlCommand oSQLCommand = new SqlCommand("SELECT prbs_CompanyID FROM PRBBScore WITH (NOLOCK) WHERE prbs_Current = 'Y' AND prbs_PRPublish = 'Y' AND prbs_CreatedDate > @LastExecutionDate ORDER BY prbs_CompanyID", oConn);
                // 8-1-2018 Purposely didn't not include check comp_PRPublishBBScore='Y' after discussion between chw/jmt

                oSQLCommand.Parameters.AddWithValue("@LastExecutionDate", dtLastExecutionDate);


                // Since we're going to generate an image for each company found,
                // let's close the DB connection as quickly as possible
                List<Int32> companyIDs = new List<int>();
                using (IDataReader reader = oSQLCommand.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        companyIDs.Add(reader.GetInt32(0));
                    }
                }


                ReportInterface oReportInterface = new ReportInterface();
                byte[] abBBScoreImage = null;


                foreach(int companyID in companyIDs) {
                    abBBScoreImage = oReportInterface.GenerateBBScoreGauge(companyID, true);
                    
                    using (FileStream stream = File.Create(Path.Combine(targetFolder, string.Format("BBScore_text_{0}.jpg", companyID)), abBBScoreImage.Length))
                    {
                        stream.Write(abBBScoreImage, 0, abBBScoreImage.Length);
                    }

                    abBBScoreImage = oReportInterface.GenerateBBScoreGauge(companyID, false);
                    byte[] abBBScoreImageCropped = CropImage(abBBScoreImage, 430, 90, 0, 0);
                    using (FileStream stream = File.Create(Path.Combine(targetFolder, string.Format("BBScore_{0}.jpg", companyID)), abBBScoreImageCropped.Length))
                    {
                        stream.Write(abBBScoreImageCropped, 0, abBBScoreImageCropped.Length);
                    }
                }

                UpdateDateTimeCustomCaption(oConn, "BBScoreImageLastRunDate", dtExecutionStartDate);

                string msg = "Generated images for " + companyIDs.Count.ToString("###,##0") + " companies.";

                if (Utilities.GetBoolConfigValue("BBScoreImageWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent("BBScoreImage Executed Successfully. " + msg);
                }

                if (Utilities.GetBoolConfigValue("BBScoreImageSendResultsToSupport", false))
                {
                    SendMail("BBScoreImage Success", msg);
                }

            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing BBScoreImage Event.", e);
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

        private byte[] CropImage(byte[] bbscoreImage, int iWidth, int iHeight, int iX, int iY)
        {
            using (MemoryStream ms = new MemoryStream(bbscoreImage))
            {
                using (Image oOriginalImage = Image.FromStream(ms))
                {
                    using (Bitmap oBitmap = new Bitmap(iWidth, iHeight))
                    {
                        oBitmap.SetResolution(oOriginalImage.HorizontalResolution, oOriginalImage.VerticalResolution);
                        using (Graphics Graphic = Graphics.FromImage(oBitmap))
                        {
                            Graphic.SmoothingMode = SmoothingMode.AntiAlias;
                            Graphic.InterpolationMode = InterpolationMode.HighQualityBicubic;
                            Graphic.PixelOffsetMode = PixelOffsetMode.HighQuality;
                            Graphic.DrawImage(oOriginalImage, new Rectangle(0, 0, iWidth, iHeight), iX, iY, iWidth, iHeight, GraphicsUnit.Pixel);
                            MemoryStream oMemoryStream = new MemoryStream();
                            oBitmap.Save(oMemoryStream, oOriginalImage.RawFormat);
                            return oMemoryStream.GetBuffer();
                        }
                    }
                }
            }
        }
    }
}
