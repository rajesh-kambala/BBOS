namespace sstchur.web.survey
{
    using System;
    using System.ComponentModel;
    using System.IO;
    using System.Web;
    using System.Web.UI;
    using System.Web.UI.WebControls;
    using System.Xml;
    using System.Xml.XPath;
    using System.Xml.Xsl;

    [ToolboxItem(false)]
    public class SurveyResult : WebControl
    {
        private XmlDocument m_docResults = new XmlDocument();
        private string m_strAnswersFile = "";
        private string m_strStylesheet = "";
        private string m_strSurveyFile = "";
        private string m_strXQuery1 = "";
        private string m_strXQuery2 = "";

        public SurveyResult()
        {
            XmlDeclaration newChild = this.m_docResults.CreateXmlDeclaration("1.0", null, null);
            this.m_docResults.AppendChild(newChild);
            XmlElement element = this.m_docResults.CreateElement("SurveyResult");
            this.m_docResults.AppendChild(element);
        }

        private void AppendNodeList(XmlDocument _doc, XmlNodeList[] _nodeListArray)
        {
            foreach (XmlNodeList list in _nodeListArray)
            {
                foreach (XmlNode node in list)
                {
                    _doc.DocumentElement.AppendChild(_doc.ImportNode(node, true));
                }
            }
        }

        private XmlNodeList[] GetNodes(XmlDocument _doc, string _queryList)
        {
            string[] textArray = _queryList.Split(new char[] { ',' });
            XmlElement documentElement = _doc.DocumentElement;
            XmlNodeList[] listArray = new XmlNodeList[textArray.Length];
            int index = 0;
            for (int i = 0; i < textArray.Length; i++)
            {
                string xpath = textArray[i];
                listArray[index] = documentElement.SelectNodes(xpath);
                index++;
            }
            return listArray;
        }

        protected override void OnLoad(EventArgs e)
        {
            XmlDocument document = new XmlDocument();
            document.Load(this.m_strSurveyFile);
            XmlDocument document2 = new XmlDocument();
            document2.Load(this.m_strAnswersFile);
            XmlNodeList[] nodes = this.GetNodes(document, this.m_strXQuery1);
            this.AppendNodeList(this.m_docResults, nodes);
            XmlNodeList[] listArray2 = this.GetNodes(document2, this.m_strXQuery2);
            this.AppendNodeList(this.m_docResults, listArray2);
            
            base.OnLoad(e);
        }

        protected override void Render(HtmlTextWriter htmlWriter)
        {
            XslTransform transform = new XslTransform();
            transform.Load(this.m_strStylesheet);
            StringWriter writer = new StringWriter();
            transform.Transform((IXPathNavigable) this.m_docResults, null, (TextWriter) writer, null);
            htmlWriter.Write(writer.ToString());
        }

        public string AnswersFile
        {
            set
            {
                this.m_strAnswersFile = HttpContext.Current.Server.MapPath(value);
            }
        }

        public string Stylesheet
        {
            set
            {
                this.m_strStylesheet = HttpContext.Current.Server.MapPath(value);
            }
        }

        public string SurveyFile
        {
            set
            {
                this.m_strSurveyFile = HttpContext.Current.Server.MapPath(value);
            }
        }

        public string XQuery1
        {
            set
            {
                this.m_strXQuery1 = value;
            }
        }

        public string XQuery2
        {
            set
            {
                this.m_strXQuery2 = value;
            }
        }
    }
}

