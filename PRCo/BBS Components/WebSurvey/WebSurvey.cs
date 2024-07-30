/*
*
*	WebSurvey by Stephen Stchur
*
*	Copyright (c) Microsoft Corporation.  All rights reserved.
*
*
*/

namespace sstchur.web.survey
{
    using sstchur.web.survey.designer;
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.IO;
    using System.Web;
    using System.Net.Mail;
    using System.Web.UI;
    using System.Web.UI.WebControls;
    using System.Xml;    

    [Designer(typeof(WebSurveyDesigner)), ToolboxData("<{0}:WebSurvey runat = \"server\"></{0}:WebSurvey>")]
    public class WebSurvey : CompositeControl
    {
        private bool m_bAllowRepeats = true;
        private ArrayList m_panels = new ArrayList();
        //private WebQuestionCollection m_questions = new WebQuestionCollection();
        private Dictionary<string, WebQuestion> m_questions = new Dictionary<string, WebQuestion>();
        private string m_strAnswersFile = "answers.xml";
        private string m_strCookieName = "WebSurvey:RepeatCookie";
        private string m_strEmailTo = null;
        private string m_strRedirectUrl = null;
        private string m_strSmtpServer = null;
        private string m_strSurveyFile = "survey.xml";

        // CHW
        private bool m_CompletedSurvey = false;
        
        private int id = 0;

        private void AddButtonToPanel(Panel _panel, ButtonType _buttonType, string _imgUrl)
        {
            ImageButton child = new ImageButton();
            child.ImageUrl = _imgUrl;
            switch (_buttonType)
            {
                case ButtonType.Back:										
                    child.Command += new CommandEventHandler(this.btnBack_Click);
                    child.CommandName = _panel.ID;
                    break;

                case ButtonType.Next:										
                    child.Command += new CommandEventHandler(this.btnNext_Click);                    
                    child.CommandName = _panel.ID;
                    break;

                case ButtonType.Submit:										
                    child.Click += new ImageClickEventHandler(this.btnSubmit_Click);
                    break;
            }            
            _panel.Controls.Add(child);
            _panel.Controls.Add(new LiteralControl("&nbsp;&nbsp;&nbsp;"));
        }

        private void btnBack_Click(object sender, CommandEventArgs e)
        {
            int num = this.HidePanel(e.CommandName);
            ((Panel) m_panels[num - 1]).Visible = true;
        }

        private void btnNext_Click(object sender, CommandEventArgs e)
        {
            if (this.Page.IsValid)
            {
                int num = this.HidePanel(e.CommandName);
                ((Panel) m_panels[num + 1]).Visible = true;                
            }
        }

        private void btnSubmit_Click(object sender, ImageClickEventArgs e)
        {
            if (this.Page.IsValid)
            {
                if (!File.Exists(m_strAnswersFile))
                {
                    XmlTextWriter writer = new XmlTextWriter(m_strAnswersFile, null);
                    writer.Formatting = Formatting.Indented;
                    writer.Indentation = 2;
                    writer.WriteStartDocument();
                    writer.WriteStartElement("Answers");
                    writer.WriteEndElement();
                    writer.WriteEndDocument();
                    writer.Flush();
                    writer.Close();
                }
                XmlDocument document = new XmlDocument();
                document.Load(m_strAnswersFile);
                XmlElement documentElement = document.DocumentElement;
                XmlElement newChild = document.CreateElement("AnswerSet");
                foreach (Control control in this.Controls)
                {
                    Panel panel = (Panel) control;
                    foreach (Control control2 in panel.Controls)
                    {
                        if (control2.GetType().BaseType == typeof(WebQuestion))
                        {
                            WebQuestion question = (WebQuestion) control2;
                            question.SetAnswer();
                            XmlElement element3 = document.CreateElement("Answer");
                            XmlAttribute node = document.CreateAttribute("questionId");
                            node.Value = question.Id;
                            element3.Attributes.Append(node);
                            element3.InnerText = HttpContext.Current.Server.HtmlEncode(question.Answer);
                            newChild.AppendChild(element3);
                        }
                    }
                }
                documentElement.AppendChild(newChild);
                document.Save(m_strAnswersFile);
                if (!m_bAllowRepeats)
                {
                    this.CreateCookie();
                }
                if (!string.IsNullOrEmpty(m_strEmailTo))
                {
                    this.EmailAnswerSet(newChild);
                }

                m_CompletedSurvey = true;

                if (!string.IsNullOrEmpty(m_strRedirectUrl))
                {
                    HttpContext.Current.Response.Redirect(m_strRedirectUrl);
                }
            }
        }

