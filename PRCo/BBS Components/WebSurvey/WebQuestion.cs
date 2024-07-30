namespace sstchur.web.survey
{
    using System;
    using System.ComponentModel;
    using System.Web.UI;
    using System.Web.UI.WebControls;

    [ToolboxItem(false)]
    public class WebQuestion : WebControl
    {
        private bool m_bRequired;
        protected string m_strRequiredText;
        protected string m_strAnswer;
        private string m_strId;
        private string m_strType;

        public WebQuestion()
        {
        }

        protected WebQuestion(string strId, string strType)
        {
            this.m_strId = strId;
            this.m_strType = strType;
        }

        protected WebQuestion(string strId, string strType, bool bRequired, string strRequiredText, string strQuestion)
        {
            this.m_strId = strId;
            this.m_strType = strType;
            this.m_bRequired = bRequired;
            this.m_strRequiredText = strRequiredText;
            this.Controls.Add(new LiteralControl("<p>"));
            Label child = new Label();
            child.Text = strQuestion;
            this.Controls.Add(child);
            this.Controls.Add(new LiteralControl("<br/>"));
        }

        public virtual void SetAnswer()
        {
        }

        public string Answer
        {
            get
            {
                return this.m_strAnswer;
            }
        }

        public string Id
        {
            get
            {
                return this.m_strId;
            }
        }

        public bool IsRequired
        {
            get
            {
                return this.m_bRequired;
            }
        }
        
        public string RequiredText
        {
					get
					{
						return this.m_strRequiredText;
					}					
        }
    }
}

