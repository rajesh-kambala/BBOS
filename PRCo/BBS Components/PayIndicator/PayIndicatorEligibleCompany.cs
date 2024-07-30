/***********************************************************************
 Copyright Blue Book Services, Inc. 2010-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PayIndicatorEligibleCompany.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace BBSI.PayIndicator
{
    public class PayIndicatorEligibleCompany
    {
        public int SubjectCompanyID;
        public int SubmitterCount;
        public int ARDetailCount;

        // This is our magic # to indicate no score, since a 
        // computed score of zero valid.
        public decimal PayIndicatorScore = -1;

        public string PayIndicator;
        public DateTime MostRecentARDate;

        public string ActionCode = "UC";

        public bool FailedSubmitterCountThreshold = false;
        public bool FailedARDetailCountThreshold = false;
        public bool FailedARDateThreshold = false;
        public bool Nuisance = false;

        public List<string> ARDetails = new List<string>();

        public PayIndicatorEligibleCompany(int companyID)
        {
            SubjectCompanyID = companyID;
        }

        public PayIndicatorEligibleCompany(IDataReader oReader)
        {
            SubjectCompanyID = oReader.GetInt32(0);

            if (oReader[1] != DBNull.Value)
            {
                PayIndicatorScore =  oReader.GetDecimal(1);
            }

            if (oReader[2] != DBNull.Value)
            {
                PayIndicator = oReader.GetString(2);
            }
            
            SubmitterCount = oReader.GetInt32(3);
            ARDetailCount = oReader.GetInt32(4);
            MostRecentARDate = oReader.GetDateTime(5);
        }
    }
}
