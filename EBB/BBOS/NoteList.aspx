<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="NoteList.aspx.cs" Inherits="PRCo.BBOS.UI.Web.NoteList" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Import Namespace="PRCo.EBB.BusinessObjects" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
  <script type="text/javascript">
    function postStdValidation() {
      szMsg = IsValidDateRange(txtDateFrom, txtDateTo);
      if (szMsg != "") {
        displayErrorMessage(szMsg);
        return false;
      }
      return true;
    }
    </script>
  <style>
    .RecordCnt {
      width: auto;
    }

    th {
      white-space: nowrap;
    }

    .main-content-old {
      width: 100%;
      padding: 16px;
    }
  </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">

  <div class="tw-flex tw-flex-col tw-gap-4">

    <div class="bbs-card-bordered">
      <div class="bbs-card-header tw-flex tw-gap-3 tw-justify-between">
        <h5><% =Resources.Global.Filter %></h5>
        <div class="tw-flex tw-gap-3 tw-justify-end tw-flex-wrap">
          <asp:LinkButton ID="btnClear" runat="server" CssClass="bbsButton bbsButton-secondary filled small" OnClick="btnClearOnClick">
		            <span class="msicon notranslate" runat="server">clear</span>
                <asp:Literal runat="server" Text="<%$Resources:Global, ClearCriteria %>" />
          </asp:LinkButton>
          <asp:LinkButton ID="btnFilter" runat="server" CssClass="bbsButton bbsButton-secondary filled small" OnClick="btnFilterOnClick">
		            <span class="msicon notranslate" runat="server">filter_list</span>
                <asp:Literal runat="server" Text="<%$Resources:Global, Filter %>" />
          </asp:LinkButton>
        </div>
      </div>
      <div class="bbs-card-body">
        <div class="row form-inline">
          <div class="col-md-3 mar_top_5">
            <div class="clr_blu"><%= Resources.Global.KeyWords%>:</div>
          </div>
          <div class="col-md-9 mar_top_5">
            <asp:TextBox ID="txtKeyWords" runat="server" CssClass="form-control" />
          </div>
        </div>
        <div class="row form-inline">
          <div class="col-md-3 mar_top_5">
            <div class="clr_blu"><%= Resources.Global.Subject%>:</div>
          </div>
          <div class="col-md-9 mar_top_5">
            <asp:TextBox ID="txtName" runat="server" CssClass="form-control" />
          </div>
        </div>




        <div class="row form-inline">
          <div class="col-md-3 mar_top_5">
            <div class="clr_blu"><%= Resources.Global.StartDate%>:</div>
          </div>
          <div class="col-md-9 mar_top_5">
            <div class="input-group mb-3">
              <asp:TextBox ID="txtDateFrom" CssClass="form-control" AutoCompleteType="None" tsiDate="true" tsiDisplayName="<%$ Resources:Global, FromDate %>" runat="server" />
              <button class="input-group-text" type="button" onclick="$('#<%=txtDateFrom.ClientID %>').focus();$('#<%=txtDateFrom.ClientID %>').click();">
                <span class="msicon notranslate">calendar_month</span>
              </button>
            </div>
            <cc1:CalendarExtender runat="server" ID="ceDatFrom" TargetControlID="txtDateFrom" />
          </div>
        </div>

        <div class="row form-inline">
          <div class="col-md-3 mar_top_5">
            <div class="clr_blu"><%= Resources.Global.EndDate%>:</div>
          </div>
          <div class="col-md-9 mar_top_5">
            <div class="input-group mb-3">
              <asp:TextBox ID="txtDateTo" CssClass="form-control" AutoCompleteType="None" tsiDate="true" tsiDisplayName="<%$ Resources:Global, ToDate %>" runat="server" />
              <button class="input-group-text" type="button" onclick="$('#<%=txtDateFrom.ClientID %>').focus();$('#<%=txtDateTo.ClientID %>').click();">
                <span class="msicon notranslate">calendar_month</span>
              </button>
              <cc1:CalendarExtender runat="server" ID="ceDateTo" TargetControlID="txtDateTo" />
            </div>
          </div>
        </div>

        <div class="row form-inline">
          <div class="col-md-3">
            <div class="clr_blu"><%= Resources.Global.PrivateOnly%>:</div>
          </div>
          <div class="col-md-9">
            <asp:CheckBox ID="cbPrivateOnly" runat="server" />
          </div>
        </div>


      </div>
    </div>

    <div class="bbs-card-bordered ">
      <div class="bbs-card-header tw-flex tw-gap-3 tw-justify-between">
        <div>
          <asp:Label ID="lblRecordCount" runat="server" />
          <span>/</span>
          <span id="lblSelectedCount" />
        </div>
        <div class="tw-flex tw-gap-3 tw-justify-end tw-flex-wrap">
          <asp:LinkButton ID="btnDeleteAll" runat="server" CssClass="bbsButton bbsButton-secondary filled small" OnClick="btnDeleteAll_Click" OnClientClick="DisableValidation();return confirm('Are you sure you want to delete all checked Notes?');">
		  <span class="msicon notranslate" runat="server">delete</span>
      <asp:Literal runat="server" Text="<%$Resources:Global, Delete %>" />
          </asp:LinkButton>
          <asp:LinkButton ID="btnNoteReport" runat="server" CssClass="bbsButton bbsButton-secondary filled small" OnClick="btnNoteReport_Click">
		      <span class="msicon notranslate" runat="server">download</span>
          <asp:Literal runat="server" Text="<%$ Resources:Global, btnNotesReport %>" />
          </asp:LinkButton>
        </div>
      </div>
      <div class="bbs-card-body no-padding">
        <div class="table-responsive">
          <asp:GridView ID="gvNotes"
            AllowSorting="true"
            runat="server"
            AutoGenerateColumns="false"
            CssClass=" table  table-hover"
            GridLines="none"
            OnSorting="GridView_Sorting"
            OnRowDataBound="GridView_RowDataBound">

            <Columns>
              <asp:TemplateField ItemStyle-CssClass="text-center vertical-align-top" HeaderStyle-CssClass="text-center vertical-align-top">
                <HeaderTemplate>
                  <!--% =Resources.Global.Select%-->
                  <span style="position: relative; top: 5px;"><% =PageBase.GetCheckAllCheckbox("cbNoteID", "setSelectedCount();")%></span>
                </HeaderTemplate>
                <ItemTemplate>
                  <input type="checkbox" name="cbNoteID" value="<%# Eval("prwun_WebUserNoteID") %>" onclick="setSelectedCount();" />
                </ItemTemplate>
              </asp:TemplateField>

              <%--BBNumber Column--%>
              <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left" DataField="prwun_Associatedid" SortExpression="prwun_Associatedid" />

              <%--Icons Column--%>
              <asp:TemplateField ItemStyle-CssClass="text-nowrap text-right">
                <HeaderTemplate>
                  <span class="msicon notranslate">notifications_active</span>
                  </HeaderTemplate>
                <ItemTemplate>
                  <%# GetNoteSubject((int)Eval("prwun_AssociatedID"), (string)Eval("prwun_AssociatedType"), (string)Eval("Subject"), true, false)%>
                </ItemTemplate>
              </asp:TemplateField>

              <%--Company Name / Location Column--%>
              <asp:TemplateField HeaderStyle-CssClass="vertical-align-top" ItemStyle-CssClass="vertical-align-top" HeaderText="<%$ Resources:Global, CompanyName%>" SortExpression="Subject2">
                <ItemTemplate>
                  <div>
                    <%# GetNoteSubject((int)Eval("prwun_AssociatedID"), (string)Eval("prwun_AssociatedType"), (string)Eval("Subject"), false, true)%>
                    <span class="tw-text-xs tw-text-text-secondary"><%# GetCompanyCityStateCountryShort((int)Eval("prwun_AssociatedID"))%></span>
                  </div>
                </ItemTemplate>
              </asp:TemplateField>

              <%-- old Location Column , can't remove them because for unknow reason aspx throws exception if you delete this.--%>
              <asp:TemplateField Visible="false"></asp:TemplateField>

              <asp:TemplateField ItemStyle-CssClass="text-left vertical-align-top nowraptd_wraplabel" HeaderStyle-CssClass="vertical-align-top" HeaderText="<%$Resources:Global,LastUpdated %>" SortExpression="prwun_NoteUpdatedDateTime">
                <ItemTemplate>
                  <%# UIUtils.GetStringFromDateTime(_oUser.ConvertToLocalDateTime(((IPRWebUserNote)Container.DataItem).prwun_NoteUpdatedDateTime))%>
                </ItemTemplate>
              </asp:TemplateField>

              <asp:TemplateField ItemStyle-CssClass="text-center vertical-align-top" HeaderStyle-CssClass="text-center text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, Private %>" SortExpression="prwun_IsPrivate">
                <ItemTemplate>
                  <%# UIUtils.GetStringFromBool((bool)Eval("prwun_IsPrivate"))%>
                </ItemTemplate>
              </asp:TemplateField>

              <asp:TemplateField ItemStyle-CssClass="text-center vertical-align-top" HeaderStyle-CssClass="text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, Reminder %>">
                <ItemTemplate>
                  <%# UIUtils.GetStringFromBool(((IPRWebUserNote)Container.DataItem).HasReminder(_oUser)) %>
                </ItemTemplate>
              </asp:TemplateField>

              <asp:TemplateField HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="vertical-align-top" HeaderText="<%$ Resources:Global, Note %>">
                <ItemTemplate>
                    <p class="text-clipped clip-2">
                     <%# PageBase.FormatTextForHTML(((IPRWebUserNote)Container.DataItem).GetTruncatedText(300)) %>
                    </p>
                    <asp:LinkButton ID="viewMore" runat="server" Text="<%$ Resources:Global,ViewMoreddd %>" 
                          CssClass="bbsButton bbsButton-secondary small full-width tw-mt-2" />

                  <asp:Panel ID="Note" Width="600px" runat="server" Style="display: none; max-height: 600px;" CssClass="Popup">
                    <div style="height: 400px; overflow: auto;">
                      <%# PageBase.FormatTextForHTML(Eval("prwun_Note")) %>
                    </div>

                    <div class="tw-flex tw-gap-3">
                      <asp:LinkButton ID="Print" runat="server" CssClass="bbsButton bbsButton-secondary filled full-width"  OnClick="btnPrintNote_Click" CommandArgument='<%# Eval("prwun_WebUserNoteID")%>'>
				                <span class="msicon notranslate">print</span>  
                        <asp:Literal runat="server" Text="<%$Resources:Global, Print %>"  />
                      </asp:LinkButton>
                      <asp:LinkButton ID="Close" runat="server" CssClass="bbsButton bbsButton-secondary filled full-width" >
				                <span class="msicon notranslate"> close </span>  
                        <asp:Literal runat="server" Text="<%$Resources:Global, Close %>" />
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

              <asp:TemplateField HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, UpdatedBy %>" SortExpression="UpdatedBy">
                <ItemTemplate>
                  <%# Eval("UpdatedBy")%><br />
                  <%# Eval("UpdatedByLocation")%>
                </ItemTemplate>
              </asp:TemplateField>

              <asp:TemplateField HeaderText="<%$ Resources:Global, Action %>" HeaderStyle-CssClass="vertical-align-top" ItemStyle-CssClass="vertical-align-top">
                <ItemTemplate>
                  <asp:LinkButton ID="EditNote" runat="server" CssClass="bbsButton bbsButton-secondary filled" CommandArgument='<%# Eval("prwun_WebUserNoteID") %>' OnClick="btnEditNote_Click">
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

  </div>

  <asp:Panel ID="pnlNoteEdit" runat="server" CssClass="Popup" align="center" Style="display: none">
    <iframe id="ifrmNoteEdit" frameborder="0" style="width: 700px; height: 600px;" scrolling="no" src="sss" runat="server"></iframe>
  </asp:Panel>

  <span style="display: none;">
    <asp:Button ID="btnNoteEdit" runat="server" />
  </span>

  <cc1:ModalPopupExtender ID="ModalPopupExtender3" runat="server"
    TargetControlID="btnNoteEdit"
    PopupControlID="pnlNoteEdit"
    BackgroundCssClass="modalBackground" />
  <br />
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptSection" runat="server">
  <script type="text/javascript">
    function setSelectedCount() {
      setSelectedCountInternal("cbNoteID", "lblSelectedCount");
    }

    setSelectedCount();
    </script>
</asp:Content>
