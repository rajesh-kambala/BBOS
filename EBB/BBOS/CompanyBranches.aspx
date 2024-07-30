<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyBranches.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyBranches" Title="Blue Book Services" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

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
  <bbos:Sidebar ID="ucSidebar" runat="server" MenuExpand="1" MenuPage="5" />

  <!-- Main  -->
  <main class="main-content tw-flex tw-flex-col tw-gap-y-4">
    <bbos:PrintHeader ID="ucPrintHeader" runat="server" Title='<% $Resources:Global, BranchesAndAffiliations %>' />
    <bbos:CompanyHero ID="ucCompanyHero" runat="server" />
    <bbos:CompanyBio ID="ucCompanyBio" runat="server" />
    <bbos:CompanyDetailsHeaderMeister ID="ucCompanyDetailsHeaderMeister" runat="server" />
    <p class="page-heading"><%= Resources.Global.BranchesAndAffiliations %></p>
    <section class="container">
      <div class="row nomargin panels_box" id="pAll">
        <div class="tw-flex tw-gap-4 tw-flex-col col-xs-12 gap-4">
          <div class="bbs-card-bordered">
            <div class="bbs-card-header tw-flex tw-gap-4 tw-justify-between">
              <h5>
                <asp:Literal runat="server" Text="<%$ Resources:Global, Headquarters %>" /></h5>
              <div class="tw-flex tw-gap-2 tw-flex-wrap tw-justify-end">
                <a id="btnBranches" class="bbsButton bbsButton-secondary filled small" href="#Branches">
                  <span class="msicon notranslate">move_down</span>
                  <span><%= Resources.Global.Branches %></span>
                </a>
                <a id="btnAffiliations" class="bbsButton bbsButton-secondary filled small" href="#Affiliations">
                  <span class="msicon notranslate">move_down</span>
                  <span><%= Resources.Global.Affiliations %></span>
                </a>
              </div>
            </div>
            <div class="bbs-card-body">
              <asp:HyperLink ID="hlHQName" runat="server" CssClass="explicitlink" /><br />
              <asp:Literal ID="litLocation" runat="server" />
              <p><% =Resources.Global.BBNumber %><asp:Literal ID="litBBID" runat="server" /></p>
            </div>
          </div>

          <%--Branches--%>
          <div class="bbs-card-bordered">
            <a name="Branches" class="anchor"></a>
            <div class="bbs-card-header tw-flex tw-gap-4 tw-justify-between">
              <asp:Label ID="lblBranches" CssClass="text-center" Text="<%$ Resources:Global, Branches %>" runat="server" />
              <div class="tw-flex tw-gap-2 tw-flex-wrap tw-justify-end">
                <asp:LinkButton CssClass="bbsButton bbsButton-secondary filled small" ID="btnReportsBranches" OnClick="btnReportsBranches_Click" runat="server">
                  <span class="msicon notranslate">download</span>
                  <span><asp:Literal runat="server" Text="<%$ Resources:Global, btnReports %>" /></span>
                </asp:LinkButton>
                <asp:LinkButton CssClass="bbsButton bbsButton-secondary filled small" ID="btnExportDataBranches" OnClick="btnExportDataBranches_Click" runat="server">
                  <span class="msicon notranslate">export_notes</span>
                  <span><asp:Literal runat="server" Text="<%$ Resources:Global, btnExportData %>" /></span>
                </asp:LinkButton>
                <asp:LinkButton CssClass="bbsButton bbsButton-secondary filled small" ID="btnAddToWatchdogBranches" OnClick="btnAddToWatchdogBranches_Click" runat="server">
                  <span class="msicon notranslate">playlist_add</span>
                  <span><asp:Literal runat="server" Text="<%$ Resources:Global, btnAddToWatchdogList %>" /></span>
                </asp:LinkButton>
              </div>
            </div>
            <div class="bbs-card-body no-padding">
              <div class="table-responsive">
                <asp:UpdatePanel runat="server">
                  <ContentTemplate>
                    <asp:GridView ID="gvBranches"
                      AllowSorting="true"
                      runat="server"
                      AutoGenerateColumns="false"
                      CssClass="table table-hover"
                      GridLines="None"
                      OnSorting="BranchesGridView_Sorting"
                      OnRowDataBound="GridView_RowDataBound">

                      <Columns>
                        <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="tw-font-semibold text-center vertical-align-top">
                          <HeaderTemplate>
                            <% =Resources.Global.Select%><br />
                            <% =GetCheckAllCheckbox("cbBranchID", "setSelectedCount_Branches();")%>
                          </HeaderTemplate>
                          <ItemTemplate>
                            <input type="checkbox" name="cbBranchID" value="<%# DataBinder.Eval(Container.DataItem, "comp_CompanyID") %>" onclick="setSelectedCount_Branches();" />
                          </ItemTemplate>
                        </asp:TemplateField>

                        <%--BBNumber Column--%>
                        <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top" ItemStyle-CssClass="text-start" DataField="comp_CompanyID" SortExpression="comp_CompanyID" />

                        <%--Icons Column--%>
                        <asp:TemplateField HeaderText="" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top border-end-0" ItemStyle-CssClass="text-nowrap text-end border-end-0">
                          <ItemTemplate>
                            <%# GetCompanyDataForCell((int)Eval("comp_CompanyID"), 
                                  (string)Eval("comp_PRBookTradestyle"), 
                                  (string)Eval("comp_PRLegalName"), 
                                  UIUtils.GetBool(Eval("HasNote")), 
                                  UIUtils.GetDateTime(Eval("comp_PRLastPublishedCSDate")), 
                                  (string)Eval("comp_PRListingStatus"), 
                                  true, 
                                  UIUtils.GetBool(Eval("HasNewClaimActivity")), 
                                  UIUtils.GetBool(Eval("HasMeritoriousClaim")), 
                                  UIUtils.GetBool(Eval("HasCertification")), 
                                  UIUtils.GetBool(Eval("HasCertification_Organic")), 
                                  UIUtils.GetBool(Eval("HasCertification_FoodSafety")), 
                                  true, 
                                  false)%>
                          </ItemTemplate>
                        </asp:TemplateField>

                        <%--Company Name column--%>
                        <asp:TemplateField HeaderStyle-CssClass="tw-font-semibold text-start vertical-align-top" ItemStyle-CssClass="text-start" HeaderText="<%$ Resources:Global, CompanyName %>" SortExpression="comp_PRBookTradestyle">
                          <ItemTemplate>
                            <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                            <%--<br />
                              <%# Eval("CityStateCountryShort") %>--%>
                          </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top" ItemStyle-CssClass="text-start" DataField="CityStateCountryShort" SortExpression="CityStateCountryShort" />
                        <asp:BoundField HeaderText="<%$ Resources:Global, Industry %>" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top" ItemStyle-CssClass="text-start" DataField="IndustryType" SortExpression="IndustryType" />
                        <asp:BoundField HeaderText="<%$ Resources:Global, Phone2 %>" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top" ItemStyle-CssClass="text-start" DataField="Phone" />
                      </Columns>
                    </asp:GridView>
                  </ContentTemplate>
                </asp:UpdatePanel>
              </div>
            </div>
          </div>

            <asp:HiddenField ID="hidSelectedCount_Branches" runat="server" Value="0" />
            <asp:HiddenField ID="hidExportsMax_Branches" runat="server" Value="0" />
            <asp:HiddenField ID="hidExportsUsed_Branches" runat="server" Value="0" />
            <asp:HiddenField ID="hidExportsPeriod_Branches" runat="server" Value="M" />




          <%--Affiliations--%>
          <div class="bbs-card-bordered">
            <a name="Affiliations" class="anchor"></a>
            <div class="bbs-card-header tw-flex tw-gap-4 tw-justify-between">
              <asp:Label ID="lblAffiliations" CssClass="text-center" Text="<%$ Resources:Global, Affiliations %>" runat="server" />
              <div class="tw-flex tw-gap-2 tw-flex-wrap tw-justify-end">
                <asp:LinkButton CssClass="bbsButton bbsButton-secondary filled small" ID="btnReports" OnClick="btnReports_Click" runat="server">
                           <span class="msicon notranslate">download</span>
                           <span><asp:Literal runat="server" Text="<%$ Resources:Global, btnReports %>" /></span>
                </asp:LinkButton>
                <asp:LinkButton CssClass="bbsButton bbsButton-secondary filled small" ID="btnExportData" OnClick="btnExportData_Click" runat="server">
                            <span class="msicon notranslate">export_notes</span>
                            <span><asp:Literal runat="server" Text="<%$ Resources:Global, btnExportData %>" /></span>
                </asp:LinkButton>
                <asp:LinkButton CssClass="bbsButton bbsButton-secondary filled small" ID="btnAddToWatchdog" OnClick="btnAddToWatchdog_Click" runat="server">
                            <span class="msicon notranslate">playlist_add</span>
                            <span><asp:Literal runat="server" Text="<%$ Resources:Global, btnAddToWatchdogList %>" /></span>
                </asp:LinkButton>
              </div>

            </div>
            <div class="bbs-card-body no-padding">
              <div class="table-responsive">
                <asp:UpdatePanel runat="server">
                  <ContentTemplate>
                    <asp:GridView ID="gvAffiliations"
                      AllowSorting="true"
                      runat="server"
                      AutoGenerateColumns="false"
                      CssClass="table table-hover"
                      GridLines="None"
                      SortField="comp_CompanyID"
                      OnSorting="AffiliationsGridView_Sorting"
                      OnRowDataBound="GridView_RowDataBound">

                      <Columns>
                        <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="tw-font-semibold text-center vertical-align-top">
                          <HeaderTemplate>
                            <% =Resources.Global.Select%><br />
                            <% =GetCheckAllCheckbox("cbAffiliateID", "setSelectedCount_Affiliates();")%>
                          </HeaderTemplate>
                          <ItemTemplate>
                            <input type="checkbox" name="cbAffiliateID" value="<%# DataBinder.Eval(Container.DataItem, "comp_CompanyID") %>" onclick="setSelectedCount_Affiliates();" />
                          </ItemTemplate>
                        </asp:TemplateField>

                        <%--BBNumber Column--%>
                        <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top" ItemStyle-CssClass="text-start" DataField="comp_CompanyID" SortExpression="comp_CompanyID" />

                        <%--Icons Column--%>
                        <asp:TemplateField HeaderText="" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top border-end-0" ItemStyle-CssClass="text-nowrap text-end border-end-0">
                          <ItemTemplate>
                            <%# GetCompanyDataForCell((int)Eval("comp_CompanyID"), 
                                  (string)Eval("comp_PRBookTradestyle"), 
                                  (string)Eval("comp_PRLegalName"), 
                                  UIUtils.GetBool(Eval("HasNote")), 
                                  UIUtils.GetDateTime(Eval("comp_PRLastPublishedCSDate")), 
                                  (string)Eval("comp_PRListingStatus"), 
                                  true, 
                                  UIUtils.GetBool(Eval("HasNewClaimActivity")), 
                                  UIUtils.GetBool(Eval("HasMeritoriousClaim")), 
                                  UIUtils.GetBool(Eval("HasCertification")), 
                                  UIUtils.GetBool(Eval("HasCertification_Organic")), 
                                  UIUtils.GetBool(Eval("HasCertification_FoodSafety")), 
                                  true, 
                                  false)%>
                          </ItemTemplate>
                        </asp:TemplateField>

                        <%--Company Name column--%>
                        <asp:TemplateField HeaderStyle-CssClass="tw-font-semibold text-start vertical-align-top" ItemStyle-CssClass="text-start vertical-align-top"
                          HeaderText="<%$ Resources:Global, CompanyName %>" SortExpression="comp_PRBookTradestyle">
                          <ItemTemplate>
                            <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                            <%--<br />
                      <%# Eval("CityStateCountryShort") %>--%>
                          </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top" DataField="CityStateCountryShort" SortExpression="CityStateCountryShort" />
                        <asp:BoundField HeaderText="<%$ Resources:Global, Industry %>" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top" DataField="IndustryType" SortExpression="IndustryType" />

                        <asp:TemplateField HeaderText="<%$ Resources:Global, Rating %>" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top">
                          <ItemTemplate>
                            <asp:Literal ID="litRatingLine" runat="server" />
                          </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField HeaderText="<%$ Resources:Global, Phone2 %>" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top" DataField="Phone" />
                        <asp:TemplateField HeaderText="<%$ Resources:Global, WebSite %>" ItemStyle-CssClass="text-start" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top">
                          <ItemTemplate>
                            <%# GetCompanyURL(Eval("emai_PRWebAddress")) %>
                          </ItemTemplate>
                        </asp:TemplateField>
                      </Columns>
                    </asp:GridView>

                  </ContentTemplate>
                </asp:UpdatePanel>
              </div>
            </div>
          </div>

            <asp:HiddenField ID="hidSelectedCount_Affiliates" runat="server" Value="0" />
            <asp:HiddenField ID="hidExportsMax_Affiliates" runat="server" Value="0" />
            <asp:HiddenField ID="hidExportsUsed_Affiliates" runat="server" Value="0" />
            <asp:HiddenField ID="hidExportsPeriod_Affiliates" runat="server" Value="M" />

          <div id="pnlRatingDef" style="display: none; width: 400px; height: auto; min-height: 300px; position: absolute; z-index: 100;" class="Popup">
            <div class="popup_header">
              <%--<span class="annotation" onclick="document.getElementById('pnlRatingDef').style.display='none';">Close</span>--%>
              <%--<img src="<% =UIUtils.GetImageURL("close.gif") %>" alt="Close" align="middle" onclick="document.getElementById('pnlRatingDef').style.display='none';" />--%>
              <button type="button" class="close" data-bs-dismiss="modal" onclick="document.getElementById('pnlRatingDef').style.display='none';">&times;</button>
            </div>
            <span id="ltRatingDef"></span>
          </div>

         
        </div>
      </div>
      <br />
    </section>
  </main>
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
    <script language="javascript" type="text/javascript">
        function setSelectedCount_Branches() {
            var c = getSelectedCountInternal("cbBranchID");
            $('#<% =hidSelectedCount_Branches.ClientID %>').attr('value', c);
        }
        function setSelectedCount_Affiliates() {
            var c = getSelectedCountInternal("cbAffiliateID");
            $('#<% =hidSelectedCount_Affiliates.ClientID %>').attr('value', c);
        }

        setSelectedCount_Branches();
        setSelectedCount_Affiliates();
    </script>
</asp:Content>
