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
using System.Data.SqlClient;
using System.IO;

namespace BBSI.CRM
{
    public class EmailImage : CRMBase
    {
        public override void BuildContents()
        {
            bDebug = false;

            try
            {
                SetRequestName("EmailImage");

                AddContent(HTML.Form());
                AddContent("<script type='text/javascript' src='/crm/CustomPages/TravantCRMScripts/EmailImage.js'></script>");

                string prei_EmailImageID = Dispatch.QueryField("prei_EmailImageID");
                string HiddenIsNewFile = Dispatch.EitherField("HiddenIsNewFile");
                if (HiddenIsNewFile == null)
                    HiddenIsNewFile = "";

                string hMode = Dispatch.EitherField("HiddenMode");
                DEBUG("hMode", hMode, false);

                Record recEmailImage = null;
                if (prei_EmailImageID == "0")
                {
                    switch(hMode)
                    {
                        case "Save":
                            recEmailImage = new Record("PREmailImages");
                            break;
                        
                        default:
                            hMode = "Change";
                            break;
                    }
                }
                else
                    recEmailImage = FindRecord("PREmailImages", "prei_EmailImageID = " + prei_EmailImageID);

                if (hMode == "Delete")
                {
                    recEmailImage.DeleteRecord = true;
                    recEmailImage.SaveChanges();

                    Dispatch.Redirect(UrlDotNet(ThisDotNetDll, "RunEmailImageListing"));
                    return;
                }

                EntryGroup screenEmailImage = new EntryGroup("PREmailImage");
                screenEmailImage[3].ReadOnly = true; //Email Image URL readonly

                if (hMode == "Save")
                {
                    screenEmailImage.Fill(recEmailImage);
                    recEmailImage.SaveChanges();


                    if (HiddenIsNewFile != "")
                    {
                        ProcessFile(recEmailImage);
                    }

                    Dispatch.Redirect(UrlDotNet(ThisDotNetDll, "RunEmailImageListing"));
                    return;
                }

                if (string.IsNullOrEmpty(hMode))
                {
                    hMode = "View";
                }

                screenEmailImage.Title = "Email Image Details";

                if (hMode == "Change")
                {
                    if (prei_EmailImageID == "0")
                        screenEmailImage.GetHtmlInEditMode();
                    else
                        screenEmailImage.GetHtmlInEditMode(recEmailImage);
                }
                else if (hMode == "View")
                {
                    screenEmailImage.GetHtmlInViewMode(recEmailImage);
                }

                VerticalPanel vpMainPanel = new VerticalPanel();
                vpMainPanel.AddAttribute("width", "100%");
                vpMainPanel.Add(screenEmailImage);
                AddContent(vpMainPanel);

                AddContent(HTML.InputHidden("HiddenMode", string.Empty));
                AddContent(HTML.InputHidden("HiddenIsNewFile", HiddenIsNewFile));

                if(hMode == "Change")
                    AddButtonContent(BuildDragAndDrop_SimpleDragDroppedCallback());

                if (prei_EmailImageID != "0")
                {
                    string szEmailType = GetCustomCaptionValue("Choices", "prei_EmailTypeCode", recEmailImage.GetFieldAsString("prei_emailtypecode"));
                    string targetFolder = string.Format("{0}Campaigns/{1}/{2}", GetBBOSURL(), szEmailType, prei_EmailImageID);
                    string targetFile = string.Format(@"{0}/{1}", targetFolder, recEmailImage.GetFieldAsString("prei_EmailImgDiskFileName"));

                    AddContent($"<div style='margin:3px; width:100%'><img style='max-width:500px' src='{targetFile}'></div>"); ;
                }

                //Add Buttons
                if (hMode == "View")
                {
                    AddUrlButton("Change", "Save.gif", "javascript:change_button();");
                    AddUrlButton("Delete", "Save.gif", "javascript:delete_button();");
                    AddUrlButton("Cancel", "cancel.gif", UrlDotNet(ThisDotNetDll, "RunEmailImageListing"));
                }
                else if (hMode == "Change")
                {
                    AddUrlButton("Save", "Save.gif", "javascript:save_button();");
                    if(prei_EmailImageID == "0")
                        AddUrlButton("Cancel", "cancel.gif", UrlDotNet(ThisDotNetDll, "RunEmailImageListing"));
                    else
                        AddUrlButton("Cancel", "cancel.gif", "javascript:cancel_button();");
                }
            }
            catch (Exception eX)
            {
                TravantLogMessage(eX.Message);
                AddContent(HandleException(eX));
            }
        }

        private void ProcessFile(Record recEmailImage)
        {
            string prei_EmailImgFileName = Dispatch.EitherField("_HIDDENprei_emailimgfilename");
            string prei_EmailImgDiskFileName = prei_EmailImgFileName;

            if (!string.IsNullOrEmpty(prei_EmailImgDiskFileName))
            {
                string szEmailType = GetCustomCaptionValue("Choices", "prei_EmailTypeCode", recEmailImage.GetFieldAsString("prei_emailtypecode"));
                string szEmailImageID = recEmailImage.GetFieldAsString("prei_EmailImageID");

                // Move our file from the temp area to the email image area
                string sourceFile = Path.Combine(TEMP_FILE_PATH, prei_EmailImgFileName); //Changed from c:\\temp to TEMP_FILE_PATH

                //string targetFolder = Path.Combine(GetBBOSAdRootDir(), szEmailType, szEmailImageID);
                string targetFolder = Path.Combine(TEMP_FILE_PATH, szEmailType, szEmailImageID);

                //CHW created a BBSMonitor process FileMoveEvent that moves the files every 5 minutes, to circumvent a QA file permissions issue creating the folders at runtime
                //Be sure folder structure in D:\Applications\CRM\WWWRoot\TempReports\Alerts is up to date to be moved every 5 minutes
                //FileMoveEvent.cs does the move
                string szMovedFileName = MoveFile(sourceFile, targetFolder, bForceUniqueFileName:false, bDebug:true); 

                recEmailImage.SetField("prei_EmailImgDiskFileName", szMovedFileName);
                recEmailImage.SaveChanges();
            }
        }

        public string GetBBOSAdRootDir()
        {
            var szRootDir = GetCustomCaptionValue("Choices", "PRCompanyAdUploadDirectory", "/Campaigns"); //     \\AZ-NC-BBOS-Q1\Campaigns

            if ((!szRootDir.EndsWith(@"\")))
            {
                szRootDir += @"\";
            }

            return szRootDir;
        }
    }
}