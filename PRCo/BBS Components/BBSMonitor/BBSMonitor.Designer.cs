using System.Diagnostics;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor {
    partial class BBSMonitor {
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing) {
            if (disposing && (components != null)) {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent() {
            this._oEventLog = new System.Diagnostics.EventLog();
            ((System.ComponentModel.ISupportInitialize)(this._oEventLog)).BeginInit();
            // 
            // _oEventLog
            // 
            this._oEventLog.Log = "Application";
            this._oEventLog.Source = GetServiceName();
            // 
            // BBSMonitor
            // 
            this.ServiceName = GetServiceName();
            ((System.ComponentModel.ISupportInitialize)(this._oEventLog)).EndInit();

        }

        #endregion

        private EventLog _oEventLog;

        /// <summary>
        /// Returns the name of this service
        /// instance.
        /// </summary>
        /// <returns></returns>
        public static string GetServiceName() {
            return Utilities.GetConfigValue("ServiceName", "BBSMonitor");
        }
        
    }
}
