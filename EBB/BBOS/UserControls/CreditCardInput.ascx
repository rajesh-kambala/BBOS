<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CreditCardInput.ascx.cs" Inherits="PRCo.BBOS.UI.Web.UserControls.CreditCardInput" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

    <div class="row nomargin panels_box">
        <div class="col-md-12 nopadding_lr">
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h4 class="blu_tab"><%= Resources.Global.CreditCardInfo%></h4>
                </div>
                <div class="panel-body nomargin pad10">
                    <div class="row mar_top_5">
                        <div class="col-sm-3 clr_blu text-nowrap">
                            <% =Resources.Global.CreditCardNumber %>:
                        </div>
                        <div class="col-sm-9 form-inline">
                            <input type="text" id="txtCreditCardNumber" name="txtCreditCardNumber" maxlength="20" class="form-control" tsiDisplayName="Credit Card Number" tsiRequired="true" />&nbsp;<% =PageBase.GetRequiredFieldIndicator() %>
                        </div>
                    </div>

                    <div class="row mar_top_5">
                        <div class="col-sm-3 clr_blu text-nowrap">
                            <% =Resources.Global.CVV %>:
                            <a id="WhatIsCVV" runat="server" onclick="return false;" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                                <img src="images/info_sm.png" />
                            </a>
                        </div>
                        <div class="col-sm-9 form-inline">
                            <input type="text" id="txtCVV" name="txtCVV" maxlength="4" class="form-control" tsiDisplayName="CVV" tsiRequired="true" />&nbsp;<% =PageBase.GetRequiredFieldIndicator() %>

                        </div>
                    </div>

                    <div class="row mar_top_5">
                        <div class="col-sm-3 clr_blu text-nowrap">
                            <% =Resources.Global.ExpirationDate %>:
                        </div>
                        <div class="col-sm-9 form-inline">
                            <input type="text" id="txtExpirationMonth" name="txtExpirationMonth" maxlength="2" class="form-control" style="width:70px;display:inline-block" placeholder="MM"/>
                            <input type="text" id="txtExpirationYear" name="txtExpirationYear" maxlength="4" class="form-control" style="width:70px;display:inline-block" placeholder="YY"/> &nbsp;<% =PageBase.GetRequiredFieldIndicator() %>
                        </div>
                    </div>

                    <div class="row mar_top_5">
                        <div class="col-sm-3 clr_blu text-nowrap">
                            <% =Resources.Global.NameOnCard %>:
                        </div>
                        <div class="col-sm-9 form-inline">
                            <asp:TextBox ID="txtNameOnCard" Columns="30" MaxLength="50" CssClass="form-control" tsiRequired="true" tsiDisplayName="<%$ Resources:Global, NameOnCard %>" runat="server" />&nbsp;<% =PageBase.GetRequiredFieldIndicator() %>
                        </div>
                    </div>

                    <div class="row mar_top_5">
                        <div class="col-sm-3 clr_blu text-nowrap">
                            <% =Resources.Global.BillingAddressLine1 %>:
                        </div>
                        <div class="col-sm-9 form-inline">
                            <asp:TextBox ID="txtStreet1" Columns="30" MaxLength="50" CssClass="form-control" tsiRequired="true" tsiDisplayName="<%$ Resources:Global, BillingAddressLine1 %>" runat="server" />&nbsp;<% =PageBase.GetRequiredFieldIndicator() %>
                        </div>
                    </div>

                    <div class="row mar_top_5">
                        <div class="col-sm-3 clr_blu text-nowrap">
                            <% =Resources.Global.BillingAddressLine2 %>:
                        </div>
                        <div class="col-sm-9 form-inline">
                            <asp:TextBox ID="txtStreet2" Columns="30" MaxLength="50" CssClass="form-control" tsiDisplayName="<% =$ Resources:Global, BillingAddressLine2 %>" runat="server" />
                        </div>
                    </div>

                    <div class="row mar_top_5">
                        <div class="col-sm-3 clr_blu text-nowrap">
                            <% =Resources.Global.BillingCity %>:
                        </div>
                        <div class="col-sm-9 form-inline">
                            <asp:TextBox ID="txtCity" Columns="30" MaxLength="50" CssClass="form-control" tsiRequired="true" tsiDisplayName="<%$ Resources:Global, BillingCity %>" runat="server" />&nbsp;<% =PageBase.GetRequiredFieldIndicator() %>
                        </div>
                    </div>

                    <div class="row mar_top_5" id="trBillingCounty" runat="server">
                        <div class="col-sm-3 clr_blu text-nowrap">
                            <% =Resources.Global.BillingCounty %>:
                        </div>
                        <div class="col-sm-9 form-inline">
                            <asp:TextBox ID="txtCounty" Columns="30" MaxLength="50" CssClass="form-control" tsiRequired="true" tsiDisplayName="<%$ Resources:Global, BillingCounty %>" runat="server" />&nbsp;<% =PageBase.GetRequiredFieldIndicator() %>
                        </div>
                    </div>

                    <div class="row mar_top_5">
                        <div class="col-sm-3 clr_blu text-nowrap">
                            <% =Resources.Global.BillingCountry %>:
                        </div>
                        <div class="col-sm-9 form-inline">
                            <asp:DropDownList ID="ddlCountry" Width="215px" tsiRequired="true" CssClass="form-control" tsiDisplayName="<%$ Resources:Global, BillingCountry %>" runat="server" />&nbsp;<% =PageBase.GetRequiredFieldIndicator() %>
                        </div>
                    </div>

                    <div class="row mar_top_5">
                        <div class="col-sm-3 clr_blu text-nowrap">
                            <% =Resources.Global.BillingState %>:
                        </div>
                        <div class="col-sm-9 form-inline">
                            <asp:DropDownList ID="ddlState" Width="215px" runat="server" CssClass="form-control" tsiRequired="true" tsiDisplayName="<%$ Resources:Global, BillingState %>" />&nbsp;<% =PageBase.GetRequiredFieldIndicator() %>
                        </div>
                    </div>

                    <cc1:CascadingDropDown ID="cddCountry" TargetControlID="ddlCountry" ServicePath="AJAXHelper.asmx" ServiceMethod="GetCountries" Category="Country" runat="server" />
                    <cc1:CascadingDropDown ID="cddState" TargetControlID="ddlState" ServicePath="AJAXHelper.asmx" ServiceMethod="GetStates" Category="State" ParentControlID="ddlCountry" runat="server" />

                    <div class="row mar_top_5 mar_bot_10">
                        <div class="col-sm-3 clr_blu text-nowrap">
                            <% =Resources.Global.BillingPostalCode %>:
                        </div>
                        <div class="col-sm-9 form-inline">
                            <asp:TextBox ID="txtPostalCode" Columns="20" MaxLength="20" CssClass="form-control" tsiRequired="true" tsiDisplayName="<%$ Resources:Global, BillingPostalCode %>" runat="server" />&nbsp;<% =PageBase.GetRequiredFieldIndicator() %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
