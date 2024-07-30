/***********************************************************************
***********************************************************************
 Copyright Blue Book Services 2023-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Blue Book Services.  Contact
 by e-mail at info@travant.com

 ClassName: PRInvoice
 Description:	

 Notes:	Created By TSI Class Generator on 5/15/2023 8:13:35 AM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;
using TSI.Security;
using TSI.DataAccess;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Data Manager for the PRInvoice class.
    /// </summary>
    public partial class PRInvoiceMgr : EBBObjectMgr
    {
        public override bool UsesIdentity
        {
            get
            {
                return false;
            }
            set
            {
                base.UsesIdentity = value;
            }
        }

        public override bool UsesOptLock
        {
            get
            {
                return false;
            }
            set
            {
                base.UsesOptLock = value;
            }
        }

        /// </summary>
        new public const string COL_CREATED_USER_ID = "prinv_CreatedBy";
        new public const string COL_UPDATED_USER_ID = "prinv_UpdatedBy";
        new public const string COL_CREATED_DATETIME = "prinv_CreatedDate";
        new public const string COL_UPDATED_DATETIME = "prinv_UpdatedDate";
        public const string COL_TIMESTAMP = "prinv_Timestamp";

        public PRInvoice GetByPaymentURLKey(string paymentURLKey)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prinv_PaymentURLKey", paymentURLKey));
            return (PRInvoice)GetObject("prinv_PaymentURLKey = @prinv_PaymentURLKey", oParameters);
        }

        public PRInvoice GetByStripeInvoiceId(string stripeInvoiceId)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prinv_StripeInvoiceId", stripeInvoiceId));
            return (PRInvoice)GetObject("prinv_StripeInvoiceId = @prinv_StripeInvoiceId", oParameters);
        }
    }
}
