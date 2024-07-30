/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ServiceUnitPaymentInfo
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace PRCo.EBB.BusinessObjects {

    /// <summary>
    /// Helper class to transmit information to the
    /// ServiceUnitPayment page from various pages that 
    /// initiate transactions.
    /// </summary>
    [Serializable]
    public class ServiceUnitPaymentInfo {
        
        public int ObjectID;
        public int Price;
        public int ProductID;
        public int UOMID;
        public bool IncludeInRequest;
        public bool Charge;
    }
}
