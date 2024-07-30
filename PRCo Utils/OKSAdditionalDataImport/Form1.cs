using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;


namespace OKSAdditionalDataImport
{
    public partial class Form1 : Form
    {
        protected Settings oSettings = new Settings();
        protected Cursor savedCursor;

        public Form1()
        {
            InitializeComponent();
        }

        private void btnSourceFile_Click(object sender, EventArgs e)
        {
            this.openFileDialog1.CheckFileExists = true;
            this.openFileDialog1.CheckPathExists = true;
            this.openFileDialog1.InitialDirectory = txtSourceFile.Text;
            this.openFileDialog1.Multiselect = false;
            this.openFileDialog1.Title = "Select the OKS source file.";
            this.openFileDialog1.ValidateNames = true;
            this.openFileDialog1.DefaultExt = "xls";
            this.openFileDialog1.Filter = "MS Excel 2003 Files (*.xls)|*.xls";

            DialogResult result = openFileDialog1.ShowDialog();
            if (result == DialogResult.OK)
            {
                txtSourceFile.Text = openFileDialog1.FileName;
            }
        }

        private void btnOutputFolder_Click(object sender, EventArgs e)
        {
            this.folderBrowserDialog1.SelectedPath = txtOutputFolder.Text;
            this.folderBrowserDialog1.Description = "Select the directory for the output.";
            this.folderBrowserDialog1.ShowNewFolderButton = true;

            DialogResult result = folderBrowserDialog1.ShowDialog();
            if (result == DialogResult.OK)
            {
                txtOutputFolder.Text = folderBrowserDialog1.SelectedPath;
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            if (File.Exists(Application.UserAppDataPath + "\\OKSImporterUISettings.dat"))
            {
                oSettings = (Settings)SaviorClass.Savior.ReadFromFile(Application.UserAppDataPath + "\\OKSImporterUISettings.dat");
            }
            else
            {
                InitializeSettings();
            }

            txtSourceFile.Text = oSettings.SourceFile;
            txtOutputFolder.Text = oSettings.OutputFolder;
            cbValidateOnly.Checked = oSettings.ValidateOnly;
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("Are you ready to exit the application?", "Confirm", MessageBoxButtons.OKCancel, MessageBoxIcon.Question) == DialogResult.OK)
            {
                SaveSettings();
                Application.Exit();
            }
        }

        private void InitializeSettings()
        {
            oSettings.OutputFolder = Application.StartupPath;
            oSettings.ValidateOnly = true;
        }


        private void SaveSettings()
        {
            oSettings.OutputFolder = txtOutputFolder.Text;
            oSettings.SourceFile = txtSourceFile.Text;
            oSettings.ValidateOnly = cbValidateOnly.Checked;

            SaviorClass.Savior.SaveToFile(oSettings, Application.UserAppDataPath + "\\OKSImporterUISettings.dat");
        }

        public void initProgressBar(int itemCount)
        {
            Invoke((MethodInvoker)delegate()
            {
                progressBar1.Maximum = itemCount;
                progressBar1.Value = 0;
                progressBar1.Step = 1;
                progressBar1.ForeColor = Color.White;
            }
            );
        }

        public void incrementProgressBar()
        {
            Invoke((MethodInvoker)delegate()
            {
                progressBar1.PerformStep();
                progressBar1.Text = progressBar1.Value.ToString() + " of " + progressBar1.Maximum.ToString();
            }
            );
        }

        public void displaySuccess(OKSImporter importer)
        {
            Invoke((MethodInvoker)delegate()
            {

                this.Cursor = savedCursor;

                string msg = null;

                if (importer.ErrorCount > 0)
                {
                    msg = "The import has completed with errors.  Please check the latest log file for details.\n\n";
                }
                else
                {
                    msg = "The import has completed successfully.\n\n";
                }


                msg += " - Company Count: " + importer.CompanyCount.ToString("###,##0") + "\n";
                msg += " - Skipped Company Count: " + importer.SkippedCount.ToString("###,##0") + "\n";
                msg += " - Emails Inserted: " + importer.EmailInsertedCount.ToString("###,##0") + "\n";
                msg += " - Products Inserted: " + importer.ProductInsertedCount.ToString("###,##0") + "\n";
                msg += " - Species Inserted: " + importer.SpecieInsertedCount.ToString("###,##0") + "\n";
                msg += " - Added Volume: " + importer.VolumeAddedCount.ToString("###,##0") + "\n";
                msg += " - Skipped Volume: " + importer.VolumeSkippedCount.ToString("###,##0") + "\n";


                //msg += " - Companess Inserted: " + importer.CompanyInsertedCount.ToString("###,##0") + "\n";

                if (importer.ErrorCount > 0)
                {
                    msg += " - Errors: " + importer.ErrorCount.ToString("###,##0") + "\n";
                }

                MessageBox.Show(msg, "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            );
        }

        public void handleException(Exception eX)
        {
            Invoke((MethodInvoker)delegate()
            {

                this.Cursor = savedCursor;


                MessageBox.Show(eX.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
             );
        }

        private void btnImport_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtOutputFolder.Text))
            {
                MessageBox.Show("Please specify an output folder.", "Missing Fields", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (string.IsNullOrEmpty(txtSourceFile.Text))
            {
                MessageBox.Show("Please specify a source file.", "Missing Fields", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }


            string msg = "The specified OKS data will be imported into";
            if (rbProduction.Checked)
            {
                msg += " PRODUCTION.";
            }
            else
            {
                msg += " TEST."; //  All pending published Credit Sheet items will be marked 'Killed'.";
            }

            if (cbValidateOnly.Checked)
            {
                msg += "  The data WILL NOT be saved, but the log files will be generated.";
            }
            else
            {
                msg += "  The data WILL be saved.";
            }

            msg += "\n\nAre you sure you want to continue?";
            if (MessageBox.Show(msg, "Confirm", MessageBoxButtons.OKCancel, MessageBoxIcon.Question) == DialogResult.OK)
            {
                try
                {
                    OKSImporter importer = new OKSImporter();
                    importer.OutputFolder = txtOutputFolder.Text;
                    importer.InputFile = txtSourceFile.Text;
                    importer.CommitChanges = !cbValidateOnly.Checked;

                    if (rbProduction.Checked)
                    {
                        importer.Destination = "Prod";
                    }
                    else
                    {
                        importer.Destination = "Test";
                    }

                    SaveSettings();

                    savedCursor = this.Cursor;
                    this.Cursor = Cursors.WaitCursor;

                    System.Threading.Thread thread = new System.Threading.Thread(new System.Threading.ParameterizedThreadStart(importer.ExecuteImport));
                    thread.Start(this);

                }
                catch (Exception eX)
                {
                    MessageBox.Show(eX.Message, "Unexpected Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }
    }

    /// <summary>
    /// Summary description for Settings.
    /// </summary>
    [Serializable]
    public class Settings
    {
        public string SourceFile;
        public string OutputFolder;
        public bool ValidateOnly;
    }
}
