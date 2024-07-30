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

 ClassName: DataSourceDownloadp.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace PRCo.EBB.BusinessObjects {
    /// <summary>
    /// Helper class that contains information about the file to download to
    /// make it easy to bind to UI controls.
    /// </summary>
    [Serializable]
    public class DownloadFile {

        private DateTime _dtFileDate;
        private string _szFileName;
        private string _szFileSize;
        private int _iIndex;

        public DateTime FileDate {
            get { return _dtFileDate; }
            set { _dtFileDate = value; }
        }
        public string FileName {
            get { return _szFileName; }
            set { _szFileName = value; }
        }

        public string FileSize {
            get { return _szFileSize; }
            set { _szFileSize = value; }
        }

        public int Index {
            get { return _iIndex; }
            set { _iIndex = value; }
        }
   
    }


    /// <summary>
    /// Helper class to sort our FileInfo array by
    /// date descending.
    /// </summary>
    public class CompareFileInfoEntries : IComparer {
        public int Compare(object oFileInfo1, object oFileInfo2) {
            // The objects are purposely reversed in order to sort
            // by date descending.
            return DateTime.Compare(((FileInfo)oFileInfo2).LastWriteTime, ((FileInfo)oFileInfo1).LastWriteTime);
        }
    }
    
}
