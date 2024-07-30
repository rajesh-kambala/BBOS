<%@ Page Title="" Language="C#" MasterPageFile="~/Produce.Master" AutoEventWireup="true" CodeBehind="PaymentReceipt.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PublicProfiles.PaymentReceipt" %>

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

        .button{
            background-color: #034889;
            color:white;
        }
        .button:hover {
            background-color: #939598;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="BBOSPublicProfilesMain" runat="server">
    <div class="row" style="margin-bottom:10px">
        <div class="col-sm-12" style="width:40%">
            <asp:Button Text="<%$Resources:Global, PrintReceipt %>" OnClientClick="window.print()" CssClass="form-control button" runat="server" />
        </div>
    </div>
    <div class="row">
        <div class="col-sm-12">
            <b>
                <asp:Label ID="lblMsg1" runat="server" Text="<%$Resources:Global,PleasePrintPageForRecords %>" />
            </b>
        </div>
    </div>

    <asp:Panel ID="pnlMembership" runat="server" Visible="false">
        <div class="row" id="divAGTools" runat="server">
            <div class="col-sm-12">
                <p>
                    <i><asp:HyperLink ID="hlAGTools" runat="server" Text="<%$Resources:Global,ClickHere %>" />&nbsp;<%=Resources.Global.LearnMoreAboutAGTools %></i>
                </p>
            </div>
        </div>
        <div class="row">
            <div class="col-sm-12">
                <p><%=Resources.Global.ThankYouForYourMembershipPurchase %></p>

                <p style="font-weight: bold; font-style: italic; background-color: yellow;">
                    <%=Resources.Global.ThankYouForYourMembershipPurchase_Info %>
                </p>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlBR" runat="server" Visible="false">
        <div class="row">
            <div class="col-sm-12">
                <%=Resources.Global.ThankYouForYourBusinessReportPurchase_Info %>
            </div>
        </div>
    </asp:Panel>

    <div class="row">
        <div class="col-sm-12">
            <p>-&nbsp;<%=Resources.Global.YourBlueBookTeam %></p>
        </div>
    </div>

    <asp:Label ID="hidRequestType" Visible="false" runat="server" />

    <p style="margin-top:25px;"><div class="registertitle" style="width:150px;margin-right:0;"><%=Resources.Global.BBOSOrderNumber %>:</div>
        <div class="registerinput"><asp:Label id="lblPaymentID" runat="server" /></div></p>

    <p><div class="registertitle" style="width:150px;margin-right:0;vertical-align:top;"><%=Resources.Global.Product %>:</div>
        <div class="registerinput"><asp:Label id="lblProduct" runat="server" /></div></p>

    <p><div class="registertitle" style="width:150px;margin-right:0;"><%=Resources.Global.SubTotal %>:</div>
        <div class="registerinput"><div class="NumericLabelData"><asp:Label ID="lblSubTotal" runat="server" /></div></div></p>

    <p><div class="registertitle" style="width:150px;margin-right:0;"><%=Resources.Global.SalesTax %>:</div>
        <div class="registerinput"><div class="NumericLabelData"><asp:Label ID="lblSalesTax" runat="server" /></div></div></p>

    <p><div class="registertitle" style="width:150px;margin-right:0;"><%=Resources.Global.Shipping %>:</div>
        <div class="registerinput"><div class="NumericLabelData"><asp:Label ID="lblShipping" runat="server" /></div></div></p>

    <p><div class="registertitle" style="width:150px;margin-right:0;"><%=Resources.Global.TotalAmount %>:</div>
        <div class="registerinput"><div class="NumericLabelDataTopBorder"><asp:Label ID="lblTotal" runat="server" /></div></div></p>


    <p style="margin-top:25px;"><div class="registertitle" style="width:150px;margin-right:0;"><%=Resources.Global.Name %>:</div>
        <div class="registerinput"><asp:Label id="lblCustomerName" runat="server" /></div></p>

    <p><div class="registertitle" style="width:150px;margin-right:0;"><%=Resources.Global.AuthorizationNumber %>:</div>
        <div class="registerinput"><asp:Label id="lblAuthorization" runat="server" /></div></p>

    <p><div class="registertitle" style="width:150px;margin-right:0;"><%=Resources.Global.CreditCardType %>:</div>
        <div class="registerinput"><asp:Label id="lblCreditCardType" runat="server" /></div></p>

    <p><div class="registertitle" style="width:150px;margin-right:0;"><%=Resources.Global.CreditCardNumber %>:</div>
        <div class="registerinput">####-####-####-<asp:Label ID="lblCreditCardNumber" runat="server" /></div></p>

    <p><div class="registertitle" style="width:150px;margin-right:0;vertical-align:top;""><%=Resources.Global.BillingAddress %>:</div>
        <div class="registerinput"><asp:Label id="lblBillingAddress" runat="server" /></div></p>
</asp:Content>
