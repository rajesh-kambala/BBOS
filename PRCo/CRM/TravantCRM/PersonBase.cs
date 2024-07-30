/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2020

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
using System.Collections.Generic;
using System.Text;

using Sage.CRM.Blocks;
using Sage.CRM.Controls;
using Sage.CRM.Data;
using Sage.CRM.HTML;
using Sage.CRM.Utils;
using Sage.CRM.WebObject;
using Sage.CRM.UI;

using TSI.Utils;


namespace BBSI.CRM
{
    public class PersonBase : CRMBase
    {
        public override void BuildContents()
        {
            throw new NotImplementedException();
        }

        private int _personID = 0;

        protected int GetPersonID()
        {
            if (_personID != 0)
                return _personID;

            var pers_personid = Dispatch.QueryField("pers_personid");

            if (string.IsNullOrEmpty(pers_personid))
                pers_personid = Dispatch.QueryField("Key2");

            if (string.IsNullOrEmpty(pers_personid))
                pers_personid = Dispatch.QueryField("pers_personid");
            
            if (string.IsNullOrEmpty(pers_personid))
                pers_personid = GetContextInfo("person", "pers_personid");

            // this is a one-off added for handling peli_personlinkid which can translate
            // indirectly to a person id
            if (string.IsNullOrEmpty(pers_personid))
            {
                var peliId = Dispatch.QueryField("peli_personlinkid");
                if (!string.IsNullOrEmpty(peliId))
                {
                    // look up the peli record and get the personid
                    var recPELI = FindRecord("Person_Link", "peli_PersonLinkId=" + peliId);
                    if (!recPELI.Eof())
                        pers_personid = recPELI.GetFieldAsString("peli_PersonId");
                }
            }

            // No Luck!
            if (string.IsNullOrEmpty(pers_personid))
                pers_personid = "-1";

            _personID = Convert.ToInt32(pers_personid);
            return _personID;
        }
    }
}
