<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserListList.aspx.cs" Inherits="PRCo.BBOS.UI.Web.UserListList"
  EnableEventValidation="false" MasterPageFile="~/BBOS.Master" MaintainScrollPositionOnPostback="true" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
  <style>
    .content-container div.row a.gray_btn {
      display: inline;
      width: auto;
      margin-right: 10px;
      margin-bottom: 20px;
    }

    .main-content-old {
      max-width: 100%;
      width: 100%;
    }
  </style>


  <div class="bbs-card-bordered">
    <div class="bbs-card-header">
      <div class="tw-flex tw-flex-wrap tw-justify-end tw-gap-3">
        <asp:LinkButton ID="btnNew" runat="server" CssClass="bbsButton bbsButton-secondary small filled" OnClick="btnNew_Click" OnClientClick="return ValidateWDCount();">
	    <span class="msicon notranslate" aria-hidden="true" runat="server">playlist_add</span>
    <asp:Literal runat="server" Text="<%$Resources:Global, btnNewWatchdogList %>" />
        </asp:LinkButton>

        <asp:LinkButton ID="btnEdit" runat="server" CssClass="bbsButton bbsButton-secondary small filled" OnClick="btnEdit_Click">
	    <span class="msicon notranslate" aria-hidden="true" runat="server">edit</span>
    <asp:Literal runat="server" Text="<%$Resources:Global, btnEdit %>" />
        </asp:LinkButton>

        <asp:LinkButton ID="btnDelete" runat="server" CssClass="bbsButton bbsButton-secondary small filled" OnClick="btnDelete_Click">
	    <span class="msicon notranslate" aria-hidden="true" runat="server">delete</span>
    <asp:Literal runat="server" Text="<%$Resources:Global, Delete %>" />
        </asp:LinkButton>

        <asp:LinkButton ID="btnMap" runat="server" CssClass="bbsButton bbsButton-secondary small filled" OnClientClick="displayUserListMap();return false;">
	    <span class="msicon notranslate" aria-hidden="true" runat="server">location_on</span>
    <asp:Literal runat="server" Text="<%$Resources:Global, ShowOnMap %>" />
        </asp:LinkButton>
      </div>
    </div>
    <div class="bbs-card-body no-padding">
      <asp:GridView ID="gvUserList"
        AllowSorting="true"
        runat="server"
        AutoGenerateColumns="false"
        CssClass=" table  table-hover"
        GridLines="None"
        OnSorting="GridView_Sorting"
        OnRowDataBound="GridView_RowDataBound"
        HeaderStyle-VerticalAlign="Top">

        <Columns>
          <asp:TemplateField HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center">
            <HeaderTemplate>
              <% =Resources.Global.Select%>
            </HeaderTemplate>
            <ItemTemplate>
              <input type="checkbox" name="rbUserListID" value="<%# Eval("prwucl_WebUserListID") %>" />
            </ItemTemplate>
          </asp:TemplateField>

          <asp:TemplateField HeaderText="<%$ Resources:Global, WatchdogListName %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left" SortExpression="prwucl_Name">
            <ItemTemplate>
              <a href="<%# PageConstants.Format(PageConstants.USER_LIST, DataBinder.Eval(Container.DataItem, "prwucl_WebUserListID")) %>" class="explicitlink">
                <%# PageControlBaseCommon.GetCategoryIcon(Eval("prwucl_CategoryIcon"), Eval("prwucl_Name"))%>
                <%# DataBinder.Eval(Container.DataItem, "prwucl_Name")%>
                </a>
              <%# DataBinder.Eval(Container.DataItem, "prwucl_Description")%>
            </ItemTemplate>
          </asp:TemplateField>

          <asp:TemplateField HeaderText="<%$ Resources:Global, Private %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap" SortExpression="prwucl_IsPrivate">
            <ItemTemplate>
              <%# UIUtils.GetStringFromBool(Eval("prwucl_IsPrivate"))%>
            </ItemTemplate>
          </asp:TemplateField>

          <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap" HeaderText="<%$ Resources:Global, LastUpdatedDate %>" SortExpression="UpdatedDate">
            <ItemTemplate>
              <%# PageBase.GetStringFromDate(DataBinder.Eval(Container.DataItem, "UpdatedDate"))%>
            </ItemTemplate>
          </asp:TemplateField>

          <asp:TemplateField HeaderText="<%$ Resources:Global, LastUpdatedBy %>" ItemStyle-CssClass="text-left">
            <ItemTemplate>
              <%# GetUserListLastUpdatedBy((int)Eval("prwucl_WebUserListID"))%>
            </ItemTemplate>
          </asp:TemplateField>

          <asp:BoundField HeaderText="<%$ Resources:Global, CompanyCount %>" ItemStyle-CssClass="text-left" DataField="CompanyCount" SortExpression="CompanyCount" />
        </Columns>
      </asp:GridView>
    </div>
  </div>

  <asp:HiddenField ID="hidWatchdogGroupMax" runat="server" />
  <asp:HiddenField ID="hidIsLumber_STANDARD" runat="server" />
  <asp:HiddenField ID="hidWatchdogGroupCount" runat="server" />
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
