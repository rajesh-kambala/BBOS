<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="PersonSearchCustom.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PersonSearchCustom" MaintainScrollPositionOnPostback="true" %>

<%@ Register Src="UserControls/PersonSearchCriteriaControl.ascx" TagName="PersonSearchCriteriaControl" TagPrefix="uc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
  <style>
    .main-content-old {
      width: 100%;
    }
  </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
  <asp:Panel ID="pnlSearch" DefaultButton="btnSearch" runat="server" CssClass="tw-px-4">
    <div class="row g-3">
      <%--Buttons--%>
      <div class="tw-flex tw-flex-wrap tw-gap-2 tw-justify-end">

        <asp:LinkButton ID="btnLoadSearch" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClientClick="return confirmOverrwrite('LoadSearch')" OnClick="btnLoadSearch_Click">
                    <span class="msicon notranslate">input</span>
                    <span><asp:Literal runat="server" Text="<%$ Resources:Global, LoadSearch %>" /></span>
        </asp:LinkButton>

        <asp:LinkButton ID="btnClearAllCriteria" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnClearAllCriteria_Click">
                    <span class="msicon notranslate">clear_all</span>
                    <span><asp:Literal runat="server" Text="<%$ Resources:Global, ClearAll %>" /></span>
        </asp:LinkButton>

        <asp:LinkButton ID="btnSaveSearch" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnSaveSearch_Click">
                    <span class="msicon notranslate">saved_search</span>
                    <span><asp:Literal runat="server" Text="<%$ Resources:Global, SaveSearch %>" /></span>
        </asp:LinkButton>
        <asp:LinkButton ID="btnSearch" runat="server" CssClass="bbsButton bbsButton-primary" OnClick="btnSearch_Click">
                    <span class="msicon notranslate">search</span>
                    <span><asp:Literal runat="server" Text="<%$ Resources:Global, Search %>" /></span>
        </asp:LinkButton>
      </div>

      <div class="bbslayout_splitView tw-gap-3 bbslayout_second_onTop">
        <div class="bbslayout_first_split">
          <%--Search Form--%>
          <div>
            <div class="bbs-card-bordered" id="pnlCriteria" runat="server">
              <div class="bbs-card-header tw-flex tw-justify-between">
                     <h5><%=Resources.Global.CustomCriteria %>
                      </h5>
                      <asp:LinkButton ID="btnClearCriteria" runat="server" CssClass="bbsButton bbsButton-secondary filled small" OnClick="btnClearCriteria_Click">
                  <span class="msicon notranslate">clear</span>
                  <span><asp:Literal runat="server" Text="<%$ Resources:Global, ClearThisCriteria %>" /></span>
                      </asp:LinkButton>
              </div>
              <div class="bbs-card-body">
                <div class="col-md-12 nopadding_lr text-nowrap">
                  <asp:CheckBox ID="chkCompanyHasNotes" runat="server" AutoPostBack="true" />
                  <asp:Label ID="lblHasNotes" AssociatedControlID="chkCompanyHasNotes"  for="chkCompanyHasNotes" runat="server" CssClass="bbos_blue"><%=Resources.Global.PersonHasNotes %></asp:Label>
                </div>
              </div>
              <hr />
              <div class="row nomargin panels_box">
                <div class="col-md-12 nopadding">
                  <asp:Panel ID="pnlWatchdogList" runat="server">
                    <div class="tw-p-2"><%= Resources.Global.SelectWatchdogListsText %>:</div>
                    <div class="bbs-card-body no-padding">
                    <asp:GridView ID="gvUserList"
                      AllowSorting="true"
                      runat="server"
                      AutoGenerateColumns="false"
                      CssClass=" table table-hover"
                      GridLines="None"
                      OnSorting="UserListGridView_Sorting"
                      OnRowDataBound="GridView_RowDataBound">

                      <Columns>
                        <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top">
                          <HeaderTemplate>
                            <% =Resources.Global.Select%><br />
                            <% =GetCheckAllCheckbox("cbUserListID")%>
                          </HeaderTemplate>
                          <ItemTemplate>
                            <input type="checkbox" name="cbUserListID" value="<%# Eval("prwucl_WebUserListID") %>"
                              <%# GetChecked((int)Eval("prwucl_WebUserListID")) %> onclick="refreshCriteria();" />
                          </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Global, WatchdogListName %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left vertical-align-top" SortExpression="prwucl_Name">
                          <ItemTemplate>
                            <a href="<%# PageConstants.Format(PageConstants.USER_LIST, Eval("prwucl_WebUserListID")) %>" class="explicitlink">
                              <%# PageControlBaseCommon.GetCategoryIcon(Eval("prwucl_CategoryIcon"), Eval("prwucl_Name"))%>
                              <%# Eval("prwucl_Name")%>
                                 </a>
                          </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, Private %>" SortExpression="prwucl_IsPrivate">
                          <ItemTemplate>
                            <%# UIUtils.GetStringFromBool(Eval("prwucl_IsPrivate"))%>
                          </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left vertical-align-top" HeaderText="<%$ Resources:Global, UpdatedDate_NoBR %>" SortExpression="UpdatedDate">
                          <ItemTemplate>
                            <%# GetStringFromDate(Eval("UpdatedDate"))%>
                          </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField HeaderText="<%$ Resources:Global, CompanyCount %>" HeaderStyle-CssClass="text-left vertical-align-top" ItemStyle-CssClass="text-left vertical-align-top" DataField="CompanyCount" SortExpression="CompanyCount" />
                      </Columns>
                    </asp:GridView>
                      </div>
                  </asp:Panel>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="bbslayout_second_split">
          <%--Selected Criteria--%>
          <div>
            <asp:UpdatePanel ID="UpdatePanel1" runat="server">
              <ContentTemplate>
                <uc1:PersonSearchCriteriaControl ID="ucPersonSearchCriteriaControl" runat="server" />
              </ContentTemplate>
              <Triggers>
                <asp:AsyncPostBackTrigger ControlID="chkCompanyHasNotes" EventName="CheckedChanged" />
              </Triggers>
            </asp:UpdatePanel>
          </div>
        </div>
      </div>

    </div>
  </asp:Panel>
  <br />
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
  <script type="text/javascript">
    btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');

    function refreshCriteria() {
            <%=ClientScript.GetPostBackEventReference(UpdatePanel1, "")%>;
    }

    var cbCheckAll = document.getElementById('cbCheckAll');
    cbCheckAll.addEventListener('click', refreshCriteria);
    </script>
</asp:Content>
