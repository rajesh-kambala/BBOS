/***********************************************************************
***********************************************************************
 Copyright Blue Book Services. 2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanySearchRequest
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using BBOSMobile.ServiceModels.Common;
using System;
using System.Collections.Generic;

namespace BBOSMobile.ServiceModels.Responses
{
    public class ContactSearchResponse: ResponseBase
    {
        public IEnumerable<ContactBase> Contacts { get; set; }

        public int ResultCount { get; set; }
    }
}
