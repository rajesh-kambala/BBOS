/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2015

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

 Notes:	Created By TSI Class Generator on 1/30/2015 10:28:52 AM

***********************************************************************
***********************************************************************/
using System;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Interface definition for the PRWebUserNoteReminder class.
    /// </summary>
    public partial interface IPRWebUserNoteReminder : IEBBObject
    {
         #region TSI Framework Generated Code
        /// <summary>
        /// Accessor for the prwunr_CreatedDate property.
        /// </summary>
        DateTime prwunr_CreatedDate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_Date property.
        /// </summary>
        DateTime prwunr_Date {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_DateUTC property.
        /// </summary>
        DateTime prwunr_DateUTC {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_SentDateTime property.
        /// </summary>
        DateTime prwunr_SentDateTime {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_SentDateTimeUTC property.
        /// </summary>
        DateTime prwunr_SentDateTimeUTC {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_TimeStamp property.
        /// </summary>
        DateTime prwunr_TimeStamp {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_UpdatedDate property.
        /// </summary>
        DateTime prwunr_UpdatedDate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_CreatedBy property.
        /// </summary>
        int prwunr_CreatedBy {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_Deleted property.
        /// </summary>
        int prwunr_Deleted {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_Secterr property.
        /// </summary>
        int prwunr_Secterr {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_UpdatedBy property.
        /// </summary>
        int prwunr_UpdatedBy {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_WebUserID property.
        /// </summary>
        int prwunr_WebUserID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_WebUserNoteID property.
        /// </summary>
        int prwunr_WebUserNoteID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_WebUserNoteReminderID property.
        /// </summary>
        int prwunr_WebUserNoteReminderID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_WorkflowId property.
        /// </summary>
        int prwunr_WorkflowId {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_AMPM property.
        /// </summary>
        string prwunr_AMPM {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_Email property.
        /// </summary>
        string prwunr_Email {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_Hour property.
        /// </summary>
        string prwunr_Hour {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_Minute property.
        /// </summary>
        string prwunr_Minute {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_Phone property.
        /// </summary>
        string prwunr_Phone {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_Threshold property.
        /// </summary>
        string prwunr_Threshold {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_Timezone property.
        /// </summary>
        string prwunr_Timezone {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwunr_Type property.
        /// </summary>
        string prwunr_Type {
            get;
            set;
        }

         #endregion
    }
}
