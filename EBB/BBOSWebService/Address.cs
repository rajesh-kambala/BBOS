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

 ClassName: Address
 Description:	

 Notes:	Created By Christopher Walls on 9/13/07

***********************************************************************
***********************************************************************/
using System;
using System.Data;

namespace PRCo.BBOS.WebServices {
    public class Address  {
	    public string Type;
	    public string Address1;
	    public string Address2;
	    public string Address3;
	    public string Address4;
	    public string Address5;
	    public string City;
	    public string State;
	    public string Country;
	    public string PostalCode;

        public void Load(IDataReader oReader) {
        
            Type = Utils.GetString(oReader, 0);
            Address1 = Utils.GetString(oReader, 1);
            Address2 = Utils.GetString(oReader, 2);
            Address3 = Utils.GetString(oReader, 3);
            Address4 = Utils.GetString(oReader, 4);
            City = Utils.GetString(oReader, 5);
            State = Utils.GetString(oReader, 6);
            PostalCode = Utils.GetString(oReader, 7);
            Country = Utils.GetString(oReader, 8);  
   
        }

        public void Load(DataRowView drRow)
        {
            Type = Utils.GetString(drRow, 0);
            Address1 = Utils.GetString(drRow, 1);
            Address2 = Utils.GetString(drRow, 2);
            Address3 = Utils.GetString(drRow, 3);
            Address4 = Utils.GetString(drRow, 4);
            City = Utils.GetString(drRow, 5);
            State = Utils.GetString(drRow, 6);
            PostalCode = Utils.GetString(drRow, 7);
            Country = Utils.GetString(drRow, 8);  
        }
    }
}