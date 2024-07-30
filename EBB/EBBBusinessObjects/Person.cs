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

 ClassName: Person
 Description:	

 Notes:	Created By Sharon Cole on 7/18/2007 3:07:32 PM

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Security;
using TSI.Utils;

using PRCo.EBB.Util;

namespace PRCo.EBB.BusinessObjects
{

    /// <summary>
    /// Container for Person information intendeded to be
    /// serialized / deserialized.
    /// </summary>
    [Serializable]
    public class Person
    {
        public int PersonID;

        public string FirstName;
        public string MiddleName;
        public string Suffix;
        public string LastName;
        public string TitleCode;
        public string Title;
        public string FullTitle;
        public string EducationDegree;
        public string EducationInstitution;
        public string TypeCode;
        public string OwnershipRole;

        // Used by the membership screens for the
        // default email address.
        public string Email;
        
        // Used by the membership screens to determine
        // who has what level of access.
        public int AccessLevel;

        public DateTime Birthdate;
        public DateTime DegreeEarnedDate;

        public bool IsActive;
        public bool IsFormerBankruptcy;

        public decimal OwnershipPercentage;

        public List<InternetAddress> Emails;
        public List<Phone> Phones;
        public List<PersonHistory> PersonHistory;

        public void AddPhone(Phone oPhone) {
            if (Phones == null) {
                Phones = new List<Phone>();
            }
            oPhone.CountryCode = "1";
            Phones.Add(oPhone);
        }

        public void AddEmail(InternetAddress oEmail) {
            if (Emails == null) {
                Emails = new List<InternetAddress>();
            }
            oEmail.Type = "E";
            oEmail.Description = "E-Mail";
            Emails.Add(oEmail);
        }

        public void AddPersonHistory(PersonHistory oPersonHistory) {
            if (PersonHistory == null) {
                PersonHistory = new List<PersonHistory>();
            }
            PersonHistory.Add(oPersonHistory);
        }
        
        public Phone GetPhone(string szType) {
            if (Phones == null) {
                return null;
            }
            
            foreach(Phone oPhone in Phones) {
                if (oPhone.Type == szType) {
                    return oPhone;
                }
            }
            
            return null;
        }
        
        
        public string FirstName2 {
            get {return FirstName;}
        }

        public string LastName2 {
            get { return LastName; }
        }

        public string TitleCode2 {
            get { return TitleCode; }
        }

        public string Title2
        {
            get { return Title; }
        }

        public string Email2 {
            get { return Email; }
        }

        public int AccessLevel2 {
            get { return AccessLevel; }
        }

        public Decimal OwnershipPercentage2 {
            get { return OwnershipPercentage; }
        }

        public DateTime Birthdate2 {
            get { return Birthdate; }
        }
    }
}
