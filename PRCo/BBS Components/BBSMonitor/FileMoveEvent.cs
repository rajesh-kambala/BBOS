/***********************************************************************
 Copyright Produce Reporter Company 2011-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: FileMoveEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Timers;

using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    public class FileMoveEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "FileMoveEvent";

            base.Initialize(iIndex);

            try
            {
                //
                // Configure our Filecleanup Event
                //
                // Defaults to 15 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("FileMoveInterval", 15)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("FileMove Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("FileMoveStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("FileMove Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing FileMove event.", e);
                throw;
            }
        }

        /// <summary>
        /// Looks to delete any "exprired" files.
        /// </summary>
        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            StringBuilder sbLog = new StringBuilder();

            int iFolderCount = Utilities.GetIntConfigValue("FileMoveFolderCount", 0);
            int iFileCount = 0;
            int iTotalFileCount = 0;

            for (int iIndex = 0; iIndex < iFolderCount; iIndex++)
            {
                iFileCount = 0;
                string szSourceFolderName = null;
                string szTargetFolderName = null;
                try
                {
                    szSourceFolderName = Utilities.GetConfigValue("FileMoveSourceFolderName" + iIndex.ToString());
                    szTargetFolderName = Utilities.GetConfigValue("FileMoveTargetFolderName" + iIndex.ToString());

                    DirectoryInfo szTargetDirInfo = new DirectoryInfo(szTargetFolderName);

                    string[] aszSourceFiles = Directory.GetFiles(szSourceFolderName, "*.*", SearchOption.AllDirectories);
                    foreach (string file in aszSourceFiles)
                    {
                        FileInfo mFile = new FileInfo(file);

                        string intermediatePath = null;
                        string targetPath = null;


                        if (szSourceFolderName != mFile.DirectoryName)
                        {
                            intermediatePath = mFile.DirectoryName.Substring(szSourceFolderName.Length + 1);
                            targetPath = Path.Combine(szTargetFolderName, intermediatePath, mFile.Name);

                            if (!Directory.Exists(Path.Combine(szTargetFolderName, intermediatePath)))
                                Directory.CreateDirectory(Path.Combine(szTargetFolderName, intermediatePath));
                        }
                        else
                        {
                            targetPath = Path.Combine(szTargetFolderName, mFile.Name);
                        }

                        if (File.Exists(targetPath))
                        {
                            if (Utilities.GetBoolConfigValue("FileMoveOverwriteExistingFile", true))
                                File.Delete(targetPath);
                            else
                                throw new ApplicationException($"Source file '{mFile.FullName}' exists in target folder '{szTargetFolderName}'.");
                        }

                        string sourcePath = mFile.DirectoryName;
                        mFile.MoveTo(targetPath);

                        // Now look to see if the intermidate folders are empty.
                        // If so, let's delete them.
                        if (!string.IsNullOrEmpty(intermediatePath))
                        {
                            // This is a safety net to make sure we don't go hog wild
                            // and delete too far up the path.  Determine how many intermediate
                            // folders we have so we don't delete any more than are found.
                            string[] intermediateFolders = intermediatePath.Split(Path.DirectorySeparatorChar);
                            int maxFolderDeleteCount = intermediateFolders.Length;
                            int deleteCount = 0;

                            while ((IsDirectoryEmpty(sourcePath)) &&
                                   (deleteCount < maxFolderDeleteCount))
                            {
                                // If we hit our source folder, then bail.  We don't want to
                                // keep deleting.  This is a second check along with the 
                                // while() condition to make sure we don't delete too much.
                                if (szSourceFolderName == sourcePath)
                                    break;

                                Directory.Delete(sourcePath);
                                deleteCount++;

                                int lastIndex = sourcePath.LastIndexOf(Path.DirectorySeparatorChar);
                                if (lastIndex == -1)
                                    break;

                                sourcePath = sourcePath.Substring(0, lastIndex);
                            }
                        }

                        iTotalFileCount++;
                        iFileCount++;
                    }

                    sbLog.Append("Moved " + iFileCount.ToString() + " from " + szSourceFolderName + " to " + szTargetFolderName);
                }
                catch (Exception e)
                {
                    LogEventError("Source Folder: " + szSourceFolderName + ". Target Folder: " + szTargetFolderName, e);
                }
            }
        }

        public bool IsDirectoryEmpty(string path)
        {
            IEnumerable<string> items = Directory.EnumerateFileSystemEntries(path);
            using (IEnumerator<string> en = items.GetEnumerator())
            {
                return !en.MoveNext();
            }
        }
    }
}
