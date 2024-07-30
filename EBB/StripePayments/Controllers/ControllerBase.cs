/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ControllerBase
 Description: 

 Notes:	

***********************************************************************/

using System;
using System.Web.Http;
using TSI.Utils;

namespace StripePayments.Controllers
{
    public class ControllerBase : ApiController
    {
        public const string PRINV_SENT_METHOD_CODE_EMAIL = "E";
        public const string PRINV_SENT_METHOD_CODE_FAX = "F";
        public const string PRINV_SENT_METHOD_CODE_MAIL = "M";

        public const string PRINV_PAYMENT_METHOD_CODE_CHECK = "C";
        public const string PRINV_PAYMENT_METHOD_CODE_CREDIT_CARD_STRIPE = "SCC";
        public const string PRINV_PAYMENT_METHOD_CODE_ACH_STRIPE = "SACH";
        public const string PRINV_PAYMENT_METHOD_CODE_CREDIT_CARD = "BBSCC";

        private ILogger _logger = null;
        protected ILogger GetLogger()
        {
            return GetLogger(string.Empty);
        }

        protected ILogger GetLogger(string method)
        {
            if (_logger == null)
            {
                _logger = LoggerFactory.GetLogger();
            }

            if (!string.IsNullOrEmpty(method))
            {
                _logger.RequestName = method;
            }

            return _logger;
        }

        protected void SetLoggerMethod(string method)
        {
            GetLogger(method);
        }
    }
}
