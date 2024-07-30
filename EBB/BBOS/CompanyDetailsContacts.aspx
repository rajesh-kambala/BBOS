<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyDetailsContacts.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyDetailsContacts" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeaderMeister" Src="UserControls/CompanyDetailsHeaderMeister.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PrintHeader" Src="UserControls/PrintHeader.ascx" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <link href="Content/print.min.css" rel="stylesheet" />
    <script type="text/javascript" src="Scripts/print.min.js"></script>

    <script type="text/javascript">
        function printdiv() {
            var pContactExport = document.getElementById('<%=fsContactExportSettings.ClientID%>');
            var pAll = document.getElementById('pAll');

            var oldBody = document.body.innerHTML;

            var headstr = "<html><head><title></title></head><body>";
            var footstr = "</body>";

            HideButtons();
            Hide('fsContactExportSettings');

            Show('printHeader');
            NoBorder('pCompanyDetailsHeader');

            szP = AddPanel(pAll);

            document.body.innerHTML = headstr + szP + footstr;

            window.print();
            document.body.innerHTML = oldBody;
            location = location;
            return false;
        }
    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box" id="pAll">
        <div class="col-xs-12">
            <asp:Label ID="hidCompanyID" Visible="false" runat="server" />

            <bbos:PrintHeader id="ucPrintHeader" runat="server" Title='<% $Resources:Global, Contacts %>' />

            <div class="row nomargin">
                <div class="col-lg-5 col-md-5 col-sm-12 nopadding_l">
                    <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" />
                </div>

                <asp:Panel ID="fsContactExportSettings" runat="server" CssClass="col-lg-7 col-md-7 col-sm-12 nopadding_r">
                    <div class="row nomargin">
                        <div class="comp_nme px-0">
                            <h4 class="blu_tab"><%=Resources.Global.ContactDataExport %></h4>
                        </div>
                        <div class="row tab_bdy nomargin">
                            <div class="form-group form-inline mar_top">
                                <label for="<%= rbExportHCO.ClientID %>" class="col-md-3 col-sm-2"><%= Resources.Global.ExportType %>:</label>
                                <div class="input-group col-md-9 col-sm-10">
                                    <div style="width: 100%">
                                        <asp:RadioButton ID="rbExportHCO" GroupName="rbExport" Text="<%$ Resources:Global, ContactExportCompanyHeadExecutive %>" Checked="true" runat="server" CssClass="space" />&nbsp;
                                        <a id="WhatIsContactExportCHE" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                                            <img src="images/info_sm.png" />
                                        </a>
                                    </div>
                                    <div style="width: 100%">
                                        <asp:RadioButton ID="rbExportAC" GroupName="rbExport" Text="<%$ Resources:Global, ContactExportAllContacts %>" runat="server" CssClass="space" />&nbsp;
                                        <a id="WhatIsContactExportAll" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                                            <img src="images/info_sm.png" />
                                        </a>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group form-inline">
                                <label for="<%= ddlContactExportFormat.ClientID %>" class="col-md-3"><%= Resources.Global.ExportFormat %>:</label>
                                <div class="input-group col-md-3 col-sm-3">
                                    <asp:DropDownList ID="ddlContactExportFormat" runat="server" CssClass="form-control" />
                                </div>
                            </div>

                            <div class="form-group">
                                <div class="offset-md-3">
                                    <asp:LinkButton CssClass="btn gray_btn" ID="btnGenerateExport" OnClick="btnGenerateExportOnClick" runat="server">
                                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnGenerateExportFile %>" />
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>
                </asp:Panel>
            </div>

            <bbos:CompanyDetailsHeaderMeister ID="ucCompanyDetailsHeaderMeister" runat="server" />

            <div class="row nomargin panels_box">
                <div class="col-md-12 nopadding">
                    <div class="panel-primary">
                        <div class="panel-heading">
                            <h4 class="blu_tab"><%= Resources.Global.BBOSContacts %></h4>
                        </div>
                        <div class="panel-body nomargin pad10">
                            <div class="table-responsive">
                                <asp:GridView ID="gvContacts"
                                    runat="server"
                                    AllowSorting="true"
                                    AutoGenerateColumns="false"
                                    CssClass="table table-striped table-hover"
                                    GridLines="None"
                                    OnSorting="GridView_Sorting"
                                    OnRowDataBound="GridView_RowDataBound"
                                    HeaderStyle-CssClass="vertical-align-top">

                                    <Columns>
                                        <asp:BoundField HeaderText="Seq" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-center" DataField="DefaultSequence" SortExpression="DefaultSequence" />
                                        <asp:TemplateField HeaderText="<%$ Resources:Global, vCard %>" ItemStyle-CssClass="text-center hidden-p" HeaderStyle-CssClass="text-center vertical-align-top hidden-p">
                                            <ItemTemplate>
                                                <asp:ImageButton ImageUrl='<%# UIUtils.GetImageURL("icon-vcard.gif") %>' ToolTip="<%$ Resources:Global, DownloadVCard %>" value='<%# Eval("pers_PersonID") %>' OnClick="btnVCardOnClick" runat="server" />
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderStyle-CssClass="vertical-align-top" HeaderText="<%$ Resources:Global, PersonName %>" SortExpression="pers_LastName">
                                            <ItemTemplate>
                                                <%# GetPersonDataForCell((int)Eval("pers_PersonID"), (string)Eval("PersonName"), UIUtils.GetBool(Eval("HasNote"))) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:BoundField HeaderText="<%$ Resources:Global, Title %>" HeaderStyle-CssClass="vertical-align-top" ItemStyle-CssClass="text-left" DataField="peli_PRTitle" SortExpression="peli_PRTitle" />

                                        <asp:TemplateField HeaderText="<%$ Resources:Global, EmailAddress %>" HeaderStyle-CssClass="vertical-align-top" ItemStyle-CssClass="text-left">
                                            <ItemTemplate>
                                                <a href='mailto:<%#Eval("Email")%>' class='explicitlink'><%#Eval("Email")%></a>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:BoundField HeaderText="<%$ Resources:Global, Phone2 %>" HeaderStyle-CssClass="vertical-align-top" ItemStyle-CssClass="text-left" DataField="Phone" />
                                        <asp:BoundField HeaderText="<%$ Resources:Global, Fax2 %>" HeaderStyle-CssClass="vertical-align-top col-p-width-100" ItemStyle-CssClass="text-left" DataField="Fax" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>
