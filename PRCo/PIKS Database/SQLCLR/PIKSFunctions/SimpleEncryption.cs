/***********************************************************************
***********************************************************************
 Copyright Travant Solutions, Inc. 2003-2007

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Travant Solutions is 
 strictly prohibited.

 Confidential, Unpublished Property of Travant Solutions, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName:		
 Description:	

 Notes:		

***********************************************************************
***********************************************************************/
using System;
using System.IO;
using System.Security.Cryptography;

using System.Collections;
using System.Configuration;
using System.Text;

/// <summary>
/// Provides basic encryption services.
/// </summary>
public class SimpleEncryption 
{
	protected string	_szEncryptionKey;
	protected string	_szInitializer;

	protected const	string	DEFAULT_KEY = "TsI.zD%2";
	protected const string	DEFAULT_INIT = "kWa5$5]9";

	protected DESCryptoServiceProvider _oDESCrypto = new DESCryptoServiceProvider() ;

	/// <summary>
	/// Initializes the object with the EncryptionKey and EncryptionInitializer
	/// application setting values.  If not found, default values are used.
	/// </summary>
	public SimpleEncryption()
	{
		_szEncryptionKey = DEFAULT_KEY;
		_szInitializer = DEFAULT_INIT;
	}

	/// <summary>
	/// Initializes the object with the specified EncryptionKey and EncryptionInitializer
	/// values.
	/// </summary>
	public SimpleEncryption(string szEncryptionKey, string szInitializer) {
		EncryptionKey = szEncryptionKey;
		Initializer   = szInitializer;
	}

	/// <summary>
	/// The Encryption Key to use for encryption and
	/// decrytion.  If the length of the key exceeds the
	/// cryptogrophy's BlockSize, it will be truncated to
	/// that BlockSize.
	/// </summary>
	public string EncryptionKey {
		get {return _szEncryptionKey;}
		set {	// Limit the key to the block size
				if (value.Length > (BlockSize/8)) {
					_szEncryptionKey = value.Substring(0, (BlockSize/8));
				} else {
					_szEncryptionKey = value;
				}
			}
	}

	/// <summary>
	/// The Initializer to use for encryption and
	/// decryption.
	/// </summary>
	public string Initializer {
		get {return _szInitializer;}
		set {_szInitializer = value;}
	}

	/// <summary>
	/// The blocksize for the cryptography provider.
	/// </summary>
	public int BlockSize {
		get {return _oDESCrypto.BlockSize;}
	}

	/// <summary>
	/// Encrypt the value using the instances
	/// Encryption Key and Initializer.
	/// </summary>
	/// <param name="szValue">Value to Encrypt</param>
	/// <returns>Encrypted Value</returns>
	public string Encrypt(string szValue) {
		return Encrypt(szValue, _szEncryptionKey, _szInitializer);
	}

	/// <summary>
	/// Encrypt the value using the instances
	/// Initializer.
	/// </summary>
	/// <param name="szValue">Value to Encrypt</param>
	/// <param name="szKey">Encryption Key</param>
	/// <returns>Encrypted Value</returns>
	public string Encrypt(string szValue, string szKey) {
		return Encrypt(szValue, szKey, _szInitializer);
	}

	/// <summary>
	/// Encrypt the value.
	/// </summary>
	/// <param name="szValue">Value to Encrypt</param>
	/// <param name="szKey">Encryption Key</param>
	/// <param name="szInit">Initializer</param>
	/// <returns>Encrypted Value</returns>
	public string Encrypt(string szValue, string szKey, string szInit) {
 
		if (szKey == null) {
			throw new ArgumentNullException("Key");
		}

		if (szInit == null) {
			throw new ArgumentNullException("Initializer");
		}

		if (szValue == null) {
			throw new ArgumentNullException("Value");
		}

		if (szKey.Length == 0) {
			throw new ArgumentException("Required String Parameter is Empty.", "Key");
		}

		if (szInit.Length == 0) {
			throw new ArgumentException("Required String Parameter is Empty.", "Initializer");
		}

		if (szValue.Length == 0) {
			throw new ArgumentException("Required String Parameter is Empty.", "Value");
		}

		if (szKey.Length > this.BlockSize) {
			throw new ArgumentException("The key cannot be longer than " + Convert.ToString(BlockSize / 8) + " bytes.", "Key");
		}

		Byte[] arrKey = GetByteArray(szKey) ;
		Byte[] arrIV = GetByteArray(szInit);

		// Convert string data to byte array
		UTF8Encoding objEncoding = new UTF8Encoding();
		Byte[] arrUTF8 = objEncoding.GetBytes(szValue);

		// Encrypt byte array
		MemoryStream objMemoryStream = new MemoryStream();
		CryptoStream objCryptoStream = new CryptoStream(objMemoryStream,
														_oDESCrypto.CreateEncryptor(arrKey, arrIV),
														CryptoStreamMode.Write);

		objCryptoStream.Write(arrUTF8, 
							  0, 
							  arrUTF8.Length);

		objCryptoStream.Flush();
		objCryptoStream.Close();
		objMemoryStream.Close();

		Byte[] arrEncryptedData = objMemoryStream.ToArray() ;
		return Convert.ToBase64String(arrEncryptedData) ;
	}

