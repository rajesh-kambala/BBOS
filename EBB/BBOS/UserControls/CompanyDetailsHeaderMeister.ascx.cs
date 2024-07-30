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

 ClassName: CompanyDetailsHeaderMeister
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using PRCo.EBB.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that displays the company header, or "banner" information
    /// on each of the company detail pages.
    /// 
    /// NOTE: This user control is also being used to display the company header information
    /// on each of the edit my company wizard pages.
    /// </summary>
    public partial class CompanyDetailsHeaderMeister : UserControlBase
    {
        protected bool _blnMeisterVisible = false;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
        }

        public bool MeisterVisible
        {
            get
            {
                return _blnMeisterVisible;
            }
            set
            {
                _blnMeisterVisible = value;
                pnlLocalSource.Visible = _blnMeisterVisible;
            }
        }
    }
}