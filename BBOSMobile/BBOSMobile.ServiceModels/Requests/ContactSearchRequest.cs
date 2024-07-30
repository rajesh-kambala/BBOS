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
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BBOSMobile.ServiceModels.Requests
{
    public class ContactSearchRequest : RequestBase
    {

        public string FirstName { get; set; }

        public string LastName { get; set; }

        public string Title { get; set; }

        public string BBID { get; set; }

        public string Email { get; set; }


        public string State { get; set; }

        public string City { get; set; }

        public string PostalCode { get; set; }

        public Enumerations.Radius Radius { get; set; }
    }
}
