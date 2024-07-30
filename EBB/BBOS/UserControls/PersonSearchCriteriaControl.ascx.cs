/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PersonSearchCriteria
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Text;

using PRCo.EBB.BusinessObjects;

namespace PRCo.BBOS.UI.Web
{
    public partial class PersonSearchCriteriaControl : SearchCriteriaControlBase
    {
        public PersonSearchCriteria PersonSearchCriteria;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            lblSearchCriteria.Text = BuildSearchCriteria();
        }

        /// <summary>
        /// This function builds the search criteria to display for each section.  
        /// </summary>
        /// <returns>String containing HTML to display the selected search criteria.</returns>
        private string BuildSearchCriteria()
        {
            StringBuilder sbSearchCriteria = new StringBuilder();

            #region Person Search Criteria
            StringBuilder sbPersonSearchCriteria = new StringBuilder();

            if (!String.IsNullOrEmpty(PersonSearchCriteria.FirstName))
            {
                sbPersonSearchCriteria.Append(GetCriteriaHTML(Resources.Global.FirstName, PersonSearchCriteria.FirstName, true));
            }

            if (!String.IsNullOrEmpty(PersonSearchCriteria.LastName))
            {
                sbPersonSearchCriteria.Append(GetCriteriaHTML(Resources.Global.LastName, PersonSearchCriteria.LastName, true));
            }


            if (!String.IsNullOrEmpty(PersonSearchCriteria.Title))
            {
                sbPersonSearchCriteria.Append(GetCriteriaHTML(Resources.Global.Title, PersonSearchCriteria.Title, true));
            }

            // Person Phone
            if (!String.IsNullOrEmpty(PersonSearchCriteria.PhoneAreaCode))
            {
                sbPersonSearchCriteria.Append(GetCriteriaHTML(Resources.Global.CompanyPhone, PersonSearchCriteria.PhoneAreaCode + " " + PersonSearchCriteria.PhoneNumber, true));
            }

            // Email
            if (!String.IsNullOrEmpty(PersonSearchCriteria.Email))
            {
                sbPersonSearchCriteria.Append(GetCriteriaHTML(Resources.Global.CompanyEmail, PersonSearchCriteria.Email, true));
            }


            // Company Name
            if (!String.IsNullOrEmpty(PersonSearchCriteria.CompanyName))
            {
                sbPersonSearchCriteria.Append(GetCriteriaHTML(Resources.Global.CompanyName, PersonSearchCriteria.CompanyName, true));
            }

            // BB #
            if (PersonSearchCriteria.BBID > 0)
            {
                sbPersonSearchCriteria.Append(GetCriteriaHTML(Resources.Global.BBNumber, PersonSearchCriteria.BBID.ToString(), true));
            }

            if (!String.IsNullOrEmpty(PersonSearchCriteria.IndustryType))
            {
                sbPersonSearchCriteria.Append(GetCriteriaHTML(Resources.Global.IndustryType, oPageBase.GetReferenceValue("comp_PRIndustryType", PersonSearchCriteria.IndustryType), true));


            }

            if (!String.IsNullOrEmpty(PersonSearchCriteria.Role))
            {
                sbPersonSearchCriteria.Append(GetCriteriaHTML("Role",
                                                              GetReferenceDisplayValues(PersonSearchCriteria.Role, "peli_PRRole"),
                                                              true));
            }


            if (sbPersonSearchCriteria.Length > 0)
            {
                sbSearchCriteria.Append(GetSectionHeaderHTML("Person Criteria"));
                sbSearchCriteria.Append(sbPersonSearchCriteria.ToString());
            }
            #endregion


            #region Location Search Criteria
            string locationSearchCriteria = GetLocationCriteria(PersonSearchCriteria);
            if (locationSearchCriteria.Length > 0)
            {
                sbSearchCriteria.Append(GetSectionHeaderHTML(Resources.Global.Location));
                sbSearchCriteria.Append(locationSearchCriteria);
            }
            #endregion


            #region Custom Search Criteria
            string customSearchCriteria = GetCustomCriteria(PersonSearchCriteria);
            if (customSearchCriteria.Length > 0)
            {
                sbSearchCriteria.Append(GetSectionHeaderHTML(Resources.Global.Custom));
                sbSearchCriteria.Append(customSearchCriteria);
            }
            #endregion

            if (sbSearchCriteria.Length == 0)
            {
                sbSearchCriteria.Append("<span>" + Resources.Global.NoCriteriaSelected + "</span>");
            }

            return sbSearchCriteria.ToString();
        }
    }
}