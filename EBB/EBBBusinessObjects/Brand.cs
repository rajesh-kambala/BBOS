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

 ClassName: Bank
 Description:	

 Notes:	Created By Chris Walls on 7/20/2007 3:19 PM

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace PRCo.EBB.BusinessObjects {

    /// <summary>
    /// Container for Brand information intendeded to be
    /// serialized / deserialized.
    /// </summary>
    [Serializable]
    public class Brand {
        public string Name;
        
        public string Name2 {
            get {return Name;}
        }
    }
}
