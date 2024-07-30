<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="PasswordChange.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PasswordChange" EnableEventValidation="false" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="bbos" TagName="EMCW_CompanyHeader" Src="~/UserControls/EMCW_CompanyHeader.ascx" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <style type="text/css">
        .main-content-old {
            width: 100%;
        }
        .pageTitle {
            text-align: center;
        }
        .panels_box .panel {
            padding: 0;
            border: 0;
        }

        .panels_box .panel-heading {
            padding: 0;
            border: 0;
        }

        .panels_box .panel-body {
            padding: 0;
            border: 1px solid #dfdddd;
        }

        .pad10 {
            padding: 10px !important;
        }

        .panels_box .pad10 {
            padding: 10px !important;
        }

        .gray_btn {
            background-color: #68AE00 !important;
            color: #fff !important;
            margin-top: 5px;
        }

            .gray_btn:hover {
                background-color: #3e6800 !important;
                color: #fff !important;
                text-decoration: none !important;
            }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Panel ID="pnlPasswordInfo" Style="width: 100%" CssClass="box_left" runat="server" Visible="false">
        <div class="row panels_box">
            <div class="col-lg-6 offset-lg-3 col-md-8 offset-md-2 col-sm-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab">
                            <%= Resources.Global.PasswordChange %>
                        </h4>
                    </div>
                    <div class="panel-body nomargin pad10">
                        <div class="row">
                            <div class="col-lg-4 col-md-4 col-sm-4">
                                <div class="clr_blu"><% =Resources.Global.NewPassword %>:</div>
                            </div>
                            <div class="col-lg-4 col-md-4 col-sm-4">
                                <asp:TextBox ID="txtPassword" TextMode="Password" MaxLength="20" tsiDisplayName="<%$ Resources:Global, Password2 %>" runat="server" CssClass="form-control" />
                                <asp:Literal ID="litPasswordReq" runat="server" />
                            </div>
                            <div class="col-lg-4 col-md-4 col-sm-4">
                                <cc1:PasswordStrength ID="psPassword" runat="server"
                                    TargetControlID="txtPassword"
                                    DisplayPosition="RightSide"
                                    StrengthIndicatorType="Text"
                                    PreferredPasswordLength="10"
                                    PrefixText="Strength:"
                                    TextStrengthDescriptions="Weak;Average;Strong;Excellent"
                                    TextStrengthDescriptionStyles="PasswordStrengthWeak;PasswordStrengthAverage;PasswordStrengthStrong;PasswordStrengthExcellent"
                                    RequiresUpperAndLowerCaseCharacters="false" />
                            </div>
                        </div>

                        <div class="row mar_top_5">
                            <div class="col-lg-4 col-md-4 col-sm-4">
                                <div class="clr_blu"><% =Resources.Global.ConfirmPassword %>:</div>
                            </div>
                            <div class="col-lg-4 col-md-4 col-sm-4">
                                <asp:TextBox ID="txtConfirmPassword" TextMode="Password" MaxLength="20" tsiDisplayName="<%$ Resources:Global, ConfirmPassword %>" runat="server" CssClass="form-control" />
                                <asp:Literal ID="litConfirmPasswordReq" runat="server" />
                            </div>
                        </div>


                        <div class="row mar_top">
                            <div class="col-md-12">
                                <asp:LinkButton ID="btnSave" runat="server" CssClass="btn gray_btn" OnClick="btnSave_Click">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnSave %>" />
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancelOnClick">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnCancel %>" />
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlKeyError" runat="server" Visible="false">
        <asp:Label ID="lblKeyError" runat="server" Text="Invalid request." />
    </asp:Panel>
</asp:Content>
