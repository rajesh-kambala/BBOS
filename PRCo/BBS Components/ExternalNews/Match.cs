/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc 2010-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyMatch
 Description:	

 Notes:	

 This module contains multiple class definitions for match flags.
 The idea is that these are generic enough for use across multiple
 news providers.

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PRCo.BBOS.ExternalNews
{
    /// <summary>
    /// Helper class that holds the flags indicating which data elements matched
    /// the specified CRM data.
    /// </summary>
    public class CompanyMatch
    {
        public bool MatchedCompanyNameFull = false;
        public bool MatchedCompanyNameFuzzy = false;
        public bool MatchedOwnershipType = false;

        public int PhoneID = 0;
        public bool MatchedPhoneNumber = false;
        public bool MatchedStockSymbol = false;

        public List<AddressMatch> MatchedAddresses = new List<AddressMatch>();

        /// <summary>
        /// Regardless of the match score, at least one key field has to be matched
        /// in order to relate this Dow Jones result to a CRM company
        /// </summary>
        public bool AnyKeyFieldMatched
        {
            get
            {
                if (MatchedPhoneNumber || MatchedCompanyNameFull || MatchedCompanyNameFuzzy || MatchedStockSymbol)
                {
                    return true;
                }
                return false;
            }
        }
    }

    /// <summary>
    /// Helper class that holds the flags indicating which data elements matched
    /// the specified CRM data.
    /// </summary>
    public class AddressMatch
    {
        public int AddressID = 0;
        public bool MatchedStreet = false;
        public bool MatchedCity = false;
        public bool MatchedState = false;
        public bool MatchedCountry = false;
        public bool MatchedPostal = false;
        public bool MatchedPostalFive = false;

        /// <summary>
        /// Indicates all of the address data elements were matched to an address.
        /// </summary>
        public bool FullMatch
        {
            get
            {
                if (MatchedStreet && MatchedCity && MatchedState && MatchedPostal)
                {
                    return true;
                }
                return false;
            }
        }

        /// <summary>
        /// Indicates at least the minimum data elements were matched to an address.
        /// Street is excluded form this due to the problematic nature of how that
        /// data is entered and maintained.
        /// </summary>
        public bool MinimumMatch
        {
            get
            {
                if (MatchedCity && MatchedState && MatchedPostalFive)
                {
                    return true;
                }
                return false;
            }
        }
    }

}
