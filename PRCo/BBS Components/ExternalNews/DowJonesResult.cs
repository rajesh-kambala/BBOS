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

 ClassName: DowJonesResult
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Xml;
using PRCo.BBOS.ExternalNews;

namespace PRCo.BBOS.ExternalNews.DowJones
{
    /// <summary>
    /// Data structure to hold the data parsed from the
    /// Dow Jones Xml
    /// </summary>
    public class DowJonesCompany
    {
        public string CompanyName;
        public string City;
        public string Country;
        public string PhoneNumber;
        public string PostalCode;
        public string State;
        public string Street1;
        public string FCode;
        public string OwnershipType;
        public string StockSymbol;

        public CompanyMatch MatchResults = new CompanyMatch();

        public DowJonesCompany(XmlNode oCompanyNode)
        {
            Load(oCompanyNode);
        }

        public void Load(XmlNode oCompanyNode)
        {

            CompanyName = Utils.GetNodeValue(oCompanyNode, "CompanyName");
            OwnershipType = Utils.GetNodeValue(oCompanyNode, "OwnershipType");

            XmlNode xmlAddressNode = Utils.GetChildNode(oCompanyNode, "Address");
            Street1 = GetStringForComparison(Utils.GetNodeValue(xmlAddressNode, "Street1"));

            City = Utils.GetNodeValue(xmlAddressNode, "City");
            State = Utils.GetNodeValue(xmlAddressNode, "State");
            Country = Utils.GetNodeValue(xmlAddressNode, "Country");
            PostalCode = Utils.GetNodeValue(xmlAddressNode, "PostalCode");
            PhoneNumber = Utils.GetNodeValue(xmlAddressNode, "PhoneNumber");

            XmlNode xmlInstrumentNode = Utils.GetChildNode(oCompanyNode, "Instrument");
            FCode = Utils.GetNodeValue(xmlInstrumentNode, "FCode");
            StockSymbol = Utils.GetNodeValue(xmlInstrumentNode, "Ticker");
        }

        /// <summary>
        /// Helper method that prepares a string for a non-exact
        /// comparison
        /// </summary>
        /// <param name="szValue"></param>
        /// <returns></returns>
        private string GetStringForComparison(string szValue)
        {
            if (string.IsNullOrEmpty(szValue))
            {
                return szValue;
            }

            return szValue.Trim().ToLower();
        }

        public void MatchCompany(Company oCompany)
        {
            MatchResults.MatchedCompanyNameFull = (oCompany.CompanyName.ToLower() == CompanyName.ToLower());
            MatchResults.MatchedCompanyNameFuzzy = (Utils.LowerAlphaFuzzifyCompanyName(oCompany.CompanyName) == Utils.LowerAlphaFuzzifyCompanyName(CompanyName));
            MatchResults.MatchedOwnershipType = (oCompany.OwnershipType == OwnershipType);

            MatchPhone(oCompany.Phones);
            MatchAddress(oCompany.Addresses);
            MatchStockSymbol(oCompany.StockSymbols);
        }

        /// <summary>
        /// Sets the MatchedPhoneNumber flag if the any of the specified
        /// phone numbers matches our phone number.
        /// </summary>
        /// <param name="lPhones"></param>
        public void MatchPhone(List<Phone> lPhones)
        {
            foreach(Phone oPhone in lPhones) 
            {
                string szPhone = oPhone.CountryCode + " " + oPhone.AreaCode + " " + oPhone.PhoneNumber.Replace("-", string.Empty);
                MatchResults.MatchedPhoneNumber = (szPhone == PhoneNumber);

                if (MatchResults.MatchedPhoneNumber)
                {
                    break;
                }
            }
        }

        /// <summary>
        /// Determines if any of the specified addresses matches our address.
        /// There must be a "minimal" match, i.e at least city, state, and postal
        /// for the address to be considered a match.  Trying to match on the 
        /// street is too problematic due to data input variations.
        /// </summary>
        /// <param name="lAddresses"></param>
        public void MatchAddress(List<Address> lAddresses)
        {
            foreach (Address oAddress in lAddresses) 
            {
                AddressMatch oAddressMatch = new AddressMatch();

                if (!string.IsNullOrEmpty(Street1))
                {
                    oAddressMatch.MatchedStreet = (oAddress.Street1.ToLower() == Street1.ToLower());
                }

                if (!string.IsNullOrEmpty(City))
                {
                    oAddressMatch.MatchedCity = (oAddress.City.ToLower() == City.ToLower());
                }

                // Just discovered that some addresses use the full name,
                // others use the abbreviation.  We need to handle this.
                if (!string.IsNullOrEmpty(State))
                {
                    // 1st match the full state name.  If not a match,
                    // try the abbreviation.
                    oAddressMatch.MatchedState = (oAddress.State.ToLower() == State.ToLower());

                    if (!oAddressMatch.MatchedState)
                    {
                        oAddressMatch.MatchedState = (oAddress.StateAbbreviation.ToLower() == State.ToLower());
                    }
                }

                if ((!string.IsNullOrEmpty(PostalCode)) &&
                    (PostalCode.Length >= 5))
                {
                    oAddressMatch.MatchedPostal = (oAddress.PostalCode == PostalCode);
                    oAddressMatch.MatchedPostalFive = (oAddress.PostalCodeFive == PostalCode.Substring(0, 5));
                }

                if (oAddressMatch.MinimumMatch)
                {
                    MatchResults.MatchedAddresses.Add(oAddressMatch);
                    break;
                }
            }
        }

        /// <summary>
        /// Public stock ticker symbols are considered unique in the business
        /// world.  This method detemines if any of the specified symbols
        /// matches our symbol.
        /// </summary>
        /// <param name="lStockSymbols"></param>
        public void MatchStockSymbol(List<StockSymbol> lStockSymbols)
        {
            foreach (StockSymbol oStockSymbol in lStockSymbols)
            {
                MatchResults.MatchedStockSymbol = (oStockSymbol.Symbol == StockSymbol);
                if (MatchResults.MatchedStockSymbol)
                {
                    break;
                }
            }
        }

        private int iScore = -1;
        /// <summary>
        /// This method calclates a Match Score based on how many of these Dow Jones data elements
        /// matched the specified CRM data elements.  Fuzzy matches and minimum/full address matches
        /// are also considered.  This is relevant when more than one Dow Jones result matches a
        /// CRM company.
        /// </summary>
        /// <returns></returns>
        public int CalculateMatchScore()
        {
            if (iScore == -1)
            {
                iScore = 0;

                if (MatchResults.MatchedCompanyNameFuzzy)
                    iScore++;

                if (MatchResults.MatchedCompanyNameFull)
                    iScore++;

                if (MatchResults.MatchedPhoneNumber)
                    iScore++;

                if (MatchResults.MatchedOwnershipType)
                    iScore++;

                foreach (AddressMatch oAddressMatch in MatchResults.MatchedAddresses)
                {
                    if (oAddressMatch.MinimumMatch)
                        iScore++;

                    if (oAddressMatch.FullMatch)
                        iScore++;
                }
            }

            return iScore;
        }
    }

    public class ExcludedSource
    {
        public string SourceCode;
        public DateTime ExcludeStartDate;

        public ExcludedSource(string code, DateTime startDate)
        {
            SourceCode = code;
            ExcludeStartDate = startDate;
        }            
    }
}
