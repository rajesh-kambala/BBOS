<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="MembershipSelect.aspx.cs" Inherits="PRCo.BBOS.UI.Web.MembershipSelect" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <style>
        .explicitlink img {
            display: inline;
            position: relative;
            top: -1px;
        }
    </style>
    <div class="row nomargin panels_box">
        <div class="row nomargin">
            <div class="col-md-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab"><%= Resources.Global.MembershipBenefits %></h4>
                    </div>
                    <div class="panel-body nomargin pad10">
                        <asp:Literal ID="litMembershipSelect" runat="server" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row nomargin panels_box">
        <div class="row nomargin">
            <div class="col-md-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab"><%= Resources.Global.SelectMembershipPackage %></h4>
                    </div>
                    <div class="panel-body nomargin pad10">
                        <div class="row nomargin_lr mar_bot" id="rowMembershipComparison" runat="server">
                            <div class="col-md-12 text-center">
                                <asp:HyperLink ID="hlMembershipComparison" runat="server" CssClass="explicitlink" Target="_blank">
                                    <img src="<% =UIUtils.GetImageURL("fileicon-pdf.gif") %>" style=" border: 0; vertical-align:middle;" alt="" /> <% =Resources.Global.MembershipComparisonChart %>
                                </asp:HyperLink>
                            </div>
                        </div>
                        <div class="row mar_bot">
                            <div class="col-md-12">
                                <asp:Literal ID="litMembershipSelectMsg2" Text="<%$ Resources:Global, MembershipSelectMsg2%>" runat="server" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12">
                                <table style="width: 100%">
                                    <asp:Repeater ID="repMemberships" runat="server">
                                        <ItemTemplate>
                                            <!-- <%# IncrementRepeaterCount()  %>-->
                                            <%# GetBeginSeparator(_iRepeaterCount, 2, "25px")%>
                                            <input type="radio" id="rbMembership<%# _iRepeaterCount %>" name="rbProductID" value="<%# Eval("prod_ProductID") %>" <%# GetDisabled((int)Eval("prod_PRSequence")) %> <%# GetChecked((int)Eval("prod_ProductID")) %> /></td>
       
                                            <td style="vertical-align: top; text-align: left;">
                                                <span style="font-weight: bold;">
                                                    <label for="rbMembership<%# _iRepeaterCount %>" class="notbold"><%# Eval("prod_Name") %>:</label>
                                                    <%# UIUtils.GetFormattedCurrency((decimal)Eval("StandardUnitPrice"))%> <%# Resources.Global.Annually %>
                                                </span>
                                                <br />
                                                <%# Eval("prod_PRDescription")%>
                                                <br />
                                                <%# GetEndSeparator(_iRepeaterCount, 2)%>
                                        </ItemTemplate>
                                    </asp:Repeater>

                                    <% =GetCompleteSeparator(_iRepeaterCount, 2)%>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

	<div class="row nomargin_lr mar_top">
		<div class="col-md-12">
			<asp:LinkButton ID="btnSelect" runat="server" CssClass="btn gray_btn" OnClick="btnSelectOnClick">
				<i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Select %>" />
			</asp:LinkButton>
        </div>
    </div>
</asp:Content>
