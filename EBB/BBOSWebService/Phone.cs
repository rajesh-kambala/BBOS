/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2014

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

 Notes:	Created By Christopher Walls on 9/13/07

***********************************************************************
***********************************************************************/
using System.Data;
namespace PRCo.BBOS.WebServices {
    public class Phone {
	    public string Type;
        public string CountryCode;
	    public string AreaCode;
	    public string Number;
        public string Description;

        public void Load(IDataReader oReader) {
            Type = Utils.GetString(oReader, 0);
            CountryCode = Utils.GetString(oReader, 1);
            AreaCode = Utils.GetString(oReader, 2);
            Number = Utils.GetString(oReader, 3);
            Description = Utils.GetString(oReader, 5);
        }

        public void Load(DataRowView drRow)
        {
            Type = drRow[0].ToString();
            CountryCode = drRow[1].ToString();
            AreaCode = drRow[2].ToString();
            Number = drRow[3].ToString();
            Description = drRow[5].ToString();
        }
    }
}