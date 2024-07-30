<%@ Page Title="" Language="C#" MasterPageFile="~/Produce.Master" AutoEventWireup="true" CodeBehind="BOR.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PublicProfiles.BOR" EnableEventValidation="false" %>
<%@ MasterType VirtualPath="~/Produce.Master" %>
<%@ Register TagPrefix="uc" TagName="MembershipHeader" Src="~/Controls/MembershipHeader.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="BBOSPublicProfilesHead" runat="server">
    <style type="text/css">
        .input td {
            padding: 2px;
        }

        .label {
            font-weight: bold;
            white-space: nowrap;
        }

        .red {
            color: Red !important;
        }

        .validationError {
            color: Red !important;
            text-align: left;
        }

            .validationError ul {
                list-style-type: disc;
                margin-left: 15px;
            }

                .validationError ul li {
                    color: Red;
                    margin-bottom: 0;
                    padding: 0;
                }

        .required {
            color: Red;
        }

        .bulletList {
            list-style-type: disc;
            margin-left: 25px;
            margin-top: 0;
        }

        .bulletListItem {
            margin-top: 5px;
        }

        .cbLabel input {
            vertical-align: middle;
            margin-right: 5px;
        }

        .NumericLabelDataTopBorder {
            border-top: black thin solid;
            width: 70px;
            text-align: right;
        }

        .NumericLabelData {
            width: 70px;
            text-align: right;
        }

        .nopadding {
            padding-left: 0;
            padding-right: 0;
        }

        .nopadding_lr {
            padding-left: 0 !important;
            padding-right: 0 !important;
        }

        .nopadding_tb {
            padding-top: 0 !important;
            padding-bottom: 0 !important;
        }

        .nopadding_l {
            padding-left: 0 !important;
        }

        .nopadding_r {
            padding-right: 0 !important;
        }

        .nomargin {
            margin-top: 0 !important;
            margin-left: 0 !important;
            margin-right: 0 !important;
        }

        .nomargin_lr {
            margin: 5px 0;
        }

        .mar_bottom_20 {
            margin-bottom: 20px;
        }

        .mar_top_20 {
            margin-top: 20px;
        }

        .mar_top_15 {
            margin-top: 15px;
        }

        .mar_top_10 {
            margin-top: 10px;
        }

        .norm_lbl label {
            font-weight: normal;
            margin-right: 10px;
        }

        .norm_lbl input[type="checkbox"] {
            margin-right: 5px;
            margin-bottom: 5px;
        }

        .norm_lbl td {
            width: 33%;
        }

        .explicitlink {
            color: #235495 !important;
            text-decoration: none !important;
            cursor: pointer !important;
        }

        .explicitlink:hover,  {
            color: #235495 !important;
            text-decoration: underline !important;
            cursor: pointer !important;
        }

        .row {
            margin-left:0px;
        }

        .mar_r_10 label {
            margin-right:10px;
        }
    </style>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="BBOSPublicProfilesMain" runat="server">
    <div style="margin-left: auto; margin-right: auto; overflow-x:hidden; overflow-y:auto; width:100%; height:100%;" id="BORContent">
        <div class="row">
            <h2><%=Resources.Global.BlueBookListing %></h2>
        </div>

        <div class="row">
            <div class="col-md-12">
                <uc:MembershipHeader ID="membershipHeader" CurrentStep="5" HideMembershipSummary="true" Visible="false" runat="server" />
            </div>

            <div class="row">
                <div class="col-md-6 col-md-offset-3">
                    <div class="panel panel-success">
                        <div class="panel-heading">
                            <%=Resources.Global.PaymentProcessed %>
                        </div>
                        <div class="panel-body">
                            <%=Resources.Global.ThankYouForYour %>&nbsp;<asp:Label ID="lblTotal" runat="server" />&nbsp;<%=Resources.Global.Payment %>.&nbsp;
                            <%=Resources.Global.ReceiptHasBeenEmailedToYou %> 
                            <a href="#" class="explicitlink" onclick="window.open('PaymentReceipt.aspx<%=LangQueryString() %>','_blank','toolbar=yes, scrollbars=yes, resizable=yes, top=100, left=200, width=600, height=700');return false">
                                <%=Resources.Global.Clickhere %></a> <%=Resources.Global.ForYourReceipt %>.
                            <br /><br />
                            <asp:HyperLink ID="hlAGTools" runat="server" Text="<%$Resources:Global,Clickhere %>" Target="_blank" CssClass="explicitlink" />&nbsp;<%=Resources.Global.LearnMoreAboutAGTools %>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-12" id="validationErrors1">
                <asp:Label CssClass="validationError" ID="errMsg" runat="server" />
                <asp:ValidationSummary CssClass="validationError" ValidationGroup="Required" HeaderText="<% $Resources:Global,OneOrMoreRequiredFieldsMissing %>" DisplayMode="BulletList" runat="server" />
            </div>

            <div class="col-md-12" id="validationErrors2" style="display: none;">
                <div class="validationError" id="divErrFreightTotal" style="display: none;"><%=Resources.Global.Errors_FreightTotal %></div>
            </div>
        </div>

        <div class="row">
            <p class="red"><%=Resources.Global.FieldsMarkedAsteriskRequired %></p>
        </div>

        <div class="row">
            <asp:Panel ID="pnlProduce0" runat="server" Visible="false">
                <div class="col-md-9 nopadding_l">
                    <b><%=Resources.Global.PRODUCE_LISTING %></b>
                </div>
                <div class="col-md-9 nopadding_l">
                    <%=Resources.Global.BlueBookListingVitalToSuccess %>
                </div>
                <div class="col-md-3">
                    <asp:LinkButton runat="server" CssClass="form-control" Text="<%$Resources:Global,SampleListing %>"
                        OnClientClick="javascript:window.open('https://www.producebluebook.com/wp-content/uploads/2018/10/Sample-Produce-Listing.jpg','samplelistingWindow','width=700,height=600'); return false;" />
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlTransportation0" runat="server" Visible="false">
                <div class="col-md-9 nopadding_l">
                    <b><%=Resources.Global.TRANSPORTATION_LISTING %></b>
                </div>
                <div class="col-md-9 nopadding_l">
                    <%=Resources.Global.BlueBookListingVitalToSuccess %>
                </div>
                <div class="col-md-3">
                    <asp:LinkButton runat="server" CssClass="form-control" Text="<%$Resources:Global,SampleListing %>"
                        OnClientClick="javascript:window.open('https://www.producebluebook.com/wp-content/uploads/2018/10/Sample-Produce-Listing.jpg','samplelistingWindow','width=700,height=600'); return false;" />
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlSupply0" runat="server" Visible="false">
                <div class="col-md-9 nopadding_l">
                    <b><%=Resources.Global.SUPPLY_LISTING %></b>
                </div>
                <div class="col-md-9 nopadding_l">
                    <%=Resources.Global.BlueBookListingVitalToSuccess %>
                </div>
                <div class="col-md-3">
                    <asp:LinkButton runat="server" CssClass="form-control" Text="<%$Resources:Global,SampleListing %>"
                        OnClientClick="javascript:window.open('https://www.producebluebook.com/wp-content/uploads/2018/10/Sample-Produce-Listing.jpg','samplelistingWindow','width=700,height=600'); return false;" />
                </div>
            </asp:Panel>
        </div>

        <asp:Panel ID="pnlBusinessInformation" runat="server" Visible="false">
            <div class="row mar_top_10">
                <h3><%=Resources.Global.BusinessInformation %></h3>
            </div>

            <div class="form-group form-inline">
                <div class="row">
                    <div class="col-xs-6">
                        <div class="row mar_top_2_imp">
                            <label for="<% =txtCompanyName.ClientID %>" class="col-md-3 col-sm-4"><%=Resources.Global.CompanyName %>&nbsp;<span class="required">*</span></label>
                            <div class="col-md-9 col-sm-8">
                                <asp:TextBox ID="txtCompanyName" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ControlToValidate="txtCompanyName" ValidationGroup="Required" Display="None" ErrorMessage="<%$Resources:Global,CompanyName %>" runat="server" />
                            </div>
                        </div>
                        <div class="row mar_top_2_imp">
                            <label for="<% =txtMailingAddress.ClientID %>" class="col-md-3 col-sm-4"><%=Resources.Global.MailingAddress %>&nbsp;<span class="required">*</span></label>
                            <div class="col-md-9 col-sm-8">
                                <asp:TextBox ID="txtMailingAddress" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" ControlToValidate="txtMailingAddress" ValidationGroup="Required" Display="None" ErrorMessage="<%$Resources:Global,MailingAddress %>" runat="server" />
                            </div>
                        </div>
                        <div class="row mar_top_2_imp">
                            <label for="<% =txtCity.ClientID %>" class="col-md-3 col-sm-4"><%=Resources.Global.MailingCity %>&nbsp;<span class="required">*</span></label>
                            <div class="col-md-9 col-sm-8">
                                <asp:TextBox ID="txtCity" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" ControlToValidate="txtCity" ValidationGroup="Required" Display="None" ErrorMessage="<%$Resources:Global,MailingCity %>" runat="server" />
                            </div>
                        </div>
                        <div class="row mar_top_2_imp">
                            <label for="<% =ddlState.ClientID %>" class="col-md-3 col-sm-4"><%=Resources.Global.MailingState %>&nbsp;<span class="required">*</span></label>
                            <div class="col-md-9 col-sm-8">
                                <asp:DropDownList ID="ddlState" runat="server" CssClass="form-control" Width="100%" />
                                <asp:CustomValidator ID="cvState" runat="server" ErrorMessage="<%$Resources:Global,MailingStateRequired %>" ClientValidationFunction="validateState" ValidationGroup="Required" Display="None"/>
                                <cc1:CascadingDropDown ID="cddCountry" TargetControlID="ddlCountry" ServiceMethod="GetCountries" Category="Country" runat="server" />
                                <cc1:CascadingDropDown ID="cddState" TargetControlID="ddlState" ServiceMethod="GetStates" Category="State" ParentControlID="ddlCountry" runat="server" />
                            </div>
                        </div>

                        <div class="row mar_top_2_imp">
                            <label for="<% =ddlCountry.ClientID %>" class="col-md-3 col-sm-4"><%=Resources.Global.MailingCountry %>&nbsp;<span class="required">*</span></label>
                            <div class="col-md-9 col-sm-8">
                                <asp:DropDownList ID="ddlCountry" runat="server" CssClass="form-control" Width="100%" />
                                <asp:CustomValidator ID="cvCountry" runat="server" ErrorMessage="<%$Resources:Global,MailingCountryRequired %>" ClientValidationFunction="validateCountry" ValidationGroup="Required" Display="None" />
                            </div>
                        </div>

                        <div class="row mar_top_2_imp">
                            <label for="<% =txtZipCode.ClientID %>" class="col-md-3 col-sm-4"><%=Resources.Global.MailingZipPostalCode %>&nbsp;<span class="required">*</span></label>
                            <div class="col-md-9 col-sm-8">
                                <asp:TextBox ID="txtZipCode" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator6" ControlToValidate="txtZipCode" ValidationGroup="Required" Display="None" ErrorMessage="<%$Resources:Global,MailingZipPostalCode %>" runat="server" />
                            </div>
                        </div>
                        <div class="row mar_top_2_imp">
                            <label for="<% =txtPhone.ClientID %>" class="col-md-3 col-sm-4"><%=Resources.Global.Phone %>&nbsp;<span class="required">*</span></label>
                            <div class="col-md-9 col-sm-8">
                                <asp:TextBox ID="txtPhone" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator7" ControlToValidate="txtPhone" ValidationGroup="Required" Display="None" ErrorMessage="<%$Resources:Global,Phone %>" runat="server" />
                            </div>
                        </div>
                        <div class="row mar_top_2_imp">
                            <label for="<% =txtFax.ClientID %>" class="col-md-3 col-sm-4"><%=Resources.Global.FAX %></label>
                            <div class="col-md-9 col-sm-8">
                                <asp:TextBox ID="txtFax" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                            </div>
                        </div>
                    </div>
                    <div class="col-xs-6">
                        <div class="row mar_top_2_imp">
                            <label for="<% =txtWebsite.ClientID %>" class="col-md-3 col-sm-4"><%=Resources.Global.Website %></label>
                            <div class="col-md-9 col-sm-8">
                                <asp:TextBox ID="txtWebsite" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                            </div>
                        </div>
                        <div class="row mar_top_2_imp">
                            <label for="<% =txtCompanyEmail.ClientID %>" class="col-md-3 col-sm-4"><%=Resources.Global.CompanyEmailAddress %>&nbsp;<span class="required">*</span></label>
                            <div class="col-md-9 col-sm-8">
                                <asp:TextBox ID="txtCompanyEmail" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator8" ControlToValidate="txtCompanyEmail" ValidationGroup="Required" Display="None" ErrorMessage="<%$Resources:Global,CompanyEmailAddress %>" runat="server" />
                            </div>
                        </div>

                        <asp:Panel ID="pnlNameofBank" runat="server" Visible="false">
                            <div class="row mar_top_2_imp">
                                <label for="<% =txtBankName.ClientID %>" class="col-md-3 col-sm-4"><%=Resources.Global.NameOfYourBank %></label>
                                <div class="col-md-9 col-sm-8">
                                    <asp:TextBox ID="txtBankName" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                                </div>
                            </div>
                        </asp:Panel>

                        <asp:Panel ID="pnlProduce1" runat="server" Visible="false">
                            <div class="row mar_top_2_imp">
                                <label for="<% =txtPACANumber.ClientID %>" class="col-md-3 col-sm-4">PACA #</label>
                                <div class="col-md-9 col-sm-8">
                                    <asp:TextBox ID="txtPACANumber" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                                </div>
                            </div>
                            <div class="row mar_top_2_imp">
                                <label for="<% =txtDRCNumber.ClientID %>" class="col-md-3 col-sm-4">DRC #</label>
                                <div class="col-md-9 col-sm-8">
                                    <asp:TextBox ID="txtDRCNumber" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                                </div>
                            </div>
                        </asp:Panel>

                        <asp:Panel ID="pnlTransportation1" runat="server" Visible="false">
                            <div class="row mar_top_2_imp">
                                <label for="<% =txtMCNumber.ClientID %>" class="col-md-3 col-sm-4">MC #</label>
                                <div class="col-md-9 col-sm-8">
                                    <asp:TextBox ID="txtMCNumber" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                                </div>
                            </div>
                            <div class="row mar_top_2_imp">
                                <label for="<% =txtFreightForwarderNumber.ClientID %>" class="col-md-3 col-sm-4"><%=Resources.Global.FreightForwarderNum %></label>
                                <div class="col-md-9 col-sm-8">
                                    <asp:TextBox ID="txtFreightForwarderNumber" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                                </div>
                            </div>
                        </asp:Panel>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlPrincipals" runat="server" Visible="false">
            <div class="row mar_top_10">
                <h3><%=Resources.Global.Principals %></h3>
            </div>

            <div class="form-group form-inline">
                <div class="row mar_top">
                    <label for="<% =txtPrincipalName1.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.Name1 %>&nbsp;<span class="required">*</span></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtPrincipalName1" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator9" ControlToValidate="txtPrincipalName1" ValidationGroup="Required" Display="None" ErrorMessage="<%$Resources:Global, Name1 %>" runat="server" />
                    </div>
                    <label for="<% =txtTitle1.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.Title %>&nbsp;<span class="required">*</span></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtTitle1" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator10" ControlToValidate="txtTitle1" ValidationGroup="Required" Display="None" ErrorMessage="<%$Resources:Global,Title %>" runat="server" />
                    </div>
                    <label for="<% =txtOwnership1.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.PctOfOwnership %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtOwnership1" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                    </div>

                    <label for="<% =txtYearBorn1.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.YearBorn %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtYearBorn1" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                    </div>
                    
                    <label for="<% =txtYearsInPosition1.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.YearsInPosition %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtYearsInPosition1" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                    </div>
                    <label for="<% =txtYearsAtCompany1.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.YearsAtCompany %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtYearsAtCompany1" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                    </div>
                </div>

                <div class="row mar_top_15">
                    <label for="<% =txtPrincipalName2.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.Name2 %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtPrincipalName2" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                    </div>
                    <label for="<% =txtTitle2.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.Title %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtTitle2" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                    </div>
                    <label for="<% =txtOwnership2.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.PctOfOwnership %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtOwnership2" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                    </div>
                    <label for="<% =txtYearBorn2.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.YearBorn %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtYearBorn2" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                    </div>
                    <label for="<% =txtYearsInPosition2.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.YearsInPosition %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtYearsInPosition2" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                    </div>
                    <label for="<% =txtYearsAtCompany2.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.YearsAtCompany %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtYearsAtCompany2" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                    </div>
                </div>

                <div class="row mar_top_15">
                    <label for="<% =txtPrincipalName3.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.Name3 %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtPrincipalName3" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                    </div>
                    <label for="<% =txtTitle3.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.Title %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtTitle3" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                    </div>
                    <label for="<% =txtOwnership3.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.PctOfOwnership %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtOwnership3" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                    </div>
                    <label for="<% =txtYearBorn3.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.YearBorn %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtYearBorn3" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                    </div>
                    <label for="<% =txtYearsInPosition3.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.YearsInPosition %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtYearsInPosition3" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                    </div>
                    <label for="<% =txtYearsAtCompany3.ClientID %>" class="col-md-2 col-sm-3"><%=Resources.Global.YearsAtCompany %></label>
                    <div class="col-md-2 col-sm-3">
                        <asp:TextBox ID="txtYearsAtCompany3" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                    </div>
                </div>
                <div class="form-group form-inline mar_top_7">
                    <span class="required">*</span>
                    <label for="<% =rblBankrupt.ClientID %>"><%=Resources.Global.PrincipalsFailedToPayDebt %></label>
                    <br />
                    <asp:RadioButtonList ID="rblBankrupt" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="mar_r_10">
                        <asp:ListItem Text="<%$Resources:Global,Yes %>" Value="Y" /> 
                        <asp:ListItem Text="<%$Resources:Global,No %>" Value="N" />
                    </asp:RadioButtonList>
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator11" ControlToValidate="rblBankrupt" ValidationGroup="Required" Display="None" ErrorMessage="<%$Resources:Global, BankruptYesNo %>" runat="server" />
                </div>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlEntity" runat="server" Visible="false">
            <div class="row mar_top_10">
                <h3><%=Resources.Global.Entity %></h3>
            </div>

            <div class="form-group form-inline">
                <div class="row mar_top_2_imp">
                    <label for="<% =ddlTypeofEntity.ClientID %>" class="col-md-2"><%=Resources.Global.TypeOfEntity %>&nbsp;<span class="required">*</span></label>
                    <div class="col-md-2">
                        <asp:DropDownList ID="ddlTypeofEntity" runat="server" CssClass="form-control" Width="100%" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator12" ControlToValidate="ddlTypeofEntity" ValidationGroup="Required" Display="None" ErrorMessage="<%$Resources:Global,TypeOfEntity %>" runat="server" />
                    </div>

                    <label for="<% =txtDateBusinessEstablished.ClientID %>" class="col-md-2"><%=Resources.Global.DateBusinessEstablished %></label>
                    <div class="col-md-2">
                        <asp:TextBox ID="txtDateBusinessEstablished" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                    </div>

                    <label for="<% =txtDateIncorporated.ClientID %>" class="col-md-2"><%=Resources.Global.DateIncorporated %></label>
                    <div class="col-md-2">
                        <asp:TextBox ID="txtDateIncorporated" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                    </div>
                </div>
                <div class="row mar_top_2_imp">
                    <div id="divOther" style="display:none;">
                        <label for="<% =txtOther.ClientID %>" class="col-md-2"><%=Resources.Global.Other %>&nbsp;<span class="required">*</span></label>
                        <div class="col-md-2">
                            <asp:TextBox ID="txtOther" runat="server" CssClass="form-control" Width="100%" />
                            <asp:RequiredFieldValidator ID="rfvOther" ControlToValidate="txtOther" ValidationGroup="Required" Display="None" ErrorMessage="<%$Resources:Global,EntityTypeOther %>" runat="server" EnableClientScript="true" Enabled="false" />
                        </div>
                    </div>
                    <div id="divOtherBlank" class="col-md-4">&nbsp;</div>

                    <label for="<% =ddlIncorporatedState.ClientID %>" class="col-md-2"><%=Resources.Global.IncorporatedInUSWhichState %></label>
                    <div class="col-md-2">
                        <asp:DropDownList ID="ddlIncorporatedState" runat="server" CssClass="form-control" Width="100%" />
                    </div>

                    <label for="<% =txtDateIncorporated.ClientID %>" class="col-md-2"><%=Resources.Global.NumPermanentEmployees %></label>
                    <div class="col-md-2">
                        <asp:TextBox ID="txtNumPermanentEmployees" MaxLength="10" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                    </div>
                </div>
            </div>
        </asp:Panel>

        <div class="row mar_top_10">
            <h3><%=Resources.Global.NatureOfBusiness %>&nbsp;<span class="required">*</span></h3>
        </div>

        <div class="form-group form-inline">
            <asp:Panel ID="pnlProduce2" runat="server" Visible="false">
                <div class="row mar_top_2_imp">
                    <label class="col-xs-12"><%=Resources.Global.PRODUCE_BUYER %></label>
                </div>
                <div class="row">
                    <div class="col-xs-11 col-xs-offset-1">
                        <asp:CheckBoxList ID="cblProduceBuyer" runat="server" RepeatDirection="Horizontal" RepeatColumns="3" CssClass="norm_lbl" Font-Size="Medium" DataTextField="prcl_Name" DataValueField="prcl_ClassificationID" />
                    </div>
                </div>
                <div class="row mar_top_2_imp">
                    <label class="col-xs-12"><%=Resources.Global.PRODUCE_SELLER %></label>
                </div>
                <div class="row">
                    <div class="col-xs-11 col-xs-offset-1">
                        <asp:CheckBoxList ID="cblProduceSeller" runat="server" RepeatDirection="Horizontal" RepeatColumns="3" CssClass="norm_lbl" Font-Size="Medium" DataTextField="prcl_Name" DataValueField="prcl_ClassificationID" />
                    </div>
                </div>
                <div class="row mar_top_2_imp">
                    <label class="col-xs-12"><%=Resources.Global.PRODUCE_BROKER %></label>
                </div>
                <div class="row">
                    <div class="col-xs-11 col-xs-offset-1">
                        <asp:CheckBoxList ID="cblProduceBroker" runat="server" RepeatDirection="Horizontal" RepeatColumns="3" CssClass="norm_lbl" Font-Size="Medium" DataTextField="prcl_Name" DataValueField="prcl_ClassificationID" />
                    </div>
                </div>

                <div class="row mar_top_2_imp">
                    <label class="col-xs-12"><%=Resources.Global.PRODUCE_SUPPLY_CHAIN_SERVICES%></label>
                </div>
                <div class="row">
                    <div class="col-xs-11 col-xs-offset-1">
                        <asp:CheckBoxList ID="cblSupplyChainServices" runat="server" RepeatDirection="Horizontal" RepeatColumns="3" CssClass="norm_lbl" Font-Size="Medium" DataTextField="prcl_Name" DataValueField="prcl_ClassificationID" />
                    </div>
                </div>


                <div class="row mar_top_7">
                    <label for="<%=txtCommoditiesHandled.ClientID %>" class="col-md-4"><%=Resources.Global.CommoditiesHandledTop5to10 %>&nbsp;<span class="required">*</span></label>
                    <div class="col-md-8">
                        <asp:TextBox ID="txtCommoditiesHandled" MaxLength="200" runat="server" CssClass="form-control" Width="100%" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator13" ControlToValidate="txtCommoditiesHandled" ValidationGroup="Required" Display="None" ErrorMessage="<%$Resources:Global,CommoditiesHandled %>" runat="server" />
                    </div>
                </div>
                <div class="row mar_top_2_imp">
                    <label for="<%=txtAnnualTrucklotVol_P.ClientID %>" class="col-md-4"><%=Resources.Global.AnnualTrucklotVolume %></label>
                    <div class="col-md-8">
                        <asp:TextBox ID="txtAnnualTrucklotVol_P" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                    </div>
                </div>
                <div class="row mar_top_2_imp">
                    <div class="col-md-4">
                        <div class="row">
                            <label for="<%=cblProduceBuyFrom.ClientID %>" class="col-md-12"><%=Resources.Global.IfBuyProduceFromWho %></label>
                        </div>
                        <div class="row mar_top_2_imp">
                            <div class="col-md-11 col-md-offset-1">
                                <asp:CheckBoxList ID="cblProduceBuyFrom" runat="server" RepeatDirection="Vertical" CssClass="norm_lbl" Font-Size="Medium">
                                    <asp:ListItem Text="<%$Resources:Global,BrokersDistributors %>" />
                                    <asp:ListItem Text="<%$Resources:Global,LocalWholesalers %>" />
                                    <asp:ListItem Text="<%$Resources:Global,DomesticShippers %>" />
                                    <asp:ListItem Text="<%$Resources:Global,InternationalExporters %>" />
                                    <asp:ListItem Text="<%$Resources:Global,GrowersShippers %>" />
                                </asp:CheckBoxList>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-8">
                        <div class="row">
                            <label class="col-md-12"><%=Resources.Global.WhereDoYouBuyYourProduce %></label>
                        </div>
                        <div class="row mar_top_2_imp">
                            <label for="<%=txtStatesBuyProduce.ClientID %>" class="col-md-4"><%=Resources.Global.WhatStates %></label>
                            <div class="col-md-8">
                                <asp:TextBox ID="txtStatesBuyProduce" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                            </div>
                        </div>
                        <div class="row mar_top_2_imp">
                            <label for="<%=txtCountriesBuyProduce.ClientID %>" class="col-md-4"><%=Resources.Global.WhatCountries %></label>
                            <div class="col-md-8">
                                <asp:TextBox ID="txtCountriesBuyProduce" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row mar_top_2_imp">
                    <div class="col-md-4">
                        <div class="row">
                            <label for="<%=cblProduceSellTo.ClientID %>" class="col-md-12"><%=Resources.Global.IfProduceSellerToWhomDoYouSell %></label>
                        </div>
                        <div class="row mar_top_2_imp">
                            <div class="col-md-11 col-md-offset-1">
                                <asp:CheckBoxList ID="cblProduceSellTo" runat="server" RepeatDirection="Vertical" CssClass="norm_lbl" Font-Size="Medium">
                                    <asp:ListItem Text="<%$Resources:Global, BrokersDistributors %>" />
                                    <asp:ListItem Text="<%$Resources:Global, Locally %>" />
                                    <asp:ListItem Text="<%$Resources:Global, DomesticBuyers %>" />
                                    <asp:ListItem Text="<%$Resources:Global, InternationalExporters %>" />
                                </asp:CheckBoxList>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-8">
                        <div class="row">
                            <label class="col-md-12"><%=Resources.Global.WhereDoYouSellYourProduce %></label>
                        </div>
                        <div class="row mar_top_2_imp">
                            <label for="<%=txtStatesSellProduce.ClientID %>" class="col-md-4"><%=Resources.Global.WhatStates %></label>
                            <div class="col-md-8">
                                <asp:TextBox ID="txtStatesSellProduce" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                            </div>
                        </div>
                        <div class="row mar_top_2_imp">
                            <label for="<%=txtCountriesSellProduce.ClientID %>" class="col-md-4"><%=Resources.Global.WhatCountries %></label>
                            <div class="col-md-8">
                                <asp:TextBox ID="txtCountriesSellProduce" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row mar_top_2_imp">
                    <label for="<%=txtBrandNames.ClientID %>" class="col-md-3"><%=Resources.Global.BrandNames %></label>
                    <div class="col-md-9">
                        <asp:TextBox ID="txtBrandNames" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlTransportation2" runat="server" Visible="false">
                <div class="row">
                    <div class="col-xs-11 col-xs-offset-1">
                        <asp:CheckBoxList ID="cblTransportation" runat="server" RepeatDirection="Horizontal" RepeatColumns="2" CssClass="norm_lbl" Font-Size="Medium" DataTextField="prcl_Name" DataValueField="prcl_ClassificationID" />
                    </div>
                </div>

                <div class="row mar_top_7">
                    <label for="<%=txtGeographicAreasServed.ClientID %>" class="col-md-4"><%=Resources.Global.GeographicAreasServed %>&nbsp;<span class="required">*</span></label>
                    <div class="col-md-8">
                        <asp:TextBox ID="txtGeographicAreasServed" MaxLength="200" runat="server" CssClass="form-control" Width="100%" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" ControlToValidate="txtGeographicAreasServed" ValidationGroup="Required" Display="None" ErrorMessage="<%$Resources:Global, GeographicAreasServed %>" runat="server" />
                    </div>
                </div>
                <div class="row mar_top_2_imp">
                    <label for="<%=txtAnnualTrucklotVol_T.ClientID %>" class="col-md-4"><%=Resources.Global.AnnualTrucklotVolume %></label>
                    <div class="col-md-8">
                        <asp:TextBox ID="txtAnnualTrucklotVol_T" MaxLength="100" runat="server" CssClass="form-control" Width="100%" />
                    </div>
                </div>
                <div class="row mar_top_2_imp">
                    <div class="col-md-4">
                        <div class="row">
                            <label for="<%=cblTransportationArrangeWith.ClientID %>" class="col-md-12"><%=Resources.Global.ArrangeTransportationWith %></label>
                        </div>
                        <div class="row mar_top_2_imp">
                            <div class="col-md-11 col-md-offset-1">
                                <asp:CheckBoxList ID="cblTransportationArrangeWith" runat="server" RepeatDirection="Vertical" CssClass="norm_lbl" Font-Size="Medium">
                                    <asp:ListItem Text="<%$Resources:Global, Air %>" />
                                    <asp:ListItem Text="<%$Resources:Global, Ocean %>" />
                                    <asp:ListItem Text="<%$Resources:Global, Rail %>" />
                                    <asp:ListItem Text="<%$Resources:Global, Truck %>" />
                                </asp:CheckBoxList>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-8">
                        <div class="row mar_top_2_imp">
                            <label for="<%=txtNumTrucksOwned.ClientID %>" class="col-md-3 col-sm-3"><%=Resources.Global.NumTrucksOwned %>:</label>
                            <div class="col-md-2 col-sm-2">
                                <asp:TextBox ID="txtNumTrucksOwned" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                            </div>
                        </div>
                        <div class="row mar_top_2_imp">
                            <label for="<%=txtNumTrucksLeased.ClientID %>" class="col-md-3 col-sm-3"><%=Resources.Global.NumTrucksLeased %>:</label>
                            <div class="col-md-2 col-sm-2">
                                <asp:TextBox ID="txtNumTrucksLeased" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                            </div>
                        </div>
                        <div class="row mar_top_2_imp">
                            <label for="<%=txtNumTrailersOwned.ClientID %>" class="col-md-3 col-sm-3"><%=Resources.Global.NumTrailersOwned %>:</label>
                            <div class="col-md-2 col-sm-2">
                                <asp:TextBox ID="txtNumTrailersOwned" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                            </div>
                        </div>
                        <div class="row mar_top_2_imp">
                            <label for="<%=txtNumTrailersLeased.ClientID %>" class="col-md-3 col-sm-3"><%=Resources.Global.NumTrailersLeased %>:</label>
                            <div class="col-md-2 col-sm-2">
                                <asp:TextBox ID="txtNumTrailersLeased" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row mar_top_10">
                    <h3><%=Resources.Global.NumUnitsEnterHowManyOfEach %></h3>
                </div>

                <div class="row mar_top_2_imp">
                    <div class="row mar_top_2_imp">
                        <label for="<%=txtReeferTrailers.ClientID %>" class="col-md-3 col-sm-3"><%=Resources.Global.ReeferTrailers %></label>
                        <div class="col-md-2 col-sm-2">
                            <asp:TextBox ID="txtReeferTrailers" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                        </div>
                    </div>
                    <div class="row mar_top_2_imp">
                        <label for="<%=txtDryVanTrailers.ClientID %>" class="col-md-3 col-sm-3"><%=Resources.Global.DryVanTrailers %></label>
                        <div class="col-md-2 col-sm-2">
                            <asp:TextBox ID="txtDryVanTrailers" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                        </div>
                    </div>
                    <div class="row mar_top_2_imp">
                        <label for="<%=txtPiggybackTrailers.ClientID %>" class="col-md-3 col-sm-3"><%=Resources.Global.PiggybackTrailers %></label>
                        <div class="col-md-2 col-sm-2">
                            <asp:TextBox ID="txtPiggybackTrailers" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                        </div>
                    </div>
                    <div class="row mar_top_2_imp">
                        <label for="<%=txtFlatbedTrailers.ClientID %>" class="col-md-3 col-sm-3"><%=Resources.Global.FlatbedTrailers %></label>
                        <div class="col-md-2 col-sm-2">
                            <asp:TextBox ID="txtFlatbedTrailers" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                        </div>
                    </div>
                    <div class="row mar_top_2_imp">
                        <label for="<%=txtTankers.ClientID %>" class="col-md-3 col-sm-3"><%=Resources.Global.Tankers %></label>
                        <div class="col-md-2 col-sm-2">
                            <asp:TextBox ID="txtTankers" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                        </div>
                    </div>
                    <div class="row mar_top_2_imp">
                        <label for="<%=txtContainers.ClientID %>" class="col-md-3 col-sm-3"><%=Resources.Global.Containers %></label>
                        <div class="col-md-2 col-sm-2">
                            <asp:TextBox ID="txtContainers" MaxLength="100" runat="server" CssClass="form-control numbersOnly" Width="100%" />
                        </div>
                    </div>
                </div>

                <div class="row mar_top_10">
                    <h3><%=Resources.Global.TypeOfFreightTotalEquals100 %></h3>
                </div>

                <div class="row mar_top_2_imp">
                    <div class="col-md-6 col-sm-12 col-xs-12">
                        <div class="row mar_top_2_imp">
                            <div class="col-md-8 col-sm-3 col-xs-5">
                                <asp:CheckBox ID="cbProduce" runat="server" CssClass="norm_lbl" />
                                <label for="<%=cbProduce.ClientID %>"><%=Resources.Global.Produce %></label>
                            </div>
                            <div class="col-md-2 col-sm-2 col-xs-2">
                                <asp:TextBox ID="txtProduce" MaxLength="100" runat="server" CssClass="form-control numbersOnly inlineblock" Width="100%" />&nbsp;%
                            </div>
                        </div>
                        <div class="row mar_top_2_imp">
                            <div class="col-md-8 col-sm-3 col-xs-5">
                                <asp:CheckBox ID="cbNonProduceCold" runat="server" CssClass="norm_lbl" />
                                <label for="<%=cbNonProduceCold.ClientID %>"><%=Resources.Global.NonProduceRefigeratedFrozen %></label>
                            </div>
                            <div class="col-md-2 col-sm-2 col-xs-2">
                                <asp:TextBox ID="txtNonProduceCold" MaxLength="100" runat="server" CssClass="form-control numbersOnly inlineblock" Width="100%" />&nbsp;%
                            </div>
                        </div>
                        <div class="row mar_top_2_imp">
                            <div class="col-md-8 col-sm-3 col-xs-5">
                                <asp:CheckBox ID="cbNonProduceNonCold" runat="server" CssClass="norm_lbl" />
                                <label for="<%=cbNonProduceNonCold.ClientID %>"><%=Resources.Global.NonProduceNonRefrigerated %></label>
                            </div>
                            <div class="col-md-2 col-sm-2 col-xs-2">
                                <asp:TextBox ID="txtNonProduceNonCold" MaxLength="100" runat="server" CssClass="form-control numbersOnly inlineblock" Width="100%" />&nbsp;%
                            </div>
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlSupply1" runat="server" Visible="false">
                <div class="row">
                    <div class="col-xs-11 col-xs-offset-1">
                        <asp:CheckBoxList ID="cblSupply" runat="server" RepeatDirection="Horizontal" RepeatColumns="3" CssClass="norm_lbl" Font-Size="Medium" DataTextField="prcl_Name" DataValueField="prcl_ClassificationID" />
                    </div>
                </div>
            </asp:Panel>
        </div>

        <asp:Panel ID="pnlListingFacts" runat="server" Visible="true">
            <div class="row mar_top_10">
                <h3><%=Resources.Global.EnhanceListingWithDescriptiveFacts %></h3>
            </div>
            <div class="form-group form-inline">
                <div class="row mar_top_2_imp nopadding_l">
                    <div class="col-md-12">
                        <%=Resources.Global.DescriptiveListingLines_Sentence %>
                    </div>
                </div>
                <div class="row mar_top_2_imp nopadding_l">
                    <div class="col-md-12">
                        <asp:TextBox ID="txtListingFacts" MaxLength="500" runat="server" CssClass="form-control" Width="100%" TextMode="MultiLine" Rows="3" />
                    </div>
                </div>
            </div>
        </asp:Panel>

        <asp:CustomValidator ID="cvNatureofBusiness" runat="server" ErrorMessage="<%$Resources:Global, NatureOfBusinessRequired %>" ClientValidationFunction="validateNatureofBusiness" ValidationGroup="Required" Display="None" />

        <div class="row text-center mar_bottom_20">
            <asp:LinkButton ID="btnSubmit" Text="<%$Resources:Global, Submit %>" class="button" OnClientClick="return validate();" OnClick="btnSubmit_Click" Style="font-size: 10pt; width: 110px" ValidationGroup="Required" runat="server" />
        </div>
    </div>

    <asp:Label ID="hidRequestType" Visible="false" runat="server" />

    <script type="text/javascript">
        jQuery('.numbersOnly').keyup(function () {
            replaceNonDigits(this);
        });

        $('#BBOSPublicProfilesMain_ddlTypeofEntity').change(function () {
            var selected = $(this).val();
            if (selected == '8') {
                $('#divOther').show();
                $('#divOtherBlank').hide();
                ValidatorEnable($get('<%=rfvOther.ClientID %>'), true);
            }
            else {
                $('#divOther').hide();
                $('#divOtherBlank').show();
                ValidatorEnable($get('<%=rfvOther.ClientID %>'), false);
            }
        });

        function calculateFreightSum() {
            var sum = 0;
            var checked = 0;

            //iterate through each textboxe and add the values
            var chk = $("#<%=cbProduce.ClientID%>");
            var txt = $("#<%=txtProduce.ClientID%>");
            if (chk.is(':checked')) {
                checked++;
                if (!isNaN(txt.val()) && txt.val().length != 0) {
                    sum += parseFloat(txt.val());
                }
            }

            chk = $("#<%=cbNonProduceCold.ClientID%>");
            txt = $("#<%=txtNonProduceCold.ClientID%>");
            if (chk.is(':checked')) {
                checked++;
                if (!isNaN(txt.val()) && txt.val().length != 0) {
                    sum += parseFloat(txt.val());
                }
            }

            chk = $("#<%=cbNonProduceNonCold.ClientID%>");
            txt = $("#<%=txtNonProduceNonCold.ClientID%>");
            if (chk.is(':checked')) {
                checked++;
                if (!isNaN(txt.val()) && txt.val().length != 0) {
                    sum += parseFloat(txt.val());
                }
            }

            if (checked)
                return sum.toFixed(2); //roundoff the final sum to 2 decimal places
            else
                return -1;
        }

        function validate() {
            var freightSum = calculateFreightSum();
            if (freightSum != -1 && calculateFreightSum() != 100) {
                $("#validationErrors2").show();
                $("#divErrFreightTotal").show();

                location.href = "#";
                sendHeight();
                return false;
            }

            $("#validationErrors2").hide();
            sendHeight();
            return true;
        }

        <%-- 
                Defect 6860
         Fix issue where Submit button disappears if there are field validation errors that appear and push it down outside the iFrame region
         Requires php to have this script to respond to event message:

						window.addEventListener('message', function(event) {
						  if(height = event.data['height']) {
							$('iframe').css('height', height + 'px')
						  }
						})--%>

        sendHeight = function () {
            height = $('#BORContent').height()
            height = height + $('#BBOSPublicProfilesMain_ctl00').height() + 400;
            window.parent.postMessage({ "height": height }, "*")
        }

        $(window).on('resize', function () {
            sendHeight();
        });

        function validateCountry(s, args) {
            var value = $("#<%= ddlCountry.ClientID %> option:selected").val();
            if (value == "0" || value == "")
                args.IsValid = false;
            else
                args.IsValid = true;
        }

        function validateState(s, args) {
            var value = $("#<%= ddlState.ClientID %> option:selected").val();
            if (value == "0" || value == "")
                args.IsValid = false;
            else
                args.IsValid = true;
        }

        function validateNatureofBusiness(s, args) {
            var chkListModules = document.getElementById('<%= cblProduceBuyer.ClientID %>');
            if (chkListModules != null) {
                var chkListinputs = chkListModules.getElementsByTagName("input");
                for (var i = 0; i < chkListinputs.length; i++) {
                    if (chkListinputs[i].checked) {
                        args.IsValid = true;
                        return;
                    }
                }
            }

            chkListModules = document.getElementById('<%= cblProduceSeller.ClientID %>');
            if (chkListModules != null) {
                var chkListinputs = chkListModules.getElementsByTagName("input");
                for (var i = 0; i < chkListinputs.length; i++) {
                    if (chkListinputs[i].checked) {
                        args.IsValid = true;
                        return;
                    }
                }
            }

            chkListModules = document.getElementById('<%= cblProduceBroker.ClientID %>');
            if (chkListModules != null) {
                var chkListinputs = chkListModules.getElementsByTagName("input");
                for (var i = 0; i < chkListinputs.length; i++) {
                    if (chkListinputs[i].checked) {
                        args.IsValid = true;
                        return;
                    }
                }
            }

            chkListModules = document.getElementById('<%= cblTransportation.ClientID %>');
            if (chkListModules != null) {
                var chkListinputs = chkListModules.getElementsByTagName("input");
                for (var i = 0; i < chkListinputs.length; i++) {
                    if (chkListinputs[i].checked) {
                        args.IsValid = true;
                        return;
                    }
                }
            }

            chkListModules = document.getElementById('<%= cblSupply.ClientID %>');
            if (chkListModules != null) {
                var chkListinputs = chkListModules.getElementsByTagName("input");
                for (var i = 0; i < chkListinputs.length; i++) {
                    if (chkListinputs[i].checked) {
                        args.IsValid = true;
                        return;
                    }
                }
            }

            args.IsValid = false;
        }



        $(document).ready(function () {
        });

    </script>
</asp:Content>
