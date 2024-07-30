<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserListAddTo.aspx.cs" Inherits="PRCo.BBOS.UI.Web.UserListAddTo" MasterPageFile="~/BBOS.Master" MaintainScrollPositionOnPostback="true" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <style>
    .main-content-old {
      width: 100%;
    }
  </style>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
  <div class="clearfix"></div>
  <div class="tw-flex tw-flex-col tw-gap-4 p-4">
    <div>
      <div class="bbs-card-bordered">
        <div class="bbs-card-header">
          <h5>
            <asp:Label ID="lblRecordCount" runat="server" />
          </h5>
        </div>
        <div class="bbs-card-body no-padding">

          <div class="table-responsive">
            <asp:GridView ID="gvSelectedCompanies"
              AllowSorting="true"
              runat="server"
              AutoGenerateColumns="false"
              CssClass="table table-hover"
              GridLines="none"
              OnSorting="GridView_Sorting"
              OnRowDataBound="GridView_RowDataBound"
              DataKeyNames="comp_CompanyID">

              <Columns>
                <%--BBNumber Column--%>
                <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="text-nowrap vertical-align-top"
                  DataField="comp_CompanyID" SortExpression="comp_CompanyID" />

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
                    <br />
                  </ItemTemplate>
                </asp:TemplateField>

                <%--Company Name column--%>
                <asp:TemplateField HeaderText="<%$ Resources:Global, CompanyName %>" HeaderStyle-CssClass="vertical-align-top" SortExpression="comp_PRBookTradestyle">
                  <ItemTemplate>
                    <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                  </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left" DataField="CityStateCountryShort"
                  SortExpression="CityStateCountryShort" />

                <asp:BoundField HeaderText="<%$ Resources:Global, Industry %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left" DataField="IndustryType"
                  SortExpression="IndustryType" />

                <%--Type/Industry Column--%>
                <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" ItemStyle-CssClass="text-left vertical-align-top" SortExpression="CompanyType">
                  <HeaderTemplate>
                    <asp:LinkButton ID="lbTypeIndustryColHeader" runat="server" Text='<%$ Resources:Global, Type %>' CommandName="Sort" CommandArgument="CompanyType" />
                    &nbsp;
                        <a id="popWhatIsIndustry" runat="server" class="clr_blc cursor_pointer" data-bs-html="true" data-bs-toggle="modal" data-bs-target="#pnlIndustry">
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
    </div>

    <div>
      <div class="bbs-card-bordered">
        <div class="bbs-card-header">
          <h5>
            <%= Resources.Global.SelectWatchdogListAddCompanyText %>
      
          </h5>
        </div>
        <div class="bbs-card-body no-padding">
          <div class="table-responsive">
            <asp:GridView ID="gvUserList"
              AllowSorting="true"
              runat="server"
              AutoGenerateColumns="false"
              CssClass="table table-hover"
              GridLines="None"
              OnSorting="UserListGridView_Sorting"
              OnRowDataBound="GridView_RowDataBound">

              <Columns>
                <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top col-sm-1">
                  <HeaderTemplate>
                    <% =Resources.Global.Select%>
                    <br />
                    <% =PageBase.GetCheckAllCheckbox("cbUserListID")%>
                  </HeaderTemplate>
                  <ItemTemplate>
                    <input type="checkbox" name="cbUserListID" value="<%# Eval("prwucl_WebUserListID") %>" <%# GetChecked((int)Eval("prwucl_WebUserListID")) %> />
                  </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="<%$ Resources:Global, WatchdogListName %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left vertical-align-top col-sm-8" SortExpression="prwucl_Name">
                  <ItemTemplate>
                    <a href="<%# PageConstants.Format(PageConstants.USER_LIST, DataBinder.Eval(Container.DataItem, "prwucl_WebUserListID")) %>">
                      <%# PageControlBaseCommon.GetCategoryIcon(Eval("prwucl_CategoryIcon"), Eval("prwucl_Name"))%>
                      <%# DataBinder.Eval(Container.DataItem, "prwucl_Name")%>
            </a>
                  </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="<%$ Resources:Global, Private %>" ItemStyle-CssClass="vertical-align-top text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top col-sm-1" SortExpression="prwucl_IsPrivate">
                  <ItemTemplate>
                    <%# UIUtils.GetStringFromBool(Eval("prwucl_IsPrivate"))%>
                  </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="text-nowrap vertical-align-top col-sm-1" HeaderText="<%$ Resources:Global, UpdatedDate %>" SortExpression="UpdatedDate">
                  <ItemTemplate>
                    <%# GetStringFromDate(DataBinder.Eval(Container.DataItem, "UpdatedDate"))%>
                  </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField HeaderText="<%$ Resources:Global, CompanyCount %>" HeaderStyle-CssClass="vertical-align-top col-sm-1" ItemStyle-CssClass="vertical-align-top text-left" DataField="CompanyCount" SortExpression="CompanyCount" />
              </Columns>
            </asp:GridView>
          </div>
        </div>
      </div>
    </div>

    <div class="tw-flex tw-gap-3 tw-justify-between tw-flex-wrap p-2 tw-bg-bg-secondary tw-border-t" style="position: sticky; bottom: 0">
      <div>
      <asp:LinkButton ID="btnNew" runat="server" CssClass="bbsButton bbsButton-secondary full-width filled" OnClick="btnNew_Click" OnClientClick="return ValidateWDCount();">
        <span class="msicon notranslate" runat="server">sound_detection_dog_barking</span>
        <span><asp:Literal runat="server" Text="<%$ Resources:Global, btnNewWatchdogList %>" /></span>
      </asp:LinkButton>
        </div>
      <div class="tw-flex tw-gap-3">
      <asp:LinkButton ID="btnCancel" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnCancel_Click">
        <span class="msicon notranslate" runat="server">cancel</span>
        <span><asp:Literal runat="server" Text="<%$ Resources:Global, Cancel %>" /></span>
      </asp:LinkButton>
      <asp:LinkButton ID="btnSave" runat="server" CssClass="bbsButton bbsButton-primary filled" OnClick="btnSave_Click">
        <span class="msicon notranslate" runat="server">save</span>
        <span><asp:Literal runat="server" Text="<%$ Resources:Global, Save %>" /></span>
      </asp:LinkButton>
      </div>
    </div>
    <asp:HiddenField ID="hidWatchdogGroupMax" runat="server" />
    <asp:HiddenField ID="hidIsLumber_STANDARD" runat="server" />
    <asp:HiddenField ID="hidWatchdogGroupCount" runat="server" />
  </div>
    <br />
</asp:Content>


<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
  <script type="text/javascript">
    function ValidateWDCount() {
      if ($('#<%=hidIsLumber_STANDARD.ClientID%>').val() == "True") {
        var iMax = Number($('#<%=hidWatchdogGroupMax.ClientID%>').val());
        var iCurrent = Number($('#<%=hidWatchdogGroupCount.ClientID%>').val());
        if (iCurrent >= iMax) {
          bbAlert("Your membership only allows a maximum of " + iMax + " Watchdog Groups, and you have already have "
            + iCurrent + ".", "Membership Watchdog Group Count Exceeded");
          return false;
        }
      }
      return true;
    }
  </script>
</asp:Content>
