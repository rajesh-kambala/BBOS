<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyNotes.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyNotes" Title="Blue Book Services" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeaderMeister" Src="UserControls/CompanyDetailsHeaderMeister.ascx" %>
<%@ Register TagPrefix="bbos" TagName="Sidebar" Src="UserControls/Sidebar.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyHero" Src="UserControls/CompanyHero.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyBio" Src="UserControls/CompanyBio.ascx" %>
<%@ Register TagPrefix="bbos" TagName="NewsArticles" Src="UserControls/NewsArticles.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PrintHeader" Src="UserControls/PrintHeader.ascx" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Import Namespace="PRCo.EBB.BusinessObjects" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
  <script type="text/javascript" src="en-us/javascript/formFunctions2.min.js"></script>
</asp:Content>

<asp:Content ID="contentMain" ContentPlaceHolderID="contentMain" runat="server">
  <asp:HiddenField ID="hidNotesShareCompanyMax" runat="server" />
  <asp:HiddenField ID="hidNotesShareCompanyMax_BASIC_PLUS" runat="server" />
  <asp:HiddenField ID="hidIsLumber_STANDARD" runat="server" />
  <asp:HiddenField ID="hidIsLumber_BASIC_PLUS" runat="server" />
  <asp:HiddenField ID="hidNotesShareCompanyCount" runat="server" />

  <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
  <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" Visible="false" />
</asp:Content>

