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

 ClassName: InternetAddress
 Description:	

 Notes:	Created By Sharon Cole on 7/18/2007 3:07:32 PM

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Container for InternetAddress information intendeded to be
    /// serialized / deserialized.
    /// </summary>
    [Serializable]
    public class InternetAddress
    {
        public string Type;
        public string Description;
        public string Address;
        
        public string Address2 {
            get{return Address;}
        }

    }
}
