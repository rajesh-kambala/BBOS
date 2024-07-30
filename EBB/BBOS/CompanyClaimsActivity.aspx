<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyClaimsActivity.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyClaimsActivity" Title="Blue Book Services" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

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
  <bbos:Sidebar ID="ucSidebar" runat="server" MenuExpand="1" MenuPage="4" />

  <!-- Main  -->
  <main class="main-content tw-flex tw-flex-col tw-gap-y-4">
    <bbos:PrintHeader ID="ucPrintHeader" runat="server" Title='<% $Resources:Global, ClaimsActivity %>' />
    <bbos:CompanyHero ID="ucCompanyHero" runat="server" />
    <bbos:CompanyBio ID="ucCompanyBio" runat="server" />
    <bbos:CompanyDetailsHeaderMeister ID="ucCompanyDetailsHeaderMeister" runat="server" />
    <p class="page-heading"><%= Resources.Global.ClaimsActivity %></p>
    <section>
      <div class="container">
        <div class="row g-4">
          <div>
            <div class="bbsButton-group-nowrap" role="group" aria-label="Basic outlined example">
              <a href="#BBSICases" class="bbsButton bbsButton-secondary filled" id="btnBBSICases">
                <asp:Literal runat="server" Text="<%$ Resources:Global, ClaimsFiledwithBlueBook %>" /></a>
              <a href="#PACACases" class="bbsButton bbsButton-secondary filled" id="btnPACACases">
                <asp:Literal runat="server" Text="<%$ Resources:Global, PACAReparationCases%>" /></a>
              <a href="#Lawsuit" class="bbsButton bbsButton-secondary filled" id="btnLawsuit">
                <asp:Literal runat="server" Text="<%$ Resources:Global, Lawsuits %>" /></a>
            </div>
          </div>

          <a name="BBSICases">
            <div class="bbs-card-bordered">
              <div class="bbs-card-header">
                <h5>
                  <asp:Literal runat="server" Text="<%$ Resources:Global, ClaimsFiledwithBlueBook %>" />
                </h5>
              </div>
              <div class="bbs-card-body no-padding">
                <p class="tw-p-4">
                  <asp:Literal ID="ClaimsFiledHeader" runat="server" />
                </p>
                <div class="table-responsive">
                  <asp:GridView ID="gvBBSClaims"
                    AllowSorting="true"
                    Width="100%"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="table table-striped table-hover tab_bdy"
                    GridLines="None"
                    OnSorting="GridView_Sorting"
                    OnRowDataBound="GridView_RowDataBound"
                    HeaderStyle-VerticalAlign="Top">
                    <Columns>
                      <asp:BoundField DataField="prss_OpenedDate" HeaderText="<%$ Resources:Global, DateBRFiled%>" SortExpression="prss_OpenedDate" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top explicitlink" DataFormatString="{0:M/d/yyyy}" HtmlEncode="false" />
                      <asp:BoundField DataField="prss_CATDataChanged" HeaderText="<%$ Resources:Global, LastBRActivity%>" SortExpression="prss_CATDataChanged" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top explicitlink" DataFormatString="{0:M/d/yyyy}" HtmlEncode="false" />
                      <asp:BoundField DataField="prss_SSFileID" HeaderText="<%$ Resources:Global, FileID%>" SortExpression="prss_SSFileID" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top explicitlink" />

                      <asp:TemplateField HeaderText="<%$ Resources:Global, OpenClosed%>" SortExpression="Status" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="text-start vertical-align-top explicitlink">
                        <ItemTemplate>
                          <%# GetStatus(Eval("Status"), Eval("prss_ClosedDate"))%>
                        </ItemTemplate>
                      </asp:TemplateField>

                      <asp:BoundField DataField="ClaimantIndustry" HeaderText="<%$ Resources:Global, ClaimantBRType%>" SortExpression="ClaimantIndustry" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top explicitlink" HtmlEncode="false" />
                      <asp:BoundField DataField="prss_InitialAmountOwed" HeaderText="<%$ Resources:Global, ClaimBRAmount%>" SortExpression="prss_InitialAmountOwed" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top explicitlink" DataFormatString="{0:c}" HtmlEncode="false" />
                      <asp:BoundField DataField="prss_PublishedIssueDesc" HeaderText="<%$ Resources:Global, IssueDescription%>" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top" />
                      <asp:BoundField DataField="prss_StatusDescription" HeaderText="<%$ Resources:Global, Status%>" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top" />
                      <asp:BoundField DataField="Meritorious" HeaderText="<%$ Resources:Global, Meritorious%>" SortExpression="Meritorious" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top explicitlink" />
                      <asp:TemplateField HeaderText="<%$ Resources:Global, Note%>" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top">
                        <ItemTemplate>
                          <asp:Image ID="noteImage" runat="server" ImageUrl='<%# UIUtils.GetImageURL("ClaimActivity-Note.png") %>' Visible='<%# DisplayNotes(Eval("prss_PublishedNotes")) %>' Style="cursor: pointer;" />
                          <asp:Panel ID="note" Style="width: 450px; min-height: 300px; text-align: left; display: none;" CssClass="Popup" runat="server">
                            <div class="popup_header">
                              <span style="float: left"><b>Note</b></span>
                              <button id="btnClose" type="button" class="close" onclick="body.click();" runat="server">&times;</button>
                            </div>
                            <div class="popup_content" style="padding: 12px;">
                              <%# FormatTextForHTML(Eval("prss_PublishedNotes"))%>
                            </div>
                          </asp:Panel>

                          <cc1:PopupControlExtender ID="PopupControlExtender4" runat="server"
                            TargetControlID="noteImage"
                            PopupControlID="note"
                            OffsetX="-450"
                            Position="Bottom" />
                        </ItemTemplate>
                      </asp:TemplateField>
                    </Columns>
                  </asp:GridView>
                </div>
              </div>
            </div>
          </a>

          <a name="PACACases">
            <div class="bbs-card-bordered">
              <div class="bbs-card-header">
                <h5>
                  <asp:Literal runat="server" Text="<%$ Resources:Global, PACAReparationCases %>" />
                </h5>
              </div>
              <div class="bbs-card-body ">
                <p id="divPACAReparationCaseHeaderMsg" runat="server">
                  <%= Resources.Global.PACAReparationCaseHeaderMsg %>
                </p>

                <div id="divComplaints" class="container tw-mt-4" runat="server">
                  <div class="row gy-4">
                    <div class="col-12 col-md-6">
                      <div class="bbs-card-bordered">
                        <div class="bbs-card-header">
                          <asp:Label ID="lblInformalComplaints" runat="server" Text="<%$ Resources:Global, InformalComplaints %>" />
                        </div>
                        <div class="bbs-card-body no-padding">
                          <ul class="list-group list-group-flush">
                            <li class="list-group-item d-flex justify-content-between align-items-center">
                              <asp:Literal runat="server" Text="<%$ Resources:Global, NoofInformalReparationComplaints %>" />
                              <span>
                                <asp:Literal ID="litInformal" runat="server" /></span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between align-items-center">
                              <asp:Literal runat="server" Text="<%$ Resources:Global, NoofDisputedInformalReparationComplaints %>" />
                              <span>
                                <asp:Literal ID="litDisputedInformal" runat="server" /></span>
                            </li>
                          </ul>
                        </div>
                      </div>
                    </div>
                    <div class="col-12 col-md-6">
                      <div class="bbs-card-bordered">
                        <div class="bbs-card-header">
                          <asp:Label ID="lblFormalComplaints" runat="server" Text="<%$ Resources:Global, FormalComplaints %>" />
                        </div>
                        <div class="bbs-card-body no-padding">
                          <ul class="list-group list-group-flush">
                            <li class="list-group-item d-flex justify-content-between align-items-center">
                              <asp:Literal runat="server" Text="<%$ Resources:Global, NoofFormalReparationComplaints %>" />
                              <span>
                                <asp:Literal ID="litFormal" runat="server" /></span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between align-items-center">
                              <asp:Literal runat="server" Text="<%$ Resources:Global, NoofDisputedFormalReparationComplaints %>" />
                              <span>
                                <asp:Literal ID="litDisputedFormal" runat="server" /></span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between align-items-center">
                              <asp:Literal runat="server" Text="<%$ Resources:Global, TotalClaimAmount %>" />
                              <span>
                                <asp:Literal ID="litTotalClaimAmount" runat="server" /></span>
                            </li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <div id="divNoComplaints" runat="server" visible="false">
                  <%=Resources.Global.PACAReparation1 %>
                </div>

              </div>
            </div>
          </a>

          <a name="Lawsuit">
            <div class="bbs-card-bordered">
              <div class="bbs-card-header">
                <h5>
                  <asp:Literal runat="server" Text="<%$ Resources:Global, Lawsuits %>" />
                </h5>
              </div>
              <div class="bbs-card-body no-padding">
                <p class="tw-p-4">
                  <%=Resources.Global.LawsuitsFiled1 %>
                  <asp:Literal ID="FederalCivilCasesThreshold" runat="server" />
                  <%=Resources.Global.LawsuitsFiled2 %>
                </p>
                <div class="table-responsive">
                  <asp:GridView ID="gvFederalCivilCases"
                    AllowSorting="true"
                    Width="100%"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="table table-striped table-hover tab_bdy"
                    GridLines="None"
                    OnSorting="GridView_Sorting"
                    OnRowDataBound="GridView_RowDataBound"
                    HeaderStyle-VerticalAlign="Top">

                    <Columns>
                      <asp:BoundField DataField="prcc_FiledDate" HeaderText="<%$ Resources:Global, DateFiled%>" SortExpression="prcc_FiledDate" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top explicitlink" DataFormatString="{0:MM/dd/yyyy}" />
                      <asp:BoundField DataField="prcc_CaseNumber" HeaderText="<%$ Resources:Global, CaseNum%>" SortExpression="prcc_CaseNumber" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top explicitlink" />
                      <asp:BoundField DataField="Court" HeaderText="<%$ Resources:Global, Court%>" SortExpression="Court" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top explicitlink" />
                      <asp:BoundField DataField="prcc_SuitType" HeaderText="<%$ Resources:Global, SuitType%>" SortExpression="prcc_SuitType" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top explicitlink" />
                      <asp:BoundField DataField="prcc_ClaimAmt" HeaderText="<%$ Resources:Global, ClaimAmount%>" SortExpression="prcc_ClaimAmt" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top explicitlink" DataFormatString="{0:c}" />
                      <asp:BoundField DataField="prcc_CaseOperatingStatus" HeaderText="<%$ Resources:Global, CaseStatus%>" SortExpression="prcc_CaseOperatingStatus" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top explicitlink" />
                      <asp:TemplateField HeaderText="<%$ Resources:Global, Note%>" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="vertical-align-top">
                        <ItemTemplate>
                          <asp:Image ID="noteImage" runat="server" ImageUrl='<%# UIUtils.GetImageURL("ClaimActivity-Note.png") %>' Visible='<%# DisplayNotes(Eval("prcc_Notes")) %>' Style="cursor: pointer;" />
                          <asp:Panel ID="note" Style="width: 450px; min-height: 300px; text-align: left; display: none;" CssClass="Popup" runat="server">
                            <div class="popup_header">
                              <span style="float: left"><b>Note</b></span>
                              <button id="btnClose" type="button" class="close" onclick="body.click();" runat="server">&times;</button>
                            </div>
                            <div class="popup_content" style="padding: 12px;">
                              <%# FormatTextForHTML(Eval("prcc_Notes"))%>
                            </div>
                          </asp:Panel>

                          <cc1:PopupControlExtender ID="PopupControlExtender4" runat="server"
                            TargetControlID="noteImage"
                            PopupControlID="note"
                            OffsetX="-450"
                            Position="Bottom" />
                        </ItemTemplate>
                      </asp:TemplateField>
                    </Columns>
                  </asp:GridView>
                </div>
                <asp:Panel ID="pnlButtons" runat="server">
                  <div class="row text-start">
                    <asp:LinkButton OnClick="btnBusinessReportOnClick" ID="btnBusinessReport" CssClass="btn gray_btn" runat="server">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/><asp:Literal runat="server" Text="<%$ Resources:Global, btnGetBusinessReport %>" />
                    </asp:LinkButton>
                  </div>
                </asp:Panel>
              </div>
            </div>
          </a>
        </div>
      </div>
      <br />
    </section>
  </main>
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
  <script language="javascript" type="text/javascript">
    $(function () {
      $("#contentLeftSidebar_gvFederalCivilCases .Popup").css("margin-top", "-300px");
      $("#contentLeftSidebar_gvFederalCivilCases .Popup .close").click(function () {
        $("html,body").click();
      });
    });
  </script>
</asp:Content>
