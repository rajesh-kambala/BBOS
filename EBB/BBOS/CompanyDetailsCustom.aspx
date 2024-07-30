<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyDetailsCustom.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyDetailsCustom" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function postStdValidation() {
            szMsg = IsValidDateRange(<%=txtDateFrom.ClientID %>, <%=txtDateTo.ClientID %>);

            if (szMsg != "") {
                displayErrorMessage(szMsg);
                return false;
            }
            return true;
        }
    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:HiddenField ID="hidNotesShareCompanyMax" runat="server"/>
    <asp:HiddenField ID="hidNotesShareCompanyMax_BASIC_PLUS" runat="server"/>
    <asp:HiddenField ID="hidIsLumber_STANDARD" runat="server" />
    <asp:HiddenField ID="hidIsLumber_BASIC_PLUS" runat="server" />
    <asp:HiddenField ID="hidNotesShareCompanyCount" runat="server" />

    <div class="row nomargin panels_box">
        <asp:Label ID="hidCompanyID" Visible="false" runat="server" />

        <div class="row nomargin">
            <div class="col-lg-5 col-md-5 col-sm-7 nopadding_l">
                <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" />
            </div>

            <div class="panel panel-primary col-lg-7 col-md-7 col-sm-5 nopadding_r">
                <div class="panel-heading">
                    <h4 class="blu_tab"><% =Resources.Global.Filter %></h4>
                </div>
                <div class="panel-body nomargin pad10">

                    <div class="form-group form-inline">
                        <div class="col-md-12">
                            <label for="<% =txtKeyWords.ClientID %>"><% =Resources.Global.KeyWords %>:</label>
                            <asp:TextBox ID="txtKeyWords" CssClass="form-control" runat="server" Columns="22" />
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mar_top">
                            <label for="<%=txtDateFrom.ClientID %>"><% =Resources.Global.DateRangeStart %>:</label>
                            <div class="input-group">
                                <asp:TextBox ID="txtDateFrom" CssClass="form-control" AutoCompleteType="None" tsiDate="true" tsiDisplayName="<%$ Resources:Global, FromDate %>" runat="server" />
                                <div class="input-group-addon" onclick="$('#<%=txtDateFrom.ClientID %>').focus();$('#<%=txtDateFrom.ClientID %>').click();">
                                    <img src="images/calendar.png" style="position: relative; left: 5px; top: 8px; cursor: pointer;" />
                                </div>
                                <cc1:CalendarExtender runat="server" ID="ceDatFrom" TargetControlID="txtDateFrom" />
                            </div>
                        </div>
                        <div class="col-md-6 mar_top">
                            <%--<label><% =Resources.Global.through %></label>--%>
                            <label for="<%=txtDateTo.ClientID %>"><% =Resources.Global.DateRangeEnd %>:</label>
                            <div class="input-group">
                                <asp:TextBox ID="txtDateTo" CssClass="form-control" AutoCompleteType="None" tsiDate="true" tsiDisplayName="<%$ Resources:Global, ToDate %>" runat="server" />
                                <div class="input-group-addon" onclick="$('#<%=txtDateTo.ClientID %>').focus();$('#<%=txtDateTo.ClientID %>').click();">
                                    <img src="images/calendar.png" style="position: relative; left: 5px; top: 8px; cursor: pointer;" />
                                </div>
                                <cc1:CalendarExtender runat="server" ID="ceDateTo" TargetControlID="txtDateTo" />
                            </div>
                        </div>
                    </div>

                    <div class="form-group form-inline">
                        <div class="col-md-12 mar_top">
                            <label for="<%=cbPrivateOnly.ClientID%>" class="text-nowrap">Private Only:</label>
                            <asp:CheckBox ID="cbPrivateOnly" runat="server" />
                        </div>
                    </div>

                    <div class="clearfix"></div>

                    <div class="btn-toolbar" role="group">
                        <asp:LinkButton CssClass="btn gray_btn me-1" ID="btnFilter" OnClick="btnFilterOnClick" runat="server">
					        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Filter %>" />
                        </asp:LinkButton>

                        <asp:LinkButton CssClass="btn gray_btn" ID="btnClear" OnClick="btnClearOnClick" runat="server">
					        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, ClearCriteria %>" />
                        </asp:LinkButton>
                    </div>
                </div>
            </div>
        </div>

        <div class="btn-toolbar pe-2" role="group">
            <asp:LinkButton ID="btnAddNote" runat="server" CssClass="btn gray_btn me-1" OnClick="btnAddNote_Click" OnClientClick="return ValidateCDCount();">
	            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, AddNote %>" />
            </asp:LinkButton>

            <asp:LinkButton ID="btnNoteReport" runat="server" CssClass="btn gray_btn" OnClick="btnNoteReport_Click" OnClientClick="DisableValidation();">
	            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnNotesReport %>" />
            </asp:LinkButton>
        </div>

        <div class="row nomargin">
            <div class="pad5">
                <asp:GridView ID="gvNotes"
                    AllowSorting="true"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="table table-striped table-hover tab_bdy"
                    GridLines="none"
                    OnSorting="GridView_Sorting"
                    OnRowDataBound="GridView_RowDataBound">

                    <Columns>
                        <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top">
                            <HeaderTemplate>
                                <% =Resources.Global.Select%><br />
                                <% =GetCheckAllCheckbox("cbNoteID")%>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <input type="checkbox" name="cbNoteID" value="<%# Eval("prwun_WebUserNoteID") %>" />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, LastUpdated %>" SortExpression="prwun_NoteUpdatedDateTime">
                            <ItemTemplate>
                                <%# UIUtils.GetStringFromDateTime(_oUser.ConvertToLocalDateTime(((IPRWebUserNote)Container.DataItem).prwun_NoteUpdatedDateTime))%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, Pinned %>" SortExpression="prwun_Key">
                            <ItemTemplate>
                                <%# UIUtils.GetStringFromBool((bool)Eval("prwun_Key"))%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, Private %>" SortExpression="prwun_IsPrivate">
                            <ItemTemplate>
                                <%# UIUtils.GetStringFromBool((bool)Eval("prwun_IsPrivate"))%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, Reminder %>">
                            <ItemTemplate>
                                <%# UIUtils.GetStringFromBool(((IPRWebUserNote)Container.DataItem).HasReminder(_oUser)) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderStyle-CssClass="text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, Note %>">
                            <ItemTemplate>
                                <%# PageBase.FormatTextForHTML(((IPRWebUserNote)Container.DataItem).GetTruncatedText(300)) %>&nbsp;&nbsp;<asp:LinkButton ID="viewMore" runat="server" CssClass="explicitlink" Text="<%$ Resources:Global,ViewMoreddd %>" />

                                <asp:Panel ID="Note" Width="600px" runat="server" Style="display: none; max-height: 600px;" CssClass="Popup">
                                    <div style="height: 400px; overflow: auto;">
                                        <%# PageBase.FormatTextForHTML(Eval("prwun_Note")) %>
                                    </div>
                                    <div style="margin-top: 10px; text-align: center;">
                                        <asp:LinkButton ID="Print" runat="server" CssClass="btn gray_btn" OnClick="btnPrintNote_Click" CommandArgument='<%# Eval("prwun_WebUserNoteID")%>'>
	                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Print %>" />
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="Close" runat="server" CssClass="btn gray_btn">
	                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Close %>" />
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

                        <asp:TemplateField HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap" HeaderText="<%$ Resources:Global, UpdatedBy %>" SortExpression="UpdatedBy">
                            <ItemTemplate>
                                <%# Eval("UpdatedBy")%><br />
                                <%# Eval("UpdatedByLocation")%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Global, Action %>" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top">
                            <ItemTemplate>
                                <asp:LinkButton ID="EditNote" runat="server" CssClass="btn gray_btn" CommandArgument='<%# Eval("prwun_WebUserNoteID") %>' OnClick="btnEditNote_Click">
                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Edit %>" />
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <asp:Panel ID="pnlNoteEdit" runat="server" CssClass="Popup" align="center" Style="display: none; width:725px;">
            <iframe id="ifrmNoteEdit" frameborder="0" style="width: 700px; height: 600px; overflow-y: hidden;" scrolling="no" runat="server"></iframe>
        </asp:Panel>

        <span style="display: none;">
            <asp:Button ID="btnNoteEdit" runat="server" />
        </span>

        <cc1:ModalPopupExtender ID="ModalPopupExtender3" runat="server"
            TargetControlID="btnNoteEdit"
            PopupControlID="pnlNoteEdit"
            BackgroundCssClass="modalBackground" />
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
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