        private bool CookieExists()
        {
            return (HttpContext.Current.Request.Cookies[m_strCookieName] != null);
        }

        private void CreateCookie()
        {
            HttpCookie cookie = new HttpCookie(m_strCookieName);
            cookie.Values.Add("CompletedSurvey", "true");
            cookie.Expires = DateTime.Now.AddYears(5);
            HttpContext.Current.Response.Cookies.Add(cookie);
        }

        private Control CreateWebSurveyControl(XmlNode _node)
        {
            string localName = _node.LocalName;
            if (localName == "Question")
            {
                string strId = _node.Attributes["id"].Value;
                string text3 = _node.Attributes["type"].Value;
                string strQuestion = "";
                XmlNode node = _node.SelectSingleNode("Statement");
                if (node != null)
                {
                    strQuestion = node.InnerXml;
                }
                int nCols = 20;
                XmlAttribute attribute = _node.Attributes["cols"];
                if (attribute != null)
                {
                    nCols = int.Parse(attribute.Value);
                }
                int nRows = 4;
                XmlAttribute attribute2 = _node.Attributes["rows"];
                if (attribute2 != null)
                {
                    nRows = int.Parse(attribute2.Value);
                }
                RepeatDirection rdLayout = RepeatDirection.Vertical;
                XmlAttribute attribute3 = _node.Attributes["layout"];
                if (attribute3 != null)
                {
                    rdLayout = (attribute3.Value == "horizontal") ? RepeatDirection.Horizontal : RepeatDirection.Vertical;
                }
                string strControlBase = "";
                XmlAttribute attribute4 = _node.Attributes["basecontrol"];
                if (attribute4 != null)
                {
                    strControlBase = attribute4.Value;
                }
                bool bRequired = false;
                XmlAttribute attribute5 = _node.Attributes["required"];
                if (attribute5 != null)
                {
                    bRequired = attribute5.Value == "true";
                }
                string strRequiredText = "*";
                XmlAttribute attribute6 = _node.Attributes["requiredtext"];                
                if (attribute6 != null)
                {
									strRequiredText = attribute6.Value;
                }
                
                WebQuestion wq;
                string[] strResponses = null;
                switch (text3)
                {
                    case "shortans":
                        wq = new ShortAnsWebQuestion(strId, bRequired, strRequiredText, strQuestion, nCols);                        
                        break;

                    case "essay":
                        wq = new EssayWebQuestion(strId, bRequired, strRequiredText, strQuestion, nRows, nCols);
                        break;

                    case "mcss":
                        if (strControlBase == "")
                        {
                            strControlBase = "radio";
                        }
                        strResponses = this.GetResponses(_node);
                        wq = new McssWebQuestion(strId, bRequired, strRequiredText, strQuestion, strControlBase, rdLayout, strResponses);
                        break;

                    case "mcms":
                        if (strControlBase == "")
                        {
                            strControlBase = "checkbox";
                        }
                        strResponses = this.GetResponses(_node);
                        wq = new McmsWebQuestion(strId, bRequired, strRequiredText, strQuestion, strControlBase, rdLayout, strResponses);
                        break;

                    case "hidden":
                        wq = new HiddenWebQuestion(strId);
                        break;

                    default:
                        wq = new WebQuestion();
                        break;
                }

                m_questions.Add(wq.Id, wq);
                return wq;
            }
            if (localName == "Separator")
            {
                return new LiteralControl(_node.InnerXml);
            }
            return new LiteralControl("");
        }

        private void CreateWebSurveyControls(XmlNodeList _groups)
        {
            foreach (XmlNode node in _groups)
            {
                Panel panel = new Panel();
                panel.Visible = false;
                panel.ID = node.Attributes["id"].Value;
                m_panels.Add(panel);
                string text = "";
                XmlAttribute attribute = node.Attributes["nextimage"];
                if (attribute != null)
                {
                    text = attribute.Value;
                }
                string text2 = "";
                XmlAttribute attribute2 = node.Attributes["backimage"];
                if (attribute2 != null)
                {
                    text2 = attribute2.Value;
                }
                foreach (XmlNode node2 in node.SelectNodes("*"))
                {
                    panel.Controls.Add(this.CreateWebSurveyControl(node2));
                }
                if (m_panels.IndexOf(panel) > 0)
                {
                    this.AddButtonToPanel(panel, ButtonType.Back, text2);
                }
                if (m_panels.IndexOf(panel) == (_groups.Count - 1))
                {
                    this.AddButtonToPanel(panel, ButtonType.Submit, text);
                }
                else
                {
                    this.AddButtonToPanel(panel, ButtonType.Next, text);
                }
                this.Controls.Add(panel);
            }
        }

