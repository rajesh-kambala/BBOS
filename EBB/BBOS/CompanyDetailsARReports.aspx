<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyDetailsARReports.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyDetailsARAReports" %>

<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
</script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box">
        <asp:Label ID="hidCompanyID" Visible="false" runat="server" />

        <div class="row nomargin">
            <div class="col-lg-5 col-md-5 col-sm-12 nopadding_l">
                <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" />
            </div>
        </div>

        <div class="row nomargin_lr nopadding_l">
            <div class="col-md-12 nopadding text-left">
                <asp:Literal runat="server" Text="<%$ Resources:Global, ARReportsTableReflects%>" />
                <%--The AR Reports table below reflects a monthly consolidated presentation of accounts receivable (AR) aging data on the subject firm provided by contributing trading and/or transportation partners of the company.   The AR data may be reflective of disputed transactions and/or product sold on an open or consignment basis.  This table is one of many sources of information available to you as a Blue Book AR contributor to evaluate the credit worthiness of the subject firm.--%>
            </div>
        </div>

        <asp:Panel ID="pnlNoData" Visible="false" runat="server">
            <div class="row nomargin panels_box nopadding_l">
                <div class="row nomargin">
                    <div class="col-md-4 nopadding">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h4 class="blu_tab"><%= Resources.Global.ARReportSummary %></h4>
                            </div>
                            <div class="panel-body nomargin pad10">
                                <div class="form-group">
                                    <div class="col-md-12">
                                        <asp:Literal runat="server" Text="<%$ Resources:Global, NoARReportsAvail%>" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <div class="row nomargin panels_box">
            <asp:Panel ID="pnlReportSummary" runat="server" CssClass="box_left col-lg-4 col-md-5 nopadding_l">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab"><%= Resources.Global.ARReportSummary %> (<asp:Literal ID="litSummaryMonths" runat="server" />
                            months)
                        </h4>
                    </div>
                    <div class="panel-body nomargin pad10">
                        <div class="form-group">
                            <div class="col-md-7">
                                <div class="clr_blu"><%= Resources.Global.AverageMonthlyBalance %>:</div>
                            </div>
                            <div class="col-md-5 text-left">
                                <asp:Literal ID="litAvgMonthlyBalance" runat="server" />
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-7">
                                <div class="clr_blu"><%= Resources.Global.HighBalance %>:</div>
                            </div>
                            <div class="col-md-5 text-left">
                                <asp:Literal ID="litHighBalance" runat="server" />
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-7">
                                <div class="clr_blu"><%= Resources.Global.TotalNumCompaniesReporting %>:</div>
                            </div>
                            <div class="col-md-5 text-left">
                                <asp:Literal ID="litTotalNumCompanies" runat="server" />
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-6">
                                <asp:LinkButton CssClass="btn gray_btn" ID="btnARReportsReport" OnClick="btARReportOnClick" runat="server">
                                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, ARReportsReportDownload %>" />
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <div class="col-lg-8 col-md-7 mar_top_5 nopadding_r" id="pnlARChart" runat="server" style="border: 1px solid gainsboro;">
                <asp:Panel ID="pnlChartProduce" runat="server">
                    <div class="table-responsive">
                        <asp:Chart ID="chartARChartProduce" runat="server" Height="300px">
                            <Titles>
                                <asp:Title Font="Times New Roman, 14pt, style=Bold" Name="Title1"
                                    Text="<%$ Resources:Global, ARReportHistory %>">
                                </asp:Title>
                            </Titles>
                            <Series>
                                <asp:Series Name="<%$ Resources:Global, AR029Days %>" ChartType="StackedColumn" XValueMember="DateDisplay"
                                    YValueMembers="praad_Amount0to29Percent" LabelFormat="###.##"
                                    ChartArea="ChartArea1" Color="LimeGreen">
                                </asp:Series>

                                <asp:Series Name="<%$ Resources:Global, AR3044Days %>" ChartType="StackedColumn" XValueMember="DateDisplay"
                                    YValueMembers="praad_Amount30to44Percent" LabelFormat="###.##"
                                    ChartArea="ChartArea1" Color="RoyalBlue">
                                </asp:Series>

                                <asp:Series Name="<%$ Resources:Global, AR4560Days %>" ChartType="StackedColumn" XValueMember="DateDisplay"
                                    YValueMembers="praad_Amount45to60Percent" LabelFormat="###.##"
                                    ChartArea="ChartArea1" Color="Gold">
                                </asp:Series>
                                <asp:Series Name="<%$ Resources:Global, AR61Days %>" ChartType="StackedColumn" XValueMember="DateDisplay"
                                    YValueMembers="praad_Amount61PlusPercent" LabelFormat="###.##"
                                    ChartArea="ChartArea1" Color="Tomato">
                                </asp:Series>
                            </Series>
                            <Legends>
                                <asp:Legend Name="MobileBrands" Docking="Right" Title="AR Aging" TableStyle="Auto" BorderDashStyle="Solid" LegendItemOrder="SameAsSeriesOrder"
                                    BorderColor="#e8eaf1" TitleSeparator="Line" TitleFont="TimesNewRoman" TitleSeparatorColor="#e8eaf1">
                                </asp:Legend>
                            </Legends>
                            <ChartAreas>
                                <asp:ChartArea Name="ChartArea1" BorderColor="Gainsboro" BorderWidth="1" BorderDashStyle="Solid">
                                    <AxisY Title="% AR Reports" Maximum="100" Minimum="0" Interval="10"
                                        IsStartedFromZero="False"
                                        TitleFont="Microsoft Sans Serif, 12pt, style=Bold">
                                        <MajorGrid LineColor="Gainsboro" />
                                        <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 9.75pt, style=Bold" />
                                    </AxisY>
                                    <AxisX Title="AR Report Date" IsLabelAutoFit="False"
                                        TitleFont="Microsoft Sans Serif, 12pt, style=Bold">
                                        <MajorGrid LineColor="Gainsboro" />
                                        <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 9.75pt, style=Bold" />
                                    </AxisX>
                                </asp:ChartArea>
                            </ChartAreas>
                        </asp:Chart>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlChartLumber" runat="server">
                    <div class="table-responsive">
                        <asp:Chart ID="chartARChartLumber" runat="server" Height="300px">
                            <Titles>
                                <asp:Title Font="Times New Roman, 14pt, style=Bold" Name="Title1"
                                    Text="<%$ Resources:Global, ARReportHistory %>">
                                </asp:Title>
                            </Titles>
                            <Series>
                                <asp:Series Name="<%$ Resources:Global, ARCurrentDays %>" ChartType="StackedColumn" XValueMember="DateDisplay"
                                    YValueMembers="praad_AmountCurrentPercent" LabelFormat="###.##"
                                    ChartArea="ChartArea1" Color="LimeGreen">
                                </asp:Series>

                                <asp:Series Name="<%$ Resources:Global, AR1to30Days %>" ChartType="StackedColumn" XValueMember="DateDisplay"
                                    YValueMembers="praad_Amount1to30Percent" LabelFormat="###.##"
                                    ChartArea="ChartArea1" Color="RoyalBlue">
                                </asp:Series>

                                <asp:Series Name="<%$ Resources:Global, AR31to60Days %>" ChartType="StackedColumn" XValueMember="DateDisplay"
                                    YValueMembers="praad_Amount31to60Percent" LabelFormat="###.##"
                                    ChartArea="ChartArea1" Color="Gold">
                                </asp:Series>
                                <asp:Series Name="<%$ Resources:Global, AR61to90Days %>" ChartType="StackedColumn" XValueMember="DateDisplay"
                                    YValueMembers="praad_Amount61to90Percent" LabelFormat="###.##"
                                    ChartArea="ChartArea1" Color="Orange">
                                </asp:Series>
                                <asp:Series Name="<%$ Resources:Global, AR91Days %>" ChartType="StackedColumn" XValueMember="DateDisplay"
                                    YValueMembers="praad_Amount91PlusPercent" LabelFormat="###.##"
                                    ChartArea="ChartArea1" Color="Tomato">
                                </asp:Series>
                            </Series>
                            <Legends>
                                <asp:Legend Name="MobileBrands" Docking="Right" Title="AR Aging" TableStyle="Auto" BorderDashStyle="Solid" LegendItemOrder="SameAsSeriesOrder"
                                    BorderColor="#e8eaf1" TitleSeparator="Line" TitleFont="TimesNewRoman" TitleSeparatorColor="#e8eaf1">
                                </asp:Legend>
                            </Legends>
                            <ChartAreas>
                                <asp:ChartArea Name="ChartArea1" BorderColor="Gainsboro" BorderWidth="1" BorderDashStyle="Solid">
                                    <AxisY Title="% AR Reports" Maximum="100" Minimum="0" Interval="10"
                                        IsStartedFromZero="False"
                                        TitleFont="Microsoft Sans Serif, 12pt, style=Bold">
                                        <MajorGrid LineColor="Gainsboro" />
                                        <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 9.75pt, style=Bold" />
                                    </AxisY>
                                    <AxisX Title="AR Report Date" IsLabelAutoFit="False"
                                        TitleFont="Microsoft Sans Serif, 12pt, style=Bold">
                                        <MajorGrid LineColor="Gainsboro" />
                                        <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 9.75pt, style=Bold" />
                                    </AxisX>
                                </asp:ChartArea>
                            </ChartAreas>
                        </asp:Chart>
                    </div>
                </asp:Panel>
            </div>
        </div>

        <div class="row nomargin panels_box">
            <asp:UpdatePanel runat="server" ID="pnlARReports">
                <ContentTemplate>
                    <a name="ARReports" class="anchor"></a>
                    <div class="col-md-12 text-center mar_top_5 nopadding">
                        <h4 class="blu_tab">
                            <asp:Label ID="lblARReports" Text="<%$ Resources:Global, ARReportHistory %>" runat="server" /></h4>
                    </div>

                    <div class="col-md-12 nopadding">
                        <div class="pad5">
                            <div class="table-responsive">
                                <asp:GridView ID="gvARReports"
                                    AllowSorting="true"
                                    runat="server"
                                    AutoGenerateColumns="false"
                                    CssClass="table table-striped table-hover tab_bdy"
                                    GridLines="None">
                                    <Columns>
                                        <asp:BoundField HeaderText="<%$ Resources:Global, MonthSubmitted %>" HeaderStyle-CssClass="vertical-align-top" DataField="DateDisplay" />
                                        <asp:BoundField HeaderText="<%$ Resources:Global, NumCompanies %>" HeaderStyle-CssClass="text-center vertical-align-top" DataField="Submitter Count" ItemStyle-CssClass="text-center" />
                                        <asp:BoundField HeaderText="<%$ Resources:Global, TotalBalance %>" HeaderStyle-CssClass="text-right vertical-align-top" DataField="praad_TotalAmount" ItemStyle-CssClass="text-right" DataFormatString="${0:###,###,##0.00}" />
                                        <asp:TemplateField HeaderStyle-CssClass="text-right vertical-align-top" HeaderText="<%$ Resources:Global, AR029Days %>" ItemStyle-CssClass="text-right">
                                            <ItemTemplate>
                                                <%# GetARAmount(Eval("praad_Amount0to29"), Eval("praad_Amount0to29Percent")) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderStyle-CssClass="text-right vertical-align-top" HeaderText="<%$ Resources:Global, AR3044Days %>" ItemStyle-CssClass="text-right">
                                            <ItemTemplate>
                                                <%# GetARAmount(Eval("praad_Amount30to44"), Eval("praad_Amount30to44Percent")) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderStyle-CssClass="text-right vertical-align-top" HeaderText="<%$ Resources:Global, AR4560Days %>" ItemStyle-CssClass="text-right">
                                            <ItemTemplate>
                                                <%# GetARAmount(Eval("praad_Amount45to60"), Eval("praad_Amount45to60Percent")) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderStyle-CssClass="text-right vertical-align-top" HeaderText="<%$ Resources:Global, AR61Days %>" ItemStyle-CssClass="text-right">
                                            <ItemTemplate>
                                                <%# GetARAmount(Eval("praad_Amount61Plus"), Eval("praad_Amount61PlusPercent")) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>
</asp:Content>
