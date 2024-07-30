<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CompanyAnalysis.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyAnalysis" MasterPageFile="~/BBOS.Master" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
    </script>
    <style>
        input[type=image] {
            height: 40px;
            width: 50px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:HiddenField ID="hidTriggerPage" runat="server" />

    <div class="col-md-12 bor_bot_thick">
        <div class="row Title" style="margin-bottom: 15px;">
            <% =Resources.Global.CompanyAnalysisText %>
        </div>

        <div class="text-center">
            <asp:HyperLink Text="<%$ Resources:Global, RatioDefinitions %>" runat="server" ID="hlRatioDefinitions" CssClass="explicitlink" />
        </div>

        <div class="table-responsive">
            <asp:GridView ID="gvSelectedCompanies"
                    AllowSorting="true"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="sch_result table table-striped table-hover"
                    GridLines="none"
                    OnSorting="GridView_Sorting"
                    OnRowDataBound="GridView_RowDataBound"
                    SortField="comp_PRBookTradestyle"
                    DataKeyNames="comp_CompanyID,prfs_FinancialID">

                    <Columns>
                        <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top" HeaderStyle-Width="50px">
                            <HeaderTemplate>
                                <!--% =Resources.Global.Select%-->
                                <!--br /-->
                                <% =PageBase.GetCheckAllCheckbox("cbCompAnalysisID")%>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <input type="checkbox" name="cbCompAnalysisID" value="<%# Eval("comp_CompanyID") %>"
                                    <%# GetChecked((int)Eval("comp_CompanyID")) %> />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left"
                            DataField="comp_CompanyID" SortExpression="comp_CompanyID" HeaderStyle-Width="75px" />

                        <%--Icons Column--%>
                        <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right" HeaderStyle-Width="10px">
                            <ItemTemplate>
                                <%# GetCompanyDataForCell((int)Eval("comp_CompanyID"), 
                                                (string)Eval("comp_PRBookTradestyle"), 
                                                (string)Eval("comp_PRLegalName"), 
                                                UIUtils.GetBool(Eval("HasNote")), 
                                                UIUtils.GetDateTime(Eval("comp_PRLastPublishedCSDate")), 
                                                (string)Eval("comp_PRListingStatus"), 
                                                true, 
                                                UIUtils.GetBool(Eval("HasNewClaimActivity")), 
                                                UIUtils.GetBool(Eval("HasMeritoriousClaim")), 
                                                UIUtils.GetBool(Eval("HasCertification")), 
                                                UIUtils.GetBool(Eval("HasCertification_Organic")), 
                                                UIUtils.GetBool(Eval("HasCertification_FoodSafety")), 
                                                true, 
                                                false)%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%--Company Name column--%>
                        <asp:TemplateField HeaderStyle-CssClass="text-left vertical-align-top" HeaderText="<%$ Resources:Global, CompanyName %>"
                            SortExpression="comp_PRBookTradestyle" HeaderStyle-Width="200px">
                            <ItemTemplate>
                                <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                                <asp:Literal ID="litLegalName" runat="server" Text='<%# PageBase.ParenWrap(Eval("comp_PRLegalName"))%>' />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Global, StatementType %>" HeaderStyle-CssClass="text-center vertical-align-top" ItemStyle-CssClass="text-center"
                            SortExpression="prfs_type" HeaderStyle-Width="75px">
                            <ItemTemplate>
                                <%# GetStatementTypeDataForCell((string)GetReferenceValue("prfs_Type", Eval("prfs_Type"))) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Global, StatementDate %>" HeaderStyle-CssClass="text-center vertical-align-top" ItemStyle-CssClass="text-center"
                            SortExpression="prfs_StatementDate" HeaderStyle-Width="75px">
                            <ItemTemplate>
                                <%# PageBase.GetStringFromDate(Eval("prfs_StatementDate")) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Global, CurrentRatio %>" HeaderStyle-CssClass="text-center vertical-align-top" ItemStyle-CssClass="text-center"
                            SortExpression="prfs_CurrentRatio" HeaderStyle-Width="60px">
                            <ItemTemplate>
                                <%# FormatDecimalDataForCell(Eval("prfs_CurrentRatio"), Eval("comp_PRConfidentialFS"))%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Global, QuickRatio %>" HeaderStyle-CssClass="text-center vertical-align-top" ItemStyle-CssClass="text-center"
                            SortExpression="prfs_QuickRatio" HeaderStyle-Width="60px">
                            <ItemTemplate>
                                <%# FormatDecimalDataForCell(Eval("prfs_QuickRatio"), Eval("comp_PRConfidentialFS")) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Global, AccountReceivableTurnover %>" HeaderStyle-CssClass="text-center vertical-align-top"
                            ItemStyle-CssClass="text-center" SortExpression="prfs_ARTurnover" HeaderStyle-Width="80px">
                            <ItemTemplate>
                                <%# FormatDecimalDataForCell(Eval("prfs_ARTurnover"), Eval("comp_PRConfidentialFS")) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Global, DaysPayableOutstanding %>" HeaderStyle-CssClass="text-center vertical-align-top"
                            ItemStyle-CssClass="text-center" SortExpression="prfs_DaysPayableOutstanding" HeaderStyle-Width="95px">
                            <ItemTemplate>
                                <%# FormatDecimalDataForCell(Eval("prfs_DaysPayableOutstanding"), Eval("comp_PRConfidentialFS"))%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Global, DebtToEquity %>" HeaderStyle-CssClass="text-center vertical-align-top"
                            ItemStyle-CssClass="text-center" SortExpression="prfs_DebtToEquity" HeaderStyle-Width="60px">
                            <ItemTemplate>
                                <%# FormatDecimalDataForCell(Eval("prfs_DebtToEquity"), Eval("comp_PRConfidentialFS"))%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Global, FixedAssetsToEquity %>" HeaderStyle-CssClass="text-center vertical-align-top"
                            ItemStyle-CssClass="text-center" SortExpression="prfs_FixedAssetsToNetWorth" HeaderStyle-Width="60px">
                            <ItemTemplate>
                                <%# FormatDecimalDataForCell(Eval("prfs_FixedAssetsToNetWorth"), Eval("comp_PRConfidentialFS"))%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Global, DebtServiceAbility %>" HeaderStyle-CssClass="text-center vertical-align-top" ItemStyle-CssClass="text-center"
                            SortExpression="prfs_DebtServiceAbility" HeaderStyle-Width="60px">
                            <ItemTemplate>
                                <%# FormatDecimalDataForCell(Eval("prfs_DebtServiceAbility"), Eval("comp_PRConfidentialFS"))%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Global, OperatingRatio %>" HeaderStyle-CssClass="text-center vertical-align-top" ItemStyle-CssClass="text-center"
                            SortExpression="prfs_OperatingRatio" HeaderStyle-Width="60px">
                            <ItemTemplate>
                                <%# FormatDecimalDataForCell(Eval("prfs_OperatingRatio"), Eval("comp_PRConfidentialFS"))%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" HeaderText="<%$ Resources:Global, Rating %>"
                            HeaderStyle-Width="100px">
                            <ItemTemplate>
                                <%# GetRatingCell(Eval("prra_RatingID"), Eval("prra_RatingLine"), Eval("IsHQRating"))%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Global, BBScore %>" HeaderStyle-CssClass="text-center vertical-align-top" ItemStyle-CssClass="text-center"
                            SortExpression="prbs_BBScore" HeaderStyle-Width="60px">
                            <ItemTemplate>
                                <%# FormatIntDataForCell(Eval("prbs_BBScore")) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
        </div>
    </div>

    <div class="col-md-12">
        <div class="row">
            <table class="sch_result table" cellspacing="3">
                <tr class="shaderow">
                    <td rowspan="7" style="width: 340px;" class="TopBorder text-left bold">
                        <%= Resources.Global.RatiosComputedFromDisplayedCompanies %>
                    </td>
                    <td style="width: 155px;" class="text-right bold TopBorder"><%= Resources.Global.Average %>:</td>
                    <%= GetAverageRowData() %>
                </tr>
                <tr class="shaderow">
                    <td class='text-right bold noborder'><%= Resources.Global.Median %>:</td>
                    <%= GetMedianRowData() %>
                </tr>
                <tr class="shaderow">
                    <td class='text-right bold noborder'><%= Resources.Global.Percentile25 %>:</td>
                    <%= Get25PercentileRowData() %>
                </tr>
                <tr class="shaderow">
                    <td class='text-right bold noborder'><%= Resources.Global.Percentile75 %>:</td>
                    <%= Get75PercentileRowData() %>
                </tr>
                <tr class="shaderow">
                    <td class='text-right bold noborder'><%= Resources.Global.HighestValue %>:</td>
                    <%= GetHighestValueRowData() %>
                </tr>
                <tr class="shaderow">
                    <td class='text-right bold noborder'><%= Resources.Global.LowestValue %>:</td>
                    <%= GetLowestValueRowData() %>
                </tr>
                <tr class="shaderow">
                    <td class='text-right bold noborder'><%= Resources.Global.StandardDeviation %>:</td>
                    <%= GetStandardDeviationRowData() %>
                </tr>
            </table>
        </div>
    </div>


            

    <%--Buttons--%>
    <div class="row nomargin text-left mar_top mar_bot">
        <asp:LinkButton ID="btnReviseSelections" runat="server" CssClass="btn gray_btn" OnClick="btnReviseSelections_Click">
		    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, ReviseSelections %>" />
        </asp:LinkButton>

        <asp:ImageButton ID="btnCompanyAnalysis" runat="server" CssClass="btn gray_btn" ImageUrl="images/print.png" OnClick="btnCompanyAnalysis_Click" />
    </div>

    <div class="row nomargin mar_top">
        <span class="bbos_blue_title"><%= Resources.Global.Legend %></span><br />
        <%= Resources.Global.LegendDefNA %><br />
        n/d = Not Disclosed (<%= Resources.Global.FinancialStatementsProvidedConfidentially %>)
    </div>

    <div class="row">
        <div id="pnlRatingDef" style="display: none; width: 450px; height: auto; min-height:300px; position: absolute; z-index: 100;" class="Popup">
            <div class='popup_header'>
                <button type="button" class="close" data-bs-dismiss="modal" onclick="document.getElementById('pnlRatingDef').style.display='none';" >&times;</button>
            </div>
            <span id="ltRatingDef"></span>
        </div>
        <span id="litNonMemberRatingDef" style="display: none; visibility: hidden;">Blue Book Ratings are only available to licensed Blue Book Members.  Blue Book Ratings reflect the pay practices, attitudes, financial conditions and services of companies buying, selling & transporting fresh produce. <a href="MembershipSelect.aspx">Sign up for membership today</a> to begin using Blue Book's credit rating information to make safe and informed decisions.</span>        
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        var tds = document.getElementsByTagName("TD");
        for (var i = 0; i < tds.length; i++) {
            if (tds[i].getAttribute("align") == "center") {
                tds[i].style.textAlign = "center";
            }
        }

        var tds = document.getElementsByTagName("TH");
        for (var i = 0; i < tds.length; i++) {
            if (tds[i].getAttribute("align") == "center") {
                tds[i].style.textAlign = "center";
            }
        }
    </script>
</asp:Content>
