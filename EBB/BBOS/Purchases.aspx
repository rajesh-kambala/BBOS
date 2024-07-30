<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Purchases.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Purchases" MasterPageFile="~/BBOS.Master" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function emailPurchases() {
            return confirmSelect('purchase', 'cbBusinessReport');
        }
    </script>
    <style>
        input[type=checkbox] {
            width: auto;
        }
        .Popup input[type=text] {
            width: auto;
            margin: 0;
            padding: 0;
        }
        .Popup sup {
            width: auto;
            position: relative;
            top: 12px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin">
        <div class="col-md-12">
            <div class="row">
                <div class="col-md-12 text-left smaller">
                <asp:Literal ID="litHeaderText" runat="server" />
                <br />
                <asp:Literal ID="litInstructionsText" runat="server" />
                </div>
            </div>

            <div class="row nomargin">
                <div class="panel-body nomargin pad10">
                    <asp:Label CssClass="RecordCnt" ID="lblBRRecordCount" runat="server" />
                    <span class="RecordCnt" id="lblSelectedCount"></span>

                    <div class="table-responsive">
                        <asp:GridView ID="gvBusinessReports"
                            AllowSorting="true"
                            runat="server"
                            AutoGenerateColumns="false"
                            CssClass="sch_result table table-striped table-hover"
                            GridLines="none" 
                            BorderWidth="1"
                            OnSorting="GridView_Sorting"
                            OnRowDataBound="GridView_RowDataBound"
                            SortField="prreq_CreatedDate"
                            Width="99%">

                            <Columns>
                                <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-center vertical-align-top" ItemStyle-CssClass="text-center" HeaderText="<%$ Resources:Global, Select %>">
                                    <HeaderTemplate>
                                        <% =Resources.Global.Select%>
                                        <br />
                                        <% =PageBase.GetCheckAllCheckbox("cbBusinessReport", "setSelectedCount();")%>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <input type="checkbox" name="cbBusinessReport" value="<%# Container.DataItemIndex %>" onclick="setSelectedCount();" />
                                        <input type="hidden" name="hidBRAssociatedID<%# Container.DataItemIndex %>" value="<%# Eval("prrc_AssociatedID") %>" />
                                        <input type="hidden" name="hidBRRequestTypeCode<%# Container.DataItemIndex %>" value="<%# Eval("prreq_RequestTypeCode") %>" />
                                        <input type="hidden" name="hidBRRequestID<%# Container.DataItemIndex %>" value="<%# Eval("prreq_RequestID") %>" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-center vertical-align-top" ItemStyle-CssClass="text-center" HeaderText="<%$ Resources:Global, Download %>">
                                    <ItemTemplate>
                                        <%# GetBusinessReportDownloadLink((int)Eval("prrc_AssociatedID"), (string)Eval("prreq_RequestTypeCode"), (int)Eval("prreq_RequestID"))%>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="<%$ Resources:Global, Level %>" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-nowrap text-center vertical-align-top" SortExpression="prreq_RequestTypeCode">
                                    <ItemTemplate>
                                        <%# GetRequestLevel((int)Eval("prreq_RequestID"), (string)Eval("prreq_RequestTypeCode")) %>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="<%$ Resources:Global, DateTimePurchased %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top" SortExpression="prreq_CreatedDate">
                                    <ItemTemplate>
                                        <%# GetStringFromDate(Eval("prreq_CreatedDate")) %>
                                    &nbsp;<%# ((DateTime)Eval("prreq_CreatedDate")).ToShortTimeString() %>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <%--BBNumber Column--%>
                                <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left" DataField="prrc_AssociatedID" SortExpression="comp_CompanyID" />

                                <%--Icons Column--%>
                                <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
                                    <ItemTemplate>
                                        <%# GetCompanyDataForCell((int)Eval("prrc_AssociatedID"), 
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
                                    SortExpression="comp_PRBookTradestyle">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("prrc_AssociatedID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                                        <asp:Literal ID="litLegalName" runat="server" Text='<%# PageBase.ParenWrap(Eval("comp_PRLegalName"), true)%>' />
                                        <%# Eval("CityStateCountryShort") %>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:BoundField HeaderText="<%$ Resources:Global, Industry %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" DataField="IndustryType" SortExpression="IndustryType" />

                                <asp:TemplateField HeaderText="<%$ Resources:Global, OrderedBy %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" SortExpression="OrderedBy">
                                    <ItemTemplate>
                                        <%# Eval("OrderedBy")%>
                                        <br />
                                        <%# Eval("OrderedByLocation")%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-12 text-center smaller">
            <asp:Literal ID="litFooterText" runat="server" />
        </div>
    </div>

    <div class="row nomargin_lr mar_top">
        <div class="col-md-12">
            <asp:LinkButton ID="btnEmailPurchases" runat="server" CssClass="btn gray_btn">
	        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, EmailPurchases %>" />
            </asp:LinkButton>
        </div>
    </div>

    <asp:Panel ID="pnlEmailAttachments" runat="server" CssClass="Popup" Width="600px">
        <h4 class="blu_tab"><% =Resources.Global.AreYouSureWantToEmail %></h4>

        <div class="row mar_top">
            <asp:Label ID="lblEmail" CssClass="clr_blu col-md-3" for="<%= txtAttachmentEmail.ClientID%>" runat="server"><%= Resources.Global.EmailAddress %>:</asp:Label>
            <asp:TextBox ID="txtAttachmentEmail" runat="server" Columns="30" MaxLength="255" tsiRequired="true" tsiEmail="true" tsiDisplayName="<%$ Resources:Global, EmailAddress %>" /><% =PageBase.GetRequiredFieldIndicator() %>
        </div>

        <div class="row">
            <asp:Label ID="lblSendAsZip" CssClass="clr_blu col-md-3" for="<%= cbAttachmentZipFiles.ClientID%>" runat="server"><%= Resources.Global.SendAsZipFile %>:</asp:Label>
            <asp:CheckBox ID="cbAttachmentZipFiles" runat="server" />
        </div>

        <div class="row nomargin_lr text-left mar_top">
            <asp:LinkButton ID="btnSendEmailAttachments" runat="server" CssClass="btn gray_btn" OnClick="btnSendEmailAttachmentsOnClick">
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, SendEmail %>" />
            </asp:LinkButton>

            <asp:LinkButton ID="btnCancelEmailAttachments" runat="server" CssClass="btn gray_btn">
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnCancel %>" />
            </asp:LinkButton>
        </div>
    </asp:Panel>

    <cc1:ModalPopupExtender ID="mdlEmailAttachments" runat="server"
        TargetControlID="btnEmailPurchases"
        PopupControlID="pnlEmailAttachments"
        CancelControlID="btnCancelEmailAttachments"
        BackgroundCssClass="modalBackground" />
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        function setSelectedCount() {
            setSelectedCountInternal("cbBusinessReport", "lblSelectedCount");
        }

        setSelectedCount();
    </script>
</asp:Content>
