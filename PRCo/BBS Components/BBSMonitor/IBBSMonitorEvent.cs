/***********************************************************************
 Copyright Produce Reporter Company 2006-2007

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Program.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Text;
using System.Timers;

namespace PRCo.BBS.BBSMonitor {
    public interface IBBSMonitorEvent {

        BBSMonitor BBSMonitorService {
            get;
            set;
        }

        Timer EventTimer {
            get;
            set;
        }

        int EventIndex {
            get;
            set;
        }

        void Initialize(int iIndex);
        void ProcessTick(object sender, System.Timers.ElapsedEventArgs e);
        void ProcessEvent();

        void OnStart();
        void OnStop();

    }
}
