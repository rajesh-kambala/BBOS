/***********************************************************************
 Copyright Produce Reporter Company 2007

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ListingTests.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace PRCo.BBS.QA {

    /// <summary>
    /// Driver for the ListingTests functionality
    /// </summary>
    class Program {
        static void Main(string[] args) {
        
            ListingTests oListingTests = new ListingTests();
            oListingTests.CompareListings(args);
        }
    }
}
