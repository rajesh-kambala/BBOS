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

 ClassName: PayIndicator
 Description:	

 Notes:	Created By Christopher Walls on 6/12/24

***********************************************************************
***********************************************************************/
using System.Data;

namespace PRCo.BBOS.WebServices
{
    public class PayIndicator
    {
        public string Code;
        public string Description;

        public void Load(IDataReader oReader)
        {
            Code = Utils.GetString(oReader, 1);
            Description = Utils.GetString(oReader, 3);
        }

        public void Load(DataRowView drRow)
        {
            Code = Utils.GetString(drRow, 1);
            Description = Utils.GetString(drRow, 3);
        }
    }
}