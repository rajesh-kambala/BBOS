using System;
using System.IO;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Text;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

using PerfectAddressDLLWrapper;

namespace PRCo.BBS.CRM
{
    /// <summary>
    /// 
    /// </summary>
     public partial class PerfectAddress : PageBase
    {
        private string sRowStyle = "ROW2";
        
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            bool bUsingStreet2 = false;

            // determine the passed values
            string szStreet1 = Request.Params["Address1"];
            string szStreet2 = Request.Params["Address2"];
            string szCityStateZip = Request.Params["CityStateZip"];

            //clear the results table
            tblResults.Rows.Clear();

            // look at the street and city address; if anything is entered
            // pass it on to address verification
            if (string.IsNullOrEmpty(szStreet1) && string.IsNullOrEmpty(szStreet2) && string.IsNullOrEmpty(szCityStateZip))
            {
                // show empty results in the table
                AddErrorRow("Enter values and press refresh to view matching records.");
                return;
            }

            // try to do some address verification
            PerfectAddressDLL PA = new PerfectAddressDLL();
            try
            {
                // manually initialize this object
                PA.Initialize();

                //int nRetCode = PA.CheckAddress("", "", "845 Geneva", "60188");
                int nRetCode = PA.CheckAddress("", "", szStreet1, szCityStateZip);

                // if street1 yields no results, try street 2
                if (nRetCode != PerfectAddressDLL.ErrorCodes.XC_MULT &&
                    (nRetCode >= PerfectAddressDLL.ErrorCodes.XC_BADADDR || nRetCode == PerfectAddressDLL.ErrorCodes.XC_NONDEL))
                {
                    bUsingStreet2 = true;
                    nRetCode = PA.CheckAddress("", "", szStreet2, szCityStateZip);
                }

                bool autoSelectFirstRow = GetConfigValue("PerfectAddressAutoSelect", true);
                int nCount = PA.GetMatchCount();
                string szStreet = string.Empty;
                string szCity = string.Empty;
                string szState = string.Empty;
                string szZip = string.Empty;
                string szCounty = string.Empty;

                string szFirmHigh = string.Empty;
                string szPRUrb = string.Empty;
                string szDelLine = string.Empty;
                string szLastLine = string.Empty;

                if (nRetCode == PerfectAddressDLL.ErrorCodes.XC_MULT)
                {
                    AddResultHeaderRow();

                    for (int i = 1; i <= nCount; i++)
                    {
                        PA.GetMatchAddr(i, ref szFirmHigh, ref szPRUrb, ref szDelLine, ref szLastLine);
                        szStreet = szDelLine.Trim();
                        PA.GetCity(ref szCity);
                        szCity = szCity.Trim();
                        PA.GetState(ref szState);
                        szState = szState.Trim();
                        PA.GetZip(ref szZip);
                        szZip = szZip.Trim();
                        PA.GetCounty(ref szCounty);
                        szCounty = szCounty.Trim();
                        AddResultRow(szStreet, szCity, szState, szZip, szCounty);

                        if (i > 1)
                        {
                            autoSelectFirstRow = false;
                        }
                    }
                }
                else if (nRetCode < PerfectAddressDLL.ErrorCodes.XC_BADADDR && nRetCode != PerfectAddressDLL.ErrorCodes.XC_NONDEL)
                {
                    AddResultHeaderRow();
                    PA.GetStdAddress(ref szFirmHigh, ref szPRUrb, ref szDelLine, ref szLastLine);
                    szStreet = szDelLine.Trim();
                    PA.GetCity(ref szCity);
                    szCity = szCity.Trim();
                    PA.GetState(ref szState);
                    szState = szState.Trim();
                    PA.GetZip(ref szZip);
                    szZip = szZip.Trim();
                    PA.GetCounty(ref szCounty);
                    szCounty = szCounty.Trim();
                    AddResultRow(szStreet, szCity, szState, szZip, szCounty);
                }
                else
                {
                    autoSelectFirstRow = false;

                    StringBuilder sbMsg = new StringBuilder("<p style=\"margin-left:25px;\">");
                    sbMsg.Append(szStreet1 + "<br/>");
                    sbMsg.Append(szStreet2 + "<br/>");
                    sbMsg.Append(szCityStateZip + "<br/>");
                    sbMsg.Append("</p>");
                    AddErrorRow("<b>No matching records for the address:</b>" + sbMsg.ToString());
                }


                string javaScript = "<script type=\"text/javascript\">" + Environment.NewLine;

                if (bUsingStreet2)
                    javaScript += "bUsingAddrLine2 = true;" + Environment.NewLine;

                if ((autoSelectFirstRow) &&
                    (hidFirstTime.Value == "Y"))
                {
                    javaScript += "autoSelectFirstRow = true;" + Environment.NewLine;
                    hidFirstTime.Value = "N";
                }

                javaScript += "</script>";

                ClientScript.RegisterClientScriptBlock(this.GetType(), "selectRow", javaScript);
            }
            catch (Exception ex)
            {
                AddErrorRow(ex.Message);
            }
            finally
            {
                // make sure we close this object
                if (PA != null)
                    PA.Terminate();
            }

        }

