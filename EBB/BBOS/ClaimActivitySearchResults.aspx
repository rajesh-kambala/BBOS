<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="ClaimActivitySearchResults.aspx.cs" Inherits="PRCo.BBOS.UI.Web.ClaimActivitySearchResults" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
  <script type="text/javascript">
</script>
  <style>
    th {
      white-space: nowrap;
    }

    .main-content-old {
      width: 100%;
    }
  </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
  <div class="p-4 tw-flex tw-flex-col tw-gap-3">
    <asp:Label ID="hidSearchID" runat="server" Visible="false" />
    <asp:Panel ID="pnlResults" runat="server">
      <div class="bbs-card-bordered ">
        <div class="bbs-card-header tw-flex tw-justify-between" style="position:sticky; top:44px;">
          <%--Record Count--%>
            <span><asp:Label ID="lblRecordCount" runat="server" />&nbsp;|&nbsp;<span id="lblSelectedCount"></span></span>
            <div class="tw-flex tw-justify-end tw-gap-3">
              <asp:LinkButton ID="btnAddToWatchdogList" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnAddToWatchdogListOnClick">
	          <span class="msicon notranslate" runat="server">playlist_add</span>
            <asp:Literal runat="server" Text="<%$ Resources:Global, btnAddToWatchdogList %>" />
              </asp:LinkButton>

              <asp:LinkButton ID="btnRefine" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnRefineOnClick">
	          <span class="msicon notranslate" runat="server">edit</span>
            <asp:Literal runat="server" Text="<%$ Resources:Global, EditSearchCriteria %>" />
              </asp:LinkButton>
            </div>
        </div>
        <div class="bbs-card-body no-padding">
          <div class="table-responsive">
            <asp:GridView ID="gvSearchResults"
              AllowSorting="true"
              runat="server"
              AutoGenerateColumns="false"
              CssClass=" table  table-hover"
              GridLines="None"
              OnSorting="GridView_Sorting"
              OnRowDataBound="GridView_RowDataBound"
              HeaderStyle-VerticalAlign="Top">

              <Columns>
                <asp:TemplateField ItemStyle-CssClass="Select text-center" HeaderStyle-CssClass="text-center vertical-align-top">
                  <HeaderTemplate>
                    <!--% =Resources.Global.Select%-->
                    <% =PageBase.GetCheckAllCheckbox("cbCompanyID", "setSelectedCount();")%>
                  </HeaderTemplate>
                  <ItemTemplate>
                    <input type="checkbox" name="cbCompanyID" value="<%# Eval("comp_CompanyID") %>" <%# GetCompanyChecked((int)Eval("comp_CompanyID")) %> onclick="setSelectedCount();" />
                  </ItemTemplate>
                </asp:TemplateField>

                <%--BBNumber Column--%>
                <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left" DataField="comp_CompanyID" SortExpression="comp_CompanyID" />

                <%--Icons Column--%>
                <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
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
                <asp:TemplateField HeaderText="<%$ Resources:Global, CompanyName %>" HeaderStyle-CssClass="vertical-align-top" SortExpression="comp_PRBookTradestyle">
                  <ItemTemplate>
                    <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                    <asp:Literal ID="litLegalName" runat="server" Text='<%# PageBase.ParenWrap(Eval("comp_PRLegalName"))%>' />
                  </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="vertical-align-top" DataField="CityStateCountryShort" SortExpression="CountryStAbbrCity" />

                <asp:HyperLinkField HeaderText="<%$ Resources:Global, Type %>" SortExpression="ClaimType" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left vertical-align-top"
                  DataNavigateUrlFields="comp_CompanyID"
                  DataNavigateUrlFormatString="CompanyClaimsActivity.aspx?CompanyID={0}"
                  ControlStyle-CssClass="explicitlink"
                  DataTextField="ClaimType" />

                <asp:TemplateField HeaderText="<%$ Resources:Global, FiledDate %>" HeaderStyle-CssClass="vertical-align-top" SortExpression="FiledDate" ItemStyle-CssClass="text-left vertical-align-top">
                  <ItemTemplate>
                    <%# PageBase.GetStringFromDate(Eval("FiledDate"))%>
                  </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField DataField="ClaimID" HeaderText="<%$ Resources:Global, FileIDCaseNum %>" SortExpression="ClaimID" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="vertical-align-top" />
                <asp:BoundField DataField="ClaimAmount" HeaderText="<%$ Resources:Global, ClaimAmount %>" SortExpression="ClaimAmount" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left vertical-align-top" DataFormatString="{0:c}" HtmlEncode="false" />
              </Columns>
            </asp:GridView>
          </div>
        </div>
      </div>
    </asp:Panel>
  </div>
  <br />
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptSection" runat="server">
  <script type="text/javascript">
    function setSelectedCount() {
      setSelectedCountInternal("cbCompanyID", "lblSelectedCount");
    }

    setSelectedCount();
    </script>
</asp:Content>
