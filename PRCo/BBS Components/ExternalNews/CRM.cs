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

 ClassName: CRM
 Description:	

 Notes:	

 This module contains multiple class definitions for CRM data.
 The idea is that they are generic enough to be shared across 
 external news providers.

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace PRCo.BBOS.ExternalNews
{
    /// <summary>
    /// This class is used to represent CRM company data with associated
    /// phones, addresses, and stock symbols.
    /// </summary>
    public class Company
    {
        public int CompanyID;
        public string CompanyName;
        public string OwnershipType;

        public List<Phone> Phones = new List<Phone>();
        public List<Address> Addresses = new List<Address>();
        public List<StockSymbol> StockSymbols = new List<StockSymbol>();

        public bool WrittenToDisk = false;
        public bool MultipeMatches = false;
        public bool DowJonesError = false;
        //public bool NoMatchFound = false;

        public bool ProcessingException = false;
        public Exception exception;

        public bool Matched = false;
        public string NewsCode = null;

        public DateTime LastArticleRetrieval;

        public int ArticleCount = 0;
        public int InsertedArticleCount = 0;


        public Company()
        {
        }
        
        public Company(int companyID, string newsCode, DateTime lastArticleRetreival)
        {
            CompanyID = companyID;
            NewsCode = newsCode;
            LastArticleRetrieval = lastArticleRetreival;
        }

        public Company(IDataReader oReader, DataView dvAddresses, DataView dvPhones, DataView dvStockSymbols)
        {
            CompanyID = oReader.GetInt32(0);
            CompanyName = oReader.GetString(1).Trim();
            OwnershipType = oReader.GetString(2);

            DataRowView[] dvrAddresses = dvAddresses.FindRows(CompanyID);
            foreach (DataRowView drAddressRow in dvrAddresses)
            {
                Addresses.Add(new Address(drAddressRow));
            }

            DataRowView[] dvrPhones = dvPhones.FindRows(CompanyID);
            foreach (DataRowView drPhoneRow in dvrPhones)
            {
                Phones.Add(new Phone(drPhoneRow));
            }

            DataRowView[] dvrStockSymboss = dvStockSymbols.FindRows(CompanyID);
            foreach (DataRowView drStockSymbol in dvrStockSymboss)
            {
                StockSymbols.Add(new StockSymbol(drStockSymbol));
            }
        }
    }

    public class Phone
    {
        public string CountryCode;
        public string AreaCode;
        public string PhoneNumber;

        public Phone(DataRowView drRow)
        {
            CountryCode = drRow[2].ToString().Trim();
            AreaCode = drRow[3].ToString().Trim();
            PhoneNumber = drRow[4].ToString().Trim();
        }
    }

    public class StockSymbol
    {
        public string Symbol;

        public StockSymbol(DataRowView drRow)
        {
            Symbol = drRow[1].ToString().Trim();
        }
    }

    public class Address
    {
        public string Street1;
        public string City;
        public string State;
        public string StateAbbreviation;
        public string Country;
        public string PostalCode;
        public string PostalCodeFive;
        public string CityStateCountryShort;

        public int CountryID;

        public Address(DataRowView drRow)
        {
            Street1 = drRow[1].ToString().Trim();
            City = drRow[2].ToString().Trim();
            State = drRow[3].ToString().Trim();
            StateAbbreviation = drRow[4].ToString().Trim();
            Country = drRow[5].ToString().Trim();
            CountryID = Convert.ToInt32(drRow[6]);
            PostalCode = drRow[7].ToString().Trim();
            PostalCodeFive = drRow[8].ToString().Trim();
            CityStateCountryShort = drRow[10].ToString().Trim();
        }
    }
}
