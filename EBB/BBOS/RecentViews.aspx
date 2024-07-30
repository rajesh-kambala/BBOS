<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="RecentViews.aspx.cs" Inherits="PRCo.BBOS.UI.Web.RecentViews" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentHead" runat="server">
  <style>
    .main-content-old {
      max-width: 100%;
      width: 100%;
    }
  </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
  <div class="tw-flex tw-gap-3 tw-flex-col">
    <div class="bbs-card-bordered">
      <div class="bbs-card-header">
        <asp:Literal ID="fsRecentCompaniesLegend" runat="server" />
      </div>
      <div class="bbs-card-body no-padding">
        <div class="table-responsive">
          <asp:GridView ID="gvRecentCompanies"
            AllowSorting="true"
            runat="server"
            AutoGenerateColumns="false"
            CssClass="table table-hover nested-no-padding"
            GridLines="None"
            OnSorting="GridView_Sorting"
            OnRowDataBound="GridView_RowDataBound"
            HeaderStyle-VerticalAlign="Top">
            <Columns>
              <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" DataField="comp_CompanyID" SortExpression="comp_CompanyID" />

              <%--Icons Column--%>
              <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
                <ItemTemplate>
                  <%# GetCompanyDataForCell((int)Eval("comp_CompanyID"), 
                            (string)Eval("comp_PRBookTradestyle"), 
                            (string)Eval("comp_PRLegalName"), 
                            UIUtils.GetBool(Eval("HasNote")), 
                            UIUtils.GetDateTime(Eval("comp_PRLastPublishedCSDate")), 
                            (string)Eval("comp_PRListingStatus"), 
                            false, 
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
              <asp:TemplateField HeaderText="<%$ Resources:Global, CompanyName %>" HeaderStyle-CssClass="vertical-align-top" SortExpression="comp_PRBookTradestyle">
                <ItemTemplate>
                  <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                  <asp:Literal ID="litLegalName" runat="server" Text='<%# PageBase.ParenWrap(Eval("comp_PRLegalName"))%>' />
                </ItemTemplate>
              </asp:TemplateField>

              <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" DataField="CityStateCountryShort" SortExpression="CountryStAbbrCity" />

              <asp:BoundField HeaderText="<%$ Resources:Global, Industry %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" DataField="IndustryType" SortExpression="IndustryType" />

              <%--Type/Industry Column--%>
              <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" ItemStyle-CssClass="text-left vertical-align-top" SortExpression="CompanyType">
                <HeaderTemplate>
                  <asp:LinkButton ID="lbTypeIndustryColHeader" runat="server" Text='<%$ Resources:Global, Type %>' CommandName="Sort" CommandArgument="CompanyType" />
                  &nbsp;
                  <a id="popWhatIsIndustry" runat="server" class="clr_blc cursor_pointer" data-bs-html="true"  data-bs-toggle="modal" data-bs-target="#pnlIndustry">
                    <span runat="server" title="<%$ Resources:Global, WhatIsThis %>" class="msicon no-translate">help</span>
                  </a>
                </HeaderTemplate>

                <ItemTemplate>
                  <%# PageControlBaseCommon.GetCompanyType((string)Eval("CompanyType"), Eval("comp_PRLocalSource"))%>
                </ItemTemplate>
              </asp:TemplateField>

            </Columns>
          </asp:GridView>

          <div id="pnlIndustry" class="modal fade" role="dialog">
            <div class="modal-dialog">
              <!-- Modal content-->
              <div class="modal-content">
                <div class="modal-header">
                  <button type="button" class="close" data-bs-dismiss="modal">&times;</button>
                </div>
                <div class="modal-body">
                  <span class="sml_font">
                    <%= Resources.Global.IndustryHelp %>
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <asp:Panel ID="pnlRecentPersons" runat="server">
      <div class="bbs-card-bordered">
        <div class="bbs-card-header">
          <asp:Literal ID="fsRecentPersonsLegend" runat="server" />
        </div>
        <div class="bbs-card-body no-padding">
          <div class="table-responsive">
            <asp:GridView ID="gvRecentPersons"
              AllowSorting="true"
              runat="server"
              AutoGenerateColumns="false"
              CssClass="table  table-hover nested-no-padding"
              GridLines="None"
              OnSorting="GridView_Sorting"
              OnRowDataBound="GridView_RowDataBound"
              HeaderStyle-VerticalAlign="Top">
              <Columns>
   

                <%--Person Name column--%>
                <asp:TemplateField HeaderText="<%$ Resources:Global, PersonName %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" SortExpression="pers_LastName" >
                  <ItemTemplate>
                     <div class="tw-flex tw-gap-2">
                    <%# GetPersonDataForCell((int)Eval("pers_PersonID"), (string)Eval("PersonName"), UIUtils.GetBool(Eval("HasNote")), false)%>
                    <%# GetPersonNameForCell((int)Eval("pers_PersonID"), (string)Eval("PersonName")) %>
                    </div>

                  </ItemTemplate>
                </asp:TemplateField>

                <%--BB#--%>
                <asp:TemplateField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top">
                  <ItemTemplate>
                    <%# GetPersonCompanies_BBNum((int)Eval("pers_PersonID"))%>
                  </ItemTemplate>
                </asp:TemplateField>

                <%--Icons Column--%>
                <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
                  <ItemTemplate>
                    <%# GetPersonCompanies_Icons((int)Eval("pers_PersonID"))%>
                  </ItemTemplate>
                </asp:TemplateField>

                <%--Company Name column--%>
                <asp:TemplateField HeaderText="<%$ Resources:Global, CompanyName %>" HeaderStyle-CssClass="vertical-align-top">
                  <ItemTemplate>
                    <%# GetPersonCompanies_CompanyName((int)Eval("pers_PersonID"))%>
                  </ItemTemplate>
                </asp:TemplateField>

                <%--Location--%>
                <asp:TemplateField HeaderText="<%$ Resources:Global, Location %>" HeaderStyle-CssClass="text-nowrap vertical-align-top">
                  <ItemTemplate>
                    <%# GetPersonCompanies_Location((int)Eval("pers_PersonID"))%>
                  </ItemTemplate>
                </asp:TemplateField>
              </Columns>
            </asp:GridView>
          </div>
        </div>
      </div>
    </asp:Panel>
    </div>
  <br />
</asp:Content>
