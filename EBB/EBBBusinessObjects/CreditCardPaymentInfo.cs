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

 ClassName: CreditCardPayment
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;

namespace PRCo.EBB.BusinessObjects {

    /// <summary>
    /// Helper class to transmit information to the
    /// CreditCardPayment page from various pages that 
    /// initiate transactions.
    /// </summary>
    [Serializable]
    public class CreditCardPaymentInfo {

        public string RequestType;
        public string TriggerPage;
        public int AdditionalUnits;
        public string SelectedIDs;
        public string Name;
        public string SpecialInstructions;
        public string IndustryType;

        public string HowLearned;
        public string HowLearnedOther;
        public string ReferralPerson;
        public string ReferralCompany;

        public decimal TaxAmount = 0M;
        public decimal Shipping = 0M;
        public decimal TotalPrice = 0M;

        public string FullName;
        public string Phone;
        public string Email;

        public string Street1;
        public string Street2;
        public string City;
        public string PostalCode;
        public string County;
        public int StateID;
        public int CountryID;
        
        public string ProductDescriptions;
        public string AuthorizationCode;
        public string CreditCardNumber;
        public string CreditCardType;
        public int PaymentID;

        public List<CreditCardProductInfo> Products = new List<CreditCardProductInfo>();

        private decimal _dCost = -1M;
        private decimal _dTaxedCost = -1M;

        public decimal GetCost() {
            _dCost = 0M;
            foreach (CreditCardProductInfo oProductInfo in Products) {
                _dCost += (oProductInfo.Price * oProductInfo.Quantity);
            }
            return _dCost;
        }

        public decimal GetTaxedCost() {
                _dTaxedCost = 0M;
                TaxAmount = 0M;
                GeneralDataMgr dataMgr = new GeneralDataMgr();
                Dictionary<string, decimal> taxRates = dataMgr.GetTaxRate(City, County, StateID, PostalCode);
                
                if (taxRates != null)
                {
                    foreach (CreditCardProductInfo oProductInfo in Products)
                    {
                        oProductInfo.TaxRate = (decimal)taxRates[oProductInfo.TaxClass];
                        if (oProductInfo.TaxRate > 0) {
                            oProductInfo.TotalAmount = oProductInfo.Price * oProductInfo.Quantity;
                            oProductInfo.TaxAmount = oProductInfo.TotalAmount * (oProductInfo.TaxRate / 100);
                            TaxAmount += oProductInfo.TaxAmount;
                            _dTaxedCost += oProductInfo.TotalAmount;
                        }
                    }
                }
            return _dTaxedCost;
        }

        public decimal GetShippingRate()
        {
            GeneralDataMgr dataMgr = new GeneralDataMgr();
            Shipping = 0;
            foreach (CreditCardProductInfo oProductInfo in Products)
            {
                Shipping += (dataMgr.GetShippingRate(CountryID, oProductInfo.ProductID) * oProductInfo.Quantity);
            }

            return Shipping;
        }

    }

    /// <summary>
    /// Helper class that is used by
    /// the CreditCardPayment class.
    /// </summary>
    [Serializable]
    public class CreditCardProductInfo {
        public int ProductID;
        public int ProductFamilyID;
        public int PriceListID;
        public int Quantity;
        public int BusinessReports;
        public int Users;
        public int AccessLevel;
        public string AccessLevelDesc;
        public decimal Price;
        public decimal TotalAmount;
        public string DeliveryCode;
        public string DeliveryDestination;
        public string TaxClass;
        public string ProductCode;
        public string Name;
        public string FormattedPrice;
        public decimal TaxRate;
        public decimal TaxAmount;

        public CreditCardProductInfo() {}
        
        public CreditCardProductInfo(int iProductID,  int iPriceListID, int iQuantity, decimal dPrice) {
            Initialize(iProductID, iPriceListID, iQuantity, dPrice);
        }

        public CreditCardProductInfo(int iProductID, int iProductFamilyID, int iPriceListID, int iQuantity, decimal dPrice)
        {
            Initialize(iProductID, iPriceListID, iQuantity, dPrice);
            ProductFamilyID = iProductFamilyID;
        }

        private void Initialize(int iProductID, int iPriceListID, int iQuantity, decimal dPrice)
        {
            ProductID = iProductID;
            PriceListID = iPriceListID;
            Quantity = iQuantity;
            Price = dPrice;

            TotalAmount = iQuantity * dPrice;
        }

        //public CreditCardProductInfo(int iProductID, int iProductFamilyID, int iPriceListID, int iQuantity, decimal dPrice, bool bIsTaxed) {
        //    ProductID = iProductID;
        //    ProductFamilyID = iProductFamilyID;
        //    PriceListID = iPriceListID;
        //    Quantity = iQuantity;
        //    Price = dPrice;
        //}        

        //public CreditCardProductInfo(int iProductID, int iPriceListID, int iQuantity, decimal dPrice, string szDeliveryCode, string szDeliveryDestination) {
        //    ProductID = iProductID;
        //    PriceListID = iPriceListID;
        //    Quantity = iQuantity;
        //    Price = dPrice;
        //    DeliveryCode = szDeliveryCode;
        //    DeliveryDestination = szDeliveryDestination;
        //}
    }
}
