<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyCSG.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyCSG" Title="Blue Book Services" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="Advertisements" Src="UserControls/Advertisements.ascx" %>

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
  <bbos:Sidebar ID="ucSidebar" runat="server" MenuExpand="1" MenuPage="9" />

  <!-- Main  -->
  <main class="main-content tw-flex tw-flex-col tw-gap-y-4">
    <bbos:PrintHeader ID="ucPrintHeader" runat="server" Title='<% $Resources:Global, ClaimsActivity %>' />
    <bbos:CompanyHero ID="ucCompanyHero" runat="server" />
    <bbos:CompanyBio ID="ucCompanyBio" runat="server" />
    <p class="page-heading"><%= Resources.Global.ChainStoreGuide %></p>
    <section>
      <div class="container">
        <div class="row g-4">
          <div>
            <div class="bbs-card-bordered">
              <div class="bbs-card-header">
                <div class="list-group-item d-flex justify-content-between">
                  <%=Resources.Global.DataLicensedProvidedByCSG %>
                  <span><a href="https://www.chainstoreguide.com" target="_blank">
                    <asp:Image ID="imgCSGLogo" AlternateText="<%$ Resources:Global, CSGLogo %>" Width="124" runat="server" />
                  </a></span>
                </div>
              </div>
              <div class="bbs-card-body no-padding">
                <ul class="list-group list-group-flush">
                  <li class="list-group-item d-flex justify-content-between align-items-center">
                    <%=Resources.Global.TotalUnits %>
                    <span>
                      <asp:Label ID="lblTotalUnits" runat="server" /></span>
                  </li>
                  <li class="list-group-item d-flex justify-content-between align-items-center">
                    <%=Resources.Global.TotalSellingSquareFootage %>
                    <span>
                      <asp:Label ID="lblSquareFootage" runat="server" /></span>
                  </li>
                </ul>
                <bbos:Advertisements ID="Advertisement" Title="" PageName="CompanyDetailsCSG.aspx" CampaignType="CSG" runat="server" />
              </div>
            </div>
          </div>
          <div>
            <div class="bbs-card-bordered">
              <div class="bbs-card-body no-padding">
                <div class="table-responsive">
                  <asp:GridView ID="gvTradeNames"
                    AllowSorting="true"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="table table-hover"
                    GridLines="none">
                    <Columns>
                      <asp:BoundField HeaderText="<%$ Resources:Global, TradeNames %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap" DataField="ValueList" />
                    </Columns>
                  </asp:GridView>
                </div>
              </div>
            </div>
          </div>
          <div>
            <div class="bbs-card-bordered">
              <div class="bbs-card-body no-padding">
                <div class="table-responsive">
                  <asp:GridView ID="gvAreasOfOperations"
                    AllowSorting="true"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="table  table-hover "
                    GridLines="none">

                    <Columns>
                      <asp:BoundField HeaderText="<%$ Resources:Global, AreasOfOperations %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap  " DataField="ValueList" />
                    </Columns>
                  </asp:GridView>
                </div>
              </div>
            </div>
          </div>
          <div>
            <div class="bbs-card-bordered">
              <div class="bbs-card-body no-padding">
                <div class="table-responsive">
                  <asp:GridView ID="gvDistributionCenters"
                    AllowSorting="true"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="table table-hover"
                    GridLines="none">

                    <Columns>
                      <asp:BoundField HeaderText="<%$ Resources:Global, DistributionCenters %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap" DataField="ValueList" />
                    </Columns>
                  </asp:GridView>
                </div>
              </div>
            </div>
          </div>
          <div>
            <div class="bbs-card-bordered">
              <div class="bbs-card-header">
                <h5>
                  <%=Resources.Global.Contacts %>
                </h5>
              </div>
              <div class="bbs-card-body no-padding">
                <div class="table-responsive">
                  <asp:GridView ID="gvContacts"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="table table-hover "
                    GridLines="None"
                    HeaderStyle-VerticalAlign="Top">
                    <Columns>
                      <asp:BoundField HeaderText="<%$ Resources:Global, ContactName %>" HeaderStyle-CssClass="text-nowrap" DataField="Name" SortExpression="prcsgp_LastName" ItemStyle-CssClass="text-nowrap text-left" />
                      <asp:BoundField HeaderText="<%$ Resources:Global, Title %>" HeaderStyle-CssClass="text-nowrap" DataField="prcsgp_Title" SortExpression="prcsgp_Title" ItemStyle-CssClass="text-nowrap text-left" />
                      <asp:TemplateField HeaderText="<%$ Resources:Global, EmailAddress %>" ItemStyle-CssClass="text-nowrap text-left">
                        <ItemTemplate>
                          <asp:HyperLink runat="server" Text='<%# Eval("prcsgp_Email") %>' NavigateUrl='<%# Eval("prcsgp_Email", "mailto:{0}") %>' />
                        </ItemTemplate>
                      </asp:TemplateField>
                    </Columns>
                  </asp:GridView>
                </div>
              </div>
            </div>
          </div>
        </div>
        <br />
      </div>
    </section>
  </main>
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
  <script language="javascript" type="text/javascript">
</script>
</asp:Content>