	/// <summary>
	/// Decrypt the value using the instances
	/// Encryption Key and Initializer.
	/// </summary>
	/// <param name="szValue">Value to Decrypt</param>
	/// <returns>Decrypted Value</returns>
	public string Decrypt(string szValue){
		return Decrypt(szValue, _szEncryptionKey);
	}

	/// <summary>
	/// Decrypt the value using the instances
	/// Initializer.
	/// </summary>
	/// <param name="szValue">Value to Decrypt</param>
	/// <param name="szKey">Encryption Key</param>
	/// <returns>Decrypted Value</returns>
	public string Decrypt(string szValue, string szKey){
		return Decrypt(szValue, szKey, _szInitializer);
	}

	/// <summary>
	/// Decrypt the value.
	/// </summary>
	/// <param name="szValue">Value to Decrypt</param>
	/// <param name="szKey">Encryption Key</param>
	/// <param name="szInit">Initializer</param>
	/// <returns>Decrypted Value</returns>
	public string Decrypt(string szValue, string szKey, string szInit) {
 
		if (szKey == null) {
			throw new ArgumentNullException("Key");
		}

		if (szInit == null) {
			throw new ArgumentNullException("Initializer");
		}

		if (szValue == null) {
			throw new ArgumentNullException("Value");
		}

		if (szKey.Length == 0) {
			throw new ArgumentException("Required String Parameter is Empty.", "Key");
		}

		if (szInit.Length == 0) {
			throw new ArgumentException("Required String Parameter is Empty.", "Initializer");
		}

		if (szValue.Length == 0) {
			throw new ArgumentException("Required String Parameter is Empty.", "Value");
		}

		if (szKey.Length > this.BlockSize) {
			throw new ArgumentException("The key cannot be longer than " + Convert.ToString(BlockSize / 8) + " bytes.", "Key");
		}


		Byte[] arrKey = GetByteArray(szKey);
		Byte[] arrIV = GetByteArray(szInit);

		// Decrypt Data.
		// First conver the user token from Base64 to byte array
		// then decrypt the data.
		Byte[] arrEncryptedData = Convert.FromBase64String(szValue);

		MemoryStream objMemoryStream = new MemoryStream();
		CryptoStream objCryptoStream = new CryptoStream(objMemoryStream,
														_oDESCrypto.CreateDecryptor(arrKey, arrIV),
														CryptoStreamMode.Write);
		objCryptoStream.Write(arrEncryptedData, 
							  0, 
							  arrEncryptedData.Length);
		objCryptoStream.Flush();
		objCryptoStream.Close();
		objMemoryStream.Close();

		// Get the byte array.
		Byte[] arrDecryptedData = objMemoryStream.ToArray();

		// Convert the array to string
		UTF8Encoding objEncoding = new UTF8Encoding();
		return objEncoding.GetString(arrDecryptedData);
	}

	/// <summary>
	/// Creates an array of Bytes from the specified
	/// string
	/// </summary>
	/// <param name="szValue"></param>
	/// <returns></returns>
	private Byte[] GetByteArray(string szValue) {
		Byte[] aByte = new Byte[szValue.Length];
		Encoding objEncoding = Encoding.UTF8;
		aByte = objEncoding.GetBytes(szValue);
		return aByte ;
	}
}