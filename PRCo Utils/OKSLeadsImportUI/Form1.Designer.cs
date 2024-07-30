namespace OKSLeadsImportUI
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.rbProduction = new System.Windows.Forms.RadioButton();
            this.rbTest = new System.Windows.Forms.RadioButton();
            this.txtSourceFile = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.btnSourceFile = new System.Windows.Forms.Button();
            this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            this.label2 = new System.Windows.Forms.Label();
            this.txtOutputFolder = new System.Windows.Forms.TextBox();
            this.btnOutputFolder = new System.Windows.Forms.Button();
            this.folderBrowserDialog1 = new System.Windows.Forms.FolderBrowserDialog();
            this.btnExit = new System.Windows.Forms.Button();
            this.btnImport = new System.Windows.Forms.Button();
            this.progressBar1 = new OKSLeadsImportUI.TextProgressBar();
            this.cbValidateOnly = new System.Windows.Forms.CheckBox();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.rbProduction);
            this.groupBox1.Controls.Add(this.rbTest);
            this.groupBox1.Location = new System.Drawing.Point(20, 90);
            this.groupBox1.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Padding = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.groupBox1.Size = new System.Drawing.Size(184, 57);
            this.groupBox1.TabIndex = 0;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Import Destination";
            // 
            // rbProduction
            // 
            this.rbProduction.AutoSize = true;
            this.rbProduction.Location = new System.Drawing.Point(79, 23);
            this.rbProduction.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.rbProduction.Name = "rbProduction";
            this.rbProduction.Size = new System.Drawing.Size(129, 26);
            this.rbProduction.TabIndex = 1;
            this.rbProduction.TabStop = true;
            this.rbProduction.Text = "Production";
            this.rbProduction.UseVisualStyleBackColor = true;
            // 
            // rbTest
            // 
            this.rbTest.AutoSize = true;
            this.rbTest.Location = new System.Drawing.Point(8, 23);
            this.rbTest.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.rbTest.Name = "rbTest";
            this.rbTest.Size = new System.Drawing.Size(76, 26);
            this.rbTest.TabIndex = 0;
            this.rbTest.TabStop = true;
            this.rbTest.Text = "Test";
            this.rbTest.UseVisualStyleBackColor = true;
            // 
            // txtSourceFile
            // 
            this.txtSourceFile.Location = new System.Drawing.Point(120, 26);
            this.txtSourceFile.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.txtSourceFile.Name = "txtSourceFile";
            this.txtSourceFile.Size = new System.Drawing.Size(548, 22);
            this.txtSourceFile.TabIndex = 1;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(16, 34);
            this.label1.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(83, 17);
            this.label1.TabIndex = 2;
            this.label1.Text = "Source File:";
            // 
            // btnSourceFile
            // 
            this.btnSourceFile.Location = new System.Drawing.Point(673, 22);
            this.btnSourceFile.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnSourceFile.Name = "btnSourceFile";
            this.btnSourceFile.Size = new System.Drawing.Size(36, 28);
            this.btnSourceFile.TabIndex = 3;
            this.btnSourceFile.Text = "...";
            this.btnSourceFile.UseVisualStyleBackColor = true;
            this.btnSourceFile.Click += new System.EventHandler(this.btnSourceFile_Click);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(16, 63);
            this.label2.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(99, 17);
            this.label2.TabIndex = 4;
            this.label2.Text = "Output Folder:";
            // 
            // txtOutputFolder
            // 
            this.txtOutputFolder.Location = new System.Drawing.Point(120, 58);
            this.txtOutputFolder.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.txtOutputFolder.Name = "txtOutputFolder";
            this.txtOutputFolder.Size = new System.Drawing.Size(548, 22);
            this.txtOutputFolder.TabIndex = 5;
            // 
            // btnOutputFolder
            // 
            this.btnOutputFolder.Location = new System.Drawing.Point(672, 58);
            this.btnOutputFolder.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnOutputFolder.Name = "btnOutputFolder";
            this.btnOutputFolder.Size = new System.Drawing.Size(37, 28);
            this.btnOutputFolder.TabIndex = 6;
            this.btnOutputFolder.Text = "...";
            this.btnOutputFolder.UseVisualStyleBackColor = true;
            this.btnOutputFolder.Click += new System.EventHandler(this.btnOutputFolder_Click);
            // 
            // btnExit
            // 
            this.btnExit.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnExit.Location = new System.Drawing.Point(609, 165);
            this.btnExit.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnExit.Name = "btnExit";
            this.btnExit.Size = new System.Drawing.Size(100, 28);
            this.btnExit.TabIndex = 7;
            this.btnExit.Text = "Exit";
            this.btnExit.UseVisualStyleBackColor = true;
            this.btnExit.Click += new System.EventHandler(this.btnExit_Click);
            // 
            // btnImport
            // 
            this.btnImport.Location = new System.Drawing.Point(501, 165);
            this.btnImport.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnImport.Name = "btnImport";
            this.btnImport.Size = new System.Drawing.Size(100, 28);
            this.btnImport.TabIndex = 8;
            this.btnImport.Text = "Import";
            this.btnImport.UseVisualStyleBackColor = true;
            this.btnImport.Click += new System.EventHandler(this.btnImport_Click);
            // 
            // progressBar1
            // 
            this.progressBar1.Location = new System.Drawing.Point(20, 148);
            this.progressBar1.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.progressBar1.Name = "progressBar1";
            this.progressBar1.Size = new System.Drawing.Size(473, 46);
            this.progressBar1.TabIndex = 9;
            // 
            // cbValidateOnly
            // 
            this.cbValidateOnly.AutoSize = true;
            this.cbValidateOnly.Location = new System.Drawing.Point(244, 113);
            this.cbValidateOnly.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.cbValidateOnly.Name = "cbValidateOnly";
            this.cbValidateOnly.Size = new System.Drawing.Size(241, 21);
            this.cbValidateOnly.TabIndex = 10;
            this.cbValidateOnly.Text = "Validate Only - Do Not Save Data";
            this.cbValidateOnly.UseVisualStyleBackColor = true;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnExit;
            this.ClientSize = new System.Drawing.Size(717, 200);
            this.Controls.Add(this.cbValidateOnly);
            this.Controls.Add(this.progressBar1);
            this.Controls.Add(this.btnImport);
            this.Controls.Add(this.btnExit);
            this.Controls.Add(this.btnOutputFolder);
            this.Controls.Add(this.txtOutputFolder);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.btnSourceFile);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.txtSourceFile);
            this.Controls.Add(this.groupBox1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.MaximizeBox = false;
            this.MaximumSize = new System.Drawing.Size(735, 245);
            this.MinimizeBox = false;
            this.MinimumSize = new System.Drawing.Size(735, 245);
            this.Name = "Form1";
            this.Text = "OKS Data Importer";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.Form1_FormClosing);
            this.Load += new System.EventHandler(this.Form1_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.RadioButton rbProduction;
        private System.Windows.Forms.RadioButton rbTest;
        private System.Windows.Forms.TextBox txtSourceFile;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button btnSourceFile;
        private System.Windows.Forms.OpenFileDialog openFileDialog1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox txtOutputFolder;
        private System.Windows.Forms.Button btnOutputFolder;
        private System.Windows.Forms.FolderBrowserDialog folderBrowserDialog1;
        private System.Windows.Forms.Button btnExit;
        private System.Windows.Forms.Button btnImport;
        private TextProgressBar progressBar1;
        private System.Windows.Forms.CheckBox cbValidateOnly;
    }
}

