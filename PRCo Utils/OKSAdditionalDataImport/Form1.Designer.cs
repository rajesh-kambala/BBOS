namespace OKSAdditionalDataImport
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
            this.btnImport = new System.Windows.Forms.Button();
            this.btnExit = new System.Windows.Forms.Button();
            this.btnOutputFolder = new System.Windows.Forms.Button();
            this.txtOutputFolder = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.btnSourceFile = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.txtSourceFile = new System.Windows.Forms.TextBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.rbProduction = new System.Windows.Forms.RadioButton();
            this.rbTest = new System.Windows.Forms.RadioButton();
            this.progressBar1 = new System.Windows.Forms.ProgressBar();
            this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            this.folderBrowserDialog1 = new System.Windows.Forms.FolderBrowserDialog();
            this.cbValidateOnly = new System.Windows.Forms.CheckBox();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnImport
            // 
            this.btnImport.Location = new System.Drawing.Point(375, 125);
            this.btnImport.Name = "btnImport";
            this.btnImport.Size = new System.Drawing.Size(75, 23);
            this.btnImport.TabIndex = 17;
            this.btnImport.Text = "Import";
            this.btnImport.UseVisualStyleBackColor = true;
            this.btnImport.Click += new System.EventHandler(this.btnImport_Click);
            // 
            // btnExit
            // 
            this.btnExit.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnExit.Location = new System.Drawing.Point(456, 125);
            this.btnExit.Name = "btnExit";
            this.btnExit.Size = new System.Drawing.Size(75, 23);
            this.btnExit.TabIndex = 16;
            this.btnExit.Text = "Exit";
            this.btnExit.UseVisualStyleBackColor = true;
            this.btnExit.Click += new System.EventHandler(this.btnExit_Click);
            // 
            // btnOutputFolder
            // 
            this.btnOutputFolder.Location = new System.Drawing.Point(503, 38);
            this.btnOutputFolder.Name = "btnOutputFolder";
            this.btnOutputFolder.Size = new System.Drawing.Size(28, 23);
            this.btnOutputFolder.TabIndex = 15;
            this.btnOutputFolder.Text = "...";
            this.btnOutputFolder.UseVisualStyleBackColor = true;
            this.btnOutputFolder.Click += new System.EventHandler(this.btnOutputFolder_Click);
            // 
            // txtOutputFolder
            // 
            this.txtOutputFolder.Location = new System.Drawing.Point(89, 38);
            this.txtOutputFolder.Name = "txtOutputFolder";
            this.txtOutputFolder.Size = new System.Drawing.Size(412, 20);
            this.txtOutputFolder.TabIndex = 14;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(11, 42);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(74, 13);
            this.label2.TabIndex = 13;
            this.label2.Text = "Output Folder:";
            // 
            // btnSourceFile
            // 
            this.btnSourceFile.Location = new System.Drawing.Point(504, 9);
            this.btnSourceFile.Name = "btnSourceFile";
            this.btnSourceFile.Size = new System.Drawing.Size(27, 23);
            this.btnSourceFile.TabIndex = 12;
            this.btnSourceFile.Text = "...";
            this.btnSourceFile.UseVisualStyleBackColor = true;
            this.btnSourceFile.Click += new System.EventHandler(this.btnSourceFile_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(11, 19);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(63, 13);
            this.label1.TabIndex = 11;
            this.label1.Text = "Source File:";
            // 
            // txtSourceFile
            // 
            this.txtSourceFile.Location = new System.Drawing.Point(89, 12);
            this.txtSourceFile.Name = "txtSourceFile";
            this.txtSourceFile.Size = new System.Drawing.Size(412, 20);
            this.txtSourceFile.TabIndex = 10;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.rbProduction);
            this.groupBox1.Controls.Add(this.rbTest);
            this.groupBox1.Location = new System.Drawing.Point(14, 64);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(138, 46);
            this.groupBox1.TabIndex = 9;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Import Destination";
            // 
            // rbProduction
            // 
            this.rbProduction.AutoSize = true;
            this.rbProduction.Location = new System.Drawing.Point(59, 19);
            this.rbProduction.Name = "rbProduction";
            this.rbProduction.Size = new System.Drawing.Size(76, 17);
            this.rbProduction.TabIndex = 1;
            this.rbProduction.TabStop = true;
            this.rbProduction.Text = "Production";
            this.rbProduction.UseVisualStyleBackColor = true;
            // 
            // rbTest
            // 
            this.rbTest.AutoSize = true;
            this.rbTest.Location = new System.Drawing.Point(6, 19);
            this.rbTest.Name = "rbTest";
            this.rbTest.Size = new System.Drawing.Size(46, 17);
            this.rbTest.TabIndex = 0;
            this.rbTest.TabStop = true;
            this.rbTest.Text = "Test";
            this.rbTest.UseVisualStyleBackColor = true;
            // 
            // progressBar1
            // 
            this.progressBar1.Location = new System.Drawing.Point(14, 116);
            this.progressBar1.Name = "progressBar1";
            this.progressBar1.Size = new System.Drawing.Size(355, 32);
            this.progressBar1.TabIndex = 18;
            // 
            // openFileDialog1
            // 
            this.openFileDialog1.FileName = "openFileDialog1";
            // 
            // cbValidateOnly
            // 
            this.cbValidateOnly.AutoSize = true;
            this.cbValidateOnly.Location = new System.Drawing.Point(174, 84);
            this.cbValidateOnly.Name = "cbValidateOnly";
            this.cbValidateOnly.Size = new System.Drawing.Size(185, 17);
            this.cbValidateOnly.TabIndex = 19;
            this.cbValidateOnly.Text = "Validate Only - Do Not Save Data";
            this.cbValidateOnly.UseVisualStyleBackColor = true;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(539, 161);
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
            this.Name = "Form1";
            this.Text = "OKS Additional Data Import";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnImport;
        private System.Windows.Forms.Button btnExit;
        private System.Windows.Forms.Button btnOutputFolder;
        private System.Windows.Forms.TextBox txtOutputFolder;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button btnSourceFile;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtSourceFile;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.RadioButton rbProduction;
        private System.Windows.Forms.RadioButton rbTest;
        private System.Windows.Forms.ProgressBar progressBar1;
        private System.Windows.Forms.OpenFileDialog openFileDialog1;
        private System.Windows.Forms.FolderBrowserDialog folderBrowserDialog1;
        private System.Windows.Forms.CheckBox cbValidateOnly;
    }
}

