/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Blue Book Services, Inc..  Contact
 by e-mail at chris@wallsfamily.com

 ClassName: PRBusinessReportPurchase
 Description:	

 Notes:	Created By TSI Class Generator on 4/15/2014 12:55:44 PM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRBusinessReportPurchase.
    /// </summary>
    public partial class PRBusinessReportPurchase : EBBObject, IPRBusinessReportPurchase
    {
        protected DateTime	_prbrp_TimeStamp;
        protected int		_prbrp_BusinessReportPurchaseID;
        protected int		_prbrp_PaymentID;
        protected int		_prbrp_ProductID;
        protected int       _prbrp_CompanyID;
        protected string	_prbrp_RequestsMembershipInfo;
        protected string	_prbrp_SubmitterEmail;
        protected string    _prbrp_IndustryType;

        /// <summary>
        /// Constructor
        /// </summary>
        public PRBusinessReportPurchase() {}

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
                _oKeyValues.Add(prbrp_BusinessReportPurchaseID);
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
            prbrp_BusinessReportPurchaseID = 0;
        }

        /// <summary>
        /// Sets the key values for this object based
        /// on the specified list of values.  The list of
        /// values must be in the same order the keys are
        /// defined in GetKeyValues();
        /// </summary>
        /// <param name="oKeyValues">IList</param>
        override public void SetKeyValues(IList oKeyValues) {
            prbrp_BusinessReportPurchaseID = Convert.ToInt32(oKeyValues[0]);
        }


        /// <summary>
        /// Accessor for the prbrp_TimeStamp property.
        /// </summary>
        public DateTime prbrp_TimeStamp {
            get {return _prbrp_TimeStamp;}
            set {SetDirty(_prbrp_TimeStamp, value);
                 _prbrp_TimeStamp = value;}
        }


        /// <summary>
        /// Accessor for the prbrp_BusinessReportPurchaseID property.
        /// </summary>
        public int prbrp_BusinessReportPurchaseID {
            get {return _prbrp_BusinessReportPurchaseID;}
            set {SetDirty(_prbrp_BusinessReportPurchaseID, value);
                 _prbrp_BusinessReportPurchaseID = value;}
        }

        /// <summary>
        /// Accessor for the prbrp_PaymentID property.
        /// </summary>
        public int prbrp_PaymentID {
            get {return _prbrp_PaymentID;}
            set {SetDirty(_prbrp_PaymentID, value);
                 _prbrp_PaymentID = value;}
        }

        /// <summary>
        /// Accessor for the prbrp_ProductID property.
        /// </summary>
        public int prbrp_ProductID {
            get {return _prbrp_ProductID;}
            set {SetDirty(_prbrp_ProductID, value);
                 _prbrp_ProductID = value;}
        }

        /// <summary>
        /// Accessor for the prbrp_CompanyID property.
        /// </summary>
        public int prbrp_CompanyID {
            get { return _prbrp_CompanyID; }
            set
            {
                SetDirty(_prbrp_CompanyID, value);
                _prbrp_CompanyID = value;
            }
        }

        /// <summary>
        /// Accessor for the prbrp_RequestsMembershipInfo property.
        /// </summary>
        public string prbrp_RequestsMembershipInfo {
            get {return _prbrp_RequestsMembershipInfo;}
            set {SetDirty(_prbrp_RequestsMembershipInfo, value);
                 _prbrp_RequestsMembershipInfo = value;}
        }

        /// <summary>
        /// Accessor for the prbrp_SubmitterEmail property.
        /// </summary>
        public string prbrp_SubmitterEmail {
            get {return _prbrp_SubmitterEmail;}
            set {SetDirty(_prbrp_SubmitterEmail, value);
                 _prbrp_SubmitterEmail = value;}
        }

        public string prbrp_IndustryType
        {
            get { return _prbrp_IndustryType; }
            set
            {
                SetDirty(_prbrp_IndustryType, value);
                _prbrp_IndustryType = value;
            }
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
                _htFieldColMapping.Add("prbrp_TimeStamp",					PRBusinessReportPurchaseMgr.COL_PRBRP_TIME_STAMP);
                _htFieldColMapping.Add("prbrp_BusinessReportPurchaseID",	PRBusinessReportPurchaseMgr.COL_PRBRP_BUSINESS_REPORT_PURCHASE_ID);
                _htFieldColMapping.Add("prbrp_PaymentID",					PRBusinessReportPurchaseMgr.COL_PRBRP_PAYMENT_ID);
                _htFieldColMapping.Add("prbrp_ProductID",					PRBusinessReportPurchaseMgr.COL_PRBRP_PRODUCT_ID);
                _htFieldColMapping.Add("prbrp_RequestsMembershipInfo",		PRBusinessReportPurchaseMgr.COL_PRBRP_REQUESTS_MEMBERSHIP_INFO);
                _htFieldColMapping.Add("prbrp_SubmitterEmail",				PRBusinessReportPurchaseMgr.COL_PRBRP_SUBMITTER_EMAIL);
                _htFieldColMapping.Add("prbrp_IndustryType",                PRBusinessReportPurchaseMgr.COL_PRBRP_INDUSTRY_TYPE);
                _htFieldColMapping.Add("prbrp_CompanyID",                   PRBusinessReportPurchaseMgr.COL_PRBRP_COMPANY_ID);
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


            _prbrp_TimeStamp				 = _oMgr.GetDateTime(oData[PRBusinessReportPurchaseMgr.COL_PRBRP_TIME_STAMP]);
            _prbrp_BusinessReportPurchaseID	 = _oMgr.GetInt(oData[PRBusinessReportPurchaseMgr.COL_PRBRP_BUSINESS_REPORT_PURCHASE_ID]);
            _prbrp_PaymentID				 = _oMgr.GetInt(oData[PRBusinessReportPurchaseMgr.COL_PRBRP_PAYMENT_ID]);
            _prbrp_ProductID				 = _oMgr.GetInt(oData[PRBusinessReportPurchaseMgr.COL_PRBRP_PRODUCT_ID]);
            _prbrp_CompanyID                 = _oMgr.GetInt(oData[PRBusinessReportPurchaseMgr.COL_PRBRP_COMPANY_ID]);
            _prbrp_RequestsMembershipInfo	 = _oMgr.GetString(oData[PRBusinessReportPurchaseMgr.COL_PRBRP_REQUESTS_MEMBERSHIP_INFO]);
            _prbrp_SubmitterEmail			 = _oMgr.GetString(oData[PRBusinessReportPurchaseMgr.COL_PRBRP_SUBMITTER_EMAIL]);
            _prbrp_IndustryType              = _oMgr.GetString(oData[PRBusinessReportPurchaseMgr.COL_PRBRP_INDUSTRY_TYPE]);


            // Handle the audit fields
            _szCreatedUserID = _oMgr.GetString(oData[PRBusinessReportPurchaseMgr.COL_CREATED_USER_ID]);
            _szUpdatedUserID = _oMgr.GetString(oData[PRBusinessReportPurchaseMgr.COL_UPDATED_USER_ID]);
            _dtCreatedDateTime = _oMgr.GetDateTime(oData[PRBusinessReportPurchaseMgr.COL_CREATED_DATETIME]);
            _dtUpdatedDateTime = _oMgr.GetDateTime(oData[PRBusinessReportPurchaseMgr.COL_UPDATED_DATETIME]);
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
            if (iOptions != PRBusinessReportPurchaseMgr.OPT_LOAD_SAVE) {
                oData.Add(PRBusinessReportPurchaseMgr.COL_PRBRP_BUSINESS_REPORT_PURCHASE_ID,	_prbrp_BusinessReportPurchaseID);
            }

            oData.Add(PRBusinessReportPurchaseMgr.COL_PRBRP_TIME_STAMP,						_prbrp_TimeStamp);
            oData.Add(PRBusinessReportPurchaseMgr.COL_PRBRP_PAYMENT_ID,						_prbrp_PaymentID);
            oData.Add(PRBusinessReportPurchaseMgr.COL_PRBRP_PRODUCT_ID,						_prbrp_ProductID);
            oData.Add(PRBusinessReportPurchaseMgr.COL_PRBRP_COMPANY_ID,                     _prbrp_CompanyID);
            oData.Add(PRBusinessReportPurchaseMgr.COL_PRBRP_REQUESTS_MEMBERSHIP_INFO,		_prbrp_RequestsMembershipInfo);
            oData.Add(PRBusinessReportPurchaseMgr.COL_PRBRP_SUBMITTER_EMAIL,				_prbrp_SubmitterEmail);
            oData.Add(PRBusinessReportPurchaseMgr.COL_PRBRP_INDUSTRY_TYPE,                  _prbrp_IndustryType);

            // Handle the audit fields
            oData.Add(PRBusinessReportPurchaseMgr.COL_CREATED_USER_ID, _szCreatedUserID);
            oData.Add(PRBusinessReportPurchaseMgr.COL_UPDATED_USER_ID, _szUpdatedUserID);
            oData.Add(PRBusinessReportPurchaseMgr.COL_CREATED_DATETIME, _dtCreatedDateTime);
            oData.Add(PRBusinessReportPurchaseMgr.COL_UPDATED_DATETIME, _dtUpdatedDateTime);
        }
        #endregion

    }
}
