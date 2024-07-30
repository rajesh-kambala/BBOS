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

 ClassName: PRPublicationTopic.ascx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace PRCo.EBB.BusinessObjects {

    /// <summary>
    /// Helper class that contains PRPublicationArticle data 
    /// </summary>
    [Serializable]
    public class PRPublicationTopic {
            protected string _szName;
            protected int _iLevel;
            protected int _iParentID;
            protected int _iID;
            protected int _iIndex;
            protected bool _bChecked;

            public PRPublicationTopic(int iID, string szName, int iLevel, int iParentID) {
                _szName = szName;
                _iLevel = iLevel;
                _iParentID = iParentID;
                _iID = iID;
            }

            public string Name {
                get { return _szName; }
                set { _szName = value; }
            }

            public int Level {
                get { return _iLevel; }
                set { _iLevel = value; }
            }

            public int ID {
                get { return _iID; }
                set { _iID = value; }
            }

            public int ParentID {
                get { return _iParentID; }
                set { _iParentID = value; }
            }

            public int Index {
                get { return _iIndex; }
                set { _iIndex = value; }
            }

            public bool IsChecked {
                get { return _bChecked; }
                set { _bChecked = value; }
            }

            public string Checked {
                get {
                    if (_bChecked) {
                        return " checked ";
                    } else {
                        return string.Empty;
                    }
                }
            }
     
    }
}
