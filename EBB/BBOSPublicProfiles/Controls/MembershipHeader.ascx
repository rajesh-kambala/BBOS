<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="MembershipHeader.ascx.cs" Inherits="PRCo.BBOS.UI.Web.PublicProfiles.Controls.MembershipHeader" %>

<style type="text/css">
    .step {
        /*width: 200px;*/
        padding: 4pt;
        padding-left: 12pt;
        border-collapse: separate;
    }

    .progressbar {
        /*width: 900px;*/
        width: 80%;
        margin-left: auto;
        margin-right: auto;
        margin-bottom: 15px;
        border-collapse: separate;
        border: solid #0055a5 1px;
        border-radius: 12px;
        -moz-border-radius: 12px;
        background-clip: padding-box;
    }

    td.step + td.step {
        border-left: solid #fff 1px;
    }

    .stepBG {
        color: #fff;
        background-color: #0055a5;
        background-clip: padding-box;
    }

        .stepBG:first-child {
            border-top-left-radius: 12px;
            border-bottom-left-radius: 12px;
            background-color: #0055a5;
            background-clip: padding-box;
            border-collapse: separate;
        }

        .stepBG:last-child {
            background-color: #0055a5;
            background-clip: padding-box;
            border-collapse: separate;
            border-top-right-radius: 12px;
            border-bottom-right-radius: 12px;
        }

    .text-right{
        text-align: right;
    }

    .nopadding_tb { padding-top: 0 !important; padding-bottom: 0 !important; }
</style>


<table class="progressbar" cellpadding="0" cellspacing="0" id="tblProduce" runat="server">
    <tr>
        <td id="tdStep1" runat="server" class="step" style="width:20%"><%=Resources.Global.Step1SelectMembership %></td>
        <td id="tdStep2" runat="server" class="step" style="width:20%"><%=Resources.Global.Step2SelectOptions %></td>
        <td id="tdStep3" runat="server" class="step" style="width:20%"><%=Resources.Global.Step3UserSetup %></td>
        <td id="tdStep4" runat="server" class="step" style="width:20%"><%=Resources.Global.Step4Payment %></td>
        <td id="tdStep5" runat="server" class="step" style="width:20%"><%=Resources.Global.Step5BlueBookListing %></td>
    </tr>
</table>

<table class="progressbar" cellpadding="0" cellspacing="0" id="tblLumber" runat="server">
    <tr>
        <td id="tdLumberStep1" runat="server" class="step" style="width:33%"><%=Resources.Global.Step1SelectMembership %></td>
        <td id="tdLumberStep2" runat="server" class="step" style="width:33%"><%=Resources.Global.Step2UserSetup %></td>
        <td id="tdLumberStep3" runat="server" class="step" style="width:33%"><%=Resources.Global.Step3Payment %></td>
    </tr>
</table>

<asp:Panel ID="pnlMembership" runat="server" Visible="false">
    <div class="row">
        <div class="col-xs-10 col-xs-offset-1">
            <div class="row">
                <div class="col-xs-4 label text-right"><%=Resources.Global.Membership %>:</div>
                <div class="col-xs-8">
                    <asp:Label ID="lblMembershipLevel" runat="server" />
                </div>
            </div>
            <div class="row">
                <div class="col-xs-4 label text-right"><%=Resources.Global.MembershipFee %>:</div>
                <div class="col-xs-8">
                    <asp:Label ID="lblMembershipFee" runat="server" />
                </div>
            </div>
            <div class="row">
                <div class="col-xs-4 label text-right"><%=Resources.Global.MembershipLicenses %>:</div>
                <div class="col-xs-8">
                    <asp:Label ID="lblNumberofUsers" runat="server" />
                </div>
            </div>
            <div class="row">
                <div class="col-xs-4 label text-right"><%=Resources.Global.BusinessReports %>:</div>
                <div class="col-xs-8">
                    <asp:Label ID="lblBusinessReports" runat="server" />
                </div>
            </div>
            <div class="row" id="trExpressUpdate" runat="server" visible="false">
                <div class="col-xs-4 label text-right"><%=Resources.Global.ExpressUpdateReports %>:</div>
                <div class="col-xs-8">
                    <asp:Label ID="lblExpressUpdate" runat="server" />
                </div>
            </div>
            <div class="row" id="trBlueBook" runat="server" visible="false">
                <div class="col-xs-4 label text-right"><%=Resources.Global.AdditionalBlueBook %>:</div>
                <div class="col-xs-8">
                    <asp:Label ID="lblBlueBook" runat="server" />
                </div>
            </div>
            <div class="row" id="trBlueprints" runat="server" visible="false">
                <div class="col-xs-4 label text-right"><%=Resources.Global.AdditionalBlueprintsSubscription %>:</div>
                <div class="col-xs-8">
                    <asp:Label ID="lblBlueprints" runat="server" />
                </div>
            </div>
            <div class="row" id="trLSS" runat="server" visible="false">
                <div class="col-xs-4 label text-right"><%=Resources.Global.LocalSourceLicenses %>:</div>
                <div class="col-xs-8">
                    <asp:Label ID="lbLSS" runat="server" />
                </div>
            </div>
        </div>
    </div>
</asp:Panel>
