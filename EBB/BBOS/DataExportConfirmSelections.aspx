<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DataExportConfirmSelections.aspx.cs" Inherits="PRCo.BBOS.UI.Web.DataExportConfirmSelections" MasterPageFile="~/BBOS.Master" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
    </script>
    <style>
        .panel-body .clr_blc {
            width: auto;
            position: relative;
            left: -20px;
            top: 4px;
        }
        .panel-body .space {
            width: auto;
        }
        .row.Title b {
            width: auto;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:HiddenField ID="hidTriggerPage" runat="server" />
    <asp:HiddenField ID="hidRemainingExportCount" runat="server" />

    <div class="row nomargin panels_box">
        <div class="col-md-12">
            <div class="row Title" style="margin-bottom: 15px;"><nobr>
                <asp:Literal ID="litHeaderText" runat="server" />
                <% =Resources.Global.CompanyDataExportMsg %>
            </nobr></div>

            <div class="row">
                <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                    <ContentTemplate>
                        <div class="row nomargin panels_box">
                            <div class="row nomargin">
                                <div class="col-md-5">
                                    <div class="panel panel-primary">
                                        <div class="panel-heading">
                                            <h4 class="blu_tab"><%= Resources.Global.SelectDataExport%></h4>
                                        </div>
                                        <div class="panel-body nomargin pad10">
                                            <div class="row nomargin" id="trExportCO" runat="server">
                                                <asp:RadioButton ID="rbExportCO" CssClass="space" GroupName="rbExport" Text="<%$Resources:Global, BasicCompanyDataExport %>" runat="server" OnCheckedChanged="rbExportType_CheckedChanged" AutoPostBack="true" />
                                                &nbsp;
                                                <a id="lbWhatIsContactExportCO" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                                                    <img src="images/info_sm.png" />
                                                </a>
                                            </div>

                                            <div class="row nomargin" id="trExportCDE" runat="server">
                                                <asp:RadioButton ID="rbExportCDE" CssClass="space" GroupName="rbExport" Text="<%$Resources:Global, DetailedCompanyDataExport%>" runat="server" OnCheckedChanged="rbExportType_CheckedChanged" AutoPostBack="true" />
                                                &nbsp;
                                                <a id="lbWhatIsCompanyDataExport" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                                                    <img src="images/info_sm.png" />
                                                </a>
                                            </div>

                                            <div class="row nomargin" id="trExportHCO" runat="server">
                                                <asp:RadioButton ID="rbExportHCO" CssClass="space" GroupName="rbExport" Text="<%$Resources:Global, ContactExportCompanyHeadExecutive%>" runat="server" OnCheckedChanged="rbExportType_CheckedChanged" AutoPostBack="true" />
                                                &nbsp;
                                                <a id="lbWhatIsContactExportCHE" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                                                    <img src="images/info_sm.png" />
                                                </a>
                                            </div>

                                            <div class="row nomargin" id="trExportAC" runat="server">
                                                <asp:RadioButton ID="rbExportAC" CssClass="space" GroupName="rbExport" Text="<%$Resources:Global, ContactExportAllContacts %>" runat="server" OnCheckedChanged="rbExportType_CheckedChanged" AutoPostBack="true" />
                                                &nbsp;
                                                <a id="lbWhatIsContactExportAll" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                                                    <img src="images/info_sm.png" />
                                                </a>

                                            </div>

                                            <div class="row nomargin" id="trExportBBSi" runat="server" visible="false">
                                                <asp:RadioButton ID="rbBBSiExport" CssClass="space" GroupName="rbExport" Text="<%$Resources:Global, BBSDataExport %>" runat="server" OnCheckedChanged="rbExportType_CheckedChanged" AutoPostBack="true" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="rbExportCO" EventName="CheckedChanged" />
                        <asp:AsyncPostBackTrigger ControlID="rbExportHCO" EventName="CheckedChanged" />
                        <asp:AsyncPostBackTrigger ControlID="rbExportAC" EventName="CheckedChanged" />
                        <asp:AsyncPostBackTrigger ControlID="rbExportCDE" EventName="CheckedChanged" />
                    </Triggers>
                </asp:UpdatePanel>

                <br />

                <%--Buttons--%>
                <div class="row nomargin text-left mar_top">
                    <asp:LinkButton ID="btnGenerateExport" runat="server" CssClass="btn gray_btn" OnClick="btnGenerateExport_Click">
	                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, GenerateExport %>" />
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnReviseSelections" runat="server" CssClass="btn gray_btn" OnClick="btnReviseSelections_Click">
	                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, ReviseSelections %>" />
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnHome" runat="server" CssClass="btn gray_btn" OnClick="btnHome_Click">
    	                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Home %>" />
                    </asp:LinkButton>
                </div>

                <div class="clearfix"></div>

                <asp:Panel ID="pnlMsg" Style="margin-top: 15px; margin-bottom: 15px; margin-left: auto; margin-right: auto; width: 800px; text-align: left;" Visible="false" runat="server">
                    <asp:Literal ID="litMsg" runat="server" Text="<%$Resources:Global, LocalSourceDataProvidedByMeisterNotLicensed %>" />
                </asp:Panel>
                
                <div class="row mar_top">
                    <asp:Label ID="lblRecordCount" runat="server" CssClass="RecordCnt" />
                </div>

                <div class="clearfix"></div>

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
                        DataKeyNames="comp_CompanyID"
                        ShowFooter="true">

                        <Columns>
                            <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap" ItemStyle-CssClass="text-left" DataField="comp_CompanyID" SortExpression="comp_CompanyID" />

                            <%--Icons Column--%>
                            <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
                                <ItemTemplate>
                                    <%# GetCompanyDataForCell((int)Eval("comp_CompanyID"), 
                                        (string)Eval("comp_PRBookTradestyle"), 
                                        (string)Eval("comp_PRLegalName"), 
                                        UIUtils.GetBool(Eval("HasNote")), 
                                        UIUtils.GetDateTime(Eval("comp_PRLastPublishedCSDate")), 
                                        (string)Eval("comp_PRListingStatus"), 
                                        true, UIUtils.GetBool(Eval("HasNewClaimActivity")), 
                                        UIUtils.GetBool(Eval("HasMeritoriousClaim")), 
                                        UIUtils.GetBool(Eval("HasCertification")), 
                                        UIUtils.GetBool(Eval("HasCertification_Organic")), 
                                        UIUtils.GetBool(Eval("HasCertification_FoodSafety")), 
                                        true, 
                                        false)%>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%--Company Name column--%>
                            <asp:TemplateField HeaderStyle-CssClass="text-left" HeaderText="<%$ Resources:Global, CompanyName %>" SortExpression="comp_PRBookTradestyle">
                                <ItemTemplate>
                                    <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField HeaderText="<%$ Resources:Global, Location %>"
                                ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left" DataField="CityStateCountryShort"
                                SortExpression="CityStateCountryShort" />

                            <asp:BoundField HeaderText="<%$ Resources:Global, Industry %>"
                                ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left" DataField="IndustryType"
                                SortExpression="IndustryType" />

                            <%--Type/Industry Column--%>
                            <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" ItemStyle-CssClass="text-left vertical-align-top" SortExpression="CompanyType">
                                <HeaderTemplate>
                                    <asp:LinkButton ID="lbTypeIndustryColHeader" runat="server" Text='<%$ Resources:Global, Type %>' CommandName="Sort" CommandArgument="CompanyType" />
                                    &nbsp;
                                        <a id="popWhatIsIndustry" runat="server" class="clr_blc cursor_pointer" data-bs-html="true" style="color: #000;" data-bs-toggle="modal" data-bs-target="#pnlIndustry">
                                            <asp:Image runat="server" ImageUrl="images/info_sm.png" ToolTip="<%$ Resources:Global, WhatIsThis %>" />
                                        </a>
                                </HeaderTemplate>

                                <ItemTemplate>
                                    <%# PageControlBaseCommon.GetCompanyType((string)Eval("CompanyType"), Eval("comp_PRLocalSource"))%>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>

                    <div id="pnlIndustry" class="modal fade" role="dialog">
                        <div class="modal-dialog">
                            <!-- Modal content-->
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-bs-dismiss="modal">&times;</button>
                                </div>
                                <div class="modal-body">
                                    <span class="sml_font">
                                        <%= Resources.Global.IndustryHelp %>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>
