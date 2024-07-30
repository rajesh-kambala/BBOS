/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2009

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 ClassName: Specie
 Description:	

 Notes:	Created By Tad Eness on 7/18/2007 3:07:32 PM

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
    /// Container for Species information intendeded to be
    /// serialized / deserialized.
    /// </summary>
    [Serializable]
    public class Specie
    {
        public int SpecieID;
        public string Name;

        /// <summary>
        /// Constructor
        /// </summary>
        public Specie() {     
        }

        /// <summary>
        /// Constructor
        /// </summary>
        public Specie(int iSpecieID) {
            SpecieID = iSpecieID;
        }
    }
}
