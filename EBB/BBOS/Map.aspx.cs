/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Map.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

using TSI.Arch;

namespace PRCo.BBOS.UI.Web
{
    public partial class Map : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            PopulateForm();
        }

        protected string mapData;
        private const string JSON_COMPANY_MAP =
            "{{\"title\":\"{0}\",\"display\":\"{1}\",\"icon\":\"{2}\",\"address\":\"{3}\",\"lat\":\"{4}\",\"long\":\"{5}\",\"addressid\":\"{6}\"}}";

        protected void PopulateForm()
        {
            if ((string.IsNullOrEmpty(GetRequestParameter("CompanyIDList", false))) &&
                (string.IsNullOrEmpty(GetRequestParameter("UserListIDList", false))))
            {
                throw new ApplicationExpectedException(Resources.Global.BookmarkError);
            }

            StringBuilder json = new StringBuilder();
            string sql = null;

            if (!string.IsNullOrEmpty(GetRequestParameter("UserListIDList", false)))
            {
                string userListIDs = GetRequestParameter("UserListIDList", true);
                sql = string.Format("SELECT * FROM vPRWatchDogMapAddresses WHERE prwucl_WebUserListID IN ({0}) ORDER BY comp_CompanyID", userListIDs);

            }
            else
            {
                string companyIDs = GetRequestParameter("CompanyIDList", true);
                sql = string.Format("SELECT * FROM vPRMapAddresses WHERE comp_CompanyID IN ({0}) ORDER BY comp_CompanyID", companyIDs);
            }

            Dictionary<Int32, string> icons = new Dictionary<int, string>();

            using (IDataReader reader = GetDBAccess().ExecuteReader(sql))
            {
                while (reader.Read())
                {
                    string icon = null;
                    if (reader["Icon"] != DBNull.Value)
                    {
                        icon = (string)reader["Icon"];

                        // Google doesn't have a black icon
                        if (icon == "black")
                            icon = "purple";
                    }
                    else
                    {
                        // This only happens for user lists
                        int userListID = (Int32)reader["prwucl_WebUserListID"];

                        if (!icons.ContainsKey(userListID))
                        {
                            switch (icons.Count)
                            {
                                case 0:
                                    icons.Add(userListID, "purple");
                                    break;
                                case 1:
                                    icons.Add(userListID, "pink");
                                    break;
                                case 2:
                                    icons.Add(userListID, "lightblue");
                                    break;
                                default:
                                    icon = "orange";
                                    break;
                            }
                        }

                        if (string.IsNullOrEmpty(icon))
                        {
                            icon = icons[userListID];
                        }
                    }

                    object[] args = {reader["Title"],
                                   reader["Display"],
                                   icon,
                                   reader["Address"],
                                   reader["addr_PRLatitude"],
                                   reader["addr_PRLongitude"],
                                   reader["addr_AddressID"]};


                    if (json.Length > 0)
                    {
                        json.Append(",");
                    }

                    json.Append(string.Format(JSON_COMPANY_MAP, args));
                    //json.Append(Environment.NewLine);
                }
            }

            mapData = "[" + json.ToString() + "];";
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }
    }
}