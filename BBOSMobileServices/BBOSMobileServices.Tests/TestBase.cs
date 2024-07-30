/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission ofBlue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: TestBase
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Net.Http.Headers;
using System.Web.Http.Results;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using BBSI.BBOSMobileServices.Controllers;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.ServiceModels.Responses;
using BBOSMobile.ServiceModels.Requests;

using Newtonsoft.Json;

namespace BBSI.BBOSMobileServices.Tests
{
    public class TestBase
    {
        protected LoginResponse _userLoginResponse;
        protected LoginResponse LoginUser()
        {
            if (_userLoginResponse == null)
            {
                LoginRequest loginRequest = new LoginRequest();
                loginRequest.Email = "support500@travant.com";
                loginRequest.Password = "GoCubs!!2016";
                //loginRequest.Email = "cwalls@travant.com";
                //loginRequest.Password = "Blu3B0ok";

                var controller = new UserController();
                _userLoginResponse = controller.Login(loginRequest);
            }

            return _userLoginResponse;
        }
    }
}
