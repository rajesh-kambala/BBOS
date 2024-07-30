<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PerformanceIndicators.ascx.cs" Inherits="PRCo.BBOS.UI.Web.PerformanceIndicators" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Import Namespace="PRCo.EBB.BusinessObjects" %>

<asp:HiddenField ID="hidHQID" runat="server" />

<div class="col4_box">
    <asp:Panel ID="pnlHidden" Visible="true" runat="server">
        <div class="cmp_nme">
            <h4 class="blu_tab">
                <asp:Literal ID="litPanelTitle" runat="server" Text="<%$ Resources:Global,PerformanceIndicators %>" />
            </h4>
        </div>

        <div class="tab_bdy dtl_tab">
            <div class="row bor_bottom nomargin pad10">
                <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                    <p class="clr_blu">
                        <asp:Literal Text="<%$ Resources:Global, RatingHistory %>" ID="litRatingHistory" runat="server" />:
                    </p>
                </div>

                <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                    <p class="nopadding">
                        <asp:Label ID="lblRatingHistory" runat="server" CssClass="PopupLink" Text="<%$ Resources:Global, View%>" onclick="PopulateRatingHistory();" />
                        <asp:Label ID="lblRatingHistory_NoLink" runat="server" Text="Not Rated" Visible="false" />
                    </p>
                </div>
            </div>

            <div class="row bor_bottom nomargin pad10" id="rowFinancialStmtLastSubmitted" runat="server">
                <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                    <p class="clr_blu">
                        <asp:Literal Text="<%$ Resources:Global, FinancialStmtLastSubmitted%>" ID="litFinancialStmsLastSubmittedTitle" runat="server" />:
                    </p>
                </div>

                <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                    <p class="nopadding">
                        <asp:Label ID="lblFinancialStmtLastSubmitted" runat="server" CssClass="PopupLink" Text="[Load Data]" onclick="PopulateFinancialStatement();" />
                    </p>
                </div>
            </div>

            <asp:Panel ID="pnlTradeActivitySummaryWrapper" runat="server">
                <div class="row nomargin pad10" runat="server" onclick="PopulateTradeActivitySummary();">
                    <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                        <p class="clr_blu">
                            <asp:Literal Text="<%$ Resources:Global, TradeActivitySummary%>" ID="litTradeActivitySummary" runat="server" />:
                        </p>
                    </div>

                    <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                        <p class="nopadding">
                            <asp:Label ID="lblTradeActivitySummary" runat="server" CssClass="PopupLink" Text="[Load Data]" />
                        </p>
                    </div>

                    <div class="col-xs-12 nopadding mar_top_5">
                        <p class="clr_blu smaller">
                            (<asp:Literal Text="<%$ Resources:Global, TradeActivitySummaryLegend%>" ID="litTradeActivitySummaryLegend" runat="server" />)
                        </p>
                    </div>

                    <div class="col-xs-12 nopadding mar_top text-center">
                        <asp:Image ID="imgTradeActivitySummary" runat="server" CssClass="PopupLink" AlternateText="[Load Data]" />
                    </div>
                </div>
                <%--Insert Linear Gauge Chart here--%>
                <div class="row nomargin pad10" runat="server" onclick="PopulateTradeActivitySummary();">
                    <div class="col-xs-12 nopadding">
                        <p class="clr_blu_color">
                            <asp:Label ID="lblTradeRepotsIncluded" runat="server" CssClass="PopupLink_NoColor" />
                        </p>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </asp:Panel>

    <!-- Modal Popups -->
    <div class="modal fade" id="pnlRatingHistory" 
            data-bs-keyboard="false"
            tabindex="-1"
            aria-labelledby="XRating_history_modalLabel"
            aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg" style="overflow-y: initial !important;">
            <div class="modal-content" id="RatingHistory_PrintDiv">
                 <div class="modal-header">
                     <h1
                         class="modal-title fs-5"
                         id="XRating_history_modalLabel"><%=Resources.Global.XRatingHistory%>
                     </h1>
                     <button
                         type="button"
                         class="btn-close"
                         data-bs-dismiss="modal"
                         aria-label="<%=Resources.Global.Close %>">
                     </button>
                 </div>
                <div class="modal-body" style="max-height:500px; overflow-y: auto;" id="RatingHistoryOverflowDiv">
                    <input type="image" id="btnPrintRatingHistory" title="Print Page" src="images/printer.png" onclick="printRatingHistory(); return false;" style="height:16px;width:16px">
                    <div class="row nomargin" id="divRatingHistory" runat="server" />
                </div>
                <div class="modal-footer">
                    <button type="button" class="bbsButton bbsButton-secondary" data-bs-dismiss="modal">
                        <div class="text-content">
                            <span class="label"><asp:Literal runat="server" Text="<%$Resources:Global, Close %>" /></span>
                        </div>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="pnlFinancials" role="dialog">
        <div class="modal-dialog" style="width:50%">
            <!-- Modal content-->
            <div class="modal-content" id="Financials_PrintDiv">
                <div class="modal-body">
                    <input type="image" id="btnPrintFinancials" title="Print Page" src="images/printer.png" onclick="printFinancials(); return false;" style="height:16px;width:16px">
                    <button type="button" class="close" data-bs-dismiss="modal">&times;</button>
                    <div class="row nomargin" id="divFinancials" runat="server" />
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="pnlTradeActivitySummary"
            data-bs-keyboard="false"
            tabindex="-1"
            aria-labelledby="TradeActivitySummary_modalLabel"
            aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg" style="width:50%; overflow-y: initial !important;">
            <div class="modal-content" id="TradeActivitySummary_PrintDiv">
                 <div class="modal-header">
                     <h1
                         class="modal-title fs-5"
                         id="TradeActivitySummary_modalLabel"><%=Resources.Global.TradeActivitySummaryHistory%>
                     </h1>
                     <button
                         type="button"
                         class="btn-close"
                         data-bs-dismiss="modal"
                         aria-label="<%=Resources.Global.Close %>">
                     </button>
                 </div>
                <div class="modal-body" style="max-height:500px; overflow-y: auto;" id="TradeActivitySummaryOverflowDiv">
                    <input type="image" id="btnPrintTradeActivitySummary" title="Print Page" src="images/printer.png" onclick="printTradeActivitySummary(); return false;" style="height:16px;width:16px">
                    
                    <div class="row nomargin" id="divTradeActivitySummary" runat="server" />
                    <div class="row bor_bottom nomargin pad10" runat="server">
                        <div class="col-xs-12 nopadding">
                            <p class="small">
                                <asp:Literal id="litDisclaimer1" runat="server" />
                            </p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="bbsButton bbsButton-secondary" data-bs-dismiss="modal">
                        <div class="text-content">
                            <span class="label"><asp:Literal runat="server" Text="<%$Resources:Global, Close %>" /></span>
                        </div>
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    function PopulateRatingHistory() {
        if ($("[id$=ucPerformanceIndicators_divRatingHistory]").html() == "") {
            var jsdata = '{HQID: ' + document.getElementById('<% =hidHQID.ClientID %>').value + '}';

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "AJAXHelper.asmx/GetRatingHistoryHTML",
                data: jsdata,
                dataType: "text",
                success: function (msg) {
                    var obj = JSON.parse(msg);
                    $("[id$=ucPerformanceIndicators_divRatingHistory]").html(obj.d);
                    $('#pnlRatingHistory').modal('show');
                },
                error: function (e) {
                }
            });
        }
        else
            $('#pnlRatingHistory').modal('show');
    }

    function PopulateFinancialStatement() {
        if (document.getElementById('contentMain_ucPerformanceIndicators_divFinancials').innerHTML == "") {
            var jsdata = '{HQID: ' + document.getElementById('<% =hidHQID.ClientID %>').value + ', FinancialStatementDate: "' + document.getElementById('<% =lblFinancialStmtLastSubmitted.ClientID %>').innerText + '"}';

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "AJAXHelper.asmx/GetFinancialsHTML",
                data: jsdata,
                dataType: "text",
                success: function (msg) {
                    var obj = JSON.parse(msg);
                    document.getElementById('contentMain_ucPerformanceIndicators_divFinancials').innerHTML = obj.d;

                    $('#pnlFinancials').modal('show');
                },
                error: function (e) {
                }
            });
        }
        else
            $('#pnlFinancials').modal('show');
    }

    function PopulateTradeActivitySummary() {
        if ($("[id$=ucPerformanceIndicators_divTradeActivitySummary]").html() == "") {
            var jsdata = '{HQID: ' + document.getElementById('<% =hidHQID.ClientID %>').value + '}';

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "AJAXHelper.asmx/GetTradeActivitySummaryHTML",
                data: jsdata,
                dataType: "text",
                success: function (msg) {
                    var obj = JSON.parse(msg);
                    $("[id$=ucPerformanceIndicators_divTradeActivitySummary]").html(obj.d);
                    $('#pnlTradeActivitySummary').modal('show');
                },
                error: function (e) {
                }
            });
        }
        else
            $('#pnlTradeActivitySummary').modal('show');
    }

    function printTradeActivitySummary() {
        $("#TradeActivitySummaryOverflowDiv").removeAttr("style");
        $("#btnPrintTradeActivitySummary").hide();
        printContent('TradeActivitySummary_PrintDiv');
        location.reload();
    };

    function printFinancials() {
        $("#btnPrintFinancials").hide();
        printContent('Financials_PrintDiv');
        location.reload();
    };

    function printRatingHistory() {
        $("#RatingHistoryOverflowDiv").removeAttr("style");
        $("#btnPrintRatingHistory").hide();
        printContent('RatingHistory_PrintDiv');
        location.reload();
    };
</script>
