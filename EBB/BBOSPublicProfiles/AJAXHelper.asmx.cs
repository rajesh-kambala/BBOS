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

 ClassName: AJAXHelper
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Data;
using System.Web.Services;
using AjaxControlToolkit;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;

namespace PRCo.EBB.UI.Web {

    /// <summary>
    /// This web service contains methods to help various AJAX enabled 
    /// extenders and controls.  It is mostly a data provider.
    /// </summary>
    [WebService(Namespace = "http://www.bluebookprco/bbos")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ToolboxItem(false)]
    [System.Web.Script.Services.ScriptService()]
    public class AJAXHelper : System.Web.Services.WebService {

        protected EBBObjectMgr _oObjectMgr;
        protected IDBAccess _oDBAccess;
        protected ILogger _oLogger;


        /// <summary>
        /// Returns Country values from PRCountry.  Uses the contextKey
        /// as the default selected value.
        /// </summary>
        /// <param name="knownCategoryValues">private storage format string</param>
        /// <param name="category">category of DropDownList to populate</param>
        /// <param name="contextKey"></param>
        /// <returns>list of content items</returns>
        [WebMethod]
        public AjaxControlToolkit.CascadingDropDownNameValue[] GetCountries(string knownCategoryValues, string category, string contextKey) {
            try
            {
                GetLogger().LogMessage("GetCountries: " + knownCategoryValues + ", " + category + ", " + contextKey);

                bool bDefault = false;
                List<CascadingDropDownNameValue> values = new List<CascadingDropDownNameValue>();
                values.Add(new CascadingDropDownNameValue(string.Empty, "0"));

                string szSQL = "SELECT prcn_CountryID, prcn_Country FROM PRCountry WITH (NOLOCK) WHERE prcn_CountryID > 0 ORDER BY prcn_Country;";

                using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection))
                {
                    while (oReader.Read())
                    {

                        if (contextKey == Convert.ToString(oReader.GetInt32(0)))
                        {
                            bDefault = true;
                        }
                        else
                        {
                            bDefault = false;
                        }

                        values.Add(new CascadingDropDownNameValue(oReader.GetString(1), Convert.ToString(oReader.GetInt32(0)), bDefault));
                    }
                }

                GetLogger().LogMessage("GetCountries: Finished");

