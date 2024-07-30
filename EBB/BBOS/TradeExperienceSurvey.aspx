<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="TradeExperienceSurvey.aspx.cs" Inherits="PRCo.BBOS.UI.Web.TradeExperienceSurvey" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="bbos" TagName="BBScoreChart" Src="~/UserControls/BBScoreChart.ascx" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Import Namespace="TSI.Utils" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function clear(radioButtonList) {
            radioButtons = document.getElementsByName(radioButtonList);
            for (var i = 0; i < radioButtons.length; i++) {
                radioButtons[i].checked = false;
            }
        }

        function toggleTB() {
            if ($("#<%=chkMailTESToSomeoneElse.ClientID%>").is(':checked')) {
                $("#<%=txtTESOtherName.ClientID%>").removeAttr("disabled");
                $("#<%=txtTESOtherTitle.ClientID%>").removeAttr("disabled");
                $("#<%=txtTESOtherEmail.ClientID%>").removeAttr("disabled");
                $("#<%=txtTESOtherPhone.ClientID%>").removeAttr("disabled");
                $("#<%=txtTESOtherFax.ClientID%>").removeAttr("disabled");
            }
            else {
                $("#<%=txtTESOtherName.ClientID%>").attr("disabled", "disabled");
                $("#<%=txtTESOtherName.ClientID%>").val("");

                $("#<%=txtTESOtherTitle.ClientID%>").attr("disabled", "disabled");
                $("#<%=txtTESOtherTitle.ClientID%>").val("");

                $("#<%=txtTESOtherEmail.ClientID%>").attr("disabled", "disabled");
                $("#<%=txtTESOtherEmail.ClientID%>").val("");

                $("#<%=txtTESOtherPhone.ClientID%>").attr("disabled", "disabled");
                $("#<%=txtTESOtherPhone.ClientID%>").val("");

                $("#<%=txtTESOtherFax.ClientID%>").attr("disabled", "disabled");
                $("#<%=txtTESOtherFax.ClientID%>").val("");
            }
        }
    </script>

    <style>
        table.tight td {
            margin: 0;
            padding: 0;
        }
        table.tight {
            border-collapse: collapse;
            border-spacing: 0;
            border:none;
        }
        .tight input {
            margin-left:5px;
            margin-right:3px;
        }
        .tight label {
            margin:0 0 0 0;
        }
        .content-container div.row a.gray_btn {
            display: inline;
            width: auto;
            margin-right: 10px;
            margin-bottom: 20px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row">
        <asp:Label ID="lblKeyMessage" Visible="false" runat="server" />
    </div>

    <asp:Panel ID="pnlKeyScreenBlock" runat="server" Visible="false" Style="margin-bottom: 30px;">
        <div class="row">
            <div class="col-md-6">
                <div class="row">
                    <div class="col-md-12">
                        <%=Resources.Global.ThisTESRequestEmailedTo %>
                    </div>
                </div>
                <div class="row mar_top_10">
                    <div class="col-md-3 bbos_blue_title">
                        <% =Resources.Global.Name_Cap %>:
                    </div>
                    <div class="col-md-9">
                        <asp:Label ID="lblTesSentToName" runat="server" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-3 bbos_blue_title">
                        <% =Resources.Global.Title %>:
                    </div>
                    <div class="col-md-9">
                        <asp:Label ID="lblTesSentToTitle" runat="server" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-3 bbos_blue_title">
                        <% =Resources.Global.Company %>:
                    </div>
                    <div class="col-md-9">
                        <asp:Label ID="lblTesSentToCompany" runat="server" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-3 bbos_blue_title">
                        <% =Resources.Global.Email_Cap %>:
                    </div>
                    <div class="col-md-9">
                        <asp:Label ID="lblTesSentToEmail" runat="server" />
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="row">
                    <div class="col-md-12">
                        <asp:CheckBox ID="chkMailTESToSomeoneElse" runat="server" OnClick="toggleTB();"/>
                        &nbsp;
                    <asp:Label ID="lblSendToSomeoneElse" runat="server" Text="<%$ Resources:Global,PleaseSendTESToSomeoneElseInOrg %>" />
                    </div>
                </div>
                <div class="row mar_top_10">
                    <div class="col-md-3">
                        <asp:Label ID="lblTESOtherName" Text="Name:" runat="server" class="bbos_blue_title" />
                    </div>
                    <div class="col-md-9">
                        <asp:TextBox ID="txtTESOtherName" runat="server" CssClass="form-control" Enabled="false" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-3">
                        <asp:Label ID="lblTESOtherTitle" Text="Title:" runat="server" class="bbos_blue_title" />
                    </div>
                    <div class="col-md-9">
                        <asp:TextBox ID="txtTESOtherTitle" runat="server" CssClass="form-control" Enabled="false" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-3">
                        <asp:Label ID="lblTESOtherEmail" Text="Email:" runat="server" class="bbos_blue_title" />
                    </div>
                    <div class="col-md-9">
                        <asp:TextBox ID="txtTESOtherEmail" runat="server" CssClass="form-control" Enabled="false" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-3">
                        <asp:Label ID="lblTESOtherPhone" Text="Phone:" runat="server" class="bbos_blue_title" />
                    </div>
                    <div class="col-md-9">
                        <asp:TextBox ID="txtTESOtherPhone" runat="server" CssClass="form-control" Enabled="false" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-3">
                        <asp:Label ID="lblTESOtherFax" Text="Fax:" runat="server" class="bbos_blue_title" />
                    </div>
                    <div class="col-md-9">
                        <asp:TextBox ID="txtTESOtherFax" runat="server" CssClass="form-control" Enabled="false" />
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlRequests" runat="server" Visible="false" Style="margin-bottom: 30px;">
        <div class="row mar_bot20">
            <div class="col-md-12 bold form-inline text-center">
                <%=Resources.Global.View %>&nbsp;
                <asp:DropDownList ID="ddlViewRecords" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlViewRecords_SelectedIndexChanged" CssClass="form-control" />:&nbsp;
                <asp:Label ID="lblRecordsDisplayed" CssClass="bbos_blue" runat="server" />&nbsp;of&nbsp;
                <asp:Label ID="lblTotalRemainingRecords" CssClass="bbos_blue" runat="server" />&nbsp;
                <span style="font-weight: bold;"><%=Resources.Global.PendingTradeExperienceSurveyRequests %></span>
            </div>
        </div>

        <div class="table-responsive">
            <asp:GridView ID="gvTESRequests"
                AllowSorting="false"
                Width="100%"
                CellSpacing="3"
                runat="server"
                AutoGenerateColumns="false"
                CssClass="sch_result table table-striped table-hover"
                GridLines="none"
                DataKeyNames="Index,Id,SerialNumber,BBNumber"
                OnRowDataBound="gvTESRequests_RowDataBound" >

                <Columns>
                    <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="vertical-align-top" DataField="BBNumber" />

                    <asp:TemplateField HeaderText="<%$ Resources:Global, RelatedCompanyName %>" HeaderStyle-CssClass="vertical-align-top" ItemStyle-CssClass="vertical-align-top">
                        <ItemTemplate>
                            <%# Eval("CompanyName")%><%# GetSecondRequestMsg(Eval("SecondRequest")) %>
                            <br />
                            <%# Eval("CompanyLocation") %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" HeaderText="<%$ Resources:Global, Rating %>">
                        <ItemTemplate>
                            <asp:Label ID="lblRating" runat="server" Visible="true" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderStyle-CssClass="text-nowrap vertical-align-top"
                        ItemStyle-CssClass="vertical-align-top">
                        <HeaderTemplate>
                            <%= Resources.Global.BlueBookScore %>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <p class="nopadding">
                                <asp:Literal ID="litBBScore" runat="server" />
                                <asp:LinkButton ID="lbBBScore" runat="server" CssClass="PopupLink2" OnClick="lbBBScore_Click" />

                                <asp:Panel ID="pnlWhatIsBBScore" Style="display: none" CssClass="Popup" Width="400px" runat="server">
                                    <asp:Image ID="WhatIsBBScore" CssClass="PopupLink" ImageUrl="~/en-us/images/info_icon.png" runat="server" Visible="false" Style="vertical-align: middle;" ToolTip="<%$ Resources:Global, WhatIsThis %>" />
                                    <cc1:PopupControlExtender ID="pceWhatIsBBScore" runat="server" TargetControlID="WhatIsBBScore" PopupControlID="pnlWhatIsBBScore" Position="Bottom" />
                                </asp:Panel>
                            </p>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="<%$ Resources:Global, TESGridIntegrityAbility %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap vertical-align-top">
                        <ItemTemplate>
                            <div class="row">
                                <div class="col-md-12">
                                    <asp:RadioButtonList ID="rdLstIntegrity" CssClass="tight space notbold" runat="server" RepeatDirection="Vertical" RepeatColumns="1" />
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="<%$ Resources:Global, PayPerformance %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" Visible="false" ItemStyle-CssClass="text-nowrap vertical-align-top">
                        <ItemTemplate>
                            <div class="row">
                                <div class="col-md-12">
                                    <asp:RadioButtonList ID="rdLstPayPerformance" CssClass="tight space notbold" runat="server" RepeatDirection="Vertical" RepeatColumns="2" />
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="<%$ Resources:Global, TESGridAmountOwed %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" Visible="false" ItemStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-Width="30%">
                        <ItemTemplate>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="row mar_bot_5">
                                        <div class="col-md-2 form-inline text-right">
                                            <%=Resources.Global.Current %>:
                                        </div>
                                        <div class="col-md-4 form-inline">
                                            $&nbsp;<asp:TextBox ID="txtAmountOwedCurrent" Columns="5" MaxLength="10" runat="server" tsiCurrency="true" CssClass="TextBoxNumeric form-control" />
                                        </div>
                                        <div class="col-md-2 form-inline text-right">
                                            1-30: 
                                        </div>
                                        <div class="col-md-4 form-inline">
                                            $&nbsp;<asp:TextBox ID="txtAmountOwed1_30" Columns="5" MaxLength="10" runat="server" tsiCurrency="true" CssClass="TextBoxNumeric form-control" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="row mar_bot_5">
                                        <div class="col-md-2 form-inline text-right">
                                            31-60:
                                        </div>
                                        <div class="col-md-4 form-inline">
                                            $&nbsp;<asp:TextBox ID="txtAmountOwed31_60" Columns="5" MaxLength="10" runat="server" tsiCurrency="true" CssClass="TextBoxNumeric form-control" />
                                        </div>
                                        <div class="col-md-2 form-inline text-right">
                                            61-90:
                                        </div>
                                        <div class="col-md-4 form-inline">
                                            $&nbsp;<asp:TextBox ID="txtAmountOwed61_90" Columns="5" MaxLength="10" runat="server" tsiCurrency="true" CssClass="TextBoxNumeric form-control" />
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <div class="row mar_bot_5">
                                        <div class="col-md-2 form-inline text-right">
                                            91+:
                                        </div>
                                        <div class="col-md-4 form-inline">
                                            $&nbsp;<asp:TextBox ID="txtAmountOwed91" Columns="5" MaxLength="10" runat="server" tsiCurrency="true" CssClass="TextBoxNumeric form-control" />
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <cc1:FilteredTextBoxExtender ID="filterTxtAmountOwedCurrent" TargetControlID="txtAmountOwedCurrent" FilterType="Custom, Numbers" ValidChars="." runat="server" />
                            <cc1:FilteredTextBoxExtender ID="filterTxtAmountOwed1_30" TargetControlID="txtAmountOwed1_30" FilterType="Custom, Numbers" ValidChars="." runat="server" />
                            <cc1:FilteredTextBoxExtender ID="filterTxtAmountOwed31_60" TargetControlID="txtAmountOwed31_60" FilterType="Custom, Numbers" ValidChars="." runat="server" />
                            <cc1:FilteredTextBoxExtender ID="filterTxtAmountOwed61_90" TargetControlID="txtAmountOwed61_90" FilterType="Custom, Numbers" ValidChars="." runat="server" />
                            <cc1:FilteredTextBoxExtender ID="filterTxtAmountOwed91" TargetControlID="txtAmountOwed91" FilterType="Custom, Numbers" ValidChars="." runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="<%$ Resources:Global, TESGridHighCredit %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap vertical-align-top">
                        <ItemTemplate>
                            <div class="row">
                                <div class="col-md-12">
                                    <asp:RadioButtonList ID="rdLstHighCredit" runat="server" CssClass="tight space notbold" RepeatDirection="Vertical" RepeatColumns="2" />
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="<%$ Resources:Global, TESGridLastDealt %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap vertical-align-top">
                        <ItemTemplate>
                            <div class="row">
                                <div class="col-md-12">
                                    <asp:RadioButtonList ID="rdLstLastDealt" runat="server" CssClass="tight space notbold" RepeatDirection="Vertical" RepeatColumns="1" />
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="<%$ Resources:Global, TESGridOutOfBusiness %>" HeaderStyle-CssClass="text-center vertical-align-top" ItemStyle-CssClass="text-center vertical-align-top" HeaderStyle-Width="50">
                        <ItemTemplate>
                            <div class="row">
                                <div class="col-md-12">
                                    <asp:CheckBox ID="chkOutOfBusiness" runat="server" />
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="<%$ Resources:Global, Comments %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="vertical-align-top">
                        <ItemTemplate>
                            <div class="row">
                                <div class="col-md-12">
                                    <textarea id="txtAreaComments" runat="server" cols="15" rows="4" class="form-control"></textarea>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>

        <div class="row nomargin text-left mar_top">
            <asp:LinkButton ID="lnkBtnSaveAndContinue" runat="server" CssClass="btn gray_btn" OnClick="btnSaveAndContinueOnClick">
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, SaveAndContinue %>" />
            </asp:LinkButton>
            <asp:LinkButton ID="lnkBtnSubmitAndFinish" runat="server" CssClass="btn gray_btn" OnClick="btnSubmitAndFinishOnClick">
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, SubmitAndFinish %>" />
            </asp:LinkButton>
            <asp:LinkButton ID="lnkBtnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancelOnClick">
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnCancel %>" />
            </asp:LinkButton>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlComplete" runat="server" Visible="false">
        <asp:Label ID="lblThankYouMessage" runat="server" /><br />
        <asp:LinkButton ID="btnThankYouAction" OnClick="btnThankYouActionOnClick" CssClass="btn gray_btn" runat="server" />
    </asp:Panel>


    <!-- Modal -->
    <bbos:BBScoreChart id="ucBBScoreChart" runat="server" panelIndex="1" />

    <div id="pnlRatingDef" style="display: none; width: 450px; min-height: 300px; height: auto; position: absolute; z-index: 100;" class="Popup">
        <div class="popup_header">
            <button type="button" class="close" data-bs-dismiss="modal" onclick="document.getElementById('pnlRatingDef').style.display='none';">&times;</button>
        </div>
        <span id="ltRatingDef"></span>
    </div>
    <span id="litNonMemberRatingDef" style="display: none; visibility: hidden;">
        <%=Resources.Global.BBRatingsAvail %>
        <%--Blue Book Ratings are only available to licensed Blue Book Members.  Blue Book Ratings reflect the pay practices, attitudes, financial conditions and services of companies buying, selling & transporting fresh produce. --%>
        <a href="MembershipSelect.aspx">
            <%= Resources.Global.SignUpForMembershipToday1 %>
        </a>
        <%= Resources.Global.SignUpForMembershipToday2 %>
    </span>
    <!-- Modal END -->
</asp:Content>
