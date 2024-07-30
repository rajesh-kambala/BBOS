<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SearchList.aspx.cs" Inherits="PRCo.BBOS.UI.Web.SearchList" MasterPageFile="~/BBOS.Master" MaintainScrollPositionOnPostback="true" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
  <script type="text/javascript">
</script>
  <style>
    .sch_result thead a {
      color: white !important;
      text-decoration: none !important;
    }

    .main-content-old {
      width: 100%;
      padding: 16px;
    }
  </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">




  <div class="bbs-card-bordered ">
    <div class="bbs-card-header tw-flex tw-justify-between">
      <asp:Label ID="lblRecordCount" runat="server" />
      <%--Buttons--%>
      <div class="tw-flex tw-gap-3 tw-flex-wrap tw-justify-end">

        <%--        
          <asp:LinkButton ID="btnEdit" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnEdit_Click">
    	<span class="msicon notranslate" runat="server">edit</span>    
      <asp:Literal runat="server" Text="<%$ Resources:Global, Edit %>" />
        </asp:LinkButton>
        --%>

        <asp:LinkButton ID="btnDelete" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnDelete_Click">
    	    <span class="msicon notranslate" runat="server">delete</span>    
          <asp:Literal runat="server" Text="<%$ Resources:Global, Delete %>" />
        </asp:LinkButton>

        <asp:LinkButton ID="btnLoadSearch" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnLoadSearch_Click">
	        <span class="msicon notranslate" runat="server">input</span>    
          <asp:Literal runat="server" Text="<%$ Resources:Global, LoadSearchCriteria %>" />
        </asp:LinkButton>

        <asp:LinkButton ID="btnSearch" runat="server" CssClass="bbsButton bbsButton-primary" OnClick="btnSearch_Click">
	        <span class="msicon notranslate" runat="server">search</span>    
          <asp:Literal runat="server" Text="<%$ Resources:Global, Search %>" />
        </asp:LinkButton>
      </div>
    </div>
    <div class="bbs-card-body no-padding">
      <div class="table-responsive">
        <asp:GridView ID="gvSavedSearches"
          AllowSorting="true"
          runat="server"
          AutoGenerateColumns="false"
          CssClass=" table  table-hover "
          GridLines="none"
          OnSorting="GridView_Sorting"
          OnRowDataBound="GridView_RowDataBound">

          <Columns>

            <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top">
              <HeaderTemplate>
                <%= Resources.Global.Select %>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:HiddenField ID="hidSearchCriteriaID" runat="server" Value='<%# DataBinder.Eval(Container.DataItem, "prsc_SearchCriteriaID") %>' />
                <input type="radio" name="rbSearchID" value="<%# Eval("prsc_SearchCriteriaID") %>" />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:BoundField HeaderText="<%$ Resources:Global, SearchName %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left vertical-align-top" DataField="prsc_Name"
              SortExpression="prsc_Name" />

            <asp:BoundField HeaderText="<%$ Resources:Global, Type %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left vertical-align-top" DataField="prsc_SearchType"
              SortExpression="prsc_SearchType" />

            <asp:TemplateField HeaderText="<%$ Resources:Global, Private %>" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top" SortExpression="prsc_IsPrivate">
              <ItemTemplate>
                <%# UIUtils.GetStringFromBool(Eval("prsc_IsPrivate"))%>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="<%$ Resources:Global, LastExecutedDate %>" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-middle" SortExpression="prsc_LastExecutionDateTime">
              <ItemTemplate>
                <%# GetStringFromDate(Eval("prsc_LastExecutionDateTime"))%>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="<%$ Resources:Global, ExecutionCount %>" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-middle"
              SortExpression="prsc_ExecutionCount">
              <ItemTemplate>
                <%# GetStatisticDataForCell(GetObjectMgr().TranslateFromCRMBool(DataBinder.Eval(Container.DataItem, "prsc_IsLastUnsavedSearch")),
                                    (int)Eval("prsc_ExecutionCount"))%>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="<%$ Resources:Global, LastResultCount %>" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top"
              SortExpression="prsc_LastExecutionResultCount">
              <ItemTemplate>
                <%# GetStatisticDataForCell(GetObjectMgr().TranslateFromCRMBool(DataBinder.Eval(Container.DataItem, "prsc_IsLastUnsavedSearch")),
                                    (int)DataBinder.Eval(Container.DataItem, "prsc_LastExecutionResultCount"))%>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderStyle-CssClass="vertical-align-top" HeaderText="<%$ Resources:Global, LastUpdatedBy %>" SortExpression="UpdatedBy" ItemStyle-CssClass="vertical-align-top">
              <ItemTemplate>
                <%# Eval("UpdatedBy")%>
                <br />
                <%# Eval("UpdatedByLocation")%>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="<%$ Resources:Global, Action %>" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top">
              <ItemTemplate>
                <asp:LinkButton ID="EditSearch" runat="server" CssClass="bbsButton bbsButton-secondary filled" CommandArgument='<%# Eval("prsc_SearchCriteriaID") %>' OnClick="btnEditSearch_Click">
                  <span class="msicon notranslate" runat="server">edit</span>  
                  <asp:Literal runat="server" Text="<%$ Resources:Global, Edit %>" />
                </asp:LinkButton>
              </ItemTemplate>
            </asp:TemplateField>
          </Columns>
        </asp:GridView>
      </div>
    </div>
  </div>




  <asp:Panel ID="pnlSearchEdit" runat="server" CssClass="Popup" align="center" Style="display: none">
    <iframe id="ifrmSearchEdit" frameborder="0" style="width: 500px; height: 250px; overflow-y: hidden;" scrolling="no" runat="server"></iframe>
  </asp:Panel>

  <span style="display: none;">
    <asp:Button ID="btnSearchEdit" runat="server" />
  </span>

  <cc1:ModalPopupExtender ID="ModalPopupExtender3" runat="server"
    TargetControlID="btnSearchEdit"
    PopupControlID="pnlSearchEdit"
    BackgroundCssClass="modalBackground" />

  <br />
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
  <script type="text/javascript">
</script>
</asp:Content>
