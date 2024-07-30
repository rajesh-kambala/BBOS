using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Web;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class SystemInfo : PageBase
    {
        //protected Table tblAppSettings;
        protected Table tblEnvironment;
        protected Table tblUsage;

        protected Label lblAssemblyVersion;
        protected Label lblAssemblyName;
        protected Table tblVersionInfo;

        protected Label lblTotalSessions;
        protected Label lblActiveSessions;
        protected Label lblMaxActiveSessions;
        protected Label lblActiveRequests;
        protected Label lblTotalRequests;
        protected Label lblMaxActiveRequests;

        protected Label lblAgentStatus;
        protected Label lblAgentInstantiate;
        protected Label lblAgentLastRun;
        protected Label lblAgentRunDuration;
        protected Label lblAgentRunCount;

        protected Label lblDBName;
        protected Label lblDBConnectString;
        protected Label lblDBTimeout;
        protected Label lblDataSource;
        protected Label lblPacketSize;
        protected Label lblServerVersion;
        protected Label lblWorkStationID;

        protected Label lblCommandLine;
        protected Label lblCurrentDirectory;
        protected Label lblCommandLineArgs;
        protected Label lblEnvironmentVariables;
        protected Label lblLogicalDrives;
        protected Label lblMachineName;
        protected Label lblOSVersion;
        protected Label lblSystemDirectory;
        protected Label lblTickCount;
        protected Label lblUserDomainName;
        protected Label lblUserName;
        protected Label lblVerison;
        protected Label lblWorkingSet;

        protected Label lblSystemUpTime;
        protected Label lblApplicationStart;
        protected Label lblApplicationUpTime;

        protected Repeater repSessionTracker;
        protected Table tblSessionTracker;
        protected Label lblSessionTrackerCount;

        protected HyperLink hlTraceFile;
        protected Label lblTraceFileCreated;
        protected Label lblTraceFileUpdated;
        protected Label lblTraceFileSize;

        protected LinkButton btnViewError;
        protected LinkButton btnViewTrace;
        protected LinkButton btnRenameTrace;
        protected LinkButton btnDeleteTrace;

        protected Table tblRefData;
        protected LinkButton btnResetRefData;

        protected GridView gvSessionTracker;
        protected Repeater repLookupCodes;

        /// <summary>
        /// Initializes the various controls when the page is loaded.  Fires
        /// before any event handlers.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, System.EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle("System Information");

            if (!IsPostBack)
            {
                try
                {
                    PerformanceCounter upTime = new PerformanceCounter("System", "System Up Time");
                    upTime.NextValue();
                    TimeSpan systemUpTime = TimeSpan.FromSeconds(upTime.NextValue());
                    lblSystemUpTime.Text = systemUpTime.Days.ToString() + " days, " +
                                           systemUpTime.Hours.ToString() + " hours, " +
                                           systemUpTime.Minutes.ToString() + " minutes ";
                } catch (Exception eX)
                {
                    lblSystemUpTime.Text = eX.Message;
                }

                if (HttpContext.Current.Cache["ApplicationStart"] == null)
                {
                    lblApplicationStart.Text = "Unknown";
                }
                else
                {
                    DateTime dtAppStart = (DateTime)HttpContext.Current.Cache["ApplicationStart"];
                    lblApplicationStart.Text = dtAppStart.ToString();
                    TimeSpan oAppUpTime = DateTime.Now.Subtract(dtAppStart);
                    lblApplicationUpTime.Text = oAppUpTime.Days + " days, " + oAppUpTime.Hours + " hours, " + oAppUpTime.Minutes + " minutes";
                }

                if (!IsPostBack)
                {
                    DisplayAppSettings();
                    DisplayUsageStats();
                    //DisplayDBInfo();
                    //DisplayEnviromentInfo();
                    //DisplayTraceFileInfo();

                    GetVersionInfo();
                    //DisplayRefData();
                    DisplayRefData2();
                    DisplaySessionTracker();
                }
            }
        }

        /// <summary>
        /// Determines if the current user has access
        /// to thi spage.
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.SystemAdmin).HasPrivilege;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        /// <summary>
        /// Displays information about the current trace file.
        /// </summary>
        protected void DisplayTraceFileInfo()
        {
            if ((!Utilities.GetBoolConfigValue("TraceEnabled")) ||
                (!File.Exists(Utilities.GetConfigValue("TraceFileName"))))
            {
                btnViewError.Enabled = false;
                btnViewTrace.Enabled = false;
                btnRenameTrace.Enabled = false;
                btnDeleteTrace.Enabled = false;
                lblTraceFileCreated.Text = "&nbsp;";
                lblTraceFileUpdated.Text = "&nbsp;";
                lblTraceFileSize.Text = "&nbsp;";
                return;
            }

            FileInfo oFileInfo = new FileInfo(Utilities.GetConfigValue("TraceFileName"));
            if (oFileInfo == null)
            {
                lblTraceFileCreated.Text = "&nbsp;";
                lblTraceFileUpdated.Text = "&nbsp;";
                lblTraceFileSize.Text = "&nbsp;";
            }
            else
            {
                lblTraceFileCreated.Text = oFileInfo.CreationTime.ToString();
                lblTraceFileUpdated.Text = oFileInfo.LastWriteTime.ToString();
                lblTraceFileSize.Text = GetFileSize(oFileInfo.Length);
            }

            if (!File.Exists(Utilities.GetConfigValue("TraceErrorFileName")))
            {
                btnViewError.Enabled = false;
            }

            btnRenameTrace.Attributes.Add("onclick", "return Confirm('rename');");
            btnDeleteTrace.Attributes.Add("onclick", "return Confirm('delete');");
            btnViewTrace.Attributes.Add("onclick", "openTraceWindow('" + GetVirtualPath() + Utilities.GetConfigValue("TraceFileHTTPPath") + "')");
            btnViewError.Attributes.Add("onclick", "openTraceWindow('" + GetVirtualPath() + Utilities.GetConfigValue("TraceErrorFileHTTPPath") + "')");
        }

        /// <summary>
        /// Renames the trace file.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void RenameFile(Object sender, EventArgs e)
        {
            if ((!Utilities.GetBoolConfigValue("TraceEnabled")) ||
                (!File.Exists(Utilities.GetConfigValue("TraceFileName"))))
            {
                AddUserMessage("Unable to rename file - Tracing not enabled or file does not exist.");
                return;
            }

            //First let's create a new file name.
            string szNewFileName = null;
            string szNewFullFileName = null;
            szNewFileName = Path.GetFileNameWithoutExtension(Utilities.GetConfigValue("TraceFileName"));
            szNewFileName += DateTime.Now.ToString("_yyyyMMdd_HHmmss") + ".txt";
            szNewFullFileName = Path.GetDirectoryName(Utilities.GetConfigValue("TraceFileName")) + "\\" + szNewFileName;
            File.Move(Utilities.GetConfigValue("TraceFileName"), szNewFullFileName);

            AddUserMessage("Successfully renamed trace file to \"" + szNewFileName + "\".");
            DisplayTraceFileInfo();
        }

        /// <summary>
        /// Deletes the Trace file.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void DeleteFile(Object sender, EventArgs e)
        {
            if ((!Utilities.GetBoolConfigValue("TraceEnabled")) ||
                (!File.Exists(Utilities.GetConfigValue("TraceFileName"))))
            {
                AddUserMessage("Unable to delete file - Tracing not enabled or file does not exist.");
                return;
            }

            File.Delete(Utilities.GetConfigValue("TraceFileName"));
            AddUserMessage("Successfully deleted trace.");
            DisplayTraceFileInfo();
        }

        /// <summary>
        /// Returns the file size in a formatted string.
        /// </summary>
        /// <param name="lFileSize">FileSize</param>
        /// <returns></returns>
        protected string GetFileSize(long lFileSize)
        {
            decimal dSize = 0.0M;
            dSize = lFileSize;

            // Gets a NumberFormatInfo associated with the en-US culture.
            //NumberFormatInfo nfi = new CultureInfo( "en-US", false ).NumberFormat;

            //MB
            if (lFileSize > (1024 * 1024))
            {
                dSize = (dSize / (1024 * 1024));
                return dSize.ToString("N") + " MB";
            }

            if (lFileSize > (1024))
            {
                dSize = (dSize / (1024));
                return dSize.ToString("N") + " KB";
            }

            return lFileSize.ToString() + " B";
        }

        /// <summary>
        /// Writes the application settings found in
        /// the configuration settings.
        /// </summary>
        protected void DisplayAppSettings()
        {
            string szKey = null;
            string szValue = null;

            TableCell oLabel = null;
            TableCell oValue = null;
            TableRow oRow = null;

            IEnumerator oEnum = ConfigurationManager.AppSettings.Keys.GetEnumerator();
            while (oEnum.MoveNext())
            {
                szKey = (string)oEnum.Current;
                szValue = (string)ConfigurationManager.AppSettings[szKey];

                oLabel = new TableCell();
                oLabel.CssClass = "rowHeader";
                oLabel.Text = szKey + ":";

                oValue = new TableCell();
                oValue.Text = HttpUtility.HtmlEncode(szValue);

                oRow = new TableRow();
                oRow.Cells.Add(oLabel);
                oRow.Cells.Add(oValue);

                /*
                if (tblAppSettings.Rows.Count % 2 == 0)
                {
                    oRow.CssClass = "shaderow";
                }

                tblAppSettings.Rows.Add(oRow);
                */
            }
        }

        /// <summary>
        /// Displays the usage statistics based on data
        /// in the cache.
        /// </summary>
        protected void DisplayUsageStats()
        {
            /*
			lblTotalSessions.Text		= Cache["TotalSessions"].ToString();
			lblActiveSessions.Text		= Cache["ActiveSessions"].ToString();
			lblMaxActiveSessions.Text	= Cache["MaxActiveSessions"].ToString();
			lblActiveRequests.Text		= Cache["ActiveRequests"].ToString();
			lblTotalRequests.Text		= Cache["TotalRequests"].ToString();
			lblMaxActiveRequests.Text	= Cache["MaxActiveRequests"].ToString();
			*/
        }

        /// <summary>
        /// Displays database connection information
        /// </summary>
        protected void DisplayDBInfo()
        {
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDbConnection oConn = oDBAccess.Open();

            lblDBName.Text = oConn.Database;
            lblDBConnectString.Text = oConn.ConnectionString;
            lblDBTimeout.Text = oConn.ConnectionTimeout.ToString();

            SqlConnection oSQLConn = (SqlConnection)oConn;
            lblDataSource.Text = oSQLConn.DataSource;
            lblPacketSize.Text = oSQLConn.PacketSize.ToString();
            lblServerVersion.Text = oSQLConn.ServerVersion;
            lblWorkStationID.Text = oSQLConn.WorkstationId;

            oConn.Close();
        }

        /// <summary>
        /// Displays OS environment information.
        /// </summary>
        protected void DisplayEnviromentInfo()
        {
            lblCommandLine.Text = System.Environment.CommandLine;
            lblCurrentDirectory.Text = System.Environment.CurrentDirectory;

            bool bDelimit = false;
            foreach (string szArg in System.Environment.GetCommandLineArgs())
            {
                if (bDelimit)
                {
                    lblCommandLineArgs.Text += ", ";
                }
                else
                {
                    bDelimit = true;
                }
                lblCommandLineArgs.Text += szArg;
            }

            IDictionary environmentVariables = System.Environment.GetEnvironmentVariables();
            foreach (DictionaryEntry de in environmentVariables)
            {
                lblEnvironmentVariables.Text += de.Key + " = " + de.Value + "<br>";
            }

            lblMachineName.Text = System.Environment.MachineName;
            lblOSVersion.Text = System.Environment.OSVersion.ToString();
            lblSystemDirectory.Text = System.Environment.SystemDirectory;
            lblTickCount.Text = System.Environment.TickCount.ToString();
            lblUserDomainName.Text = System.Environment.UserDomainName;
            lblUserName.Text = System.Environment.UserName;
            lblVerison.Text = System.Environment.Version.ToString();
            lblWorkingSet.Text = System.Environment.WorkingSet.ToString();
        }

        /// <summary>
        /// Displays the versions for the specified
        /// assemblies.
        /// </summary>
        protected void GetVersionInfo()
        {
            if (tblVersionInfo.Rows.Count > 0)
                return;

            DisplayAssemblyInfo("BBOS Version:", new PageConstants());
            DisplayAssemblyInfo("Framework Version:", new PRWebUser());
            
            string szCRMVersion = GetReferenceValue("CRMBuildNumber", "1");

            TableRow oRow = new TableRow();
            TableCell oNameCell = new TableCell();
            oRow.Cells.Add(oNameCell);
            oNameCell.CssClass = "rowHeader";
            oNameCell.Text = "CRM Version:";

            TableCell oVersionCell = new TableCell();
            oRow.Cells.Add(oVersionCell);
            oVersionCell.Text = szCRMVersion;

            if (tblVersionInfo.Rows.Count % 2 == 0)
                oRow.CssClass = "shaderow";

            tblVersionInfo.Rows.Add(oRow);


            DisplayAssemblyInfo("Travant Framework Version:", new TSI.BusinessObjects.SortCriterion());

            oRow = new TableRow();
            oNameCell = new TableCell();
            oRow.Cells.Add(oNameCell);
            oNameCell.CssClass = "rowHeader";
            oNameCell.Text = ".NET Framework Version:";

            oVersionCell = new TableCell();
            oRow.Cells.Add(oVersionCell);
            oVersionCell.Text = System.Environment.Version.ToString(); 

            if (tblVersionInfo.Rows.Count % 2 == 0)
                oRow.CssClass = "shaderow";

            tblVersionInfo.Rows.Add(oRow);
        }

        /// <summary>
        /// Obtains the version info for the specified
        /// class.
        /// </summary>
        /// <param name="oObject"></param>
        private void DisplayAssemblyInfo(string name, object oObject)
        {
            System.Reflection.AssemblyName oAssName = oObject.GetType().Assembly.GetName();

            TableRow oRow = new TableRow();
            TableCell oNameCell = new TableCell();
            oRow.Cells.Add(oNameCell);
            oNameCell.CssClass = "rowHeader";
            oNameCell.Text = name;
            oNameCell.Attributes.Add("width", "250");

            TableCell oVersionCell = new TableCell();
            oRow.Cells.Add(oVersionCell);
            oVersionCell.Text = oAssName.Version.ToString();

            if (tblVersionInfo.Rows.Count % 2 == 0)
            {
                oRow.CssClass = "shaderow";
            }

            tblVersionInfo.Rows.Add(oRow);
        }

        private void DisplayRefData2()
        {
            IList<string> keys = new List<string>();
            IDictionaryEnumerator oEnum = HttpRuntime.Cache.GetEnumerator();

            while (oEnum.MoveNext())
            {
                if (oEnum.Key != null)
                {
                    string szKey = (string)oEnum.Key;
                    if (szKey.StartsWith(REF_DATA_PREFIX))
                    {
                        keys.Add(szKey);
                    }
                }
            }

            repLookupCodes.DataSource = keys;
            repLookupCodes.DataBind();
        }

        protected string GetDisplayName(string key)
        {
            string temp = key;
            if (temp.StartsWith(REF_DATA_PREFIX))
            {
                temp = temp.Substring(REF_DATA_PREFIX.Length + 1);
            }

            if (temp.EndsWith("_en-us"))
            {
                temp = temp.Substring(0, temp.Length - 6);
            }
            return temp;
        }

        protected IBusinessObjectSet GetLookupCodes(string key)
        {
            if (HttpRuntime.Cache[key] == null)
            {
                return new BusinessObjectSet();
            }

            Object cachedData = HttpRuntime.Cache[key];
            if (cachedData is IBusinessObjectSet)
            {
                return (IBusinessObjectSet)cachedData;
            }
            return new BusinessObjectSet();
        }

        /// <summary>
        /// Removes all reference data from the cache.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void ResetRefData(Object sender, EventArgs e)
        {
            IDictionaryEnumerator oEnum = HttpContext.Current.Cache.GetEnumerator();
            while (oEnum.MoveNext())
            {
                string szKey = (string)oEnum.Key;
                if (szKey.StartsWith(REF_DATA_PREFIX))
                {
                    HttpRuntime.Cache.Remove(szKey);
                }
            }

            Session["szUserMessage"] = "Successfully reset reference data.";
            Response.Redirect("SystemInfo.aspx");
        }

        /// <summary>
        /// Displays all reference data currently
        /// cached in memory.
        /// </summary>
        private void DisplaySessionTracker()
        {
            Hashtable htSessionTracker = (Hashtable)Application[PageConstants.SESSION_TRACKER];
            if (htSessionTracker == null)
            {
                return;
            }

            List<SessionTracker> lSessionTracker = new List<SessionTracker>();
            IDictionaryEnumerator oEnum = htSessionTracker.GetEnumerator();
            while (oEnum.MoveNext())
            {
                lSessionTracker.Add((SessionTracker)oEnum.Value);
            }

            lSessionTracker.Sort(new SessionTrackerComparer(GetSortField(gvSessionTracker), GetSortAsc(gvSessionTracker)));

            gvSessionTracker.DataSource = lSessionTracker;
            gvSessionTracker.DataBind();
            EnableBootstrapFormatting(gvSessionTracker);

            lblSessionTrackerCount.Text = lSessionTracker.Count.ToString("###,##0") + " sessions found.";
        }

        /// <summary>
        /// Removes all reference data from the cache.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void RemoveSessionTracker(Object sender, EventArgs e)
        {
            string szIDs = GetRequestParameter("cbSessionTracker", false);
            if (string.IsNullOrEmpty(szIDs))
            {
                return;
            }

            string[] aszSessionIDs = szIDs.Split(',');
            foreach (string szID in aszSessionIDs)
            {
                RemoveSessionTracker(Convert.ToInt32(szID));
            }

            Session["szUserMessage"] = "Removed " + aszSessionIDs.Length.ToString() + " session trackers.";
            Response.Redirect("SystemInfo.aspx");
        }

        protected void gvSession_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            DisplaySessionTracker();
        }

        #region Web Form Designer generated code
        override protected void OnInit(EventArgs e)
        {
            //
            // CODEGEN: This call is required by the ASP.NET Web Form Designer.
            //
            InitializeComponent();
            base.OnInit(e);
        }

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.Load += new System.EventHandler(this.Page_Load);
        }
        #endregion
    }

    class SessionTrackerComparer : IComparer<SessionTracker>
    {
        private string _sortField = "LastRequest";
        private bool _sortAsc = false;

        public SessionTrackerComparer()
        {
        }

        public SessionTrackerComparer(string sortField, bool sortAsc)
        {
            _sortField = sortField;
            _sortAsc = sortAsc;
        }

        public int Compare(SessionTracker Session1, SessionTracker Session2)
        {
            switch (_sortField)
            {
                default:
                    if (_sortAsc)
                    {
                        return Session1.LastRequest.CompareTo(Session2.LastRequest);
                    }
                    else
                    {
                        return Session2.LastRequest.CompareTo(Session1.LastRequest);
                    }

                case "PageCount":
                    if (_sortAsc)
                    {
                        return Session1.PageCount.CompareTo(Session2.PageCount);
                    }
                    else
                    {
                        return Session2.PageCount.CompareTo(Session1.PageCount);
                    }

                case "FirstAccess":
                    if (_sortAsc)
                    {
                        return Session1.FirstAccess.CompareTo(Session2.FirstAccess);
                    }
                    else
                    {
                        return Session2.FirstAccess.CompareTo(Session1.FirstAccess);
                    }

                case "Email":
                    if (_sortAsc)
                    {
                        return Session1.Email.CompareTo(Session2.Email);
                    }
                    else
                    {
                        return Session2.Email.CompareTo(Session1.Email);
                    }

                case "Expiration":
                    if (_sortAsc)
                    {
                        return Session1.Expiration.CompareTo(Session2.Expiration);
                    }
                    else
                    {
                        return Session2.Expiration.CompareTo(Session1.Expiration);
                    }

                case "UserID":
                    if (_sortAsc)
                    {
                        return Session1.UserID.CompareTo(Session2.UserID);
                    }
                    else
                    {
                        return Session2.UserID.CompareTo(Session1.UserID);
                    }
            }

            //return 0;
        }
    }
}