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

 ClassName: TradeAssociation
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using PRCo.EBB.BusinessObjects;
using System.Collections;
using TSI.BusinessObjects;
using System.Text;
using System.Data;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that displays the company header, or "banner" information
    /// on each of the company detail pages.
    /// 
    /// NOTE: This user control is also being used to display the company header information
    /// on each of the edit my company wizard pages.
    /// </summary>
    public partial class TradeAssociation : UserControlBase
    {
        //protected string _szLocation = null;
        protected string _szCompanyID;

        public enum TradeAssociationFormatType
        {
            FORMAT_ORIG = 1,
            FORMAT_BBOS9 = 2
        }

        protected TradeAssociationFormatType _eFormat = TradeAssociationFormatType.FORMAT_ORIG; //default to original style

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!Page.IsPostBack)
            {
                SetVisibility();
            }
        }

        public string companyID
        {
            set
            {
                _szCompanyID = value;
                PopulateTradeAssociation(WebUser);
            }
            get { return _szCompanyID; }
        }

        /// <summary>
        /// Make this string publically available for 
        /// use on the parent pages.
        /// </summary>
        public string Location
        {
            get
            {
                CompanyData ocd = GetCompanyData(_szCompanyID, WebUser, GetDBAccess(), GetObjectMgr());
                return ocd.szLocation;
            }
        }

        protected const string TRADE_ASSOC = "<img src=\"{0}\" alt=\"{1}\" border=\"0\" />";
        protected const string SQL_TRADE_ASSOC =
            @"SELECT prcta_TradeAssociationCode, capt_us As TradeAssociationName
               FROM PRCompanyTradeAssociation WITH (NOLOCK)
                    INNER JOIN custom_captions ON prcta_TradeAssociationCode = capt_code AND capt_family ='prcta_TradeAssociationCode'  
              WHERE prcta_CompanyID=@CompanyID 
                AND prcta_Disabled IS NULL
           ORDER BY capt_order";

        protected const string TRADE_ASSOC_URL = "<a href=\"{1}\" target=\"_blank\">{0}</a>";

        /// <summary>
        /// Populates the header.
        /// </summary>
        public void PopulateTradeAssociation(IPRWebUser oWebUser)
        {
            CompanyData ocd = GetCompanyData(companyID, oWebUser, GetDBAccess(), GetObjectMgr());

            Visible = false;
            StringBuilder sbTradeAssociation = new StringBuilder();

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_TRADE_ASSOC, oParameters, CommandBehavior.CloseConnection, null))
            {
                while (oReader.Read())
                {
                    if (sbTradeAssociation.Length > 0)
                    {
                        sbTradeAssociation.Append("&nbsp;");
                    }

                    string szHTML = string.Format(TRADE_ASSOC,
                                                  UIUtils.GetImageURL(oReader.GetString(0) + ".png"),
                                                  oReader.GetString(1));

                    string szURL = GetReferenceValue("prcta_TradeAssociationURL", oReader.GetString(0));
                    if (!string.IsNullOrEmpty(szURL))
                    {
                        szURL = Utilities.GetConfigValue("VirtualPath") + PageConstants.Format(PageConstants.EXTERNAL_LINK_TRIGGER,
                                                     szURL,
                                                     companyID,
                                                     "C",
                                                     Request.ServerVariables.Get("SCRIPT_NAME"));

                        szHTML = string.Format(TRADE_ASSOC_URL, szHTML, szURL);
                    }

                    Visible = true;
                    litTradeAssociationsSpacer.Visible = true;
                    sbTradeAssociation.Append(szHTML);

                }
            }

            litTradeAssociations.Text = sbTradeAssociation.ToString();
            litTradeAssociations2.Text = sbTradeAssociation.ToString();
        }

        public TradeAssociationFormatType Format
        {
            set
            {
                _eFormat = value;
                SetVisibility();
            }
            get { return _eFormat; }
        }

        private void SetVisibility()
        {
            switch (Format)
            {
                case TradeAssociationFormatType.FORMAT_BBOS9:
                    pnlTradeAssoc1.Visible = false;
                    pnlTradeAssoc2.Visible = true;
                    break;

                default:
                    pnlTradeAssoc1.Visible = true;
                    pnlTradeAssoc2.Visible = false;
                    break;
            }
        }
    }
}