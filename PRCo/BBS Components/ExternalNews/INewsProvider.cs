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

 ClassName: INewsProvider
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;

namespace PRCo.BBOS.ExternalNews
{
    /// <summary>
    /// This interface defines the common functionality that must be implemented
    /// by each external news source provider.
    /// </summary>
    public interface INewsProvider
    {
        /// <summary>
        /// This is a public property that has the unique name of this external news source as determined by BBSi.  
        /// It is used when storing/querying for records on the PRCompanyExternalNews and PRExternalNews tables.
        /// </summary>
        string NewsProviderName
        {
            get;
        }

        /// <summary>
        /// This method is for those news sources that maintain their own list of unique IDs for companies.  
        /// Using the appropriate mechanism, this method should query the news source for the unique ID for 
        /// every Company record that does not already have a record in PRCompanyExternalNews.  For each 
        /// new unique ID found, insert a new record into the PRCompanyExternalNews table.
        /// </summary>
        void RefreshCodes();

        /// <summary>
        /// Refreshes the news articles for the specified company, honoring the cache
        /// settings, meaning that we only query the external source if the cache time
        /// limit has expired.
        /// </summary>
        /// <param name="companyID"></param>
        void RefreshCompany(int companyID);

        /// <summary>
        /// Refreshes the news articles for the specified company.
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="overrideCache">If true, then we query the external news source
        /// regardless if the cache time limit has expired. </param>
        void RefreshCompany(int companyID, bool overrideCache);

        /// <summary>
        /// Refreshes the news articles for the all companies, honoring the cache
        /// settings, meaning that we only query the external source if the cache time
        /// limit has expired.
        /// </summary>        
        void RefreshAllCompanies();

        /// <summary>
        /// Refreshes the news articles for all companies.
        /// </summary>
        /// <param name="overrideCache">If true, then we query the external news source
        /// regardless if the cache time limit has expired. </param>
        void RefreshAllCompanies(bool overrideCache);


        void WriteLogToFile(string filename);
        void WriteLogToFile(string path, string filename);
    }
}
