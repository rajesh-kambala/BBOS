<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="SpecialServicesCourtesyContact.aspx.cs" Inherits="PRCo.BBOS.UI.Web.SpecialServicesCourtesyContact" Title="Untitled Page" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" ValidateRequest="false" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Register TagPrefix="bbos" TagName="TESLongForm" Src="UserControls/TESLongForm.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function OnBeginRequest(sender, args) {
            var postBackElement = args.get_postBackElement();

            if ((postBackElement.id == "<%= btnAttachFile.ClientID %>") ||
                (postBackElement.id == "<%= btnRemoveFile.ClientID %>")) {
                manager._scrollPosition = null;
            }
        }

        function refresh() {
            refreshInvoiceTable();
            refreshPreview();
        }

        function refreshPreview() {
            var $myDiv = $('#<%=pnlCourtesyContact.ClientID%>');
            if ($myDiv.length == 0)
                return;

            var ul = "__________";
            var p = $("#<%=hidPreviewTemplate.ClientID%>").val();
            if ($('#<%=txtContactName.ClientID%>').val().length > 0)
                p = p.replaceAll('{0}', $('#<%=txtContactName.ClientID%>').val())
            else
                p = p.replaceAll('{0}', ul)

            if ($('#<%=hidClaimantCompanyName.ClientID%>').val().length > 0)
                p = p.replaceAll('{1}', $('#<%=hidClaimantCompanyName.ClientID%>').val())
            else
                p = p.replaceAll('{1}', ul);

            if ($("#<%=hidInvoices.ClientID%>").val().length == 0)
            {
                p = p.replaceAll('{2}', ul);
                p = p.replaceAll('{3}', ul);
            };

            if ($("#contentMain_hidInvoices").val() != "") {
                var invoices = JSON.parse($("#<%=hidInvoices.ClientID%>").val());
                if (invoices.length > 0) {
                    var szInvoices = "";
                    var szDates = "";

                    for (var i = 0; i < invoices.length; i++) {
                        if (invoices[i] != null) {
                            var invoice = invoices[i];

                            szInvoices += invoice.invoicenum;

                            szDates += new Date(invoice.invoicedate).toLocaleDateString($("#<%=hidCulture.ClientID%>").val());

                            szInvoices += ", ";
                            szDates += ", ";
                        }
                    }

                    szInvoices = szInvoices.slice(0, -2);
                    szDates = szDates.slice(0, -2);

                    p = p.replaceAll('{2}', szInvoices)
                    p = p.replaceAll('{3}', szDates)
                }
            }

            $('#divPreview').html(p);
        }

        function refreshInvoiceTable()
        {
            if ($("#<%=hidInvoices.ClientID%>").val() == "") {
                $("#<%=divAttachedInvoices.ClientID%>").html("");
                return;
            }

            var invoices = JSON.parse($("#<%=hidInvoices.ClientID%>").val());

            var row = 0;
            var sb = "";

            if (invoices.length > 0) {
                sb += "<table class='table table-striped table-hover table_bbos norm_lbl mar_bot_5' style='border:1px solid'>";
                sb += "<tr><th class='text-center'>#</th><th> <asp:Literal runat="server" Text="<%$ Resources:Global, InvoiceNumber%>" /></th><th> <asp:Literal runat="server" Text="<%$ Resources:Global, InvoiceDate%>" /></th><th> <asp:Literal runat="server" Text="<%$ Resources:Global, Amount%>" /></th><th></th></tr>";

                for (var i = 0; i < invoices.length; i++) {
                    if (invoices[i] != null) {
                        row++;
                        var invoice = invoices[i];

                        var szButton = "<a class='btn gray_btn' href=\"javascript: removeInvoice(" + row + ");\" <i class='fa fa-caret-right' aria-hidden='true'></i>&nbsp;<%= Resources.Global.RemoveInvoice %></a>";
                        sb += "<tr>";
                        sb += "<td class='text-center' style='padding:8px !important'>" + row + "</td><td class='text-left' style='padding:8px !important'>" + invoice.invoicenum + "</td><td class='text-left' style='padding:8px !important'>" + new Date(invoice.invoicedate).toLocaleDateString($("#<%=hidCulture.ClientID%>").val()) + "</td><td class='text-left' style='padding:8px !important'>" + invoice.amount + "</td><td class='text-center' style='padding:8px !important'>" + szButton + "</td>";
                        sb += "</tr>";
                    }
                }

                sb += "</table>";
            }
            else {
                $("#contentMain_hidInvoices").val("");
            }

            $("#<%=divAttachedInvoices.ClientID%>").html(sb);
        }

        function removeInvoice(num) {
            var invoices = JSON.parse($("#<%=hidInvoices.ClientID%>").val());
            var ndx = 0;
            for (var i = 0; i < invoices.length; i++) {
                if (invoices[i] != null) {
                    ndx++;
                    if (ndx == num) {
                        delete invoices[i];
                        break;
                    }
                }
            }

            var data = JSON.stringify(invoices).replace("null,", "").replace("null", "");
            $("#<%=hidInvoices.ClientID%>").val(data);

            refresh();
        }

        function validateInvoiceData(t) {
            var msg = "";
            var f = "";

            f = $("#<%=txtInvoiceNumber.ClientID%>").val() == undefined ? '' : $("#<%=txtInvoiceNumber.ClientID%>").val().trim();
            if (f == '')
                msg += "- Invoice Number<br/>";

            f = $("#<%=txtInvoiceDate.ClientID%>").val() == undefined ? '' : $("#<%=txtInvoiceDate.ClientID%>").val().trim();
            if (f == '')
                msg += "- Invoice Date<br/>";

            f = $("#<%=txtInvoiceAmount.ClientID%>").val() == undefined ? '' : $("#<%=txtInvoiceAmount.ClientID%>").val().trim();
            if (f == '')
                msg += "- Invoice Amount<br/>";

            if (msg.length > 0 && t.id !== undefined) {
                event.preventDefault();
                msg = "The following required Invoice fields are empty:<br><br>" + msg;
                displayErrorMessage(msg);
                return false;
            }

            return true;
        }
    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Label ID="ReturnURL" Visible="false" runat="server" />
    <asp:HiddenField ID="PostBackURL" runat="server" />
    <asp:HiddenField ID="hidInvoices" runat="server" />
    <asp:HiddenField ID="hidCulture" runat="server" />

    <asp:Panel ID="pnlCourtesyContact" runat="server">
        <div class="form-group">
            <div class="row">
                <div class="col-md-12">
                    <asp:Literal ID="litCourtestyContactForm" runat="server" />
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.SelectACompany %>:</div>
                    <asp:HiddenField ID="hidClaimantCompanyName" runat="server" />
                </div>
                <div class="col-md-9 form-inline">
                    <asp:Label ID="lblRespondentCompanyName" runat="server" />
                    <asp:HiddenField ID="hidShortCompanyName" runat="server" />
                    <asp:LinkButton ID="btnAddRespondent" runat="server" CssClass="btn gray_btn" OnClick="btnAddRespondentClick">
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnSelect %>" />
                    </asp:LinkButton>
                    <asp:HiddenField ID="hdnRespondentCompanyID" runat="server" />
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.ContactName %>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:TextBox ID="txtContactName" Columns="30" MaxLength="50" tsiRequired="true" tsiDisplayName='<%$Resources:Global, RespondentContactName %>' 
                        runat="server" CssClass="form-control preview" />
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.ContactEmail%>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:TextBox ID="txtContactEmail" Columns="30" MaxLength="255" tsiRequired="true" tsiEmail="true" tsiDisplayName="<%$ Resources:Global, ContactEmail %>" runat="server"
                        CssClass="form-control preview"/>
                </div>
            </div>

            <div class="row mar_top25">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.InvoiceNumber%>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:TextBox ID="txtInvoiceNumber" Columns="30" MaxLength="255" tsiDisplayName="<%$ Resources:Global, InvoiceNumber %>" runat="server"
                        CssClass="form-control preview"/>
                </div>
            </div>

            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.InvoiceDate%>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:TextBox ID="txtInvoiceDate" Columns="30" MaxLength="255" tsiDate="true" tsiDisplayName="<%$ Resources:Global, InvoiceDate %>" runat="server" CssClass="form-control preview"/>
                    <cc1:CalendarExtender id="ceDate" TargetControlID="txtInvoiceDate" runat="server" />
                </div>
            </div>

            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.InvoiceAmount%>:</div>
                </div>
                <div class="col-md-5 form-inline">
                    $ <asp:TextBox ID="txtInvoiceAmount" Columns="10" tsiCurrency="true" tsiDisplayName="<%$ Resources:Global, InvoiceAmount%>" runat="server" CssClass="form-control preview" placeholder="###.##"/>
                    <%= Resources.Global.inusdollars %>
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-5 offset-md-3">
                    <asp:LinkButton ID="btnAddInvoice" runat="server" CssClass="btn gray_btn" OnClick="btnAddInvoice_Click" OnClientClick="validateInvoiceData(this);" >
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, AddInvoice %>" />
                    </asp:LinkButton>
                </div>
            </div>

            <div class="row mar_top20">
                <div class="col-md-7 offset-md-3" id="divAttachedInvoices" runat="server">
                </div>
            </div>

            <div class="row mar_top_5">
                &nbsp;
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><asp:Literal runat="server" Text="<%$Resources:Global, InvoicePDFs%>" /></div>
                </div>
                <div class="col-md-5">
                    <asp:FileUpload ID="FileUpload1" ClientIDMode="Static" runat="server" tsiDisplayName="<%$Resources:Global, AdditionalFile1 %>" Width="100%" onchange="this.form.submit()" />
                </div>
                <div class="col-md-2">
                    <asp:LinkButton ID="btnAttachFile" runat="server" CssClass="btn gray_btn" OnClick="btnAttach_Click" Visible="false">
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnAttachFile %>" />
                    </asp:LinkButton>
                </div>
            </div>

            <asp:UpdatePanel ID="pnlAttachedFiles" UpdateMode="Always" ChildrenAsTriggers="true" runat="server">
                <ContentTemplate>
                    <div class="row mar_top_5">
                        <div class="col-md-5 offset-md-3">
                            <asp:ListBox ID="lbAttachedFiles" Width="100%" Rows="2" runat="server" />
                        </div>
                        <div class="col-md-2">
                            <asp:LinkButton ID="btnRemoveFile" runat="server" CssClass="btn gray_btn" OnClick="btnRemoveFile_Click">
		                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnRemoveFile %>" />
                            </asp:LinkButton>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>

            <asp:HiddenField ID="hidPreviewTemplate" runat="server" />


            <div class="row mar_top25">
                <div class="col-md-3">
                    <div class="clr_blu"><asp:Literal runat="server" Text="<%$Resources:Global, btnPreviewCourtesyContact %>" />:</div>
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-12" id="divPreview">
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-9">
                <asp:LinkButton ID="btnSubmit" runat="server" CssClass="btn gray_btn" OnClick="btnSubmitOnClick" OnClientClick="return Submit();">
		            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnSubmitCourtesyContact %>" />
                </asp:LinkButton>
                <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancelOnClick">
		            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnCancel %>" />
                </asp:LinkButton>
            </div>
        </div>

        <div class="row mar_top25">
            <div class="col-md-12" id="divBottom" runat="server">
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlThankYou" Visible="false" runat="server">
        <br />
        <div class="row">
            <div class="col-md-12">
                <asp:Literal ID="litThankYouMsg" runat="server" />
            </div>
        </div>

        <div class="row nomargin">
            <asp:LinkButton ID="btnDone" runat="server" CssClass="btn gray_btn" OnClick="btnDone_Click" >
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnDone %>" />
            </asp:LinkButton>
        </div>
    </asp:Panel>    
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        var manager = Sys.WebForms.PageRequestManager.getInstance();
        manager.add_beginRequest(OnBeginRequest);

        function Submit() {
            if ($("#<%=hdnRespondentCompanyID.ClientID%>").val() == "") {
                bbAlert('<% =Resources.Global.RespondentCompanyName %> <%=Resources.Global.RequiredFieldsMsg2%>');
                return false;
            }

            return true;
        }

        $(".preview").on('blur', function () {
            refreshPreview();
        });

        ///  This will fire on initial page load, and all subsequent partial page updates made  by any update panel on the page (i.e. when an invoice is added or removed)
        function pageLoad() { refresh(); }

        function preStdValidation(form) {

            return validateInvoiceData(this);
        }
    </script>
</asp:Content>