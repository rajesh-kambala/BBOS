using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.DataVisualization.Charting;
using System.Web.UI.WebControls;

namespace PRCo.BBOS.UI.Web.UserControls
{
    public partial class BBScoreChart : System.Web.UI.UserControl
    {
        protected string _panelIndex = "1";
        protected string _industry = "P";

        protected void Page_Load(object sender, EventArgs e)
        {
            //Show BBScore disclaimer based on flag BBSUseBothModelsForLineChart in database
            if (PageControlBaseCommon.BBSUseBothModelsForLineChart() && industry != "L")
                lblBBScoreDisclaimer.Visible = true;
        }

        public string panelIndex
        {
            get { return _panelIndex;  }
            set { _panelIndex = value; }
        }

        public string industry
        {
            get { return _industry; }
            set { _industry = value; }
        }

        public Chart chart
        {
            get { return chartBBScore; }
        }

        public UpdatePanel updatePanel
        {
            get { return upnlBBScoreChart; }
        }   

        public Image bbScoreImage
        {
            get { return imgBBScoreText; }
        }

        public Literal bbScoreLiteral
        {
            get { return litBBScoreText; }
        }
    }
}