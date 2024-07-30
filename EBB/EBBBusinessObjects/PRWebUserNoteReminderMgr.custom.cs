/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Blue Book Services, Inc..  Contact
 by e-mail at chris@wallsfamily.com

 ClassName: PRWebUserNoteReminder
 Description:	

 Notes:	Created By TSI Class Generator on 8/20/2014 7:40:17 AM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;
using TSI.Security;
using TSI.DataAccess;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Data Manager for the PRWebUserNoteReminder class.
    /// </summary>
    public partial class PRWebUserNoteReminderMgr : EBBObjectMgr
    {
        /// <summary>
        /// Override the standard TSI audit column names with the
        /// Sage CRM names.
        /// </summary>
        new public const string COL_CREATED_USER_ID = "prwunr_CreatedBy";
        new public const string COL_UPDATED_USER_ID = "prwunr_UpdatedBy";
        new public const string COL_CREATED_DATETIME = "prwunr_CreatedDate";
        new public const string COL_UPDATED_DATETIME = "prwunr_UpdatedDate";


        public IBusinessObjectSet GetByUser(int noteID, int userID)
        {
            IList parmList = GetParmList("prwunr_WebUserNoteID", noteID);
            parmList.Add(new ObjectParameter("prwunr_WebUserID", userID));
            return GetObjects(FormatSQL("prwunr_WebUserNoteID={0} AND prwunr_WebUserID={1}", parmList), null, parmList);
        }

        public IBusinessObjectSet GetByNote(int noteID)
        {
            IList parmList = GetParmList("prwunr_WebUserNoteID", noteID);
            return GetObjects(FormatSQL("prwunr_WebUserNoteID={0}", parmList), null, parmList);
        }

        public override bool UsesIdentity
        {
            get
            {
                return true;
            }
            set
            {
                base.UsesIdentity = value;
            }
        }

        public override bool UsesOptLock
        {
            get
            {
                return false;
            }
            set
            {
                base.UsesOptLock = value;
            }
        }

    }
}
