/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2021

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyFindResult
 Description:	

 Notes:	Created By Christopher Walls on 4/6/21

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;

namespace PRCo.BBOS.WebServices
{
    public class CompanyFindResult
    {
        public int BBID;
        public string CompanyName;
        public string WebSite;

        public List<Address> Addresses;
        public List<Phone> Phones;

        public void Load(IDataReader oReader)
        {
            BBID = oReader.GetInt32(0);
            CompanyName = Utils.GetString(oReader, 5);
            WebSite = Utils.GetString(oReader, 4);
        }
    }
}