                return values.ToArray();
            }
            catch (Exception e)
            {
                GetLogger().LogError(e);
                throw;
            }
        }


        /// <summary>
        /// Returns PRState values.  Uses the contextKey as the defualt value.
        /// </summary>
        /// <param name="knownCategoryValues">private storage format string</param>
        /// <param name="category">category of DropDownList to populate</param>
        /// <param name="contextKey"></param>
        /// <returns>list of content items</returns>
        [WebMethod]
        public AjaxControlToolkit.CascadingDropDownNameValue[] GetStates(string knownCategoryValues, string category, string contextKey) {

            bool bDefault = false;
            List<CascadingDropDownNameValue> values = new List<CascadingDropDownNameValue>();
            values.Add(new CascadingDropDownNameValue(string.Empty, "0"));
            
            StringDictionary kv = CascadingDropDown.ParseKnownCategoryValuesString(knownCategoryValues);

            int iCountryID;
            if (!kv.ContainsKey("Country") ||
                !Int32.TryParse(kv["Country"], out iCountryID)) {
                return null;
            }
            
            ArrayList oParamters = new ArrayList();
            oParamters.Add(new ObjectParameter("prst_CountryID", iCountryID));
            string szSQL = GetObjectMgr().FormatSQL("SELECT prst_StateID, prst_State FROM PRState WITH (NOLOCK) WHERE prst_CountryID = {0} and prst_State IS NOT NULL ORDER BY prst_State;", oParamters);
            IDataReader oReader = null;

            try {
                oReader = GetDBAccess().ExecuteReader(szSQL, oParamters, CommandBehavior.CloseConnection, null);
                while (oReader.Read()) {

                    if (contextKey == Convert.ToString(oReader.GetInt32(0))) {
                        bDefault = true;
                    } else {
                        bDefault = false;
                    }

                    values.Add(new CascadingDropDownNameValue(oReader.GetString(1), Convert.ToString(oReader.GetInt32(0)), bDefault));
                }

                return values.ToArray();
            } catch (Exception e) {
                GetLogger().LogError(e);
                throw;
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }
        }


        /// <summary>
        /// Returns PRState values.  Uses the contextKey as the defualt value.
        /// </summary>
        /// <param name="knownCategoryValues">private storage format string</param>
        /// <param name="category">category of DropDownList to populate</param>
        /// <param name="contextKey"></param>
        /// <returns>list of content items</returns>
        [WebMethod]
        public AjaxControlToolkit.CascadingDropDownNameValue[] GetStateAbbreviations(string knownCategoryValues, string category, string contextKey) {

            bool bDefault = false;
            List<CascadingDropDownNameValue> values = new List<CascadingDropDownNameValue>();
            values.Add(new CascadingDropDownNameValue(string.Empty, "0"));

            StringDictionary kv = CascadingDropDown.ParseKnownCategoryValuesString(knownCategoryValues);

            int iCountryID;
            if (!kv.ContainsKey("Country") ||
                !Int32.TryParse(kv["Country"], out iCountryID)) {
                return null;
            }

            ArrayList oParamters = new ArrayList();
            oParamters.Add(new ObjectParameter("prst_CountryID", iCountryID));
            string szSQL = GetObjectMgr().FormatSQL("SELECT prst_StateID, ISNULL(prst_Abbreviation, prst_State) FROM PRState WITH (NOLOCK) WHERE prst_CountryID = {0} and prst_State IS NOT NULL ORDER BY prst_State;", oParamters);
            IDataReader oReader = null;

            try {
                oReader = GetDBAccess().ExecuteReader(szSQL, oParamters, CommandBehavior.CloseConnection, null);
                while (oReader.Read()) {

                    if (contextKey == Convert.ToString(oReader.GetInt32(0))) {
                        bDefault = true;
                    } else {
                        bDefault = false;
                    }

                    values.Add(new CascadingDropDownNameValue(oReader.GetString(1), Convert.ToString(oReader.GetInt32(0)), bDefault));
                }

                return values.ToArray();
            } catch (Exception e) {
                GetLogger().LogError(e);
                throw;
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }
        }

        [WebMethod]
        public AjaxControlToolkit.CascadingDropDownNameValue[] GetProduceHowLearnedDetails(string knownCategoryValues, string category)
        {
            StringDictionary kv = CascadingDropDown.ParseKnownCategoryValuesString(knownCategoryValues);
            if (!kv.ContainsKey("ProduceHowLearned")) {
                return null;
            }
            string produceHowLearned = kv["ProduceHowLearned"];

            return GetCustomCaptionValues(produceHowLearned, string.Empty, true);
        }


        [WebMethod]
        public AjaxControlToolkit.CascadingDropDownNameValue[] GetProduceHowLearned(string knownCategoryValues, string category)
        {
            return GetCustomCaptionValues("ProduceHowLearned", string.Empty, true);
        }


        private AjaxControlToolkit.CascadingDropDownNameValue[] GetCustomCaptionValues(string captFamily, string defaultValue, bool includeEmpty)
        {
            bool bDefault = false;

            List<CascadingDropDownNameValue> values = new List<CascadingDropDownNameValue>();

            if (includeEmpty) {
                values.Add(new CascadingDropDownNameValue(string.Empty, ""));
            }
            

            ArrayList oParamters = new ArrayList();
            oParamters.Add(new ObjectParameter("CaptFamily", captFamily));
            string szSQL = GetObjectMgr().FormatSQL("SELECT RTRIM(capt_code), capt_us FROM Custom_Captions WITH (NOLOCK) WHERE capt_family = {0} ORDER BY capt_order;", oParamters);
            IDataReader oReader = null;

            try
            {
                oReader = GetDBAccess().ExecuteReader(szSQL, oParamters, CommandBehavior.CloseConnection, null);
                while (oReader.Read())
                {

                    if (oReader.GetString(0) == defaultValue)
                    {
                        bDefault = true;
                    }
                    else
                    {
                        bDefault = false;
                    }

                    values.Add(new CascadingDropDownNameValue(oReader.GetString(1), oReader.GetString(0), bDefault));
                }

                return values.ToArray();
            }
            catch (Exception e)
            {
                GetLogger().LogError(e);
                throw;
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }


        #region Helper Methods

        /// <summary>
        /// Returns an instance of an ObjectMgr
        /// </summary>
        /// <returns></returns>
        protected EBBObjectMgr GetObjectMgr() {
            if (_oObjectMgr == null) {
                _oObjectMgr = new PRWebUserMgr(GetLogger(), null);
            }
            return _oObjectMgr;
        }

        /// <summary>
        /// Returns an isntance of a DBAccess
        /// </summary>
        /// <returns></returns>
        protected IDBAccess GetDBAccess() {
            if (_oDBAccess == null) {
                _oDBAccess = DBAccessFactory.getDBAccessProvider();
                _oDBAccess.Logger = GetLogger();
            }
            return _oDBAccess;
        }

        /// <summary>
        /// Returns an instance of a Logger
        /// </summary>
        /// <returns></returns>
        protected ILogger GetLogger() {
            if (_oLogger == null) {
                _oLogger = LoggerFactory.GetLogger();
                _oLogger.RequestName = this.GetType().Name;
            }

            return _oLogger;
        }

       
        #endregion Helper Methods
    }
}
