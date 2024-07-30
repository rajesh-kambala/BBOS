/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2024-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BusinessValuationDownload.aspx
 Description: 

 Notes:	

***********************************************************************
***********************************************************************/
using ICSharpCode.SharpZipLib.Zip;
using Newtonsoft.Json.Linq;
using PayPal.Payments.DataObjects;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Net.Mail;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Web.Services.Description;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public partial class BusinessValuationDownload : BusinessValuationBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            string szGuid = GetRequestParameter("g", true, false, true);
            BusinessValuation.BusinessValuationData oBVData = PageControlBaseCommon.GetBusinessValuationData(szGuid);

            string szBVFolder = Utilities.GetConfigValue("BusinessValuationFolder", "/BBOS/Campaigns/BusinessValuations");
            string szFullFileName = Path.Combine(szBVFolder, oBVData.BusinessValuationID.ToString(), oBVData.FileName);

            Response.ClearContent();
            Response.ContentType = "application/pdf";
            Response.AddHeader("Content-Disposition", "attachment; filename=" + oBVData.FileName);
            Response.TransmitFile(szFullFileName);
            Response.End();
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }
    }
}