        private void AddErrorRow(string szMsg)
        {
            TableRow newRow = new TableRow();
            TableCell newCell = new TableCell();
            newCell.CssClass = "ROW2";
            newCell.Text = szMsg;
            newRow.Cells.Add(newCell);
            tblResults.Rows.Add(newRow);
        }
    
        private void AddResultRow(string szStreet, string szCity, string szState, string szZip, string szCounty)
        {
            TableRow newRow = new TableRow();
            newRow.VerticalAlign = VerticalAlign.Top;
            newRow.CssClass = sRowStyle + " selectRow";

            AddResultCell(newRow, szStreet);
            AddResultCell(newRow, szCity);
            AddResultCell(newRow, szState);
            AddResultCell(newRow, szZip);
            AddResultCell(newRow, szCounty);

            tblResults.Rows.Add(newRow);
            if (sRowStyle == "ROW2")
                sRowStyle = "ROW1";
            else
                sRowStyle = "ROW2";
        }

        private void AddResultCell(TableRow row, string szValue)
        {
            TableCell newCell = new TableCell();
            newCell.VerticalAlign = VerticalAlign.Top;
            newCell.HorizontalAlign = HorizontalAlign.Left;
            newCell.CssClass = sRowStyle;
            newCell.Attributes["onDblClick"] = "javascript:selectRow(this);";
            if (string.IsNullOrEmpty(szValue))
                szValue = "&nbsp;";
            newCell.Text = szValue;
            row.Cells.Add(newCell);
        }
        
        private void AddResultHeaderRow()
        {
            TableHeaderRow newRow = new TableHeaderRow();
            newRow.VerticalAlign = VerticalAlign.Top;
            // Add Street
            TableHeaderCell newCell = new TableHeaderCell();
            newCell.VerticalAlign = VerticalAlign.Top;
            newCell.HorizontalAlign = HorizontalAlign.Left;
            newCell.CssClass = "GRIDHEAD";
            newCell.Text = "Address Line 1";
            newRow.Cells.Add(newCell);

            // Add City
            newCell = new TableHeaderCell();
            newCell.VerticalAlign = VerticalAlign.Top;
            newCell.HorizontalAlign = HorizontalAlign.Left;
            newCell.CssClass = "GRIDHEAD";
            newCell.Text = "City";
            newRow.Cells.Add(newCell);

            // Add State
            newCell = new TableHeaderCell();
            newCell.VerticalAlign = VerticalAlign.Top;
            newCell.HorizontalAlign = HorizontalAlign.Left;
            newCell.CssClass = "GRIDHEAD";
            newCell.Text = "State";
            newRow.Cells.Add(newCell);

            // Add Zip
            newCell = new TableHeaderCell();
            newCell.VerticalAlign = VerticalAlign.Top;
            newCell.HorizontalAlign = HorizontalAlign.Left;
            newCell.CssClass = "GRIDHEAD";
            newCell.Text = "Zip Code";
            newRow.Cells.Add(newCell);

            // Add County
            newCell = new TableHeaderCell();
            newCell.VerticalAlign = VerticalAlign.Top;
            newCell.HorizontalAlign = HorizontalAlign.Left;
            newCell.CssClass = "GRIDHEAD";
            newCell.Text = "County";
            newRow.Cells.Add(newCell);

            tblResults.Rows.Add(newRow);
        }
    }  
}
