namespace sstchur.web.survey
{
    using System;
    using System.Web.UI;
    using System.Web.UI.WebControls;

    public class EssayWebQuestion : WebQuestion
    {
        private TextBox m_textBox;

        public EssayWebQuestion(string strId, bool bRequired, string strRequiredText, string strQuestion, int nRows, int nCols) : base(strId, "shortans", bRequired, strRequiredText, strQuestion)
        {
            this.m_textBox = new TextBox();
            this.Controls.Add(this.m_textBox);
            this.m_textBox.ID = "txt_" + strId;
            this.m_textBox.TextMode = TextBoxMode.MultiLine;
            this.m_textBox.Wrap = true;
            this.m_textBox.Columns = nCols;
            this.m_textBox.Rows = nRows;
            if (bRequired)
            {
                RequiredFieldValidator child = new RequiredFieldValidator();
                child.ControlToValidate = this.m_textBox.ID;
                child.EnableClientScript = false;
                child.Text = strRequiredText;
                this.Controls.Add(child);
                this.Controls.Add(new LiteralControl("<br>"));
            }
            this.Controls.Add(new LiteralControl("</p>"));
        }

        public override void SetAnswer()
        {
            base.m_strAnswer = this.m_textBox.Text;
        }
    }
}

