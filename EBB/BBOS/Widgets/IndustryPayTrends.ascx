<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="IndustryPayTrends.ascx.cs" Inherits="PRCo.BBOS.UI.Web.Widgets.IndustryPayTrends" %>

<script type="text/javascript">
    function TES() {
        //Show TES
        var TES = document.getElementsByName('btnTES')[0];
        if (TES != undefined) {
          TES.classList.add("bbsButton-primary");
          TES.classList.remove("bbsButton-secondary");
        }

        var divTES = document.getElementById('divTES');
        if (divTES != undefined) {
            divTES.setAttribute('style', 'display:inline')
        }

        //Hide AR
        var AR = document.getElementsByName('btnAR')[0];
        if (AR != undefined) {

          AR.classList.remove("bbsButton-primary");
          AR.classList.add("bbsButton-secondary");
        }

        var divAR = document.getElementById('divAR');
        if (divAR != undefined) {
            divAR.setAttribute('style', 'display:none')
        }
    }

    function AR() {
        //Hide TES
        var TES = document.getElementsByName('btnTES')[0];
      if (TES != undefined) {
          TES.classList.remove("bbsButton-primary");
          TES.classList.add("bbsButton-secondary");
        }

        var divTES = document.getElementById('divTES');
        if (divTES != undefined) {
            divTES.setAttribute('style', 'display:none')
        }

        //Show AR
        var AR = document.getElementsByName('btnAR')[0];
        if (AR != undefined) {
          AR.classList.add("bbsButton-primary");
          AR.classList.remove("bbsButton-secondary");
        }

        if (divAR != undefined) {
            divAR.setAttribute('style', 'display:inline')
        }
    }
</script>

