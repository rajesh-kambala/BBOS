namespace sstchur.web.survey
{
    using System;
    using System.Web.UI;
    using System.Web.UI.WebControls;

    public class McssWebQuestion : WebQuestion
    {
        private DropDownList m_dropDownList;
        private ListControl m_listControl;
        private RadioButtonList m_radioButtonList;

        public McssWebQuestion(string strId, bool bRequired, string strRequiredText, string strQuestion, string strControlBase, RepeatDirection rdLayout, string[] strResponses) : base(strId, "mcss", bRequired, strRequiredText, strQuestion)
        {
            this.m_radioButtonList = new RadioButtonList();
            this.m_dropDownList = new DropDownList();
            this.m_listControl = null;
            if (strControlBase == "dropdown")
            {
                this.m_listControl = this.m_dropDownList;
            }
            else
            {
                this.m_radioButtonList.RepeatDirection = rdLayout;
                this.m_listControl = this.m_radioButtonList;
            }
            foreach (string text in strResponses)
            {
                this.m_listControl.Items.Add(new ListItem(text));
            }
            this.m_listControl.ID = "lst_" + strId;
            if (bRequired)
            {
                ListControlValidator child = new ListControlValidator();
                child.EnableClientScript = false;
                child.Text = strRequiredText;
                child.Display = ValidatorDisplay.Dynamic;
                child.ControlToValidate = this.m_listControl.ID;
                this.Controls.Add(child);
            }
            this.Controls.Add(this.m_listControl);
            this.Controls.Add(new LiteralControl("</p>"));
        }

        public override void SetAnswer()
        {
            base.m_strAnswer = this.m_listControl.SelectedValue;
        }
    }
}

