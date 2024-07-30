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

 ClassName: PRWebUser
 Description:	

 Notes:	Created By TSI Class Generator on 7/17/2007 1:11:32 PM

***********************************************************************
***********************************************************************/
using System;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Interface definition for the PRWebUserSearchCriteria class.
    /// </summary>
    public interface IPRWebUserSearchCriteria : IEBBObject
    {

        bool IsCriteriaDirty {
            get;
            set;
        }

        
        
         #region TSI Framework Generated Code
        /// <summary>
        /// Accessor for the prsc_LastExecutionDateTime property.
        /// </summary>
        DateTime prsc_LastExecutionDateTime {
            get;
            set;
        }


        /// <summary>
        /// Accessor for the prsc_CompanyID property.
        /// </summary>
        int prsc_CompanyID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prsc_ExecutionCount property.
        /// </summary>
        int prsc_ExecutionCount {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prsc_HQID property.
        /// </summary>
        int prsc_HQID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prsc_LastExecutionResultCount property.
        /// </summary>
        int prsc_LastExecutionResultCount {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prsc_SearchCriteriaID property.
        /// </summary>
        int prsc_SearchCriteriaID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prsc_WebUserID property.
        /// </summary>
        int prsc_WebUserID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prsc_Criteria property.
        /// </summary>
        string prsc_Criteria {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prsc_IsLastUnsavedSearch property.
        /// </summary>
        bool prsc_IsLastUnsavedSearch {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prsc_IsPrivate property.
        /// </summary>
        bool prsc_IsPrivate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prsc_Name property.
        /// </summary>
        string prsc_Name {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prsc_SearchType property.
        /// </summary>
        string prsc_SearchType {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prsc_SelectedIDs property.
        /// </summary>
        string prsc_SelectedIDs {
            get;
            set;
        }

        SearchCriteriaBase Criteria {
            get;
            set;
        }

        #endregion

        IPRWebUser WebUser
        {
            get;
            set;
        }

    }
}
