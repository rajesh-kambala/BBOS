namespace sstchur.web.survey.designer
{
    using System;
    using System.IO;
    using System.Web.UI;
    using System.Web.UI.Design;
    using System.Web.UI.HtmlControls;
    using System.Web.UI.WebControls;

    public class WebSurveyDesigner : ControlDesigner
    {
        public HtmlTable table = new HtmlTable();

        public WebSurveyDesigner()
        {
            this.table.Border = 0;
            this.table.CellSpacing = 0;
            this.table.Width = "30%";
            this.table.Attributes.Add("style", "border: dashed 1px #000000; background-color: #ffffcc; font-family: arial; font-size: 12px;");
        }

        public override string GetDesignTimeHtml()
        {
            HtmlTableRow row = new HtmlTableRow();
            row.VAlign = "top";
            row.Align = "center";
            HtmlTableCell cell = new HtmlTableCell();
            cell.InnerHtml = "<b>sstchur's WebSurvey Control</b>";
            row.Cells.Add(cell);
            this.table.Rows.Add(row);
            row = new HtmlTableRow();
            cell = new HtmlTableCell();
            Label child = new Label();
            child.Text = "<b>What is your name?</b>";
            TextBox box = new TextBox();
            box.Columns = 30;
            cell.Controls.Add(new LiteralControl("<br>"));
            cell.Controls.Add(new LiteralControl("<p>"));
            cell.Controls.Add(child);
            cell.Controls.Add(new LiteralControl("<br>"));
            cell.Controls.Add(box);
            cell.Controls.Add(new LiteralControl("<p>"));
            cell.Controls.Add(new LiteralControl("<p>"));
            RadioButtonList list = new RadioButtonList();
            list.Attributes.Add("style", "font-size: 12px;");
            list.Items.Add("Red");
            list.Items.Add("Blue");
            list.Items.Add("Green");
            cell.Controls.Add(list);
            cell.Controls.Add(new LiteralControl("</p>"));
            Button button = new Button();
            button.Text = "Submit";
            cell.Controls.Add(new LiteralControl("<p>"));
            cell.Controls.Add(button);
            cell.Controls.Add(new LiteralControl("</p>"));
            child = new Label();
            child.Text = "<p><b>Note:</b> <small>The above questions are only samples displayed at design-time. Actual questions will be generated at run-time based on the XML in your SurveyFile.</small></p>";
            cell.Controls.Add(child);
            row.Cells.Add(cell);
            this.table.Rows.Add(row);
            StringWriter writer = new StringWriter();
            HtmlTextWriter writer2 = new HtmlTextWriter(writer);
            this.table.RenderControl(writer2);
            return writer2.InnerWriter.ToString();
        }
    }
}

