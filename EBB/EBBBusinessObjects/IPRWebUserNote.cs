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

 ClassName: PRWebUserNote
 Description:	

 Notes:	Created By TSI Class Generator on 8/20/2014 8:41:03 AM

***********************************************************************
***********************************************************************/
using System;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Interface definition for the PRWebUserNote class.
    /// </summary>
    public partial interface IPRWebUserNote : IEBBObject
    {
         #region TSI Framework Generated Code
        /// <summary>
        /// Accessor for the prwun_IsPrivate property.
        /// </summary>
        bool prwun_IsPrivate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_Key property.
        /// </summary>
        bool prwun_Key {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_CreatedDate property.
        /// </summary>
        DateTime prwun_CreatedDate {
            get;
            set;
        }

        DateTime prwun_NoteUpdatedDateTime
        {
            get;
            set;
        }


        int prwun_NoteUpdatedBy
        {
            get;
            set;
        }
        
        /// <summary>
        /// Accessor for the prwun_Date property.
        /// </summary>
        DateTime prwun_Date {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_DateUTC property.
        /// </summary>
        DateTime prwun_DateUTC {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_TimeStamp property.
        /// </summary>
        DateTime prwun_TimeStamp {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_UpdatedDate property.
        /// </summary>
        DateTime prwun_UpdatedDate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_AssociatedID property.
        /// </summary>
        int prwun_AssociatedID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_CompanyID property.
        /// </summary>
        int prwun_CompanyID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_CreatedBy property.
        /// </summary>
        int prwun_CreatedBy {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_HQID property.
        /// </summary>
        int prwun_HQID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_UpdatedBy property.
        /// </summary>
        int prwun_UpdatedBy {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_WebUserID property.
        /// </summary>
        int prwun_WebUserID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_WebUserNoteID property.
        /// </summary>
        int prwun_WebUserNoteID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_AMPM property.
        /// </summary>
        string prwun_AMPM {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_AssociatedType property.
        /// </summary>
        string prwun_AssociatedType {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_Hour property.
        /// </summary>
        string prwun_Hour {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_Minute property.
        /// </summary>
        string prwun_Minute {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_Note property.
        /// </summary>
        string prwun_Note {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_Subject property.
        /// </summary>
        string prwun_Subject {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwun_Timezone property.
        /// </summary>
        string prwun_Timezone {
            get;
            set;
        }

         #endregion
    }
}
