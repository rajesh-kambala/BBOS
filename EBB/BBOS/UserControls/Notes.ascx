<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Notes.ascx.cs" Inherits="PRCo.BBOS.UI.Web.Notes" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Import Namespace="PRCo.EBB.BusinessObjects" %>

<asp:HiddenField ID="hidNotesShareCompanyMax" runat="server"/>
<asp:HiddenField ID="hidNotesShareCompanyMax_BASIC_PLUS" runat="server"/>
<asp:HiddenField ID="hidIsLumber_STANDARD" runat="server" />
<asp:HiddenField ID="hidIsLumber_BASIC_PLUS" runat="server" />
<asp:HiddenField ID="hidNotesShareCompanyCount" runat="server" />

<div class="col4_box news_box">
    <div class="cmp_nme">
        <h4 class="blu_tab"><%=Resources.Global.Notes %></h4> 
    </div>
    <div class="tab_bdy pad5">
        <asp:GridView ID="gvNotes" 
            AllowSorting="false" 
            Width="100%" 
            CellSpacing="3" 
            runat="server"
            AutoGenerateColumns="false" 
            CssClass="table table-hover table-striped"
            GridLines="None" 
            OnRowDataBound="gvNotes_RowDataBound">

            <Columns>
                <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap" HeaderText='<%$ Resources:Global, LastUpdated %>'>
                    <ItemTemplate>
                        <%# UIUtils.GetStringFromDateTime(WebUser.ConvertToLocalDateTime(((IPRWebUserNote)Container.DataItem).prwun_NoteUpdatedDateTime))%>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-nowrap" HeaderText='<%$ Resources:Global, Pinned %>'>
                    <ItemTemplate>
                        <%# UIUtils.GetStringFromBool((bool)Eval("prwun_Key"))%>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-nowrap" HeaderText="<%$ Resources:Global, Private %>">
                    <ItemTemplate>
                        <%# UIUtils.GetStringFromBool((bool)Eval("prwun_IsPrivate"))%>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderStyle-CssClass="text-nowrap" HeaderText="<%$ Resources:Global, Note %>">
                    <ItemTemplate>
                        <%# PageBase.FormatTextForHTML(((IPRWebUserNote)Container.DataItem).GetTruncatedText(300)) %>&nbsp;&nbsp;<asp:LinkButton ID="viewMore" runat="server" Text="<%$ Resources:Global,ViewMoreddd %>" />

                        <asp:Panel ID="Note" Width="600px" runat="server" Style="display: none; max-height: 600px; overflow: scroll; position: absolute" CssClass="Popup">
                            <div class="row nomargin panels_box">
                                <div class="panel panel-primary">
                                    <div class="panel-heading">
                                        <h4 class="blu_tab">
                                            <asp:Literal ID="litPanelTitle" runat="server" Text="Note" />
                                        </h4>
                                    </div>
                                    <div class="panel-body">
                                        <div class="col-md-12">
                                            <%# PageBase.FormatTextForHTML(Eval("prwun_Note")) %>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-12 text-center">
                                <asp:LinkButton ID="Print" OnClick="btnPrintNote_Click" CssClass="btn gray_btn" runat="server" CommandArgument='<%# Eval("prwun_WebUserNoteID")%>'>
    	                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Print %>"/>
                                </asp:LinkButton>
                                <asp:LinkButton ID="Close" CssClass="btn gray_btn" runat="server">
	                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Close %>" />
                                </asp:LinkButton>
                            </div>
                        </asp:Panel>

                    <cc1:modalpopupextender id="mpeViewMore" runat="server"
                        targetcontrolid="viewMore"
                        popupcontrolid="Note"
                        okcontrolid="Close"
                        backgroundcssclass="modalBackground" />

                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>

        <div class="row pad10 bb_service">
            <div class="col-md-6 col-sm-12 search_crit">
                <asp:LinkButton ID="btnAddNote" runat="server" CssClass="btn MediumButton gray_btn" OnClick="btnAddNote_Click" OnClientClick="return ValidateCount();">
	                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<%=Resources.Global.AddNote %>
                </asp:LinkButton>
            </div>
            <div class="col-md-6 col-sm-12 search_crit">
                <asp:LinkButton ID="lnkViewAllNews" runat="server" CssClass="btn MediumButton gray_btn">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal ID="litViewAllNews" runat="server" />
                </asp:LinkButton>
            </div>
        </div>

        <asp:Panel ID="pnlNoteEdit" runat="server" CssClass="Popup" align="center" Style="display: none">
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
</div>

<script type="text/javascript">
    function ValidateCount() {
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
        return true;
    }
</script>
