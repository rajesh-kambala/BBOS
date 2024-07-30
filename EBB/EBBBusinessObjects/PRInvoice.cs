/***********************************************************************
***********************************************************************
 Copyright Blue Book Services 2023

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
using TSI.Arch;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRInvoice.
    /// </summary>
    public partial class PRInvoice : EBBObject
    {
        protected DateTime	_prinv_CreatedDate;
        protected DateTime	_prinv_PaymentDateTime;
        protected DateTime	_prinv_SentDateTime;
        protected DateTime	_prinv_TimeStamp;
        protected DateTime	_prinv_UpdatedDate;
        protected int		_prinv_CompanyID;
        protected int		_prinv_CreatedBy;
        protected int		_prinv_Deleted;
        protected int		_prinv_InvoiceID;
        protected int		_prinv_Secterr;
        protected int		_prinv_UpdatedBy;
        protected int		_prinv_WorkflowId;
        protected string	_prinv_InvoiceNbr;
        protected string	_prinv_PaymentMethod;
        protected string	_prinv_PaymentMethodCode;
        protected string    _prinv_PaymentBrand;
        protected string    _prinv_PaymentImportedIntoMAS;
        protected string	_prinv_StripePaymentURL;
        protected string    _prinv_StripeInvoiceId;
        protected string	_prinv_SentMethodCode;

        /// <summary>
        /// Constructor
        /// </summary>
        public PRInvoice() {}

        #region TSI Framework Generated Code
        /// <summary>
        /// Returns the key values of the current
        /// instance in the same order as the key
        /// fields.
        /// </summary>
        /// <returns>IList</returns>
        override public IList GetKeyValues() {
            if (_oKeyValues == null) {
                _oKeyValues = new ArrayList();
                _oKeyValues.Add(prinv_InvoiceID);
            }
	          return _oKeyValues;
        }

        /// <summary>
        /// Sets the key values for this object based
        /// on the specified list of values.  The list of
        /// values must be in the same order the keys are
        /// defined in GetKeyValues()
        /// </summary>
        override public void ClearKeyValues() {
            prinv_InvoiceID = 0;
        }

        /// <summary>
        /// Sets the key values for this object based
        /// on the specified list of values.  The list of
        /// values must be in the same order the keys are
        /// defined in GetKeyValues();
        /// </summary>
        /// <param name="oKeyValues">IList</param>
        override public void SetKeyValues(IList oKeyValues) {
            prinv_InvoiceID = Convert.ToInt32(oKeyValues[0]);
        }

        /// <summary>
        /// Accessor for the prinv_CreatedDate property.
        /// </summary>
        public DateTime prinv_CreatedDate {
            get {return _prinv_CreatedDate;}
            set {SetDirty(_prinv_CreatedDate, value);
                 _prinv_CreatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prinv_PaymentDateTime property.
        /// </summary>
        public DateTime prinv_PaymentDateTime {
            get {return _prinv_PaymentDateTime;}
            set {SetDirty(_prinv_PaymentDateTime, value);
                 _prinv_PaymentDateTime = value;}
        }

        /// <summary>
        /// Accessor for the prinv_SentDateTime property.
        /// </summary>
        public DateTime prinv_SentDateTime {
            get {return _prinv_SentDateTime;}
            set {SetDirty(_prinv_SentDateTime, value);
                 _prinv_SentDateTime = value;}
        }

        /// <summary>
        /// Accessor for the prinv_TimeStamp property.
        /// </summary>
        public DateTime prinv_TimeStamp {
            get {return _prinv_TimeStamp;}
            set {SetDirty(_prinv_TimeStamp, value);
                 _prinv_TimeStamp = value;}
        }

        /// <summary>
        /// Accessor for the prinv_UpdatedDate property.
        /// </summary>
        public DateTime prinv_UpdatedDate {
            get {return _prinv_UpdatedDate;}
            set {SetDirty(_prinv_UpdatedDate, value);
                 _prinv_UpdatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prinv_CompanyID property.
        /// </summary>
        public int prinv_CompanyID {
            get {return _prinv_CompanyID;}
            set {SetDirty(_prinv_CompanyID, value);
                 _prinv_CompanyID = value;}
        }

        /// <summary>
        /// Accessor for the prinv_CreatedBy property.
        /// </summary>
        public int prinv_CreatedBy {
            get {return _prinv_CreatedBy;}
            set {SetDirty(_prinv_CreatedBy, value);
                 _prinv_CreatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prinv_Deleted property.
        /// </summary>
        public int prinv_Deleted {
            get {return _prinv_Deleted;}
            set {SetDirty(_prinv_Deleted, value);
                 _prinv_Deleted = value;}
        }

        /// <summary>
        /// Accessor for the prinv_InvoiceID property.
        /// </summary>
        public int prinv_InvoiceID {
            get {return _prinv_InvoiceID;}
            set {SetDirty(_prinv_InvoiceID, value);
                 _prinv_InvoiceID = value;}
        }

        /// <summary>
        /// Accessor for the prinv_Secterr property.
        /// </summary>
        public int prinv_Secterr {
            get {return _prinv_Secterr;}
            set {SetDirty(_prinv_Secterr, value);
                 _prinv_Secterr = value;}
        }

        /// <summary>
        /// Accessor for the prinv_UpdatedBy property.
        /// </summary>
        public int prinv_UpdatedBy {
            get {return _prinv_UpdatedBy;}
            set {SetDirty(_prinv_UpdatedBy, value);
                 _prinv_UpdatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prinv_WorkflowId property.
        /// </summary>
        public int prinv_WorkflowId {
            get {return _prinv_WorkflowId;}
            set {SetDirty(_prinv_WorkflowId, value);
                 _prinv_WorkflowId = value;}
        }

        /// <summary>
        /// Accessor for the prinv_InvoiceNbr property.
        /// </summary>
        public string prinv_InvoiceNbr {
            get {return _prinv_InvoiceNbr;}
            set {SetDirty(_prinv_InvoiceNbr, value);
                 _prinv_InvoiceNbr = value;}
        }

        /// <summary>
        /// Accessor for the prinv_PaymentMethod property.
        /// </summary>
        public string prinv_PaymentMethod {
            get {return _prinv_PaymentMethod;}
            set {SetDirty(_prinv_PaymentMethod, value);
                 _prinv_PaymentMethod = value;}
        }

        /// <summary>
        /// Accessor for the prinv_PaymentMethodCode property.
        /// </summary>
        public string prinv_PaymentMethodCode {
            get {return _prinv_PaymentMethodCode;}
            set {SetDirty(_prinv_PaymentMethodCode, value);
                 _prinv_PaymentMethodCode = value;}
        }

        /// <summary>
        /// Accessor for the prinv_PaymentBrand property.
        /// </summary>
        public string prinv_PaymentBrand
        {
            get { return _prinv_PaymentBrand; }
            set
            {
                SetDirty(_prinv_PaymentBrand, value);
                _prinv_PaymentBrand = value;
            }
        }

        /// <summary>
        /// Accessor for the prinv_PaymentImportedIntoMAS property.
        /// </summary>
        public string prinv_PaymentImportedIntoMAS
        {
            get { return prinv_PaymentImportedIntoMAS; }
            set
            {
                SetDirty(prinv_PaymentImportedIntoMAS, value);
                prinv_PaymentImportedIntoMAS = value;
            }
        }

        /// <summary>
        /// Accessor for the prinv_StripePaymentURL property.
        /// </summary>
        public string prinv_StripePaymentURL {
            get {return _prinv_StripePaymentURL;}
            set {SetDirty(_prinv_StripePaymentURL, value);
                 _prinv_StripePaymentURL = value;}
        }

        /// <summary>
        /// Accessor for the _prinv_StripeInvoiceId property.
        /// </summary>
        public string prinv_StripeInvoiceId
        {
            get { return _prinv_StripeInvoiceId; }
            set
            {
                SetDirty(_prinv_StripeInvoiceId, value);
                _prinv_StripeInvoiceId = value;
            }
        }

        /// <summary>
        /// Accessor for the prinv_SentMethodCode property.
        /// </summary>
        public string prinv_SentMethodCode {
            get {return _prinv_SentMethodCode;}
            set {SetDirty(_prinv_SentMethodCode, value);
                 _prinv_SentMethodCode = value;}
        }

        /// <summary>
        /// Return a Dictionary of Field to Column mappings with the field
        /// as the key based on the Load/Unload options specified.
        /// </summary>
        /// <returns>IDictionary</returns>
        override public IDictionary GetFieldColMapping() {
            bool bCreateMapping = false;
            if (_htFieldColMapping == null) {
                bCreateMapping = true;
            }

            base.GetFieldColMapping();

            if (bCreateMapping) {
                _htFieldColMapping.Add("prinv_CreatedDate",			PRInvoiceMgr.COL_PRINV_CREATED_DATE);
                _htFieldColMapping.Add("prinv_PaymentDateTime",		PRInvoiceMgr.COL_PRINV_PAYMENT_DATE_TIME);
                _htFieldColMapping.Add("prinv_SentDateTime",		PRInvoiceMgr.COL_PRINV_SENT_DATE_TIME);
                _htFieldColMapping.Add("prinv_TimeStamp",			PRInvoiceMgr.COL_TIMESTAMP);
                _htFieldColMapping.Add("prinv_UpdatedDate",			PRInvoiceMgr.COL_PRINV_UPDATED_DATE);
                _htFieldColMapping.Add("prinv_CompanyID",			PRInvoiceMgr.COL_PRINV_COMPANY_ID);
                _htFieldColMapping.Add("prinv_CreatedBy",			PRInvoiceMgr.COL_PRINV_CREATED_BY);
                _htFieldColMapping.Add("prinv_Deleted",				PRInvoiceMgr.COL_PRINV_DELETED);
                _htFieldColMapping.Add("prinv_InvoiceID",			PRInvoiceMgr.COL_PRINV_INVOICE_ID);
                _htFieldColMapping.Add("prinv_Secterr",				PRInvoiceMgr.COL_PRINV_SECTERR);
                _htFieldColMapping.Add("prinv_UpdatedBy",			PRInvoiceMgr.COL_PRINV_UPDATED_BY);
                _htFieldColMapping.Add("prinv_WorkflowId",			PRInvoiceMgr.COL_PRINV_WORKFLOW_ID);
                _htFieldColMapping.Add("prinv_InvoiceNbr",			PRInvoiceMgr.COL_PRINV_INVOICE_NBR);
                _htFieldColMapping.Add("prinv_PaymentMethod",		PRInvoiceMgr.COL_PRINV_PAYMENT_METHOD);
                _htFieldColMapping.Add("prinv_PaymentMethodCode",	PRInvoiceMgr.COL_PRINV_PAYMENT_METHOD_CODE);
                _htFieldColMapping.Add("prinv_PaymentBrand",        PRInvoiceMgr.COL_PRINV_PAYMENT_BRAND);
                _htFieldColMapping.Add("prinv_PaymentImportedIntoMAS", PRInvoiceMgr.COL_PRINV_PAYMENT_IMPORTED_INTO_MAS);
                _htFieldColMapping.Add("prinv_StripePaymentURL",	PRInvoiceMgr.COL_PRINV_STRIPE_PAYMENT_URL);
                _htFieldColMapping.Add("prinv_StripeInvoiceId",     PRInvoiceMgr.COL_PRINV_STRIPE_INVOICE_ID);
                _htFieldColMapping.Add("prinv_SentMethodCode",		PRInvoiceMgr.COL_PRINV_SENT_METHOD_CODE);
            }
            return _htFieldColMapping;
        }

        /// <summary>
        /// Populates the object from the Dictionary
        /// specified.
        /// </summary>
        /// <param name="oData">Dictionary of Data</param>
        /// <param name="iOptions">Load Option</param>
        override public void LoadObject(IDictionary oData, int iOptions) {
            base.LoadObject(oData, iOptions);

            _prinv_CreatedDate			 = _oMgr.GetDateTime(oData[PRInvoiceMgr.COL_PRINV_CREATED_DATE]);
            _prinv_PaymentDateTime		 = _oMgr.GetDateTime(oData[PRInvoiceMgr.COL_PRINV_PAYMENT_DATE_TIME]);
            _prinv_SentDateTime			 = _oMgr.GetDateTime(oData[PRInvoiceMgr.COL_PRINV_SENT_DATE_TIME]);
            _prinv_UpdatedDate			 = _oMgr.GetDateTime(oData[PRInvoiceMgr.COL_PRINV_UPDATED_DATE]);
            _prinv_CompanyID			 = _oMgr.GetInt(oData[PRInvoiceMgr.COL_PRINV_COMPANY_ID]);
            _prinv_CreatedBy			 = _oMgr.GetInt(oData[PRInvoiceMgr.COL_PRINV_CREATED_BY]);
            _prinv_Deleted				 = _oMgr.GetInt(oData[PRInvoiceMgr.COL_PRINV_DELETED]);
            _prinv_InvoiceID			 = _oMgr.GetInt(oData[PRInvoiceMgr.COL_PRINV_INVOICE_ID]);
            _prinv_Secterr				 = _oMgr.GetInt(oData[PRInvoiceMgr.COL_PRINV_SECTERR]);
            _prinv_UpdatedBy			 = _oMgr.GetInt(oData[PRInvoiceMgr.COL_PRINV_UPDATED_BY]);
            _prinv_WorkflowId			 = _oMgr.GetInt(oData[PRInvoiceMgr.COL_PRINV_WORKFLOW_ID]);
            _prinv_InvoiceNbr			 = _oMgr.GetString(oData[PRInvoiceMgr.COL_PRINV_INVOICE_NBR]);
            _prinv_PaymentMethod		 = _oMgr.GetString(oData[PRInvoiceMgr.COL_PRINV_PAYMENT_METHOD]);
            _prinv_PaymentMethodCode	 = _oMgr.GetString(oData[PRInvoiceMgr.COL_PRINV_PAYMENT_METHOD_CODE]);
            _prinv_PaymentBrand          = _oMgr.GetString(oData[PRInvoiceMgr.COL_PRINV_PAYMENT_BRAND]);
            _prinv_PaymentImportedIntoMAS = _oMgr.GetString(oData[PRInvoiceMgr.COL_PRINV_PAYMENT_IMPORTED_INTO_MAS]);
            _prinv_StripePaymentURL		 = _oMgr.GetString(oData[PRInvoiceMgr.COL_PRINV_STRIPE_PAYMENT_URL]);
            _prinv_StripeInvoiceId =     _oMgr.GetString(oData[PRInvoiceMgr.COL_PRINV_STRIPE_INVOICE_ID]);
            _prinv_SentMethodCode		 = _oMgr.GetString(oData[PRInvoiceMgr.COL_PRINV_SENT_METHOD_CODE]);

            // Handle the audit fields
            _szCreatedUserID = _oMgr.GetString(oData[PRInvoiceMgr.COL_CREATED_USER_ID]);
            _szUpdatedUserID = _oMgr.GetString(oData[PRInvoiceMgr.COL_UPDATED_USER_ID]);
            _dtCreatedDateTime = _oMgr.GetDateTime(oData[PRInvoiceMgr.COL_CREATED_DATETIME]);
            _dtUpdatedDateTime = _oMgr.GetDateTime(oData[PRInvoiceMgr.COL_UPDATED_DATETIME]);
            _prinv_TimeStamp = _oMgr.GetDateTime(oData[PRInvoiceMgr.COL_TIMESTAMP]);
        }

        /// <summary>
        /// Populates the specified Dictionary from the Object.
        /// </summary>
        /// <param name="oData">Dictionary of Data</param>
        /// <param name="iOptions">Unload Option</param>
        /// <returns>IDictionary</returns>
        override public void UnloadObject(IDictionary oData, int iOptions) {
            base.UnloadObject(oData, iOptions);

            // If we're saving this object, don't include the
            // key as part of the data since we use an
            // identity field.
            if (iOptions != PRInvoiceMgr.OPT_LOAD_SAVE) {
                oData.Add(PRInvoiceMgr.COL_PRINV_INVOICE_ID,			_prinv_InvoiceID);
            }

            oData.Add(PRInvoiceMgr.COL_PRINV_CREATED_DATE,			_prinv_CreatedDate);
            oData.Add(PRInvoiceMgr.COL_PRINV_PAYMENT_DATE_TIME,		_prinv_PaymentDateTime);
            oData.Add(PRInvoiceMgr.COL_PRINV_SENT_DATE_TIME,		_prinv_SentDateTime);
            oData.Add(PRInvoiceMgr.COL_PRINV_UPDATED_DATE,			_prinv_UpdatedDate);
            oData.Add(PRInvoiceMgr.COL_PRINV_COMPANY_ID,			_prinv_CompanyID);
            oData.Add(PRInvoiceMgr.COL_PRINV_CREATED_BY,			_prinv_CreatedBy);
            oData.Add(PRInvoiceMgr.COL_PRINV_DELETED,				_prinv_Deleted);
            oData.Add(PRInvoiceMgr.COL_PRINV_SECTERR,				_prinv_Secterr);
            oData.Add(PRInvoiceMgr.COL_PRINV_UPDATED_BY,			_prinv_UpdatedBy);
            oData.Add(PRInvoiceMgr.COL_PRINV_WORKFLOW_ID,			_prinv_WorkflowId);
            oData.Add(PRInvoiceMgr.COL_PRINV_INVOICE_NBR,			_prinv_InvoiceNbr);
            oData.Add(PRInvoiceMgr.COL_PRINV_PAYMENT_METHOD,		_prinv_PaymentMethod);
            oData.Add(PRInvoiceMgr.COL_PRINV_PAYMENT_METHOD_CODE,	_prinv_PaymentMethodCode);
            oData.Add(PRInvoiceMgr.COL_PRINV_PAYMENT_BRAND,         _prinv_PaymentBrand);
            oData.Add(PRInvoiceMgr.COL_PRINV_PAYMENT_IMPORTED_INTO_MAS, _prinv_PaymentImportedIntoMAS);
            oData.Add(PRInvoiceMgr.COL_PRINV_STRIPE_PAYMENT_URL,	_prinv_StripePaymentURL);
            oData.Add(PRInvoiceMgr.COL_PRINV_STRIPE_INVOICE_ID,     _prinv_StripeInvoiceId);
            oData.Add(PRInvoiceMgr.COL_PRINV_SENT_METHOD_CODE,		_prinv_SentMethodCode);


            // Handle the audit fields
            oData.Add(PRInvoiceMgr.COL_CREATED_USER_ID, _szCreatedUserID);
            oData.Add(PRInvoiceMgr.COL_UPDATED_USER_ID, _szUpdatedUserID);
            oData.Add(PRInvoiceMgr.COL_CREATED_DATETIME, _dtCreatedDateTime);
            oData.Add(PRInvoiceMgr.COL_UPDATED_DATETIME, _dtUpdatedDateTime);
            oData.Add(PRInvoiceMgr.COL_TIMESTAMP, _prinv_TimeStamp);
        }
        #endregion
    }
}
