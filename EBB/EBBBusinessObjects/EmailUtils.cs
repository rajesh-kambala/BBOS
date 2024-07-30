/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Email
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net.Mail;
using System.Net;

using TSI.Utils;

namespace PRCo.EBB.Util
{
	/// <summary>
	/// Provides basic email functionality.  Looks for the
	/// following configuration values:
	/// 
	/// <code>EMailFromAddress</code>
	/// </summary>
    public class EmailUtils
	{
		private EmailUtils()	{}

		/// <summary>
		/// Returns the default From address.
		/// </summary>
		/// <returns></returns>
		static public string GetFromAddress() {
			return Utilities.GetConfigValue("EMailFromAddress");
		}

		/// <summary>
		/// Sends email formatted for plain text.
		/// </summary>
		/// <param name="szToAddress">To Address</param>
		/// <param name="szSubject">Subject</param>
		/// <param name="szMessage">Message</param>
		static public void SendMail(string szToAddress,
									string szSubject,
									string szMessage) {
			SendMail(szToAddress,
					 GetFromAddress(),
					 szSubject,
					 szMessage,
					 false,
				     null);
		}

		/// <summary>
		/// Sends email formatted for HTML.
		/// </summary>
		/// <param name="szToAddress">To Address</param>
		/// <param name="szSubject">Subject</param>
		/// <param name="szMessage">Message</param>
		static public void SendHtmlMail(string szToAddress,
										 string szSubject,
										 string szMessage) {
			SendMail(szToAddress,
				GetFromAddress(),
				szSubject,
				szMessage,
				true,
				null);
		}


		/// <summary>
		/// Sends email formatted for HTML.
		/// </summary>
		/// <param name="szToAddress">To Address</param>
		/// <param name="szSubject">Subject</param>
		/// <param name="szMessage">Message</param>
		/// <param name="oAttachments">List of MailAttachment objects</param>
		static public void SendHtmlMail(string szToAddress,
										string szSubject,
										string szMessage,
                                        List<Attachment> oAttachments)
        {
			SendMail(szToAddress,
					GetFromAddress(),
					szSubject,
					szMessage,
					true,
					oAttachments);
		}


		/// <summary>
		/// Sends email.
		/// </summary>
		/// <param name="szToAddress">To Address</param>
		/// <param name="szFromAddress">From Address</param>
		/// <param name="szSubject">Subject</param>
		/// <param name="szMessage">Message</param>
        /// <param name="bIsBodyHTML">Mail Format</param>
        /// <param name="oAttachments">List of Attachment objects</param>
		static public void SendMail(string szToAddress,
									string szFromAddress,
									string szSubject,
									string szMessage,
									bool bIsBodyHTML,
									List<Attachment> oAttachments) {

            MailMessage oMessage = new MailMessage();
            oMessage.From = new MailAddress(szFromAddress);

			if (Utilities.GetConfigValue("OverrideEmailAddress", "x") != "x")
				oMessage.To.Add(new MailAddress(Utilities.GetConfigValue("OverrideEmailAddress")));
			else
			{
				string[] aszToAddresses = szToAddress.Split(',');
				foreach (string szAddress in aszToAddresses)
				{
					oMessage.To.Add(new MailAddress(szAddress.Trim()));
				}
			}

            oMessage.Subject = szSubject;
            oMessage.Body = szMessage;
            oMessage.IsBodyHtml = bIsBodyHTML;

			if (Utilities.GetBoolConfigValue("EnabledBCCToFromAddress", false)) 
				oMessage.Bcc.Add(new MailAddress(GetFromAddress()));

            if (oAttachments != null)
            {
                foreach (Attachment attachment in oAttachments)
                {
                    oMessage.Attachments.Add(attachment);
                }
            }
            
			WriteMailToFile(oMessage);

			// If mail is disabled, then exit.
			if (!Utilities.GetBoolConfigValue("EmailEnabled"))
				return;

			SmtpClient oClient = new SmtpClient(Utilities.GetConfigValue("EMailSMTPServer"));
            oClient.Port = Utilities.GetIntConfigValue("EMailSMTPPort", 25);
            if (Utilities.GetBoolConfigValue("EMailSMTPServerAuthenticate", false))
            {
                oClient.UseDefaultCredentials = false;
                oClient.Credentials = new NetworkCredential(Utilities.GetConfigValue("EMailSMTPUserName"), Utilities.GetConfigValue("EMailSMTPPassword"));
            }

            oClient.EnableSsl = Utilities.GetBoolConfigValue("EmailSMTPEnableSSL", false);

            oClient.Send(oMessage);
		}

		/// <summary>
		/// Writes the contents of the email message
		/// to disk.
		/// </summary>
		/// <param name="oMessage">Message</param>
		static private void WriteMailToFile(MailMessage oMessage) {
			if (!Utilities.GetBoolConfigValue("EmailWriteToFileEnabled", false)) {
				return;
			}

            if (Utilities.GetBoolConfigValue("EmailWriteToFileEML", true))
            {
                SmtpClient client = new SmtpClient();
                client.DeliveryMethod = SmtpDeliveryMethod.SpecifiedPickupDirectory;
                client.PickupDirectoryLocation = Utilities.GetConfigValue("EmailFilePath");
                client.Send(oMessage);
                return;
            }


			string szFileName = Utilities.GetConfigValue("EmailFilePath") + DateTime.Now.ToString("yyyyMMdd_HHmmssff") + "_" + oMessage.To + "_" + oMessage.Subject;
			if (oMessage.IsBodyHtml) {
				szFileName += ".html";
			} else {
				szFileName += ".txt";
			}
			
			using (StreamWriter oEmailFile = new StreamWriter(szFileName)) {
				oEmailFile.Write(oMessage.Body);
			}
		}
	}
}
