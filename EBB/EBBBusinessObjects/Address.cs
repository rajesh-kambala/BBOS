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

 ClassName: Address
 Description:	

 Notes:	Created By Sharon Cole on 7/18/2007 3:07:32 PM

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Security;
using TSI.Utils;

using PRCo.EBB.Util;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Container for Address information intendeded to be
    /// serialized / deserialized.
    /// </summary>
    [Serializable]
    public class Address 
    {
        public const string TYPE_MAIL = "M";
        public const string TYPE_PHYSICAL = "PH";
    
        public int StateID;
        public string Type;
        public string Address1;
        public string Address2;
        public string Address3;
        public string Address4;
        public string County;
        public string City;
        public int CountryID;
        public string PostalCode;
        public bool Publish;
    }
}
