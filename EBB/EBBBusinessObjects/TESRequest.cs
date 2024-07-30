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

 ClassName: CompanyRelationship
 Description:	

 Notes:	Created By Sharon Cole on 7/18/2007 3:07:32 PM

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Xml;
using System.Xml.Serialization;

using TSI.Arch;
using TSI.DataAccess;
using TSI.BusinessObjects;
using TSI.Utils;

using PRCo.EBB.Util;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Container for TESRequest information intendeded to be
    /// serialized / deserialized.
    /// </summary>
    [Serializable]
    public class TESRequest
    {
        public int Index { get; set; }
        public int Id { get; set; }
        public int SerialNumber { get; set; }
        public int BBNumber { get; set; }
        public string CompanyName { get; set; }
        public string CompanyLocation { get; set; }
        public string CompanyIntegrity { get; set; }
        public string CompanyPayPerformance { get; set; }
        public string CompanyHighCredit { get; set; }
        public string CompanyLastDealt { get; set; }
        public bool CompanyOutOfBusiness { get; set; }
        public string CompanyAmountOwedCurrent { get; set; }
        public string CompanyAmountOwed1To30 { get; set; }
        public string CompanyAmountOwed31To60 { get; set; }
        public string CompanyAmountOwed61To90 { get; set; }
        public string CompanyAmountOwed91Plus { get; set; }
        public string Comments { get; set; }
        public string SecondRequest { get; set; }
    }
}
