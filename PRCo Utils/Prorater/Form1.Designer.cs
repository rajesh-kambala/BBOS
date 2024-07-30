namespace Prorater
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
            this.previousService = new System.Windows.Forms.ComboBox();
            this.newService = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.cycleCode = new System.Windows.Forms.ComboBox();
            this.label5 = new System.Windows.Forms.Label();
            this.lblOutput = new System.Windows.Forms.Label();
            this.btnCalculate = new System.Windows.Forms.Button();
            this.btnClipboard = new System.Windows.Forms.Button();
            this.btnReset = new System.Windows.Forms.Button();
            this.label4 = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // previousService
            // 
            this.previousService.FormattingEnabled = true;
            this.previousService.Location = new System.Drawing.Point(148, 12);
            this.previousService.Name = "previousService";
            this.previousService.Size = new System.Drawing.Size(322, 24);
            this.previousService.TabIndex = 0;
            this.previousService.SelectedIndexChanged += new System.EventHandler(this.previousService_SelectedIndexChanged);
            // 
            // newService
            // 
            this.newService.FormattingEnabled = true;
            this.newService.Location = new System.Drawing.Point(147, 42);
            this.newService.Name = "newService";
            this.newService.Size = new System.Drawing.Size(323, 24);
            this.newService.TabIndex = 1;
            this.newService.SelectedIndexChanged += new System.EventHandler(this.newService_SelectedIndexChanged);
            // 
            // label1
            // 
            this.label1.Location = new System.Drawing.Point(0, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(100, 23);
            this.label1.TabIndex = 13;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(48, 45);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(90, 17);
            this.label2.TabIndex = 3;
            this.label2.Text = "New Service:";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(14, 75);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(124, 17);
            this.label3.TabIndex = 4;
            this.label3.Text = "Billing Cycle Code:";
            // 
            // cycleCode
            // 
            this.cycleCode.FormattingEnabled = true;
            this.cycleCode.Location = new System.Drawing.Point(148, 72);
            this.cycleCode.Name = "cycleCode";
            this.cycleCode.Size = new System.Drawing.Size(67, 24);
            this.cycleCode.TabIndex = 5;
            this.cycleCode.SelectedIndexChanged += new System.EventHandler(this.cycleCode_SelectedIndexChanged);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label5.Location = new System.Drawing.Point(35, 100);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(103, 17);
            this.label5.TabIndex = 8;
            this.label5.Text = "Prorated Price:";
            // 
            // lblOutput
            // 
            this.lblOutput.AutoSize = true;
            this.lblOutput.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblOutput.Location = new System.Drawing.Point(150, 100);
            this.lblOutput.Name = "lblOutput";
            this.lblOutput.Size = new System.Drawing.Size(0, 17);
            this.lblOutput.TabIndex = 9;
            // 
            // btnCalculate
            // 
            this.btnCalculate.Location = new System.Drawing.Point(147, 135);
            this.btnCalculate.Name = "btnCalculate";
            this.btnCalculate.Size = new System.Drawing.Size(91, 32);
            this.btnCalculate.TabIndex = 10;
            this.btnCalculate.Text = "Calculate";
            this.btnCalculate.UseVisualStyleBackColor = true;
            this.btnCalculate.Click += new System.EventHandler(this.btnCalculate_Click);
            // 
            // btnClipboard
            // 
            this.btnClipboard.Location = new System.Drawing.Point(245, 135);
            this.btnClipboard.Name = "btnClipboard";
            this.btnClipboard.Size = new System.Drawing.Size(137, 32);
            this.btnClipboard.TabIndex = 11;
            this.btnClipboard.Text = "Copy to Clipboard";
            this.btnClipboard.UseVisualStyleBackColor = true;
            this.btnClipboard.Click += new System.EventHandler(this.btnClipboard_Click);
            // 
            // btnReset
            // 
            this.btnReset.Location = new System.Drawing.Point(388, 135);
            this.btnReset.Name = "btnReset";
            this.btnReset.Size = new System.Drawing.Size(91, 32);
            this.btnReset.TabIndex = 12;
            this.btnReset.Text = "Reset";
            this.btnReset.UseVisualStyleBackColor = true;
            this.btnReset.Click += new System.EventHandler(this.btnReset_Click);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(20, 15);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(118, 17);
            this.label4.TabIndex = 14;
            this.label4.Text = "Previous Service:";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(482, 180);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.btnReset);
            this.Controls.Add(this.btnClipboard);
            this.Controls.Add(this.btnCalculate);
            this.Controls.Add(this.lblOutput);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.cycleCode);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.newService);
            this.Controls.Add(this.previousService);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.MaximumSize = new System.Drawing.Size(500, 225);
            this.MinimizeBox = false;
            this.MinimumSize = new System.Drawing.Size(500, 225);
            this.Name = "Form1";
            this.Text = "BBSi Prorater";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ComboBox previousService;
        private System.Windows.Forms.ComboBox newService;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ComboBox cycleCode;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label lblOutput;
        private System.Windows.Forms.Button btnCalculate;
        private System.Windows.Forms.Button btnClipboard;
        private System.Windows.Forms.Button btnReset;
        private System.Windows.Forms.Label label4;
    }
}

