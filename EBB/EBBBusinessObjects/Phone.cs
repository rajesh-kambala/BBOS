/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2009

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Phone
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
    /// Container for Phone information intendeded to be
    /// serialized / deserialized.
    /// </summary>
    [Serializable]
    public class Phone
    {
        public string Type;
        public string AreaCode;
        public string Number;
        public string Extension;
        public string CountryCode;
        
        public string Type2 {
            get{return Type;}
        }
        public string AreaCode2 {
            get { return AreaCode; }
        }
        public string Number2 {
            get { return Number; }
        }
        public string Extension2 {
            get { return Extension; }
        }
        public string CountryCode2
        {
            get { return CountryCode; }
        }
    }
}
