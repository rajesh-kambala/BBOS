/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2010

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Person
 Description:	

 Notes:	Created By Christopher Walls on 1/4/10

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;

namespace PRCo.BBOS.WebServices
{
    public class Person
    {
        public int PersonID;
        public string FirstName;
        public string LastName;
        public string MiddleName;
        public string Suffix;
        public string Title;
        public string Email;
        public List<Phone> Phones;


        public void Load(IDataReader oReader) {
            PersonID = oReader.GetInt32(0);
            FirstName = Utils.GetString(oReader, 2);
            LastName = Utils.GetString(oReader, 3);
            MiddleName = Utils.GetString(oReader, 4);
            Suffix = Utils.GetString(oReader, 5);
            Title = Utils.GetString(oReader, 6);
            Email = Utils.GetString(oReader, 7);
        }

        public void Load(DataRowView drRow)
        {
            PersonID = Convert.ToInt32(drRow[0]);
            FirstName = Utils.GetString(drRow, 2);
            LastName = Utils.GetString(drRow, 3);
            MiddleName = Utils.GetString(drRow, 4);
            Suffix = Utils.GetString(drRow, 5);
            Title = Utils.GetString(drRow, 6);
            Email = Utils.GetString(drRow, 7);
        }

    }
}
