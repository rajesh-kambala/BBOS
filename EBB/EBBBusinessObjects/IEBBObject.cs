/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: IEBBObject
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
	/// <summary>
	/// Provides the common functionality for the EBB
	/// business objects.
	/// </summary>
	public interface IEBBObject: IBusinessObject
	{
        DateTime ConvertToUTC(DateTime dtDateTime, string timeZone);
	}
}
