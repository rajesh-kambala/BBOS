/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyRelationship
 Description:	

 Notes:	Created By Sharon Cole on 7/18/2007 3:07:32 PM

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Xml;
using System.Xml.Serialization;

using TSI.Arch;
using TSI.DataAccess;
using TSI.BusinessObjects;
using TSI.Utils;

using PRCo.EBB.Util;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Container for CompanyRelationship information intendeded to be
    /// serialized / deserialized.
    /// </summary>
    [Serializable]
    public class CompanyRelationships
    {
        protected ILogger _oLogger;

        private int _iRelatedCompanyID;
        private int _iCompanyRelationshipID;

        private string _szType;
        private string _szVolume;
        private string _szFrequencyOfDealing;
        private string _szRelatedCompanyName;
        private string _szRelatedContactName;
        private string _szLocation;
        private string _szListingStatus;
        private string _relationshipTypeList;
        private string _relationshipTypeCodeList;
        private string _relationshipIDList;
        private bool _bHasNote;
        private bool _bHasNewClaimActivity;
        private bool _bHasMeritoriousClaim;
        private bool _bHasCertification;
        private bool _bHasCertification_Organic;
        private bool _bHasCertification_FoodSafety;
        private DateTime _dtLastPublishedCSDate;
        private string _szEmail;

        public int IntegrityID;
        public int RatingID;

        public string TradePracticeName;
        public string PayPerformanceName;
        public string HighCreditName;
        public string LastDealtName;
        public string Comments;

        public bool IsActive;

        public Address Addresses;

        public Phone Phone;
        public Phone Fax;

        // The following fields are required to be implemented as properties in order
        // to bind the CompanyRelationships list to a grid.
        public int RelatedCompanyID {
            get { return _iRelatedCompanyID; }
            set { _iRelatedCompanyID = value; }
        }

        public int CompanyRelationshipID
        {
            get { return _iCompanyRelationshipID; }
            set { _iCompanyRelationshipID = value; }
        }

        public string FrequencyOfDealing
        {
            get { return _szFrequencyOfDealing; }
            set { _szFrequencyOfDealing = value; }
        }

        public string Type
        {
            get { return _szType; }
            set { _szType = value; }
        }

        public string Email
        {
            get { return _szEmail; }
            set { _szEmail = value; }
        }
        public string Volume
        {
            get { return _szVolume; }
            set { _szVolume = value; }
        }

        public string RelatedCompanyName
        {
            get { return _szRelatedCompanyName; }
            set { _szRelatedCompanyName = value; }
        }

        public string RelatedContactName
        {
            get { return _szRelatedContactName; }
            set { _szRelatedContactName = value; }
        }

        public string Location {
            get { return _szLocation; }
            set { _szLocation = value; }
        }

        public string ListingStatus {
            get { return _szListingStatus; }
            set { _szListingStatus = value; }
        }

        public bool HasNote {
            get { return _bHasNote; }
            set { _bHasNote = value; }
        }

        public bool HasNewClaimActivity
        {
            get { return _bHasNewClaimActivity; }
            set { _bHasNewClaimActivity = value; }
        }
        public bool HasMeritoriousClaim
        {
            get { return _bHasMeritoriousClaim; }
            set { _bHasMeritoriousClaim = value; }
        }
        public bool HasCertification
        {
            get { return _bHasCertification; }
            set { _bHasCertification = value; }
        }
        public bool HasCertification_Organic
        {
            get { return _bHasCertification_Organic; }
            set { _bHasCertification_Organic = value; }
        }
        public bool HasCertification_FoodSafety
        {
            get { return _bHasCertification_FoodSafety; }
            set { _bHasCertification_FoodSafety = value; }
        }
        
        public DateTime LastPublishedCSDate {
            get { return _dtLastPublishedCSDate; }
            set { _dtLastPublishedCSDate = value; }
        }

        public string RelationshipTypeList
        {
            get { return _relationshipTypeList; }
            set { _relationshipTypeList = value; }
        }


        public string RelationshipTypeCodeList
        {
            get { return _relationshipTypeCodeList; }
            set { _relationshipTypeCodeList = value; }
        }

        public string RelationshipIDList
        {
            get { return _relationshipIDList; }
            set { _relationshipIDList = value; }
        }

        
        /// <summary>
        /// Constructor
        /// </summary>
        public CompanyRelationships() {     
        }

        public int CompareTo(CompanyRelationships cr2, string szComparisonMethod, bool SortAsc) {
        
            if (SortAsc) {
                switch (szComparisonMethod) {
                    case "RelatedCompanyID":
                        return RelatedCompanyID.CompareTo(cr2.RelatedCompanyID);
                    case "Location":
                        return Location.CompareTo(cr2.Location);
                    case "RelatedCompanyName:Location":
                        string szTemp = RelatedCompanyName + ":" + Location;
                        return szTemp.CompareTo(cr2.RelatedCompanyName + ":" + cr2.Location);
                    case "RelatedCompanyName":
                    default:
                        return RelatedCompanyName.CompareTo(cr2.RelatedCompanyName);
                }
            } else {

                switch (szComparisonMethod) {
                    case "RelatedCompanyID":
                        return cr2.RelatedCompanyID.CompareTo(RelatedCompanyID);
                    case "Location":
                        return cr2.Location.CompareTo(Location);
                    case "RelatedCompanyName:Location":
                        string szTemp = cr2.RelatedCompanyName + ":" + cr2.Location;
                        return szTemp.CompareTo(RelatedCompanyName + ":" + Location);
                    case "RelatedCompanyName":
                    default:
                        return cr2.RelatedCompanyName.CompareTo(RelatedCompanyName);
                }
            }
        }        
    }

    public class CompanyRelationshipComparer : IComparer<CompanyRelationships> {
        private string _szComparisonType;
        private bool _bSortAsc;

        public string ComparisonMethod {
            get { return _szComparisonType; }
            set { _szComparisonType = value; }
        }

        public bool SortAsc {
            get { return _bSortAsc; }
            set { _bSortAsc = value; }
        }

        public int Compare(CompanyRelationships cr1, CompanyRelationships cr2) {
            return cr1.CompareTo(cr2, _szComparisonType, _bSortAsc);
        }
    }    
}