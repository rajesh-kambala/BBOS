/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BBScore
 Description:	

 Notes:	Created By Christopher Walls on 7/3/2024

***********************************************************************
***********************************************************************/
using System;
using System.Data;
namespace PRCo.BBOS.WebServices
{
    public class StockExchange
    {
        public string Name;
        public string Symbol;

        public void Load(IDataReader oReader)
        {
            Name = Utils.GetString(oReader, 0);
            Symbol = Utils.GetString(oReader, 1);
        }

        public void Load(DataRowView drRow)
        {
            Name = Utils.GetString(drRow, 0);
            Symbol = Utils.GetString(drRow, 1);
        }
    }
}