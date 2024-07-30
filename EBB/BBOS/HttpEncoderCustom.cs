/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2011

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. 
 is strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: HttpEncoderCustom
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.IO;
using System.Text;
using System.Web;

namespace PRCo.BBOS.UI.Web
{

    /// <summary>
    /// This class was created as a result of ASP.NET 4.0 encoding single ticks
    /// when adding custom attirbutes to web controls.  This was breaking functionality
    /// when adding an "onsubmit" handler to the form (see PageBase.EnableFormValidation()).
    /// <remarks>
    /// http://forums.asp.net/t/1554455.aspx/1/10
    /// </remarks>
    /// </summary>
    public class HttpEncoderCustom : System.Web.Util.HttpEncoder
    {

        /// <summary>
        /// Allow the normal encoding to happen, but then decode and encoded single 
        /// ticks.
        /// </summary>
        /// <param name="value"></param>
        /// <param name="output"></param>
        protected override void HtmlAttributeEncode(string value, System.IO.TextWriter output)
        {
            StringBuilder sb = new StringBuilder();
            StringWriter sw = new StringWriter(sb);

            base.HtmlAttributeEncode(value, sw);

            output.Write(sw.ToString().Replace("&#39;", "'"));
        }
    }
}