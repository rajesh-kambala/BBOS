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

 Notes:	Created By TSI Class Generator on 8/20/2014 7:40:17 AM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using TSI.Arch;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRWebUserNoteReminder.
    /// </summary>
    public partial class PRWebUserNoteReminder : EBBObject, IPRWebUserNoteReminder
    {
        public override void OnAfterLoad(IDictionary oData, int iOptions)
        {
            base.OnAfterLoad(oData, iOptions);

            _dtCreatedDateTime = _oMgr.GetDateTime(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_CREATED_DATE]);
            _szCreatedUserID = _oMgr.GetString(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_CREATED_BY]);
        }


        public override void Save(System.Data.IDbTransaction oTran)
        {
            if (_prwunr_Date != DateTime.MinValue)
            {

                DateTime dtDateTime = _prwunr_Date;

                dtDateTime = dtDateTime.AddHours(Convert.ToInt32(_prwunr_Hour));
                dtDateTime = dtDateTime.AddMinutes(Convert.ToInt32(_prwunr_Minute));

                if (_prwunr_AMPM == "PM")
                {
                    dtDateTime = dtDateTime.AddHours(12);
                }

                prwunr_DateUTC = ConvertToUTC(dtDateTime, _prwunr_Timezone);
            }

            base.Save(oTran);

        }
    }
}
