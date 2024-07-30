namespace sstchur.web.survey
{
    using System;
    using System.Web.UI;
    using System.Web.UI.WebControls;

    public class McmsWebQuestion : WebQuestion
    {
        private CheckBoxList m_checkBoxList;
        private ListBox m_listBox;
        private ListControl m_listControl;

        public McmsWebQuestion(string strId, bool bRequired, string strRequiredText, string strQuestion, string strControlBase, RepeatDirection rdLayout, string[] strResponses) : base(strId, "mcms", bRequired, strRequiredText, strQuestion)
        {
            this.m_listBox = new ListBox();
            this.m_checkBoxList = new CheckBoxList();
            this.m_listControl = null;
            if (strControlBase == "checkbox")
            {
                this.m_checkBoxList.RepeatDirection = rdLayout;
                this.m_listControl = this.m_checkBoxList;
            }
            else
            {
                this.m_listBox.SelectionMode = ListSelectionMode.Multiple;
                this.m_listControl = this.m_listBox;
            }
            foreach (string text in strResponses)
            {
                this.m_listControl.Items.Add(new ListItem(text));
            }
            this.m_listControl.ID = "lst_" + strId;
            this.Controls.Add(this.m_listControl);

            if (bRequired)
            {
                ListControlValidator child = new ListControlValidator();
                child.EnableClientScript = false;
                child.Text = strRequiredText;
                child.Display = ValidatorDisplay.Dynamic;
                child.ControlToValidate = this.m_listControl.ID;
                this.Controls.Add(child);
            }

            this.Controls.Add(new LiteralControl("</p>"));
        }

        public override void SetAnswer()
        {
            base.m_strAnswer = "";
            foreach (ListItem item in this.m_listControl.Items)
            {
                if (item.Selected)
                {
                    base.m_strAnswer = base.m_strAnswer + item.Value + "|";
                }
            }
            base.m_strAnswer = base.m_strAnswer.Trim(new char[] { '|' });
        }
    }
}

