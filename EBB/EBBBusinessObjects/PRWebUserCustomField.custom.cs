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

 ClassName: PRWebUserCustomField
 Description:	

 Notes:	Created By TSI Class Generator on 7/18/2014 9:36:57 AM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TSI.Arch;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRWebUserCustomField.
    /// </summary>
    [Serializable]
    public partial class PRWebUserCustomField : EBBObject, IPRWebUserCustomField
    {
        protected string _value = null;
        protected string _lookupValue = null;

        protected int _companyCount = 0;
        protected int _valueCount = 0;


        public override void OnAfterLoad(IDictionary oData, int iOptions)
        {
            base.OnAfterLoad(oData, iOptions);

            _value = _oMgr.GetString(oData["prwucd_Value"]);
            _lookupValue = _oMgr.GetString(oData["prwucfl_LookupValue"]);

            _companyCount = _oMgr.GetInt(oData["CompanyCount"]);
            _valueCount = _oMgr.GetInt(oData["ValueCount"]);

            _dtCreatedDateTime = _oMgr.GetDateTime(oData[PRWebUserCustomFieldMgr.COL_PRWUCF_CREATED_DATE]);
            _szCreatedUserID = _oMgr.GetString(oData[PRWebUserCustomFieldMgr.COL_PRWUCF_CREATED_BY]);
        }



        public int CompanyCount
        {
            get
            {
                return _companyCount;
            }
        }

        public int ValueCount
        {
            get
            {
                return _valueCount;
            }
        }


        public string Value
        {
            get
            {
                if (!string.IsNullOrEmpty(_lookupValue))
                {
                    return _lookupValue;
                }
                return _value;
            }
        }

        public void SetValue(int companyID, string value)
        {
            IPRWebUserCustomData data =  GetWebUserCustomData(companyID);

            // If we don't have a value, delete
            // the record.
            if (string.IsNullOrEmpty(value))
            {
                data.Delete();
                return;
            }

            data.prwucd_WebUserCustomFieldLookupID = 0;
            data.prwucd_Value = value;
            data.Save();
        }

        public void SetValue(int companyID, int filedLookupID)
        {
            IPRWebUserCustomData data = GetWebUserCustomData(companyID);

            // If we don't have a value, delete
            // the record.
            if (filedLookupID == 0)
            {
                data.Delete();
                return;
            }

            data.prwucd_Value = null;
            data.prwucd_WebUserCustomFieldLookupID = filedLookupID;
            data.Save();
        }

        private IBusinessObjectSet _lookupValues = null;
        public IBusinessObjectSet GetLookupValues()
        {
            if (_lookupValues == null)
            {
                _lookupValues = GetWebUserCustomFieldLookupMgr().GetByCustomField(_prwucf_WebUserCustomFieldID);
            }
            return _lookupValues;
        }

        public IPRWebUserCustomFieldLookup GetLookupValue(int lookupID)
        {
            foreach (IPRWebUserCustomFieldLookup lookupValue in GetLookupValues())
            {
                if (lookupValue.prwucfl_WebUserCustomFieldLookupID == lookupID)
                {
                    return lookupValue;
                }
            }
            return null;
        }


        public void AddLookupValue(string value, int sequence)
        {
            IPRWebUserCustomFieldLookup lookup = (IPRWebUserCustomFieldLookup)GetWebUserCustomFieldLookupMgr().CreateObject();
            lookup.prwucfl_LookupValue = value;
            lookup.prwucfl_Sequence = sequence;
            lookup.prwucfl_WebUserCustomFieldID = _prwucf_WebUserCustomFieldID;

            GetLookupValues().Add(lookup);
        }

        private List<string> _removeValues = null;
        public void RemoveLookupValue(string value)
        {
            if (_removeValues == null)
            {
                _removeValues = new List<string>();
            }
            _removeValues.Add(value);

        }


        private List<int> _removeIDs = null;
        public void RemoveLookupValue(int id)
        {
            if (_removeIDs == null)
            {
                _removeIDs = new List<int>();
            }
            _removeIDs.Add(id);

        }

        private IPRWebUserCustomData GetWebUserCustomData(int companyID)
        {
            IPRWebUserCustomData data = (IPRWebUserCustomData)GetWebUserCustomDataMgr().GetFieldValue(_prwucf_WebUserCustomFieldID, companyID);
            if (data == null)
            {
                data = (IPRWebUserCustomData)GetWebUserCustomDataMgr().CreateObject();
                data.prwucd_AssociatedID = companyID;
                data.prwucd_AssociatedType = "C";
                data.prwucd_WebUserCustomFieldID = _prwucf_WebUserCustomFieldID;
                data.prwucd_WebUserID = GetWebUser().prwu_WebUserID;
                data.prwucd_HQID = GetWebUser().prwu_HQID;
            }
            return data;
        }

        public override void Save(System.Data.IDbTransaction oTran)
        {
            bool bLocalTran = false;
            try {

                // Make sure we have a transaction
                // open
                if (oTran == null) {
                    oTran = _oMgr.BeginTransaction();
                    bLocalTran = true;
                }

                base.Save(oTran);

                if (_lookupValues != null)
                {
                    foreach (IPRWebUserCustomFieldLookup lookup in _lookupValues)
                    {
                        if (!string.IsNullOrEmpty(lookup.prwucfl_LookupValue))
                        {
                            lookup.prwucfl_WebUserCustomFieldID = _prwucf_WebUserCustomFieldID;
                            lookup.Save(oTran);
                        }
                    }
                }

                if (_removeValues != null)
                {
                    PRWebUserCustomDataMgr customDataMgr = new PRWebUserCustomDataMgr(_oMgr);

                    IBusinessObjectSet _deleteValues = new BusinessObjectSet();
                    foreach (string value in _removeValues)
                    {
                        foreach (IPRWebUserCustomFieldLookup lookup in _lookupValues)
                        {
                            if (lookup.prwucfl_LookupValue == value)
                            {
                                _deleteValues.Add(lookup);
                                customDataMgr.DeleteByLookupValue(lookup.prwucfl_WebUserCustomFieldLookupID, oTran);
                            }
                        }
                    }

                    _deleteValues.Delete(oTran);
                }

                if (_removeIDs != null)
                {
                    PRWebUserCustomDataMgr customDataMgr = new PRWebUserCustomDataMgr(_oMgr);

                    IBusinessObjectSet _deleteValues = new BusinessObjectSet();
                    foreach (int id in _removeIDs)
                    {
                        foreach (IPRWebUserCustomFieldLookup lookup in _lookupValues)
                        {
                            if (lookup.prwucfl_WebUserCustomFieldLookupID == id)
                            {
                                _deleteValues.Add(lookup);
                                customDataMgr.DeleteByLookupValue(lookup.prwucfl_WebUserCustomFieldLookupID, oTran);
                            }
                        }
                    }

                    _deleteValues.Delete(oTran);
                }


                _lookupValues = null;

                if (bLocalTran)
                {
                    _oMgr.Commit();
                }
            }
            catch
            {
                if (bLocalTran)
                {
                    _oMgr.Rollback();
                }
                throw;
            }
        }


        private PRWebUserCustomDataMgr _webUserCustomDataMgr = null;
        private PRWebUserCustomDataMgr GetWebUserCustomDataMgr()
        {
            if (_webUserCustomDataMgr == null)
            {
                _webUserCustomDataMgr = new PRWebUserCustomDataMgr(_oMgr);
            }

            return _webUserCustomDataMgr;
        }

        private PRWebUserCustomFieldLookupMgr _webUserCustomFieldLookupMgr = null;
        private PRWebUserCustomFieldLookupMgr GetWebUserCustomFieldLookupMgr()
        {
            if (_webUserCustomFieldLookupMgr == null)
            {
                _webUserCustomFieldLookupMgr = new PRWebUserCustomFieldLookupMgr(_oMgr);
            }

            return _webUserCustomFieldLookupMgr;
        }
    }
}
