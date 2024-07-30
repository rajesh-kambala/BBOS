namespace sstchur.web.survey
{
    using System;
    using System.Web.UI.HtmlControls;

    public class HiddenWebQuestion : WebQuestion
    {
        private HtmlInputHidden m_hiddenInput;

        public HiddenWebQuestion(string strId) : base(strId, "hidden")
        {
            this.m_hiddenInput = new HtmlInputHidden();
            this.Controls.Add(this.m_hiddenInput);
            this.m_hiddenInput.ID = "hidden_" + strId;
        }

        public override void SetAnswer()
        {
            base.m_strAnswer = this.m_hiddenInput.Value;
        }

        public void SetAnswer(string value)
        {
            this.m_hiddenInput.Value = value;
        }
    }
}

