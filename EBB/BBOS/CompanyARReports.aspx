<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyARReports.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyARReports" Title="Blue Book Services" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeaderMeister" Src="UserControls/CompanyDetailsHeaderMeister.ascx" %>

<%@ Register TagPrefix="bbos" TagName="Sidebar" Src="UserControls/Sidebar.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyHero" Src="UserControls/CompanyHero.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyBio" Src="UserControls/CompanyBio.ascx" %>

<%@ Register TagPrefix="bbos" TagName="PrintHeader" Src="UserControls/PrintHeader.ascx" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Import Namespace="PRCo.EBB.BusinessObjects" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="contentMain" ContentPlaceHolderID="contentMain" runat="server">
  <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
  <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" Visible="false" />
</asp:Content>

<asp:Content ID="contentLeftSidebar" ContentPlaceHolderID="contentLeftSidebar" runat="server">
  <!-- Left nav bar  -->
  <bbos:Sidebar ID="ucSidebar" runat="server" MenuExpand="1" MenuPage="3" />

  <!-- Main  -->
  <main class="main-content tw-flex tw-flex-col tw-gap-y-4">
    <bbos:PrintHeader ID="ucPrintHeader" runat="server" Title='<% $Resources:Global, ARReports %>' />
    <bbos:CompanyHero ID="ucCompanyHero" runat="server" />
    <bbos:CompanyBio ID="ucCompanyBio" runat="server" />
    <bbos:CompanyDetailsHeaderMeister ID="ucCompanyDetailsHeaderMeister" runat="server" />
    <p class="page-heading"><%= Resources.Global.ARReports %></p>
    <section>
      <div id="pAll">

        <%--For No AR data--%>
        <asp:Panel ID="pnlNoData" Visible="false" runat="server">
          <div class="bbs-card-bordered">
            <div class="bbs-card-header"><%= Resources.Global.ARReportSummary %></div>
            <div class="bbs-card-body">
              <asp:Literal runat="server" Text="<%$ Resources:Global, NoARReportsAvail%>" />
            </div>
          </div>
        </asp:Panel>

        <%--For AR data--%>
        <div class="container">
          <div class="row g-4">
            <div class="col-md-8">
              <asp:Literal runat="server" Text="<%$ Resources:Global, ARReportsTableReflects%>" />
              <%--The AR Reports table below reflects a monthly consolidated presentation of accounts receivable 
                          (AR) aging data on the subject firm provided by contributing trading and/or transportation partners of the company.]
                          The AR data may be reflective of disputed transactions and/or product sold on an open or consignment basis.
                          This table is one of many sources of information available to you as a Blue Book AR contributor to evaluate 
                          the credit worthiness of the subject firm.--%>
            </div>

            <asp:Panel ID="pnlReportSummary" runat="server" class="col-md-4">
              <div class="bbs-card-bordered">
                <div class="bbs-card-header">
                  <%= Resources.Global.ARReportSummary %> (<asp:Literal ID="litSummaryMonths" runat="server" />
                  months)
                </div>
                <div class="bbs-card-body no-padding">
                  <ul class="list-group list-group-flush">
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                      <%= Resources.Global.AverageMonthlyBalance %>
                      <span>
                        <asp:Literal ID="litAvgMonthlyBalance" runat="server" /></span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                      <%= Resources.Global.HighBalance %>
                      <span>
                        <asp:Literal ID="litHighBalance" runat="server" /></span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                      <%= Resources.Global.TotalNumCompaniesReporting %>
                      <span>
                        <asp:Literal ID="litTotalNumCompanies" runat="server" /></span>
                    </li>
                  </ul>
                </div>
              </div>
            </asp:Panel>

            <%--AR Chart--%>
            <div id="pnlARChart" runat="server" class="col-sm-12">
              <%--Chart for Produce--%>
              <asp:Panel ID="pnlChartProduce" runat="server">
                <div class="table-responsive tw-rounded tw-border tw-border-border" style="width: fit-content;">
                  <asp:Chart ID="chartARChartProduce" runat="server" Height="300px" CssClass="object-fit-contain " >
                    <Titles>
                      <asp:Title Font="Sans, 14pt, style=Bold" Name="Title1"
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
                        <AxisY Title="<%$ Resources:Global, PercentageARReport %>"  Maximum="100" Minimum="0" Interval="10"
                          IsStartedFromZero="False"
                          TitleFont="Microsoft Sans Serif, 12pt, style=Bold">
                          <MajorGrid LineColor="Gainsboro" />
                          <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 9.75pt, style=Bold" />
                        </AxisY>
                        <AxisX Title="<%$ Resources:Global, ARReportDate %>" IsLabelAutoFit="False"
                          TitleFont="Microsoft Sans Serif, 12pt, style=Bold">
                          <MajorGrid LineColor="Gainsboro" />
                          <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 9.75pt, style=Bold" />
                        </AxisX>
                      </asp:ChartArea>
                    </ChartAreas>
                  </asp:Chart>
                </div>
              </asp:Panel>
              <%--Chart for Lumber--%>
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
                        <AxisY Title="<%$ Resources:Global, PercentageARReport %>" Maximum="100" Minimum="0" Interval="10"
                          IsStartedFromZero="False"
                          TitleFont="Microsoft Sans Serif, 12pt, style=Bold">
                          <MajorGrid LineColor="Gainsboro" />
                          <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 9.75pt, style=Bold" />
                        </AxisY>
                        <AxisX Title="<%$ Resources:Global, ARReportDate %>" IsLabelAutoFit="False"
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



            <%--This is the AR Table--%>
            <asp:UpdatePanel runat="server" ID="pnlARReports">
              <ContentTemplate>
                <a name="ARReports" class="anchor"></a>
                <div class="bbs-card-bordered">
                  <div class="bbs-card-header tw-flex tw-justify-between">
                    <asp:Label ID="lblARReports" Text="<%$ Resources:Global, ARReportHistory %>" runat="server" />
                    <asp:LinkButton CssClass="bbsButton bbsButton-secondary filled small" ID="btnARReportsReport" OnClick="btARReportOnClick" runat="server">
                      <span class="msicon notranslate">download</span>
                      <span><asp:Literal runat="server" Text="<%$ Resources:Global, ARReportsReportDownload %>" /></span>
                    </asp:LinkButton>
                  </div>
                  <div class="bbs-card-body no-padding overflow-auto">
                    <div class="table-responsive">
                      <asp:GridView ID="gvARReports"
                        AllowSorting="true"
                        runat="server"
                        AutoGenerateColumns="false"
                        CssClass="table table-hover"
                        GridLines="None">
                        <Columns>
                          <asp:BoundField HeaderText="<%$ Resources:Global, MonthSubmitted %>" HeaderStyle-Width="100px" HeaderStyle-CssClass="tw-font-semibold vertical-align-top" DataField="DateDisplay" />
                          <asp:BoundField HeaderText="<%$ Resources:Global, NumCompanies %>" HeaderStyle-Width="50px" HeaderStyle-CssClass="tw-font-semibold text-end vertical-align-top" DataField="Submitter Count" ItemStyle-CssClass="text-end" />
                          <asp:BoundField HeaderText="<%$ Resources:Global, TotalBalance %>" HeaderStyle-CssClass="tw-font-semibold text-end vertical-align-top" DataField="praad_TotalAmount" ItemStyle-CssClass="text-end" DataFormatString="${0:###,###,##0.00}" />
                          <asp:TemplateField HeaderStyle-CssClass="tw-font-semibold text-end vertical-align-top" HeaderText="<%$ Resources:Global, AR029Days %>" ItemStyle-CssClass="text-end">
                            <ItemTemplate>
                              <%# GetARAmount(Eval("praad_Amount0to29"), Eval("praad_Amount0to29Percent")) %>
                            </ItemTemplate>
                          </asp:TemplateField>

                          <asp:TemplateField HeaderStyle-CssClass="tw-font-semibold text-end vertical-align-top" HeaderText="<%$ Resources:Global, AR3044Days %>" ItemStyle-CssClass="text-end">
                            <ItemTemplate>
                              <%# GetARAmount(Eval("praad_Amount30to44"), Eval("praad_Amount30to44Percent")) %>
                            </ItemTemplate>
                          </asp:TemplateField>

                          <asp:TemplateField HeaderStyle-CssClass="tw-font-semibold text-end vertical-align-top" HeaderText="<%$ Resources:Global, AR4560Days %>" ItemStyle-CssClass="text-end">
                            <ItemTemplate>
                              <%# GetARAmount(Eval("praad_Amount45to60"), Eval("praad_Amount45to60Percent")) %>
                            </ItemTemplate>
                          </asp:TemplateField>

                          <asp:TemplateField HeaderStyle-CssClass="tw-font-semibold text-end vertical-align-top" HeaderText="<%$ Resources:Global, AR61Days %>" ItemStyle-CssClass="text-end">
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
      </div>
      <br />
    </section>
  </main>
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
  <script language="javascript" type="text/javascript">
</script>
</asp:Content>
