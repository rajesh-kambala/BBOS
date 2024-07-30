<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="PersonSearchResults.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PersonSearchResults" MaintainScrollPositionOnPostback="true" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
  <script type="text/javascript">
</script>
  <style>
    td a img {
      margin-top: 3px;
    }

    .main-content-old {
      max-width: 100%;
      width: 100%;
    }
  </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">

  <asp:HiddenField ID="hidSelectedCount" runat="server" Value="0" />
  <asp:HiddenField ID="hidExportsMax" runat="server" Value="0" />
  <asp:HiddenField ID="hidExportsUsed" runat="server" Value="0" />
  <asp:HiddenField ID="hidExportsPeriod" runat="server" Value="M" />

  <div class="tw-flex tw-flex-col tw-gap-3">

    <div class="tw-flex tw-justify-end tw-flex-wrap tw-gap-3">
      <asp:LinkButton ID="btnSaveSearch" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnSaveSearch_Click">
	        <span class="msicon notranslate" aria-hidden="true" runat="server">saved_search</span>
          <asp:Literal runat="server" Text="<%$ Resources:Global, SaveSearch %>" />
      </asp:LinkButton>
      <asp:LinkButton ID="btnEditSearchCriteria" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnEditSearchCriteria_Click">
	        <span class="msicon notranslate" aria-hidden="true" runat="server">edit</span>
          <asp:Literal runat="server" Text="<%$ Resources:Global, EditSearchCriteria %>" />
      </asp:LinkButton>
      <asp:LinkButton ID="btnNewSearch" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnNewSearch_Click" OnClientClick="return confirmOverrwrite('NewSearch')">
	        <span class="msicon notranslate" aria-hidden="true" runat="server">find_replace</span>
          <asp:Literal runat="server" Text="<%$ Resources:Global, NewSearch %>" />
      </asp:LinkButton>
    </div>

    <div class="bbs-card-bordered">
      <div class="bbs-card-header tw-flex tw-justify-between tw-flex-wrap tw-gap-3">
        <div>
          <asp:Label ID="lblRecordCount" runat="server" />&nbsp;|&nbsp;
        <span id="lblSelectedCount">&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Selected%>" /></span>
        </div>
        <div class="tw-flex tw-gap-3 tw-flex-wrap tw-justify-end">
          <asp:LinkButton ID="btnPrintList" runat="server" CssClass="bbsButton bbsButton-secondary filled small" OnClick="btnPrintList_Click">
	        <span class="msicon notranslate" aria-hidden="true" runat="server">print</span>
          <asp:Literal runat="server" Text="<%$ Resources:Global, btnPrintList %>" />
          </asp:LinkButton>
          <asp:LinkButton ID="btnExportData" runat="server" CssClass="bbsButton bbsButton-secondary filled small" OnClick="btnExportData_Click">
	        <span class="msicon notranslate" aria-hidden="true" runat="server">export_notes</span>
          <asp:Literal runat="server" Text="<%$ Resources:Global, btnExportData %>" />
          </asp:LinkButton>
        </div>
      </div>
      <div class="bbs-card-body no-padding">
        <asp:GridView ID="gvSearchResults"
          AllowSorting="true"
          runat="server"
          AutoGenerateColumns="false"
          CssClass=" table table-hover nested-no-padding"
          GridLines="None"
          OnSorting="GridView_Sorting"
          OnRowDataBound="GridView_RowDataBound"
          SortField="LastName"
          DataKeyNames="PersonId,SourceTable"
          HeaderStyle-VerticalAlign="Top">

          <Columns>
            <asp:TemplateField ItemStyle-CssClass="text-center vertical-align-top" HeaderStyle-CssClass="text-center vertical-align-top">
              <HeaderTemplate>
                <% =Resources.Global.Select%><br />
                <% =PageBase.GetCheckAllCheckbox("cbPersonID", "setSelectedCount();")%>
              </HeaderTemplate>
              <ItemTemplate>
                <input type="checkbox" name="cbPersonID" value="<%# Eval("PersonId") %>" <%# GetChecked((int)Eval("PersonId")) %> onclick="setSelectedCount();" />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField Visible="false" ShowHeader="false">
              <ItemTemplate>
                <input type="hidden" id="hidSource" value="<%# (string)Eval("SourceTable") %>" />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderStyle-CssClass="text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, PersonName %>" SortExpression="LastName" >
              <ItemTemplate>
                <div class="tw-flex tw-gap-2">
                <%# GetPersonDataForCell((int)Eval("PersonId"), (string)Eval("PersonName"), UIUtils.GetBool(Eval("HasNote")), (string)Eval("SourceTable"))%>
                  </div>
              </ItemTemplate>
            </asp:TemplateField>

            <%--BBNumber Column--%>
            <asp:TemplateField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left">
              <ItemTemplate>
                <%# GetBBNumbers((int)Eval("PersonID"), (string)Eval("SourceTable"))%>
              </ItemTemplate>
            </asp:TemplateField>

            <%--Icons Column--%>
            <asp:TemplateField  HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
               <HeaderTemplate>
                <span class="msicon notranslate">notifications_active</span>
                </HeaderTemplate>
              <ItemTemplate>
                <%# GetCompanyNames((int)Eval("PersonID"), (string)Eval("SourceTable"), true, false)%>
              </ItemTemplate>
            </asp:TemplateField>

            <%--Company Name column--%>
            <asp:TemplateField HeaderText="<%$ Resources:Global, CompanyName %>" HeaderStyle-CssClass="text-nowrap vertical-align-top">
              <ItemTemplate>
                <%# GetCompanyNames((int)Eval("PersonID"), (string)Eval("SourceTable"), false, true)%>
              </ItemTemplate>
            </asp:TemplateField>

            <%--Location column--%>
            <asp:TemplateField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left vertical-align-top">
              <ItemTemplate>
                <%# GetCompanyLocations((int)Eval("PersonID"), (string)Eval("SourceTable"))%>
              </ItemTemplate>
            </asp:TemplateField>
          </Columns>
        </asp:GridView>
      </div>
    </div>
  
  </div>
  <br />
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
  <script type="text/javascript">
    function setSelectedCount() {
      var c = getSelectedCountInternal("cbPersonID");
      $('#<% =hidSelectedCount.ClientID %>').attr('value', c);

      setSelectedCountInternal("cbPersonID", "lblSelectedCount", "");
    }

    setSelectedCount();
    </script>
</asp:Content>
