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

 ClassName: PRBusinessReportPurchase
 Description:	

 Notes:	Created By TSI Class Generator on 4/15/2014 12:55:44 PM

***********************************************************************
***********************************************************************/
using System;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Interface definition for the PRBusinessReportPurchase class.
    /// </summary>
    public partial interface IPRBusinessReportPurchase : IEBBObject
    {
        void CreateCRMTask(CreditCardPaymentInfo oCCPayment, CreditCardProductInfo oProductInfo);

        void SendBREmail();
        void SendBREmail(string productCode);
    }
}
