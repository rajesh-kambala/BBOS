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

 ClassName: Custom_Caption
 Description:	

 Notes:	Created By TSI Class Generator on 10/18/2005 10:13:21 AM

***********************************************************************
***********************************************************************/
using System;
using TSI.BusinessObjects;
using PRCo.EBB.BusinessObjects;

namespace PRCo.EBB.Util
{
    /// <summary>
    /// Interface definition for the Custom_Caption class.
    /// </summary>
    public interface ICustom_Caption : IEBBObject
    {
         #region TSI Framework Generated Code
        /// <summary>
        /// Accessor for the ID property.
        /// </summary>
        int ID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the Code property.
        /// </summary>
        string Code {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the Meaning property.
        /// </summary>
        string Meaning {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the Name property.
        /// </summary>
        string Name {
            get;
            set;
        }

         #endregion
    }
}
