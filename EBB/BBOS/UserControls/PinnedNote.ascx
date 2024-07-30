<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PinnedNote.ascx.cs" Inherits="PRCo.BBOS.UI.Web.UserControls.PinnedNote" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:HiddenField ID="hidNotesShareCompanyMax" runat="server"/>
<asp:HiddenField ID="hidNotesShareCompanyMax_BASIC_PLUS" runat="server"/>
<asp:HiddenField ID="hidIsLumber_STANDARD" runat="server" />
<asp:HiddenField ID="hidIsLumber_BASIC_PLUS" runat="server" />
<asp:HiddenField ID="hidNotesShareCompanyCount" runat="server" />

<div class="" id="pPinnedNote">
    <div class="col4_box">
        <div class="cmp_nme">
            <h4 class="blu_tab">
                <%= Resources.Global.PinnedNote %>
            </h4>
        </div>
        <div class="tab_bdy pad10">
                <div class="row" id="trKeyNote" visible="true" runat="server">
                    <div class="col-md-12 clr_blu">
                        <b>Pinned Note:</b>
                        <span id="tdKeyNoteLastUpdated" runat="server" class="text-right"><%=Resources.Global.LastUpdated %>:
                    <asp:Literal ID="litKeyNoteLastUpdated" runat="server" /></span>
                    </div>
                    <div class="col-md-12 mar_bot">
                        <asp:Literal ID="litKeyNote" runat="server" />&nbsp;&nbsp;<asp:LinkButton ID="viewMore" runat="server" CssClass="explicitlink" Text="<%$ Resources:Global,ViewMoreddd %>" />
                    </div>

                    <asp:Panel ID="KeyNote" Width="600px" runat="server" Style="display: none; max-height: 600px; overflow: scroll; position: absolute" CssClass="Popup">
                        <div class="row nomargin panels_box">
                            <div class="panel panel-primary">
                                <div class="panel-heading">
                                    <h4 class="blu_tab">
                                        <asp:Literal ID="litPanelTitle" runat="server" Text="Note" />
                                    </h4>
                                </div>
                                <div class="panel-body">
                                    <div class="col-md-12 text-right">
                                        <em>
                                            <span style="font-size: .8em"><%=Resources.Global.LastUpdated %>:
                                            <asp:Literal ID="litKeyNoteLastUpdated2" runat="server" />
                                            </span>
                                            <br />
                                            <span style="font-size: .8em"><%=Resources.Global.By %>:
                                            <asp:Literal ID="litKeyNoteLastUpdatedBy" runat="server" />
                                            </span>
                                        </em>
                                    </div>

                                    <div class="col-md-12 text-left">
                                        <asp:Literal ID="litKeyNote2" runat="server" />
                                    </div>

                                </div>
                            </div>
                        </div>

                        <div class="col-md-12 text-left">
                            <asp:LinkButton ID="Print" OnClick="btnPrintNote_Click" CssClass="btn gray_btn" runat="server">
    	                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Print %>" />
                            </asp:LinkButton>
                            <asp:LinkButton ID="Close" CssClass="btn gray_btn" runat="server">
	                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Close %>" />
                            </asp:LinkButton>
                        </div>
                    </asp:Panel>

                    <cc1:ModalPopupExtender ID="ModalPopupExtender1" runat="server"
                        TargetControlID="viewMore"
                        PopupControlID="KeyNote"
                        OkControlID="Close"
                        BackgroundCssClass="modalBackground" />
                </div>

                <div class="row" id="trKeyNoteEmpty" visible="false" runat="server">
                    <div class="col-md-12 mar_bot mar_top">
                        <span style="font-style: italic;"><%=Resources.Global.NoNoteHasBeenPinned %></span>
                        <br />
                        <div class="text-left">
                            <asp:LinkButton ID="btnNotes" CssClass="btn btnWidthStd gray_btn" runat="server" NavigateUrl="CompanyDetailsCustom.aspx?CompanyID=">
	                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ViewNotes %>" />
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnAddNote" CssClass="btn btnWidthStd gray_btn" runat="server" OnClick="btnAddNote_Click" OnClientClick="return ValidatePNCount();">
	                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, AddNote %>" />
                            </asp:LinkButton>
                        </div>

                        <asp:Panel ID="pnlNoteEdit" runat="server" CssClass="Popup" align="center" Style="display: none">
                            <iframe id="ifrmNoteEdit" frameborder="0" style="width: 700px; height: 600px; overflow-y: hidden;" scrolling="no" runat="server"></iframe>
                        </asp:Panel>

                        <span style="display: none;">
                            <asp:Button ID="btnNoteEdit" CssClass="btn gray_btn" runat="server" />
                        </span>
                        <cc1:ModalPopupExtender ID="ModalPopupExtender3" runat="server"
                            TargetControlID="btnNoteEdit"
                            PopupControlID="pnlNoteEdit"
                            BackgroundCssClass="modalBackground" />
                    </div>
                </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    function ValidatePNCount() {
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
