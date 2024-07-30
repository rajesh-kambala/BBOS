/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Utils
 Description:	

 Notes:	Created By Christopher Walls on 9/13/07

***********************************************************************
***********************************************************************/
using System;
using System.Data;

namespace PRCo.BBOS.WebServices {
    public class Utils {

        public static string GetString(IDataReader oReader, int iOrdinal) {
            if (oReader[iOrdinal] == DBNull.Value) {
                //return string.Empty;
                return null;
            }

            return oReader.GetString(iOrdinal).Trim();
        }

        public static string GetString(DataRowView drRow, int iOrdinal)
        {
            if (drRow[iOrdinal] == DBNull.Value)
            {
                //return string.Empty;
                return null;
            }

            return drRow[iOrdinal].ToString().Trim();
        }

        public static string GetString(DataRow drRow, int iOrdinal)
        {
            if (drRow[iOrdinal] == DBNull.Value)
            {
                //return string.Empty;
                return null;
            }

            return drRow[iOrdinal].ToString().Trim(); 
        }
    }
}
