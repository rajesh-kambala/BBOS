/***********************************************************************
 Copyright Blue Book Services, Inc. 2014

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: EmailResult.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PRCo.BBOS.EmailInterface
{

    public class EmailResult
    {
        public string FromAddress;
        public string ToAddress;
        public string Subject;
        public string ErrorMessage;
        public string ErrorCategory;
        public string AdditionalInfo;
        public DateTime SentDateTime;
        public bool IsBouncedEmail = false;


        public void PrepareResult()
        {
            ToAddress = cleanString(ToAddress);
            ErrorMessage = cleanString(ErrorMessage);
            SetCategory();
        }

        private string cleanString(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return value;
            }

            if ((value.StartsWith("'")) &&
                (value.EndsWith("'")))
            {
                value = value.Substring(1, value.Length - 2);
            }

            if ((value.StartsWith("<")) &&
                (value.EndsWith(">")))
            {
                value = value.Substring(1, value.Length - 2);
            }

            return value.Trim();
        }


        // http://community.spiceworks.com/how_to/show/939-ndr-non-delivery-receipts-codes-and-their-meanings
        private void SetCategory()
        {

            if (string.IsNullOrEmpty(ErrorMessage))
            {
                return;
            }

            string work = ErrorMessage.ToLower();

            if (ErrorMessage.IndexOf("5.4.0") > 0)
            {
                ErrorCategory = "Unable to Find Email Server";  // Check for misspellings in the email address and confirm the company still exists.
                return;
            }

            if ((ErrorMessage.IndexOf("4.4.2") > 0) ||
                (ErrorMessage.IndexOf("4.4.7") > 0) ||
                (ErrorMessage.IndexOf("hop count exceeded") > 0) ||
                (ErrorMessage.IndexOf("unable to relay") > 0) ||
                (ErrorMessage.IndexOf("relay access denied") > 0) ||
                (ErrorMessage.IndexOf("sender denied") > 0) ||
                (ErrorMessage.IndexOf("does not comply with required standards") > 0) ||
                (ErrorMessage.IndexOf("helo command rejected") > 0) ||
                (ErrorMessage.IndexOf("spf check failed") > 0)
                )
            {
                ErrorCategory = "Technical Issue";  // Contact BBSI IT to research further.
                return;
            }


          
            if  ((work.IndexOf("does not exist") > 0) ||
                 (work.IndexOf("user unknown") > 0) ||
                 (work.IndexOf("user account is unavailable") > 0) ||
                 (work.IndexOf("no such user") > 0) ||
                 (work.IndexOf("is disabled") > 0) ||
                 (work.IndexOf("recipient not found") > 0) ||
                 (work.IndexOf("recipient doesn't exist") > 0) ||
                 (work.IndexOf("recipient rejected") > 0) ||
                 (work.IndexOf("invalid recipient") > 0) ||
                 (work.IndexOf("unknown or illegal alias") > 0) ||
                 (work.IndexOf("invalid mailbox") > 0) ||
                 (work.IndexOf("mailbox unavailable") > 0) ||
                 (work.IndexOf("address rejected") > 0) ||
                 (work.IndexOf("recipnotfound") > 0) ||
                 (work.IndexOf("message rejected") > 0) ||
                 (work.IndexOf("there is no one at this address") > 0) ||
                 (work.IndexOf("mailbox is inactive") > 0) ||
                 (work.IndexOf("not liste d ") > 0) ||   // Misspelling is intentional
                 (work.IndexOf("account has been disabled") > 0))  
            {
                ErrorCategory = "Email Address Not Found";  // Check for misspellings in the email address and confirm this person is still with the organization.
                return;
            }

            if ((work.IndexOf("is over quota") > 0) ||
                (work.IndexOf("quota exceeded") > 0) ||
                (work.IndexOf("exceed quota") > 0) ||
                (work.IndexOf("mailbox is full") > 0) ||
                (work.IndexOf("mailfolder is full") > 0))
            {
                ErrorCategory = "Email Address Rejecting Email";  // Confirm this person is still with the organization
                return;
            }

            if ((work.IndexOf("looks like spam") > 0) ||
                (work.IndexOf("spam") > 0))
            {
                ErrorCategory = "Rejected as Spam/Junk";  // Contact company and ask to add ‘bluebookservices.com” to white list.
                return;
            }

        }
    }
}