        private void EmailAnswerSet(XmlElement _elemAnswerSet)
        {
            XmlTextWriter writer = new XmlTextWriter(HttpContext.Current.Server.MapPath("~answerset.xml"), null);
            writer.Formatting = Formatting.Indented;
            writer.Indentation = 2;
            writer.WriteStartDocument();
            writer.WriteStartElement("AnswerSet");
            writer.WriteRaw(_elemAnswerSet.InnerXml);
            writer.WriteEndElement();
            writer.WriteEndDocument();
            writer.Flush();
            writer.Close();


            MailMessage message = new MailMessage(m_strEmailTo, m_strEmailTo);
            message.Subject = "Web Survey Answer Set (Web-generated Email)";
            message.IsBodyHtml = true;
            message.Body = "WebSurvey Answer Set Attached";
            message.Attachments.Add(new Attachment(HttpContext.Current.Server.MapPath("~answerset.xml")));

            SmtpClient SmtpMail = new SmtpClient(m_strSmtpServer);
            SmtpMail.Send(message);
        }

        private string[] GetResponses(XmlNode _node)
        {
            XmlNodeList list = _node.SelectNodes("Responses/Response");
            string[] textArray = new string[list.Count];
            for (int i = 0; i < list.Count; i++)
            {
                XmlNode node = list[i];
                textArray[i] = node.InnerText;
            }
            return textArray;
        }

        private int HidePanel(string _strPanelId)
        {
            Panel panel = (Panel) this.FindControl(_strPanelId);
            panel.Visible = false;
            return m_panels.IndexOf(panel);
        }

		protected override void OnLoad(EventArgs e)
		{			
			m_strSurveyFile = HttpContext.Current.Server.MapPath(m_strSurveyFile);
			m_strAnswersFile = HttpContext.Current.Server.MapPath(m_strAnswersFile);						

			XmlDocument document = new XmlDocument();
			document.Load(m_strSurveyFile);

			XmlElement documentElement = document.DocumentElement;
			XmlAttribute attribute = documentElement.Attributes["allowrepeats"];
			if (attribute != null)
				m_bAllowRepeats = attribute.Value != "false";
				
			XmlAttribute attribute2 = documentElement.Attributes["redirecturl"];
			if (attribute2 != null)
				m_strRedirectUrl = attribute2.Value;
		
			XmlAttribute attribute3 = documentElement.Attributes["cookiename"];
			if (attribute3 != null)
				m_strCookieName = attribute3.Value;

			XmlNode node = documentElement.SelectSingleNode("//WebSurvey/EmailResults");
			if (node != null)
			{
				m_strEmailTo = node.SelectSingleNode("EmailTo").InnerText;
				m_strSmtpServer = node.SelectSingleNode("SmtpServer").InnerText;
			}
		
			XmlNodeList list = documentElement.SelectNodes("//WebSurvey/Group");
			this.CreateWebSurveyControls(list);
			
			if (!Page.IsPostBack)
			{
				((Panel) m_panels[0]).Visible = true;
			}

			base.OnLoad(e);
		}

        protected override void Render(HtmlTextWriter writer)
        {
            this.Page.VerifyRenderingInServerForm(this);
            base.Render(writer);
        }

        [Description("Relative path to the XML file that will store the survey's answers"), Browsable(true), Category("Data"), DefaultValue("answers.xml")]
        public string AnswersFile
        {
            get
            {
                return m_strAnswersFile;
            }
            set
            {
                m_strAnswersFile = value;
            }
        }

        [Browsable(false)]
        public bool PreviouslyCompleted
        {
            get
            {
                return this.CookieExists();
            }
        }

        // CHW
        [Browsable(false)]
        public bool IsCompleted
        {
            get
            {
                return this.m_CompletedSurvey;
            }
        }

        // CHW
        public Dictionary<string, WebQuestion> Questions
        {
            get
            {
                return m_questions;
            }
        }

        // Added by CHW 6/26/2012
        public string CookieName
        {
            get
            {
                return m_strCookieName;
            }
        }

        [Category("Data"), DefaultValue("survey.xml"), Description("Relative path to the XML file containing the survey's question"), Browsable(true)]
        public string SurveyFile
        {
            get
            {
                return m_strSurveyFile;
            }
            set
            {
                m_strSurveyFile = value;
            }
        }
    }
}

