/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PersonDetailsBase
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;

using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Provides the common functionality for the Person Detail
    /// pages.
    /// </summary>
    public class PersonDetailsBase : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
        }

        protected const string SQL_SELECT_PERSON_NAME = "SELECT dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix) as PersonName FROM Person WITH (NOLOCK) WHERE pers_PersonID = {0}";
        protected string GetPersonName()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("pers_PersonID", GetRequestParameter("PersonID")));

            string szSQL = GetObjectMgr().FormatSQL(SQL_SELECT_PERSON_NAME, oParameters);

            return (string)GetDBAccess().ExecuteScalar(szSQL, oParameters);
        }

        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.PersonDetailsPage).HasPrivilege;
        }


        protected const string SQL_PERSON_LISTING_STATUS = "SELECT 'x' " +
                                                             "FROM Person_Link WITH (NOLOCK) " +
                                                                  "INNER JOIN vPRBBOSCompanyList ON peli_CompanyID = comp_CompanyID " +
                                                             "WHERE peli_PersonID = {0} " +
                                                               "AND peli_PRStatus = '1' " +
                                                               "AND peli_PREBBPublish = 'Y';";
        /// <summary>
        /// Only Persons that are actively associated with listed
        /// companies and have the EBBPublish flag can be
        /// viewed.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            int iPersonID = 0;
            if (!int.TryParse(GetRequestParameter("PersonID"), out iPersonID))
            {
                throw new ArgumentException("Invalid PersonID parameter specified");
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PersonID", iPersonID));

            string szSQL = GetObjectMgr().FormatSQL(SQL_PERSON_LISTING_STATUS, oParameters);
            string szExists = (string)GetDBAccess().ExecuteScalar(szSQL, oParameters);

            if (string.IsNullOrEmpty(szExists))
            {
                return false;
            }

            return true;
        }
    }
}