<%@ Page Title="" Language="C#" MasterPageFile="~/Produce.Master" EnableEventValidation="false" AutoEventWireup="true" CodeBehind="Visitor.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PublicProfiles.Visitor" %>
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

        .validationError {
            color: Red;
            text-align: left;
        }

            .validationError ul {
                list-style-type: disc;
                margin-left: 15px;
            }

                .validationError ul li {
                    color: Red;
                    margin-bottom: 0px;
                    padding: 0px;
                }

        .required {
            color: Red;
        }

        .bulletList {
            list-style-type: disc;
            margin-left: 25px;
            margin-top: 0px;
        }

        .bulletListItem {
            margin-top: 5px;
        }

        .cbLabel input {
            vertical-align: middle;
            margin-right: 5px;
        }
    </style>

    <script type="text/javascript">
        if (!inIframe()) {
            var expiredate = new Date();
            expiredate.setDate(expiredate.getDate() + 1);
            document.cookie = "CompanyID=" + vars['CompanyID'] + ";path=/;expires=" + expiredate.toUTCString();

            if (document.location.hostname != "localhost") {
                window.location.href = "<% =GetMarketingSiteURL() %>/find-companies/company-profile/?ID=" + vars['CompanyID'];
            }
        }

        function toggleMoreInfo(cbMoreInfo) {
            if (cbMoreInfo.checked) {
                document.getElementById("pnlMoreInfo").style.display = "";
            } else {
                document.getElementById("pnlMoreInfo").style.display = "none";
            }
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="BBOSPublicProfilesMain" runat="server">
    <div class="row">
        <h2>Visitor Information</h2>
        <hr />
    </div>
    
    <div class="row">
        <asp:Label ID="tmpValidationMsg" runat="server" CssClass="validationError" Visible="false">One or more required fields are missing</asp:Label>
        <asp:ValidationSummary ID="ValidationSummary1" CssClass="validationError" ValidationGroup="Required" HeaderText="One or more required fields are missing" DisplayMode="BulletList" runat="server" />
        <asp:ValidationSummary ID="ValidationSummary2" CssClass="validationError" ValidationGroup="InvalidEmail" HeaderText="The specified email address is invalid." DisplayMode="BulletList" runat="server" />
    </div>
    
    <div class="row">
        <p>To continue to access free basic company profiles, please provide the following information.</p>
        <p style="color: red;">Fields marked with * are required.</p>
    </div>



    <div class="row">
        <div class="col-xs-4">Your Email Address <span class="required">*</span></div>
        <div class="col-xs-8">
            <asp:TextBox ID="txtSubmitterEmail" MaxLength="255" runat="server" CssClass="form-control" />
            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" ValidationGroup="Required" ControlToValidate="txtSubmitterEmail" Display="None" runat="server" />
            <asp:RegularExpressionValidator ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" Display="None" ValidationGroup="InvalidEmail" ControlToValidate="txtSubmitterEmail" ID="RegularExpressionValidator1" runat="server" />
        </div>
    </div>

    <div class="row mar_top_7">
        <div class="col-xs-4">Company Name <span class="required">*</span></div>
        <div class="col-xs-8">
            <asp:TextBox ID="txtCompanyName" MaxLength="200" runat="server" CssClass="form-control" />
            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" ValidationGroup="Required" ControlToValidate="txtCompanyName" Display="None" runat="server" />
        </div>
    </div>

    <div class="row mar_top_7">
        <div class="col-xs-4">Please provide your company's primary function</div>
        <div class="col-xs-8">
            <asp:DropDownList ID="ddlPrimaryFunction" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row mar_top_7">
        <div class="col-xs-12">
            <asp:CheckBox ID="cbMoreInfo" Text="&nbsp;&nbsp;I would like more information about Blue Book Services Membership." 
                onclick="toggleMoreInfo(this);" runat="server" />
        </div>
    </div>


    <div id="pnlMoreInfo" style="display: none;">
        <div class="row">
            <div class="col-xs-4">Your Name <span class="required">*</span></div>
            <div class="col-xs-8">
                <asp:TextBox ID="txtSubmitterName" MaxLength="255" runat="server" CssClass="form-control" />
            </div>
        </div>

        <div class="row mar_top_7">
            <div class="col-xs-4">Your Phone Number <span class="required">*</span></div>
            <div class="col-xs-8">
                <asp:TextBox ID="txtSubmitterPhone" MaxLength="25" runat="server" CssClass="form-control" />
            </div>
        </div>

        <div class="row mar_top_7">
            <div class="col-xs-4">State/Province<span class="required">*</span></div>
            <div class="col-xs-8">
                <asp:DropDownList ID="ddlState" runat="server" CssClass="form-control" />
                <cc1:CascadingDropDown ID="cddCountry" TargetControlID="ddlCountry" ServiceMethod="GetCountries" Category="Country" runat="server" />
                <cc1:CascadingDropDown ID="cddState" TargetControlID="ddlState" ServiceMethod="GetStates" Category="State" ParentControlID="ddlCountry" runat="server" />
            </div>
        </div>

        <div class="row mar_top_7">
            <div class="col-xs-4">Country <span class="required">*</span></div>
            <div class="col-xs-8">
                <asp:DropDownList ID="ddlCountry" runat="server" CssClass="form-control" />
            </div>
        </div>
    </div>

    <hr />

    <div class="row">
        <div class="col-xs-8 col-xs-offset-2">
            <asp:LinkButton ID="LinkButton1" Text="Submit" class="button" OnClick="btnSubmitOnClick" CausesValidation="false" runat="server" />
        </div>
    </div>

    <script type="text/javascript">
        toggleMoreInfo(document.getElementById("<% =cbMoreInfo.ClientID %>"));
    </script>
</asp:Content>
