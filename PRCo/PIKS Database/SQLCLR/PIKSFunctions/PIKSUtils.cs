/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2010

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PIKSUtils
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using Microsoft.SqlServer.Server;
using System.Data.SqlTypes;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Text;

/// <summary>
/// Provides utiltiy functionality that cannot easily be provided
/// for using T-SQL or otherwise in SQL Server.
/// </summary>
public class PIKSUtils {

    private static SimpleEncryption _oEncryptionProvider = null;
    private static string _szEncryptionKey = null;
    
    /// <summary>
    /// Returns the encrpyted version of the specified 
    /// text.
    /// </summary>
    /// <param name="szText"></param>
    /// <returns></returns>
    [SqlFunction(DataAccess = DataAccessKind.Read)]
    public static SqlString EncryptText(SqlString szText) {
        return GetEncryptionProvider().Encrypt(szText.ToString());
    }

    /// <summary>
    /// Returns the decrypted version of the specified
    /// text.
    /// </summary>
    /// <param name="szEncryptedText"></param>
    /// <returns></returns>
    [SqlFunction(DataAccess = DataAccessKind.Read)]
    public static SqlString DecryptText(SqlString szEncryptedText) {
        return GetEncryptionProvider().Decrypt(szEncryptedText.ToString());
    }

    [SqlFunction(DataAccess = DataAccessKind.Read)]
    public static SqlString GetEncryptionKey2() {
        return GetEncryptionProvider().EncryptionKey;
    }


    /// <summary>
    /// Helper method that returns an instance of the Encryption
    /// provider.
    /// </summary>
    /// <returns></returns>
    private static SimpleEncryption GetEncryptionProvider() {
        if (_oEncryptionProvider == null) {
            _oEncryptionProvider = new SimpleEncryption();
            _oEncryptionProvider.EncryptionKey = GetEncryptionKey();
        }

        return _oEncryptionProvider;
    }
    
    /// <summary>
    /// Helper method that returns then encryption key stored
    /// in custom_captions.
    /// </summary>
    /// <returns></returns>
    [SqlFunction(DataAccess = DataAccessKind.Read)]
    public static string GetEncryptionKey() {
        if (_szEncryptionKey == null) {
            using (SqlConnection oConn = new SqlConnection("context connection=true")) {
                oConn.Open();
                SqlCommand oCmd = new SqlCommand("SELECT capt_US FROM custom_captions WHERE capt_family='PIKSUtils' AND capt_code='EncryptionKey'", oConn);
                _szEncryptionKey = (string)oCmd.ExecuteScalar();
            }
        }
        return _szEncryptionKey;
    }

    private static string _szBBSUtilsURL = null;

    [SqlFunction(DataAccess = DataAccessKind.Read)]
    public static int DoesLogoExist(SqlString szLogoFile)
    {
        if (_szBBSUtilsURL == null)
        {
            using (SqlConnection oConn = new SqlConnection("context connection=true"))
            {
                oConn.Open();
                SqlCommand oCmd = new SqlCommand("SELECT capt_US FROM CRM.dbo.custom_captions WHERE capt_family='PIKSUtils' AND capt_code='LogoURL'", oConn);
                _szBBSUtilsURL = (string)oCmd.ExecuteScalar();
            }
        }

        int iFound = 1;

        string szURL = _szBBSUtilsURL + (string)szLogoFile;
        HttpWebRequest httpRequest = (HttpWebRequest)WebRequest.Create(szURL);
        try
        {
            HttpWebResponse httpResponse = (HttpWebResponse)httpRequest.GetResponse();
        }
        catch 
        {
            iFound = 0;
        }

        return iFound;

    }

    public static SqlInt32 GetLogoWidth(SqlString logoURL)
    {
        HttpWebRequest httpRequest = (HttpWebRequest)WebRequest.Create((string)logoURL);
        System.Drawing.Image logoImage = System.Drawing.Image.FromStream(httpRequest.GetResponse().GetResponseStream());
        return logoImage.Width;
    }
}
