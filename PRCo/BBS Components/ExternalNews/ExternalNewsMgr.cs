/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc 2010

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ExternalNewsMgr
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using TSI.Utils;

namespace PRCo.BBOS.ExternalNews
{
    /// <summary>
    /// This class is used by consuming modules to load external news data from however many sources are implemented.
    /// </summary>
    public class ExternalNewsMgr
    {

        private ILogger _oLogger;
        protected List<INewsProvider> _newsProviders;
        private int _iProviderCount;


        public ExternalNewsMgr()
        {
            //InitializeComponent();

            _newsProviders = new List<INewsProvider>();
            _iProviderCount = 0;

            _oLogger = LoggerFactory.GetLogger();
            _oLogger.RequestName = "Initialize";

            // Look at our config file for which External News Provider classes we need to load.
            string szNewsProviderClassName = Utilities.GetConfigValue("NewsProviderClassName" + _iProviderCount.ToString(), string.Empty);

            while (szNewsProviderClassName.Length > 0)
            {
                InitializeNewsProvider(szNewsProviderClassName);
                _iProviderCount++;
                szNewsProviderClassName = Utilities.GetConfigValue("NewsProviderClassName" + _iProviderCount.ToString(), string.Empty);
            }

            _oLogger.LogMessage("Started " + _iProviderCount.ToString() + " News Providers");

        }

        /// <summary>
        /// Instantiates and initilizes the specified News Provider
        /// </summary>
        /// <param name="szNewsProviderClassName"></param>
        protected void InitializeNewsProvider(string szNewsProviderClassName)
        {
            Type oNewsProviderType = Type.GetType(szNewsProviderClassName);

            if (oNewsProviderType == null)
                throw new ApplicationException("Invalid News Provider type found: " + szNewsProviderClassName);

            INewsProvider oNewsProvider = (INewsProvider)Activator.CreateInstance(oNewsProviderType);

            _newsProviders.Add(oNewsProvider);
        }

        /// <summary>
        /// Iterates through all news providers in the provider list and calls RefreshCodes for each one.
        /// </summary>
        public void RefreshCodes()
        {
            foreach (INewsProvider oNewsProvider in _newsProviders)
                oNewsProvider.RefreshCodes();
        }

        /// <summary>
        /// Invokes RefreshCompany overload.
        /// </summary>
        /// <param name="companyID"></param>
        public void RefreshCompany(int companyID)
        {
            RefreshCompany(companyID, false);
        }

        /// <summary>
        /// Iterates through all news providers in the provider list and calls RefreshCompany for each one.
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="overrideCache"></param>
        public void RefreshCompany(int companyID, bool overrideCache)
        {
            foreach (INewsProvider oNewsProvider in _newsProviders)
                oNewsProvider.RefreshCompany(companyID, overrideCache);
        }

        /// <summary>
        /// Invokes RefreshAllCompanies overload.
        /// </summary>
        public void RefreshAllCompanies()
        {
            RefreshAllCompanies(false);
        }

        /// <summary>
        /// Iterates through all news providers in the provider list and calls RefreshAllCompanies for each one.
        /// </summary>
        /// <param name="overrideCache"></param>
        public void RefreshAllCompanies(bool overrideCache)
        {
            foreach (INewsProvider oNewsProvider in _newsProviders)
                oNewsProvider.RefreshAllCompanies(overrideCache);
        }
    }
}