<asp:Content ID="contentLeftSidebar" ContentPlaceHolderID="contentLeftSidebar" runat="server">
  <!-- Left nav bar  -->
  <bbos:Sidebar ID="ucSidebar" runat="server" MenuExpand="1" MenuPage="8" />

  <!-- Main  -->
  <main class="main-content tw-flex tw-flex-col tw-gap-y-4">
    <bbos:PrintHeader ID="ucPrintHeader" runat="server" Title='<% $Resources:Global, CompanyCustom %>' />
    <bbos:CompanyHero ID="ucCompanyHero" runat="server" />
    <bbos:CompanyBio ID="ucCompanyBio" runat="server" />
    <bbos:CompanyDetailsHeaderMeister ID="ucCompanyDetailsHeaderMeister" runat="server" />
    <p class="page-heading"><%= Resources.Global.CompanyCustom %></p>

    <div class="container">
      <div class="row g-4">
        <%--Filter start --%>
        <div class="col-xs-12">
          <div class="bbs-card-bordered">
            <div class="bbs-card-header tw-flex tw-justify-between">
              <h5><% =Resources.Global.Filter %></h5>
              <div class="tw-flex tw-gap-2">
                <asp:LinkButton CssClass="bbsButton bbsButton-secondary filled small" ID="btnClear" OnClick="btnClearOnClick" runat="server">
                  <span class="msicon notranslate">clear</span>
                  <span><asp:Literal runat="server" Text="<%$ Resources:Global, ClearCriteria %>" /></span>
                </asp:LinkButton>
                <asp:LinkButton CssClass="bbsButton bbsButton-secondary filled small" ID="btnFilter" OnClick="btnFilterOnClick" runat="server">
                  <span class="msicon notranslate">filter_list</span>
                  <span><asp:Literal runat="server" Text="<%$ Resources:Global, Filter %>" /></span>
                </asp:LinkButton>
              </div>
            </div>
            <div class="bbs-card-body">
              <div class="container">
                <div class="row">
                  <div class="col-6 col-md-4">
                    <label for="<%=txtDateFrom.ClientID %>"><% =Resources.Global.DateRangeStart %></label>
                    <div class="input-group mb-3">
                      <asp:TextBox ID="txtDateFrom" CssClass="form-control" aria-describedby="button-addon1" AutoCompleteType="None" tsiDate="true" tsiDisplayName="<%$ Resources:Global, FromDate %>" runat="server" />
                      <button
                        class="input-group-text" type="button" id="button-addon1"
                        onclick="$('#<%=txtDateFrom.ClientID %>').focus();$('#<%=txtDateFrom.ClientID %>').click();">
                        <span class="msicon notranslate">calendar_month</span>
                      </button>
                      <cc1:CalendarExtender runat="server" ID="ceDatFrom" TargetControlID="txtDateFrom" />
                    </div>
                  </div>

                  <div class="col-6 col-md-4">
                    <label for="<%=txtDateTo.ClientID %>"><% =Resources.Global.DateRangeEnd %></label>
                    <div class="input-group mb-3">
                      <asp:TextBox ID="txtDateTo" CssClass="form-control" aria-describedby="button-addon2"
                        AutoCompleteType="None" tsiDate="true" tsiDisplayName="<%$ Resources:Global, ToDate %>" runat="server" />
                      <button
                        class="input-group-text" type="button" id="button-addon2"
                        onclick="$('#<%=txtDateTo.ClientID %>').focus();$('#<%=txtDateTo.ClientID %>').click();">
                        <span class="msicon notranslate">calendar_month</span>
                      </button>
                      <cc1:CalendarExtender runat="server" ID="ceDateTo" TargetControlID="txtDateTo" />
                    </div>
                  </div>

                  <div class="col-6">
                    <label for="<% =txtKeyWords.ClientID %>"><% =Resources.Global.KeyWords %></label>
                    <asp:TextBox ID="txtKeyWords" CssClass="form-control" runat="server" Columns="22" />
                  </div>

                  <div class="col-6 tw-flex tw-gap-2 tw-items-center">
                    <asp:CheckBox ID="cbPrivateOnly" runat="server" />
                    <label for="<%=cbPrivateOnly.ClientID%>" class="text-nowrap"><% =Resources.Global.PrivateOnly %></label>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <%--Filter end --%>
        <%--Notes start --%>
        <div class="col-xs-12">
          <div class="bbs-card-bordered">
            <div class="bbs-card-header tw-flex tw-justify-between">
              <h5><% =Resources.Global.Notes %></h5>
              <div class="tw-flex tw-gap-2">
                <asp:LinkButton CssClass="bbsButton bbsButton-secondary filled small" ID="btnAddNote" OnClick="btnAddNote_Click" runat="server" OnClientClick="return ValidateCDCount();">
                  <span class="msicon notranslate">add</span>
                  <span><asp:Literal runat="server" Text="<%$ Resources:Global, AddNote %>" /></span>
                </asp:LinkButton>
                <asp:LinkButton CssClass="bbsButton bbsButton-secondary filled small" ID="btnNoteReport" OnClick="btnNoteReport_Click" runat="server" OnClientClick="DisableValidation()">
                  <span class="msicon notranslate">download</span>
                  <span><asp:Literal runat="server" Text="<%$ Resources:Global, btnNotesReport %>" /></span>
                </asp:LinkButton>
              </div>
            </div>
            <div class="bbs-card-body no-padding overflow-auto">
              <asp:GridView ID="gvNotes"
                AllowSorting="true"
                runat="server"
                AutoGenerateColumns="false"
                CssClass="table table-hover "
                GridLines="none"
                OnSorting="GridView_Sorting"
                OnRowDataBound="GridView_RowDataBound">

                <Columns>
                  <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="tw-font-semibold text-center vertical-align-top">
                    <HeaderTemplate>
                      <% =Resources.Global.Select%><br />
                      <% =GetCheckAllCheckbox("cbNoteID")%>
                    </HeaderTemplate>
                    <ItemTemplate>
                      <input type="checkbox" name="cbNoteID" value="<%# Eval("prwun_WebUserNoteID") %>" />
                    </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField ItemStyle-CssClass="text-start" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, LastUpdated %>" SortExpression="prwun_NoteUpdatedDateTime">
                    <ItemTemplate>
                      <%# UIUtils.GetStringFromDateTime(_oUser.ConvertToLocalDateTime(((IPRWebUserNote)Container.DataItem).prwun_NoteUpdatedDateTime))%>
                    </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField ItemStyle-CssClass="text-start" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, Pinned %>" SortExpression="prwun_Key">
                    <ItemTemplate>
                      <%# UIUtils.GetStringFromBool((bool)Eval("prwun_Key"))%>
                    </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField ItemStyle-CssClass="text-start" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, Private %>" SortExpression="prwun_IsPrivate">
                    <ItemTemplate>
                      <%# UIUtils.GetStringFromBool((bool)Eval("prwun_IsPrivate"))%>
                    </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField ItemStyle-CssClass="text-start" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, Reminder %>">
                    <ItemTemplate>
                      <%# UIUtils.GetStringFromBool(((IPRWebUserNote)Container.DataItem).HasReminder(_oUser)) %>
                    </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, Note %>">
                    <ItemTemplate>
                        <p class="text-clipped clip-2">
                        <%# PageBase.FormatTextForHTML(((IPRWebUserNote)Container.DataItem).GetTruncatedText(300)) %>
                        </p>
                        <asp:LinkButton ID="viewMore" runat="server" CssClass="bbsButton bbsButton-secondary small full-width tw-mt-2" 
                            Text="<%$ Resources:Global,ViewMoreddd %>" />

                      <asp:Panel ID="Note" Width="600px" runat="server" Style="display: none; max-height: 600px;" CssClass="Popup p-0">
                        <div style="height: 400px; padding:16px; overflow: auto;">
                          <%# PageBase.FormatTextForHTML(Eval("prwun_Note")) %>
                        </div>
                        <div class="tw-flex tw-gap-2 tw-w-full tw-bg-bg-secondary tw-border-t tw-justify-between" style="
                          position: absolute;
                          bottom: 0px;
                          padding: 8px;">
                          <asp:LinkButton ID="Print" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnPrintNote_Click" CommandArgument='<%# Eval("prwun_WebUserNoteID")%>'>
	                          <span class="msicon notranslate">print</span>
                            <span><asp:Literal runat="server" Text="<%$ Resources:Global, Print %>" /></span>                
                          </asp:LinkButton>
                          <asp:LinkButton ID="Close" runat="server" CssClass="bbsButton bbsButton-secondary filled">
	                          <span class="msicon notranslate">close</span>
                            <span><asp:Literal runat="server" Text="<%$ Resources:Global, Close %>" /></span>                 
                          </asp:LinkButton>
                        </div>
                      </asp:Panel>

                      <cc1:ModalPopupExtender ID="ModalPopupExtender1" runat="server"
                        TargetControlID="viewMore"
                        PopupControlID="Note"
                        OkControlID="Close"
                        BackgroundCssClass="modalBackground" />
                    </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap" HeaderText="<%$ Resources:Global, UpdatedBy %>" SortExpression="UpdatedBy">
                    <ItemTemplate>
                      <%# Eval("UpdatedBy")%><br />
                      <%# Eval("UpdatedByLocation")%>
                    </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="<%$ Resources:Global, Action %>" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="tw-font-semibold text-center vertical-align-top">
                    <ItemTemplate>
                      <asp:LinkButton ID="EditNote" runat="server" CssClass="bbsButton bbsButton-secondary filled small" CommandArgument='<%# Eval("prwun_WebUserNoteID") %>' OnClick="btnEditNote_Click">
                        <span class="msicon notranslate">edit</span>
                        <span><asp:Literal runat="server" Text="<%$ Resources:Global, Edit %>" /></span>
                      </asp:LinkButton>
                    </ItemTemplate>
                  </asp:TemplateField>

                </Columns>
              </asp:GridView>

            </div>
          </div>
        </div>

        <%--Notes end --%>
      </div>
    </div>
    <br />

    <asp:Panel ID="pnlNoteEdit" runat="server" CssClass="Popup p-0" align="center" Style="display: none; width: 1200px; max-width:90%">
      <iframe id="ifrmNoteEdit" frameborder="0" style="width: 100%; height: 600px; overflow-y: hidden;" scrolling="no" runat="server"></iframe>
    </asp:Panel>

    <span style="display: none;">
      <asp:Button ID="btnNoteEdit" runat="server" />
    </span>

    <cc1:ModalPopupExtender ID="ModalPopupExtender3" runat="server"
      TargetControlID="btnNoteEdit"
      PopupControlID="pnlNoteEdit"
      BackgroundCssClass="modalBackground" />
  </main>
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
  <script type="text/javascript">
    function ValidateCDCount() {
      if ($('#<%=hidIsLumber_STANDARD.ClientID%>').val() == "True" || $('#<%=hidIsLumber_BASIC_PLUS.ClientID%>').val() == "True") {
        var iMax;
        if ($('#<%=hidIsLumber_STANDARD.ClientID%>').val() == "True")
          iMax = Number($('#<%=hidNotesShareCompanyMax.ClientID%>').val());
            else if ($('#<%=hidIsLumber_BASIC_PLUS.ClientID%>').val() == "True")
              iMax = Number($('#<%=hidNotesShareCompanyMax_BASIC_PLUS.ClientID%>').val());

        var iCurrent = Number($('#<%=hidNotesShareCompanyCount.ClientID%>').val());
        if (iCurrent >= iMax) {
          bbAlert("Your membership only allows creating notes on a maximum of " + iMax + " companies, and you have already entered notes on "
            + iCurrent + " companies.", "Membership Share Notes Company Count Exceeded");
          return false;
        }
      }
      DisableValidation();
      return true;
    }

  </script>
</asp:Content>
