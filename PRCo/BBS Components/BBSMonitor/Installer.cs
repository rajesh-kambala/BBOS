using System;
using System.Collections;
using System.ComponentModel;
using System.Configuration.Install;

namespace PRCo.BBS.BBSMonitor {
    [RunInstaller(true)]
    public partial class Installer : System.Configuration.Install.Installer {

        private System.ServiceProcess.ServiceProcessInstaller serviceProcessInstaller1;
        private System.ServiceProcess.ServiceInstaller serviceInstaller1;

        public Installer() {
            InitializeComponent();
        }

        /// <summary>
        /// Looks for the ServiceName command line parameter to name this
        /// instance of the service.  If not specified, uses BBS Monitor Service.
        /// </summary>
        /// <param name="savedState"></param>
        protected override void OnBeforeInstall(IDictionary savedState) {
            base.OnBeforeInstall(savedState);

            string szName = Context.Parameters["ServiceName"];
            if ((szName == null) ||
                (szName.Length == 0)) {
                szName = "BBSMonitor";
            }

            serviceInstaller1.ServiceName = szName;
        }

        /// <summary>
        /// Looks for the ServiceName command line parameter to name this
        /// instance of the service.  If not specified, uses BBS Monitor Service.
        /// </summary>
        /// <param name="savedState"></param>
        protected override void OnBeforeUninstall(IDictionary savedState) {
            base.OnBeforeUninstall(savedState);

            string szName = Context.Parameters["ServiceName"];
            if ((szName == null) ||
                (szName.Length == 0)) {
                szName = "BBSMonitor";
            }

            serviceInstaller1.ServiceName = szName;
        }

        private void serviceInstaller1_AfterInstall(object sender, InstallEventArgs e) {

        }
    }
}