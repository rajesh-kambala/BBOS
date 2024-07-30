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

 Notes:	Created By TSI Class Generator on 8/20/2014 7:40:16 AM

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
        bool IsUserAuthorized(IPRWebUser user);
        IPRWebUserNoteReminder GetReminder(IPRWebUser user, string type);
        IPRWebUserNoteReminder AddReminder(IPRWebUser user, string type);
        IBusinessObjectSet GetReminders(IPRWebUser user);
        void DismissReminder(IPRWebUser user, string type);
        bool HasReminder(IPRWebUser user);

        string GetTruncatedText(int maxLength);
        string GetFormattedDateTime();
        string GetFormattedDateTime(string lineBreak);

        void SendReminderEmail(IPRWebUser user);

        string NoteType
        {
            get;
        }


        string Subject
        {
            get;
        }

        string UpdatedBy
        {
            get;
        }

        string UpdatedByLocation
        {
            get;
        }

        string ReminderTypes
        {
            get;
        }
    }
}
