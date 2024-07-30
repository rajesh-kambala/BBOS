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

 ClassName: Numeral
 Description:	

 Notes:	Created By Christopher Walls on 9/13/07

***********************************************************************
***********************************************************************/
using System.Data;

namespace PRCo.BBOS.WebServices {

    public class RatingNumeral  {
	    public string Code;
	    public string Description;

        public void Load(IDataReader oReader) {
            Code = Utils.GetString(oReader, 0);
            Description = Utils.GetString(oReader, 1);
        }

        public void Load(DataRowView drRow)
        {
            Code = Utils.GetString(drRow, 0);
            Description = Utils.GetString(drRow, 1);
        }
    }
}