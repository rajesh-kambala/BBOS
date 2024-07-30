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

 ClassName: PRGetListedRequest
 Description:	

 Notes:	Created By TSI Class Generator on 3/17/2014 2:42:33 PM

***********************************************************************
***********************************************************************/
using System;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Interface definition for the PRGetListedRequest class.
    /// </summary>
    public partial interface IPRGetListedRequest : IBusinessObject
    {

        void CreateCRMTask();
        void SendThankYouEmail();
    }
}
