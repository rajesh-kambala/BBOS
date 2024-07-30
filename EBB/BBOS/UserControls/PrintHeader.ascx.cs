/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2018-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PrintHeader.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that determines what advertisements gets displayed based on the 
    /// specified pagename, ad campaign type, and maximum number of ads.
    /// 
    /// <remarks>
    /// This component is shared with the marketing web site so we should avoid using
    /// resource files if possible. 
    /// </remarks>
    /// </summary>
    public partial class PrintHeader : UserControlBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
        }

        public string Title
        {
            get { return litTitle.Text; }
            set { litTitle.Text = value; }
        }

        public string SubTitle
        {
            get { return litSubTitle.Text; }
            set { litSubTitle.Text = value; }
        }
    }
}