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

 ClassName: PRWebUserCustomField
 Description:	

 Notes:	Created By TSI Class Generator on 7/18/2014 9:36:57 AM

***********************************************************************
***********************************************************************/
using System;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Interface definition for the PRWebUserCustomField class.
    /// </summary>
    public partial interface IPRWebUserCustomField : IEBBObject
    {
        string Value
        {
            get;
        }

        int CompanyCount { get; }
        int ValueCount { get; }

        void SetValue(int companyID, string value);
        void SetValue(int companyID, int filedLookupID);

        IBusinessObjectSet GetLookupValues();
        IPRWebUserCustomFieldLookup GetLookupValue(int lookupID);

        void AddLookupValue(string value, int sequence);
        void RemoveLookupValue(string value);
        void RemoveLookupValue(int id);
    }
}
