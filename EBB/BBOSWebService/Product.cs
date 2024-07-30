/***********************************************************************
***********************************************************************
 Copyright Blue Book Services LLC 2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services LLC is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services LLC
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Product
 Description:	

 Notes:	Created By Christopher Walls on 6/10/24

***********************************************************************
***********************************************************************/
using System.Data;
namespace PRCo.BBOS.WebServices
{
    public class Product
    {
        public string Name;

        public void Load(IDataReader oReader)
        {
            Name = Utils.GetString(oReader, 0);
        }

        public void Load(DataRowView drRow)
        {
            Name = Utils.GetString(drRow, 0);
        }
    }
}