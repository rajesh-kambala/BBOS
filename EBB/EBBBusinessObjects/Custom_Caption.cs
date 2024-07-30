/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Custom_Caption
 Description:	

 Notes:	Created By TSI Class Generator on 10/18/2005 10:13:21 AM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using TSI.Arch;
using TSI.BusinessObjects;
using PRCo.EBB.BusinessObjects;

namespace PRCo.EBB.Util
{
    /// <summary>
    /// Provides the functionality for the Custom_Caption.
    /// </summary>
    [Serializable]
    public class Custom_Caption : EBBObject, ICustom_Caption
    {
        protected int		_iID;
        protected string	_szCode;
        protected string	_szMeaning;
        protected string	_szName;

        /// <summary>
        /// Constructor
        /// </summary>
        public Custom_Caption() {}

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
                _oKeyValues.Add(ID);
            }
	          return _oKeyValues;
        }

        /// <summary>
        /// Sets the key values for this object based
        /// on the specified list of values.  The list of
        /// values must be in the same order the keys are
        /// defined in GetKeyValues();
        /// </summary>
        /// <param name="oKeyValues">IList</param>
        override public void SetKeyValues(IList oKeyValues) {
            ID = Convert.ToInt32(oKeyValues[0]);
        }

        /// <summary>
        /// Accessor for the ID property.
        /// </summary>
        public int ID {
            get {return _iID;}
            set {SetDirty(_iID, value);
                 _iID = value;}
        }

        /// <summary>
        /// Accessor for the Code property.
        /// </summary>
        public string Code {
            get {return _szCode;}
            set {SetDirty(_szCode, value);
                 _szCode = value;}
        }

        /// <summary>
        /// Accessor for the Meaning property.
        /// </summary>
        public string Meaning {
            get {return _szMeaning;}
            set {SetDirty(_szMeaning, value);
                 _szMeaning = value;}
        }

        /// <summary>
        /// Accessor for the Name property.
        /// </summary>
        public string Name {
            get {return _szName;}
            set {SetDirty(_szName, value);
                 _szName = value;}
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
                _htFieldColMapping.Add("Code",						Custom_CaptionMgr.COL_CODE);
                _htFieldColMapping.Add("Meaning",					Custom_CaptionMgr.COL_MEANING);
                _htFieldColMapping.Add("Name",						Custom_CaptionMgr.COL_NAME);
                _htFieldColMapping.Add("Order",                     Custom_CaptionMgr.COL_ORDER);
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

            _szCode						= _oMgr.GetString(oData[Custom_CaptionMgr.COL_CODE]);
            _szMeaning					= _oMgr.GetString(oData[Custom_CaptionMgr.COL_MEANING]);
            _szName						= _oMgr.GetString(oData[Custom_CaptionMgr.COL_NAME]);
        }

        /// <summary>
        /// Populates the specified Dictionary from the Object.
        /// </summary>
        /// <param name="oData">Dictionary of Data</param>
        /// <param name="iOptions">Unload Option</param>
        /// <returns>IDictionary</returns>
        override public void UnloadObject(IDictionary oData, int iOptions) {
            base.UnloadObject(oData, iOptions);


            oData.Add(Custom_CaptionMgr.COL_CODE,							_szCode);
            oData.Add(Custom_CaptionMgr.COL_MEANING,						_szMeaning);
            oData.Add(Custom_CaptionMgr.COL_NAME,							_szName);
        }
        #endregion

    }
}
