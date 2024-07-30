/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2020-2024

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Blue Book Services, Inc.  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
using System;
using Sage.CRM.WebObject;
using System.Reflection;

namespace BBSI.CRM
{
    /// <summary>
    ///  static class AppFactory is REQUIRED!
    ///  
    ///  This is the CRM Dispatcher.  It look in this static class for the method noted in
    ///  CRM and then executes it.
    /// </summary>

    public static class AppFactory
    {
        static AppFactory()
        {
            // This code will get executed before each call to an AppFactory method
            AppDomain currentDomain = AppDomain.CurrentDomain;
            currentDomain.AssemblyResolve += new ResolveEventHandler(CRMResolveEventHandler);
        }

        public static void RunCompanyInteractionListing(ref Web AretVal)
        {
            AretVal = new CompanyInteraction();
        }

        public static void RunMyCRMInteractionListing(ref Web AretVal)
        {
            AretVal = new MyCRMInteraction();
        }

        public static void RunPersonInteractionListing(ref Web AretVal)
        {
            AretVal = new PersonInteraction();
        }

        public static void RunEmailImageListing(ref Web AretVal)
        {
            AretVal = new EmailImageListing();
        }

        public static void RunEmailImage(ref Web AretVal)
        {
            AretVal = new EmailImage();
        }

        public static void RunPersonAlertImport(ref Web AretVal)
        {
            AretVal = new PersonAlertImport();
        }

        public static void RunCompanyCreateNew(ref Web AretVal)
        {
            AretVal = new CompanyCreateNew();
        }

        public static void RunBackgroundCheckRequestListing(ref Web AretVal)
        {
            AretVal = new BackgroundCheckRequestListing();
        }

        public static void RunBackgroundCheckRequest(ref Web AretVal)
        {
            AretVal = new BackgroundCheckRequest();
        }

        public static void RunBackgroundCheck(ref Web AretVal)
        {
            AretVal = new BackgroundCheck();
        }
        public static void RunBackgroundCheckListing(ref Web AretVal)
        {
            AretVal = new BackgroundCheckListing();
        }

        public static void RunTravantTest(ref Web AretVal)
        {
            AretVal = new TravantTest();
        }

        public static void RunBackgroundCheckAllocationListing(ref Web AretVal)
        {
            AretVal = new BackgroundCheckAllocationListing();
        }

        public static void RunBusinessValuationRequestListing(ref Web AretVal)
        {
            AretVal = new BusinessValuationRequestListing();
        }
        public static void RunBusinessValuationRequest(ref Web AretVal)
        {
            AretVal = new BusinessValuationRequest();
        }


        public static void RunChangeQueueListing(ref Web AretVal)
        {
            AretVal = new ChangeQueueListing();
        }

        public static void RunChangeQueueDetail(ref Web AretVal)
        {
            AretVal = new ChangeQueueDetail();
        }

        private static Assembly CRMResolveEventHandler(object sender, ResolveEventArgs args)
        {
            //This handler is called only when the common language runtime tries to bind to the assembly and fails.

            //Retrieve the list of referenced assemblies in an array of AssemblyName.
            Assembly MyAssembly, objExecutingAssemblies;
            string strTempAssmbPath = "";

            objExecutingAssemblies = Assembly.GetExecutingAssembly();
            AssemblyName[] arrReferencedAssmbNames = objExecutingAssemblies.GetReferencedAssemblies();

            //Loop through the array of referenced assembly names.
            foreach (AssemblyName strAssmbName in arrReferencedAssmbNames)
            {
                //Check for the assembly names that have raised the "AssemblyResolve" event.
                if (strAssmbName.FullName.Substring(0, strAssmbName.FullName.IndexOf(",")) == args.Name.Substring(0, args.Name.IndexOf(",")))
                {
                    //Build the path of the assembly from where it has to be loaded.
                    strTempAssmbPath = Stub.Web.Metadata.GetParam("InstallDirName") + "\\CustomDotNet\\" + args.Name.Substring(0, args.Name.IndexOf(",")) + ".dll";
                    break;
                }
            }
            //Load the assembly from the specified path. 
            MyAssembly = Assembly.LoadFrom(strTempAssmbPath);

            //Return the loaded assembly.
            return MyAssembly;
        }
    }

    public static class Stub
    {
        private class WebToe : Sage.CRM.WebObject.Web
        {
            public WebToe() { }
            public override void BuildContents() { throw new NotImplementedException(); }
        }

        private static WebToe web;
        public static Sage.CRM.WebObject.Web Web {
            get
            {
                if (web == null) web = new WebToe();
                return web;
            }
        }
    }

}