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

 ClassName: PayRating
 Description:	

 Notes:	Created By Christopher Walls on 9/13/07

***********************************************************************
***********************************************************************/
using System.Data;

namespace PRCo.BBOS.WebServices {
    public class PayRating {
	    public string Code;
	    public string Description;

        public void Load(IDataReader oReader) {
            Code = Utils.GetString(oReader, 5);
            Description = Utils.GetString(oReader, 4);
        }

        public void Load(DataRowView drRow)
        {
            Code = Utils.GetString(drRow, 5);
            Description = Utils.GetString(drRow, 4);
        }
    }
}