/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2017-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: UserDefinedFunctions
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Net;
using System.IO;
using System.Collections.Specialized;
using System.Text;
using System.Collections;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction]

    public static SqlString HTTPS_POST_JSON_UTF8(SqlString url, SqlString json_body, SqlString custom_headers_name_value_pairs_with_semicomma_delim)
    {

        ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;


        WebClient wc = new WebClient();
        wc.Headers[HttpRequestHeader.ContentType] = "application/json";
        wc.Headers[HttpRequestHeader.CacheControl] = "no-cache";
        wc.Headers[HttpRequestHeader.Accept] = "application/json"; // Added on 2/7 due to an Experian change.

        String[] value_pairs = custom_headers_name_value_pairs_with_semicomma_delim.Value.Split(';');

        for (int x = 0; x < value_pairs.Length; x++)
        {
            String[] name_value_pair = value_pairs[x].Split('=');
            wc.Headers.Add(name_value_pair[0], name_value_pair[1]);
        }
        wc.Encoding = System.Text.Encoding.UTF8;
        String response;
        Uri uri = new Uri(url.ToString());
        //response = wc.UploadString(uri, string_data.ToString());

        try
        {
            response = wc.UploadString(uri, "POST", json_body.Value);

        }
        catch (WebException wex)
        {
            response = wex.Message;


            if (wex.Response != null)
            {
                using (StreamReader responseReader = new StreamReader(wex.Response.GetResponseStream()))
                {
                    response = responseReader.ReadToEnd();
                }
            }


        }
        return new SqlString(response);

    }
}
