/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Company
 Description:	

 Notes:	Created By Christopher Walls on 9/13/07

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;

namespace PRCo.BBOS.WebServices
{
    public class Company
    {
        public int BBID;
        public int HQID;
        public string CompanyName;
        public string ListingCity;
        public string ListingCounty;
        public string ListingState;
        public string ListingCountry;
        public string Industry;
        public string Email;
        public string WebSite;
        public string Volume;
        public string Type;
        public string TradeStyle1;
        public string TradeStyle2;
        public string RatingLine;
        public string TMAward;
        public int TMYear;
        public string PreviousRatingLine;
        public string RatingSinceDate;

        public int OpenClaims = 0;
        public int TotalClaims2Years = 0;
        public int TotalMertioriousClaims2Years = 0;
        public string TradeActivitySummaryScore;
        public string FullTimeEmployees;
        public string DateBusinessStarted;

        public BlueBookScore BlueBookScore;
        public CreditWorthRating CreditWorthRating;
        public PayRating PayRating;
        public IntegrityRating IntegrityRating;
        public PayIndicator PayIndicator;
        public FinancialStatement FinancialStatement;
        public StockExchange StockExchange;

        public List<RatingNumeral> RatingNumerals;
        public List<License> Licenses;
        public List<Address> Addresses;
        public List<Phone> Phones;
        public List<Classification> Classifications;
        public List<Commodity> Commodities;
        public List<Brand> Brands;
        public List<Person> Persons;
        public List<Specie> Species;
        public List<Product> Products;
        public List<Service> Services;

        public void Load(IDataReader oReader, int iAccessLevel, int iPRWUAccessLevel)
        {
            BBID = oReader.GetInt32(0);
            HQID = oReader.GetInt32(1);
            CompanyName = Utils.GetString(oReader, 2);
            ListingCity = Utils.GetString(oReader, 3);
            ListingState = Utils.GetString(oReader, 4);
            ListingCountry = Utils.GetString(oReader, 5);
            Industry = Utils.GetString(oReader, 6);
            Type = Utils.GetString(oReader, 10);
            TradeStyle1 = Utils.GetString(oReader, 2);
            TradeStyle2 = Utils.GetString(oReader, 15);

            if (!IsLumber)
            {
                TMAward = Utils.GetString(oReader, 16);

                if ((TMAward == "Y") &&
                    (oReader[17] != DBNull.Value))
                {
                    TMYear = oReader.GetDateTime(17).Year;
                }
            } else 
                FullTimeEmployees = Utils.GetString(oReader, 22);

            if (iAccessLevel >= 2)
            {
                Volume = Utils.GetString(oReader, 9);
                PreviousRatingLine = Utils.GetString(oReader, 20);
                if (oReader[21] != DBNull.Value)
                {
                    DateTime dtRatingSince = Convert.ToDateTime(oReader[21]);
                    RatingSinceDate = dtRatingSince.ToString("M/d/yyyy");
                }
            }

            if (iAccessLevel >= 3)
            {
                Email = Utils.GetString(oReader, 7);
                WebSite = Utils.GetString(oReader, 8);

                if (oReader[13] != DBNull.Value)
                {
                    FinancialStatement oFS = new FinancialStatement();
                    oFS.Load(oReader);
                    FinancialStatement = oFS;
                }

                if (iPRWUAccessLevel >= 600 && oReader[18] != DBNull.Value && oReader[19] != DBNull.Value)
                {
                    decimal decAveIntegrity = oReader.GetDecimal(18);
                    decimal decIndustryAveIntegrity = Convert.ToDecimal(oReader.GetString(19));
                    TradeActivitySummaryScore = string.Format("{0} (Industry Avg: {1})", decAveIntegrity.ToString("0.00"), decIndustryAveIntegrity.ToString("0.00"));
                }
            }
        }

        public bool IsLumber
        {
            get { return (Industry == "Lumber"); }
        }
    }
}