<div class="bbs-list-panel">
    <div class="bbs-list-panel-heading">
        <h3 style="margin-right: auto"><%=string.Format(Resources.Global.IndustryPayTrendsPast12Months,Utilities.GetIntConfigValue("IndustryPayTrendsARCount", 12)) %></h3>
        <h3 style="margin-left: auto; font-size: smaller; white-space:nowrap;">
            <asp:HyperLink ID="hlChangeWidgets" runat="server" NavigateUrl="~/UserProfile.aspx" Text='<%$ Resources:Global, ChangeWidgets %>'  />
        </h3>
        <br style="clear: both;" />
    </div>

    <div class="bbs-list-group">
        <div class="d-flex justify-content-center py-3">
            <span id="divTES">
                <asp:Chart ID="chartPayTrends_TES" runat="server" CssClass="chart">
                    <Legends>
                        <asp:Legend Alignment="Center" Docking="Bottom" IsTextAutoFit="true" Name="Legend" LegendStyle="Table" TableStyle="Wide"
                            Font="Microsoft Sans Serif, 8.0pt" />
                    </Legends>
                    <Series>
                        <asp:Series Name="Series1" ChartType="Pie" XValueMember="PayRatingShort"
                            YValueMembers="PayRatingCount" IsVisibleInLegend="true" IsValueShownAsLabel="False"
                            ChartArea="ChartArea1" MarkerStyle="Square" Color="Black" Font="Microsoft Sans Serif, 10.0pt">
                        </asp:Series>
                    </Series>
                    <ChartAreas>
                        <asp:ChartArea Name="ChartArea1">
                            <AxisX Title="PayRatingShort" IsLabelAutoFit="True"
                                TitleFont="Microsoft Sans Serif, 7.5pt, style=Bold">
                                <MajorGrid LineColor="Gainsboro" />
                                <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 8.0pt, style=Bold" />
                            </AxisX>
                            <AxisY Title='PayRatingCount' Maximum="1000" Minimum="500" Interval="100"
                                IsStartedFromZero="False"
                                TitleFont="Microsoft Sans Serif, 7.5pt, style=Bold">
                                <MajorGrid LineColor="Gainsboro" />
                                <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 8.0pt, style=Bold" />
                            </AxisY>
                        </asp:ChartArea>
                    </ChartAreas>
                </asp:Chart>
            </span>
            <span id="divAR" style="display: none">
                <asp:Chart ID="chartPayTrends_AR" runat="server" CssClass="chart" Visible="false">
                    <Legends>
                        <asp:Legend Alignment="Center" Docking="Bottom" IsTextAutoFit="true" Name="Legend" LegendStyle="Table" TableStyle="Wide"
                            Font="Microsoft Sans Serif, 8.0pt" LegendItemOrder="ReversedSeriesOrder" />
                    </Legends>
                    <Series>
                        <asp:Series Name="0-29 Days" ChartType="StackedColumn100" XValueMember="DisplayText"
                            YValueMembers="Amount0to29Pct" IsVisibleInLegend="true" IsValueShownAsLabel="False"
                            ChartArea="ChartArea1" MarkerStyle="Square" Font="Microsoft Sans Serif, 10.0pt" Color="Green" />
                        <asp:Series Name="30-44 Days" ChartType="StackedColumn100" XValueMember="DisplayText"
                            YValueMembers="Amount30to44Pct" IsVisibleInLegend="true" IsValueShownAsLabel="False"
                            ChartArea="ChartArea1" MarkerStyle="Square" Font="Microsoft Sans Serif, 10.0pt" Color="#056492" />
                        <asp:Series Name="45-60 Days" ChartType="StackedColumn100" XValueMember="DisplayText"
                            YValueMembers="Amount45to60Pct" IsVisibleInLegend="true" IsValueShownAsLabel="False"
                            ChartArea="ChartArea1" MarkerStyle="Square" Font="Microsoft Sans Serif, 10.0pt" Color="#bfbfbf" />
                        <asp:Series Name="61+ Days" ChartType="StackedColumn100" XValueMember="DisplayText"
                            YValueMembers="Amount61PlusPct" IsVisibleInLegend="true" IsValueShownAsLabel="False"
                            ChartArea="ChartArea1" MarkerStyle="Square" Font="Microsoft Sans Serif, 10.0pt" Color="#fcb441" />
                    </Series>
                    <ChartAreas>
                        <asp:ChartArea Name="ChartArea1">
                            <AxisX IsLabelAutoFit="True"
                                TitleFont="Microsoft Sans Serif, 11.0pt, style=Bold">
                                <MajorGrid LineColor="Gainsboro" />
                                <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 8.0pt, style=Bold" />
                            </AxisX>
                            <AxisY Maximum="100" Minimum="0" Interval="10"
                                IsStartedFromZero="True"
                                TitleFont="Microsoft Sans Serif, 11.0pt, style=Bold"
                                Title="%" TextOrientation="Horizontal">
                                <MajorGrid LineColor="Gainsboro" />
                                <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 8.0pt, style=Bold" />
                            </AxisY>
                        </asp:ChartArea>
                    </ChartAreas>
                </asp:Chart>
                <asp:Chart ID="chartPayTrends_AR_Lumber" runat="server" CssClass="chart" Visible="false">
                    <Legends>
                        <asp:Legend Alignment="Center" Docking="Bottom" IsTextAutoFit="true" Name="Legend" LegendStyle="Table" TableStyle="Wide"
                            Font="Microsoft Sans Serif, 8.0pt" LegendItemOrder="ReversedSeriesOrder" />
                    </Legends>
                    <Series>
                        <asp:Series Name="Current" ChartType="StackedColumn100" XValueMember="DisplayText"
                            YValueMembers="AmountCurrentPct" IsVisibleInLegend="true" IsValueShownAsLabel="False"
                            ChartArea="ChartArea1" MarkerStyle="Square" Font="Microsoft Sans Serif, 10.0pt" Color="Green" />
                        <asp:Series Name="1-30 Days" ChartType="StackedColumn100" XValueMember="DisplayText"
                            YValueMembers="Amount1to30Pct" IsVisibleInLegend="true" IsValueShownAsLabel="False"
                            ChartArea="ChartArea1" MarkerStyle="Square" Font="Microsoft Sans Serif, 10.0pt" Color="Purple" />
                        <asp:Series Name="31-60 Days" ChartType="StackedColumn100" XValueMember="DisplayText"
                            YValueMembers="Amount31to60Pct" IsVisibleInLegend="true" IsValueShownAsLabel="False"
                            ChartArea="ChartArea1" MarkerStyle="Square" Font="Microsoft Sans Serif, 10.0pt" Color="#056492" />
                        <asp:Series Name="61-90 Days" ChartType="StackedColumn100" XValueMember="DisplayText"
                            YValueMembers="Amount61to90Pct" IsVisibleInLegend="true" IsValueShownAsLabel="False"
                            ChartArea="ChartArea1" MarkerStyle="Square" Font="Microsoft Sans Serif, 10.0pt" Color="#bfbfbf" />
                        <asp:Series Name="91+ Days" ChartType="StackedColumn100" XValueMember="DisplayText"
                            YValueMembers="Amount91PlusPct" IsVisibleInLegend="true" IsValueShownAsLabel="False"
                            ChartArea="ChartArea1" MarkerStyle="Square" Font="Microsoft Sans Serif, 10.0pt" Color="#fcb441" />
                    </Series>
                    <ChartAreas>
                        <asp:ChartArea Name="ChartArea1">
                            <AxisX IsLabelAutoFit="True"
                                TitleFont="Microsoft Sans Serif, 11.0pt, style=Bold">
                                <MajorGrid LineColor="Gainsboro" />
                                <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 8.0pt, style=Bold" />
                            </AxisX>
                            <AxisY Maximum="100" Minimum="0" Interval="10"
                                IsStartedFromZero="True"
                                TitleFont="Microsoft Sans Serif, 11.0pt, style=Bold"
                                Title="%" TextOrientation="Horizontal">
                                <MajorGrid LineColor="Gainsboro" />
                                <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 8.0pt, style=Bold" />
                            </AxisY>
                        </asp:ChartArea>
                    </ChartAreas>
                </asp:Chart>
            </span>
        </div>

        <div class="d-flex justify-content-center py-3">
          <div class="bbsButton-group-nowrap">
            <button id="btnTES" name="btnTES" class="bbsButton bbsButton-primary" onclick="TES(); return false;" runat="server"><%=Resources.Global.TradeExperiences %></button>
            <button id="btnAR" name="btnAR" class="bbsButton bbsButton-secondary" onclick="AR(); return false;" runat="server"><%=Resources.Global.AccountsReceivable %></button>
        </div></div>
    </div>
</div>
