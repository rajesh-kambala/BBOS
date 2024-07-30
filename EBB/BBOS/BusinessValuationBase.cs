/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2024-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BusinessValuationBase
 Description: This class implements base functionality for BusinessValuation tasks

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using System;
using System.Data;
using System.Text;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public class BusinessValuationBase : PageBase
    {
        protected string simulateSageFileUpload(string sSSFileId, string szSourceFile, string szFileName, int iAssignedToId, string szNotePrefix, IDbTransaction oTran)
        {
            return base.simulateSageFileUpload(sSSFileId, szSourceFile, szFileName, iAssignedToId, string.Format(Resources.Global.BusinessValuationTaskNotes,szNotePrefix), "Business Valuation File was created through BBOS.", Utilities.GetIntConfigValue("BusinessValuationChannelIdOverride", 0), "BV", oTran);
        }

        protected string createEmailCommunicationRecord(string sSSFileId, string subject, string sTaskNotes, int iAssignedToId, IDbTransaction oTran)
        {
            return base.createEmailCommunicationRecord(sSSFileId, subject, sTaskNotes, iAssignedToId, "SS", "BV", oTran); //Special Services, Business Valuation
        }

        /// <summary>
        /// Notifies a BBS User that a new file was opened (overloaded).
        /// </summary>
        /// <param name="iFileID"></param>
        /// <param name="iUserID"></param>
        /// <param name="emailTo"></param>
        /// <param name="subject"></param>
        /// <param name="oTran"></param>
        protected void AssignRatingAnalystTask(int iFileID, int iUserID, IDbTransaction oTran)
        {
            string szSubject = Utilities.GetConfigValue("BusinessValuationNotifyNewFileEmailSubject", "New Business Valuation Files Received via BBOS");
            StringBuilder szBody = new StringBuilder("Business Valuation file ID " + iFileID.ToString() + " was created via BBOS.");

            //Assign task to Rating Analyst Channel
            GetObjectMgr().CreateTask(iUserID,
                                      "Pending",
                                      szBody.ToString(),
                                      Utilities.GetConfigValue("BusinessValuationFileCategory", "SS"),
                                      Utilities.GetConfigValue("BusinessValuationFileSubcategory", "BV"),
                                      _oUser.prwu_BBID,
                                      _oUser.peli_PersonID,
                                      iFileID,
                                      "ToDo",
                                      szSubject,
                                      null,
                                      Utilities.GetIntConfigValue("BusinessValuationChannelIdOverride", 0),
                                      oTran);
        }
    }
}