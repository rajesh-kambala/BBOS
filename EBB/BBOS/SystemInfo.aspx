<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="SystemInfo.aspx.cs" Inherits="PRCo.BBOS.UI.Web.SystemInfo" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    <script type="text/javascript">
        function openTraceWindow(szURL) {
            winTraceHandle = window.open(szURL,
                "winTrace",
                "height=260,width=610,location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes", true);
        }

        function toggleElement(displayElement, imgElement) {

            var eDisplayElement = document.getElementById(displayElement);
            var eImageElement = document.getElementById(imgElement);

            if (eDisplayElement.style.display == "") {
                eDisplayElement.style.display = "none";
                eImageElement.src = "en-us/images/plus.gif";
            } else {
                eDisplayElement.style.display = "";
                eImageElement.src = "en-us/images/minus.gif";
            }
        }
    </script>

    <div class="row nomargin panels_box">
        <a href="#SystemAvailability" runat="server"/>
        <div class="col-md-6 col-xs-12">
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h4 class="blu_tab"><%= Resources.Global.SystemAvailability%></h4>
                </div>
                <div class="panel-body nomargin pad10">
                    <div class="small_horizontal_box_content">
                        <table class="table table-striped table-hover tab_bdy" >
                            <tr>
                                <td class="text-nowrap" width="200">System Up Time:</td>
                                <td class="text-nowrap">
                                    <asp:Label ID="lblSystemUpTime" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td class="text-nowrap">Application Start:</td>
                                <td class="text-nowrap">
                                    <asp:Label ID="lblApplicationStart" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td class="text-nowrap">Application Up Time:</td>
                                <td class="text-nowrap">
                                    <asp:Label ID="lblApplicationUpTime" runat="server" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-6 col-xs-12">
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h4 class="blu_tab"><%= Resources.Global.VersionInfo%></h4>
                </div>
                <div class="panel-body nomargin pad10">
                    <asp:Table ID="tblVersionInfo" runat="server" CssClass="table table-striped table-hover tab_bdy"/>
                </div>
            </div>
        </div>
        <div class="col-xs-12">
            <a href="#UserSessions" runat="server"/>
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h4 class="blu_tab"><%= Resources.Global.UserSessions%></h4>
                </div>
                <div class="panel-body nomargin pad10">
                    <asp:UpdatePanel ID="pnlSessionTracker" runat="server">
                        <ContentTemplate>
                            <div class="row nomargin_lr mar_bot">
                                <asp:Label ID="lblSessionTrackerCount" runat="server" />
                            </div>

                            <div style="width: 100%; max-height: 500px; overflow-y: auto;">
                                <asp:GridView ID="gvSessionTracker" 
                                    AllowSorting="true" 
                                    Width="100%" 
                                    CellSpacing="3"
                                    runat="server" 
                                    AutoGenerateColumns="false" 
                                    CssClass="table table-striped table-hover tab_bdy" 
                                    GridLines="none"
                                    OnSorting="gvSession_Sorting">

                                    <Columns>
                                        <asp:TemplateField HeaderText="Select" HeaderStyle-CssClass="text-center text-nowrap" ItemStyle-CssClass="text-center">
                                            <ItemTemplate>
                                                <input type="checkbox" name="cbSessionTracker" value="<%# Eval("UserID")%>">
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:BoundField HeaderText="User ID" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap" DataField="UserID" SortExpression="UserID" />

                                        <asp:TemplateField HeaderText="Email" HeaderStyle-CssClass="text-nowrap" ItemStyle-CssClass="text-left" SortExpression="Email">
                                            <ItemTemplate>
                                                <%# UIUtils.GetHyperlink("mailto://" + (string)Eval("Email"), (string)Eval("Email"))%>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:BoundField HeaderText="First Access" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap" DataField="FirstAccess" SortExpression="FirstAccess" />
                                        <asp:BoundField HeaderText="Last Access" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap" DataField="LastRequest" SortExpression="LastRequest" />
                                        <asp:BoundField HeaderText="Expiration" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap" DataField="Expiration" SortExpression="Expiration" />
                                        <asp:BoundField HeaderText="Page Count" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap" DataField="PageCount" SortExpression="PageCount" />
                                    </Columns>
                                </asp:GridView>
                            </div>

                            <div class="row nomargin text-left mar_top">
                                <asp:LinkButton ID="btnRemoveSessionTracker" runat="server" CssClass="btn gray_btn" OnClick="RemoveSessionTracker">
		                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, RemoveSessionTracker %>" />
                                </asp:LinkButton>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>
        <div class="col-xs-12">
            <a href="#ReferenceData" runat="server"/>
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h4 class="blu_tab"><%= Resources.Global.CachedCustomCaptions%></h4>
                </div>
                <div class="panel-body nomargin pad10">
                    <div style="width: 100%; max-height: 500px; overflow-y: auto;">
                        <table cellspacing="2" cellpadding="5" class="table table-striped table-hover tab_bdy" width="100%">
                            <tr>
                                <th class="text-nowrap" colspan="2">Name</th>
                                <th class="text-nowrap" style="width:80px;">Code</th>
                                <th class="text-nowrap" style="width:500px;">Meaning</th>
                            </tr>
                            <asp:Repeater ID="repLookupCodes" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td style="width: 20px" class='text-center vertical-align-top'>
                                            <img src="en-us/images/plus.gif" id="imgtbl<%# (string)Container.DataItem %>" style="cursor: pointer;" onclick="toggleElement('tbl<%# (string)Container.DataItem %>', 'imgtbl<%# (string)Container.DataItem %>');" />
                                        </td>
                                        <td class="vertical-align-top" style="width:200px;"><%# GetDisplayName((string)Container.DataItem) %>:</td>
                                        <td class="vertical-align-top" style="width:580px;" colspan="2">
                                            <table id="tbl<%# (string)Container.DataItem %>" style="display: none;">
                                                <asp:Repeater ID="repUserWeek" DataSource="<%# GetLookupCodes((string)Container.DataItem) %>" runat="server">
                                                    <ItemTemplate>
                                                        <tr>
                                                            <td style="width: 80px;"><%# Eval("Code") %> </td>
                                                            <td style="width: 500px;"><%# Eval("Meaning") %> </td>
                                                        </tr>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </table>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </table>
                    </div>

                    <div class="row nomargin text-left mar_top">
                        <asp:LinkButton ID="btnClearRefData" runat="server" CssClass="btn gray_btn" OnClick="ResetRefData">
		                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ClearReferenceData %>" />
                        </asp:LinkButton>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xs-12 hidden">
            <a href="#TraceFile" runat="server"/>
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h4 class="blu_tab"><%= Resources.Global.TraceFile%></h4>
                </div>
                <div class="panel-body nomargin pad10">
                    <table class="table table-striped table-hover tab_bdy" >
                        <tr>
                            <td class="text-nowrap">Date Created:</td>
                            <td class="text-nowrap">
                                <asp:Label ID="lblTraceFileCreated" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td class="text-nowrap">Date Updated:</td>
                            <td class="text-nowrap">
                                <asp:Label ID="lblTraceFileUpdated" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td class="text-nowrap">Size:</td>
                            <td class="text-nowrap">
                                <asp:Label ID="lblTraceFileSize" runat="server" />
                            </td>
                        </tr>
                    </table>

                    <div class="row nomargin text-left mar_top">
                        <asp:LinkButton ID="btnViewTrace" runat="server" CssClass="btn gray_btn">
		                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ViewTraceFile%>" />
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnViewError" runat="server" CssClass="btn gray_btn">
		                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ViewErrorFile%>" />
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnRenameTrace" runat="server" CssClass="btn gray_btn" OnClick="RenameFile">
		                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Rename%>" />
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnDeleteTrace" runat="server" CssClass="btn gray_btn" OnClick="DeleteFile">
		                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Delete%>" />
                        </asp:LinkButton>
                    </div>

                    <script type="text/javascript">
                        function Confirm(szAction) {
                            return confirm("Are you sure you want to " + szAction + " the trace file?");
                        }
	                </script>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
</asp:Content>
