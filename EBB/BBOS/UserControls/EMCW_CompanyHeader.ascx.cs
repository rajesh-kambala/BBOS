/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of lue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of lue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: EMCW_CompanyHeader
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class EMCW_CompanyHeader : UserControlBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
        }

        protected const string SQL_EMCW_COMPANY_HEADER_SELECT =
                @"SELECT comp_PRCorrTradestyle, CityStateCountryShort
                    FROM Company WITH (NOLOCK) 
                         INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
                   WHERE comp_CompanyID={0}";

        /// <summary>
        /// Populates the header.
        /// </summary>
        /// <param name="szCompanyID"></param>
        public void LoadCompanyHeader(string szCompanyID)
        {
            string szSQL = string.Format(SQL_EMCW_COMPANY_HEADER_SELECT, szCompanyID);
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection))
            {
                if (oReader.Read())
                {

                    litBBID.Text = szCompanyID;
                    hlCompanyName.Text = GetDBAccess().GetString(oReader, 0);
                    hlCompanyName.NavigateUrl = PageConstants.FormatFromRoot(PageConstants.COMPANY_DETAILS_SUMMARY, szCompanyID);
                    litLocation.Text = GetDBAccess().GetString(oReader, 1);
                }
            }
        }

        public  string BBID
        {
            get { return litBBID.Text; }
        }

        public string CompanyName
        {
            get { return hlCompanyName.Text; }
        }
        public string CompanyLocation
        {
            get { return litLocation.Text; }
        }
    }
}