/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Blue Book Services, Inc..  Contact
 by e-mail at chris@wallsfamily.com

 ClassName: PRGetListedRequest
 Description:	

 Notes:	Created By TSI Class Generator on 3/17/2014 2:42:33 PM

***********************************************************************
***********************************************************************/
using System;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Interface definition for the PRGetListedRequest class.
    /// </summary>
    public partial interface IPRGetListedRequest : IBusinessObject
    {
         #region TSI Framework Generated Code
        /// <summary>
        /// Accessor for the prglr_CreatedDate property.
        /// </summary>
        DateTime prglr_CreatedDate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_TimeStamp property.
        /// </summary>
        DateTime prglr_TimeStamp {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_UpdatedDate property.
        /// </summary>
        DateTime prglr_UpdatedDate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_CreatedBy property.
        /// </summary>
        int prglr_CreatedBy {
            get;
            set;
        }


        /// <summary>
        /// Accessor for the prglr_GetListedRequestID property.
        /// </summary>
        int prglr_GetListedRequestID {
            get;
            set;
        }



        /// <summary>
        /// Accessor for the prglr_UpdatedBy property.
        /// </summary>
        int prglr_UpdatedBy {
            get;
            set;
        }


        /// <summary>
        /// Accessor for the prglr_HowLearned property.
        /// </summary>
        string prglr_HowLearned {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_PrimaryFunction property.
        /// </summary>
        string prglr_PrimaryFunction
        {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_RequestsMembershipInfo property.
        /// </summary>
        string prglr_RequestsMembershipInfo
        {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_SubmitterIsOwner property.
        /// </summary>
        string prglr_SubmitterIsOwner
        {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_City property.
        /// </summary>
        string prglr_City {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_CompanyEmail property.
        /// </summary>
        string prglr_CompanyEmail {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_CompanyName property.
        /// </summary>
        string prglr_CompanyName {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_CompanyPhone property.
        /// </summary>
        string prglr_CompanyPhone {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_CompanyWebsite property.
        /// </summary>
        string prglr_CompanyWebsite {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_Country property.
        /// </summary>
        string prglr_Country {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_PostalCode property.
        /// </summary>
        string prglr_PostalCode {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_Principals property.
        /// </summary>
        string prglr_Principals {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_State property.
        /// </summary>
        string prglr_State {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_Street1 property.
        /// </summary>
        string prglr_Street1 {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_Street2 property.
        /// </summary>
        string prglr_Street2 {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_SubmitterEmail property.
        /// </summary>
        string prglr_SubmitterEmail {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_SubmitterIPAddress property.
        /// </summary>
        string prglr_SubmitterIPAddress {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_SubmitterName property.
        /// </summary>
        string prglr_SubmitterName {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prglr_SubmitterPhone property.
        /// </summary>
        string prglr_SubmitterPhone {
            get;
            set;
        }

        string prglr_IndustryType
        {
            get;
            set;
        }

         #endregion
    }
}
