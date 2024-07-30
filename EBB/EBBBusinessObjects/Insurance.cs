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

 ClassName: Insurance
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace PRCo.EBB.BusinessObjects {

    /// <summary>
    /// Container for Insurance Carrier information intendeded to be
    /// serialized / deserialized.
    /// </summary>
    [Serializable]
    public class Insurance {

        public decimal Amount;
        public string Name;
        public string Address1;
        public string Address2;
        public string City;
        public string PostalCode;

        public int StateID;
        public int CountryID;
    
        public string Type;
    }
}
