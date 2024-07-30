<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EMCW_EditPersonnel.aspx.cs" Inherits="PRCo.BBOS.UI.Web.EMCW_EditPersonnel" MasterPageFile="~/BBOS.Master" EnableEventValidation="false" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="bbos" TagName="EMCW_CompanyHeader" Src="~/UserControls/EMCW_CompanyHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyListing" Src="UserControls/CompanyListing.ascx" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">

    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row">
        <div class="col-md-4">
            <%--Company Header--%>
            <bbos:EMCW_CompanyHeader ID="ucCompanyDetailsHeader" runat="server" />

            <%--Listing Report Button--%>
            <div class="row nomargin_lr mar_top_5">
                <div class="col-md-12">
                    <asp:LinkButton ID="btnListingReport" runat="server" CssClass="btn gray_btn" OnClick="btnListingReport_Click" OnClientClick="bDirty=false">
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text='<%$Resources:Global, ListingReport %>' />
                    </asp:LinkButton>
                </div>
            </div>

            <%--Listing Panel--%>
            <bbos:CompanyListing ID="ucCompanyListing" runat="server" Visible="true" />

            <asp:HiddenField ID="hidCompanyID" runat="server" />
            <asp:HiddenField ID="hidIncludeBranches" Value="false" runat="server" />
        </div>
        <div class="col-md-8 nomargin nopadding">
            <div class="row">
                <div class="col-md-12 clr_blu">
                    <%= Resources.Global.EMCWCompanyListingHeaderText %>
                </div>
            </div>

            <asp:Panel ID="pnlEnterprise" runat="server" Visible="false">
                <div class="row">
                    <div class="col-md-12 form-inline label_top">
                        <span class="clr_blu"><% =Resources.Global.Company %>:</span>
                        <asp:DropDownList ID="ddlCompanies" tsiSkipOnChange="true" runat="server" CssClass="form-control"></asp:DropDownList>
                        &nbsp;
                        <asp:LinkButton ID="btnSelectCompany" runat="server" CssClass="btn gray_btn" OnClick="btnSelectOnClick" OnClientClick="return onCompanyChange();">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text='<%$Resources:Global, Select %>' />
                        </asp:LinkButton>
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlNotListed" runat="server" Visible="false">
                <div class="row nomargin">
                    <div class="col-md-12 clr_blu">
                        <%= Resources.Global.EditCompanyNotListedText %>
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlNoEdit" runat="server" Visible="false">
                <div class="row nomargin">
                    <div class="col-md-12 clr_blu">
                        <%= Resources.Global.NoEditRole%>
                    </div>
                </div>
            </asp:Panel>

            <div class="row">
                <div class="col-md-12">
                    <asp:LinkButton ID="btnManageCompanyListing" runat="server" CssClass="btn gray_btn" OnClick="btnManageCompanyListing_Click"  >
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text='<%$Resources:Global, CompanyListing %>' />
                    </asp:LinkButton>
                </div>
                <div class="col-md-12 mar_top_10 clr_blu">
                    <asp:Literal ID="litLicenseInfo" runat="server" />
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <%-- Requested Changes --%>
                    <div class="row panels_box">
                        <div class="col-md-12">
                            <div class="panel panel-primary">
                                <div class="panel-heading">
                                    <h4 class="blu_tab">
                                        <%= Resources.Global.RequestedChanges %>
                                    </h4>
                                </div>
                                <div class="panel-body nomargin pad10 gray_bg">
                                    <div class="row nomargin_lr">
                                        <asp:UpdatePanel ID="upPersonnel" runat="server">
                                            <ContentTemplate>
                                                <asp:Repeater ID="repPersonnel" runat="server" OnItemDataBound="repPersonnel_ItemDataBound">
                                                    <ItemTemplate>
                                                        <div class="row">
                                                            <div class="col-md-3">
                                                                <asp:Label runat="server" Text='<%$Resources:Global, Name_Cap %>' />:
                                                            </div>
                                                            <div class="col-md-3">
                                                                <asp:TextBox ID="txtFormattedName" runat="server" CssClass="form-control" Enabled="false" ReadOnly="true" />
                                                                <asp:HiddenField ID="hidFormattedName" runat="server" />
                                                            </div>
                                                            <div class="col-md-3">
                                                                <asp:Label runat="server" Text='<%$Resources:Global, Title %>' />:
                                                            </div>
                                                            <div class="col-md-3">
                                                                <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" />
                                                                <asp:HiddenField ID="hidTitle" runat="server" />
                                                            </div>
                                                        </div>
                                                        <div class="row mar_top_5">
                                                            <div class="col-md-3">
                                                                <asp:Label runat="server" Text='<%$Resources:Global, Email_Cap %>' />:
                                                            </div>
                                                            <div class="col-md-3">
                                                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" />
                                                                <asp:HiddenField ID="hidEmail" runat="server" />
                                                            </div>
                                                            <div class="col-md-3">
                                                                <asp:Label runat="server" Text='<%$Resources:Global, OwnershipPct %>' />:
                                                            </div>
                                                            <div class="col-md-3">
                                                                <asp:TextBox ID="txtOwnershipPct" runat="server" CssClass="form-control" />
                                                                <asp:HiddenField ID="hidOwnershipPct" runat="server" />
                                                            </div>
                                                        </div>
                                                        <div class="row mar_top_5">
                                                            <div class="col-md-3">
                                                                <asp:Label runat="server" Text='<%$Resources:Global, OnlineAccessLicense %>' />:
                                                            </div>
                                                            <div class="col-md-3">
                                                                <asp:CheckBox ID="cbHasBBOSLicense" runat="server" />
                                                                <asp:HiddenField ID="hidHasBBOSLicense" runat="server" />
                                                            </div>

                                                            <div class="col-md-3">
                                                                <asp:Label runat="server" Text='<%$Resources:Global, NoLongerAtCompany%>' />:
                                                            </div>
                                                            <div class="col-md-3">
                                                                <asp:CheckBox ID="cbNoLongerAtCompany" runat="server" CssClass="NoLongerAtCompany" />
                                                                <asp:HiddenField ID="hidNoLongerAtCompany" runat="server" />
                                                            </div>

                                                        </div>
                                                        <div class="row mar_top_5 DateReasonLeftRow">
                                                            <div class="col-md-3 ">
                                                                <asp:Label runat="server" Text='<%$Resources:Global, DateLeft %>' />:
                                                            </div>
                                                            <div class="col-md-3 ">
                                                                <asp:TextBox ID="txtDateLeft" runat="server" CssClass="form-control" />
                                                                <asp:HiddenField ID="hidDateLeft" runat="server" />
                                                                <cc1:CalendarExtender runat="server" ID="ceDateLeft" TargetControlID="txtDateLeft" />
                                                            </div>

                                                            <div class="col-md-3">
                                                                <asp:Label runat="server" Text='<%$Resources:Global, ReasonLeft %>' />:
                                                            </div>
                                                            <div class="col-md-3">
                                                                <asp:DropDownList ID="ddlReasonLeft" runat="server" CssClass="form-control" />
                                                                <asp:HiddenField ID="hidReasonLeft" runat="server" />
                                                            </div>
                                                        </div>

                                                        <div class="row mar_top_5 DateReasonLeftRow">
                                                            <div class="col-md-4">
                                                                <asp:Label runat="server" Text='<%$Resources:Global, EmployedAtIfKnown %>' />:
                                                            </div>

                                                            <div class="col-md-2">
                                                                <asp:TextBox ID="txtCurrentlyEmployedAt" runat="server" CssClass="form-control" />
                                                                <asp:HiddenField ID="hidCurrentlyEmployedAt" runat="server" />
                                                            </div>
                                                        </div>

                                                        <div class="row mar_top_5">
                                                            <div class="col-md-3">
                                                                <asp:Label runat="server" Text='<%$Resources:Global, PhoneNumber %>' />:
                                                            </div>
                                                            <div class="col-md-3">
                                                                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" />
                                                                <asp:HiddenField ID="hidPhone" runat="server" />
                                                            </div>
                                                            <div class="col-md-3">
                                                                <asp:Label runat="server" Text='<%$Resources:Global, Type%>' />:
                                                            </div>
                                                            <div class="col-md-3">
                                                                <asp:DropDownList ID="ddlPhoneType" runat="server" CssClass="form-control" />
                                                                <asp:HiddenField ID="hidPhoneType" runat="server" />
                                                            </div>
                                                        </div>

                                                        <div class="row mar_top_5">
                                                            <div class="col-md-4">
                                                                <asp:Label runat="server" Text='<%$Resources:Global, AdditionalChangeInstructions %>' />:
                                                            </div>
                                                            <div class="col-md-8">
                                                                <asp:TextBox ID="txtAdditionalChangeInstructions" runat="server" CssClass="form-control" />
                                                                <asp:HiddenField ID="hidAdditionalChangeInstructions" runat="server" />
                                                            </div>
                                                        </div>
                                                        <div class="row nomargin_lr bor_bot_thick_blue">
                                                        </div>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>

                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <%-- Adding Primary Personnel --%>
                    <div class="row panels_box">
                        <div class="col-md-12">
                            <div class="panel panel-primary">
                                <div class="panel-heading">
                                    <h4 class="blu_tab">
                                        <%= Resources.Global.AddingPrimaryPersonnel %>
                                    </h4>
                                </div>
                                <div class="panel-body nomargin pad10 gray_bg">
                                    <div class="row nomargin_lr">
                                        <div class="row">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, Name_Cap %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtFormattedName1" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, Title %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtTitle1" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                        <div class="row mar_top_5">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, Email_Cap %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtEmail1" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, DateStarted %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtDateStarted1" runat="server" CssClass="form-control" />
                                                <cc1:CalendarExtender runat="server" ID="ceDateStarted1" TargetControlID="txtDateStarted1" />
                                            </div>
                                        </div>

                                        <div class="row mar_top_5">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, PhoneNumber %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtPhone1" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, Type %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:DropDownList ID="ddlPhoneType1" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>

                                        <div class="row mar_top_5">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, PreviousEmployer %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtPrevEmployer1" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, AddToListing %>' />
                                            </div>
                                            <div class="col-md-3">
                                                <asp:RadioButtonList ID="rblAddToListing1" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl" >
                                                    <asp:ListItem Text="Yes" Value="Yes" />
                                                    <asp:ListItem Text="No" Value="No" Selected="True" />
                                                </asp:RadioButtonList>
                                            </div>
                                        </div>
                                        <div class="row mar_top_5">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, AssignOnlineAccessLicense %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:CheckBox ID="cbAssignBBOSLicense1" runat="server" />
                                            </div>
                                        </div>
                                        <div class="row mar_top_5">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, AdditionalInstructions %>' />:
                                            </div>
                                            <div class="col-md-9">
                                                <asp:TextBox ID="txtAdditionalChangeInstructions1" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                        <div class="row nomargin_lr bor_bot_thick_blue">
                                        </div>
                                    </div>
                                    <div class="row nomargin_lr">
                                        <div class="row">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, Name_Cap %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtFormattedName2" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, Title %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtTitle2" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                        <div class="row mar_top_5">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, Email_Cap %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtEmail2" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, DateStarted %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtDateStarted2" runat="server" CssClass="form-control" />
                                                <cc1:CalendarExtender runat="server" ID="ceDateStarted2" TargetControlID="txtDateStarted2" />
                                            </div>
                                        </div>
                                        <div class="row mar_top_5">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, PhoneNumber %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtPhone2" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, Type %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:DropDownList ID="ddlPhoneType2" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>

                                        <div class="row mar_top_5">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, PreviousEmployer %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtPrevEmployer2" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, AddToListing %>' />
                                            </div>
                                            <div class="col-md-3">
                                                <asp:RadioButtonList ID="rblAddToListing2" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl" >
                                                    <asp:ListItem Text="Yes" Value="Yes" />
                                                    <asp:ListItem Text="No" Value="No" Selected="True" />
                                                </asp:RadioButtonList>
                                            </div>
                                        </div>
                                        <div class="row mar_top_5">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, AssignOnlineAccessLicense %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:CheckBox ID="cbAssignBBOSLicense2" runat="server" />
                                            </div>
                                        </div>
                                        <div class="row mar_top_5">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, AdditionalInstructions %>' />:
                                            </div>
                                            <div class="col-md-9">
                                                <asp:TextBox ID="txtAdditionalChangeInstructions2" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                        <div class="row nomargin_lr bor_bot_thick_blue">
                                        </div>
                                    </div>
									<div class="row nomargin_lr">
                                        <div class="row">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, Name_Cap %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtFormattedName3" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, Title %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtTitle3" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                        <div class="row mar_top_5">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, Email_Cap %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtEmail3" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, DateStarted %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtDateStarted3" runat="server" CssClass="form-control" />
                                                <cc1:CalendarExtender runat="server" ID="ceDateStarted3" TargetControlID="txtDateStarted3" />
                                            </div>
                                        </div>
                                        <div class="row mar_top_5">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, PhoneNumber %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtPhone3" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, Type %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:DropDownList ID="ddlPhoneType3" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>

                                        <div class="row mar_top_5">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, PreviousEmployer %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="txtPrevEmployer3" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, AddToListing %>' />
                                            </div>
                                            <div class="col-md-3">
                                                <asp:RadioButtonList ID="rblAddToListing3" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl" >
                                                    <asp:ListItem Text="Yes" Value="Yes" />
                                                    <asp:ListItem Text="No" Value="No" Selected="True"/>
                                                </asp:RadioButtonList>
                                            </div>
                                        </div>
                                        <div class="row mar_top_5">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, AssignOnlineAccessLicense %>' />:
                                            </div>
                                            <div class="col-md-3">
                                                <asp:CheckBox ID="cbAssignBBOSLicense3" runat="server" />
                                            </div>
                                        </div>
                                        <div class="row mar_top_5">
                                            <div class="col-md-3">
                                                <asp:Label runat="server" Text='<%$Resources:Global, AdditionalInstructions %>' />:
                                            </div>
                                            <div class="col-md-9">
                                                <asp:TextBox ID="txtAdditionalChangeInstructions3" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                        <div class="row nomargin_lr bor_bot_thick_blue">
                                        </div>
                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row mar_top">
                <div class="col-md-9">
                    <asp:LinkButton ID="btnSubmit" runat="server" CssClass="btn gray_btn" OnClick="btnSubmit_Click" OnClientClick="bDirty=false">
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text='<%$Resources:Global, Submit %>' />
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancel_Click" OnClientClick="bDirty=false">
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text='<%$Resources:Global, Cancel %>' />
                    </asp:LinkButton>
                </div>
            </div>
        </div>
    </div>

    <div class="text-left">
        <asp:Panel ID="pnlListingReport" Style="display: none" CssClass="Popup" Width="300" runat="server">
            <h4 class="blu_tab"><% =Resources.Global.PleaseConfirm %></h4>
            <div class="row mar_top">
                <div class="col-md-12">
                    <asp:Literal ID="litBranchMsg" runat="server"></asp:Literal>
                </div>
            </div>

            <div class="row mar_top">
                <div class="col-md-12">
                    <asp:LinkButton ID="btnYes" runat="server" CssClass="btn gray_btn" Width="75px" OnClientClick="bDirty=false">
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text='<%$Resources:Global, Yes %>' />
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnNo" runat="server" CssClass="btn gray_btn" Width="75px" OnClientClick="bDirty=false">
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text='<%$Resources:Global, No %>' />
                    </asp:LinkButton>
                </div>
            </div>
        </asp:Panel>
    </div>
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        // Declare our Dirty flag
        var bDirty = false;

        // This event will fire when any
        // control on the form is changed.
        function onDataChange() {
            bDirty = true;
        }

        // This function fires prior to the unloading
        // of the page.  It checks the Dirty flag to
        // determine if we should warn the user.
        function onCompanyChange() {
            if (bDirty == true) {
                return confirm("The Listing changes have not been saved.  If you continue, the changes will be lost.  Click 'OK' to switch to the selected company.  Click 'Cancel' to stay on this page.");
            }
        }

        $('.NoLongerAtCompany').change(function () {
            if ($(this).find('input:checkbox:first').is(':checked'))
            {
                $(this).closest('.row').next('.DateReasonLeftRow').removeClass('d-none');
                $(this).closest('.row').next('.DateReasonLeftRow').next('.DateReasonLeftRow').removeClass('d-none');
            }
            else
            {
                $(this).closest('.row').next('.DateReasonLeftRow').addClass('d-none');
                $(this).closest('.row').next('.DateReasonLeftRow').next('.DateReasonLeftRow').addClass('d-none');
            }
        });

        // Iterate through all of the elements on
        // the form.  Set the element's onChange
        // event handler to the global handler to
        // set the dirty flag.
        function onFormLoad() {

            var oForm = document.forms[0];
            for (i = 0; i < oForm.elements.length; i++) {
                var oElement = oForm.elements[i];

                if (oElement.getAttribute('tsiSkipOnChange')) {
                    //
                } else {
                    oForm.elements[i].onchange = onDataChange;
                }
            }

            //hide all NoLongerAtCompany regions initially
            $.each($('.NoLongerAtCompany').find('input:checkbox:first'), function () {
                if ($(this).is(':checked')) {
                    $(this).closest('.row').next('.DateReasonLeftRow').removeClass('d-none');
                    $(this).closest('.row').next('.DateReasonLeftRow').next('.DateReasonLeftRow').removeClass('d-none');
                }
                else {
                    $(this).closest('.row').next('.DateReasonLeftRow').addClass('d-none');
                    $(this).closest('.row').next('.DateReasonLeftRow').next('.DateReasonLeftRow').addClass('d-none');
                }
            });
        }

        function postStdValidation(form) {
            var errMsg = "";

            if (HasInput("<%=txtFormattedName1.ClientID%>", "<%=txtTitle1.ClientID%>", "<%=txtEmail1.ClientID%>", "<%=txtDateStarted1.ClientID%>", "<%=txtPrevEmployer1.ClientID%>", "<%=rblAddToListing1.ClientID%>", "<%=cbAssignBBOSLicense1%>"))
                        if ($("#<%=txtTitle1.ClientID%>").val().length == 0)
                            errMsg += "New Personnel #1 \"Title\" is required.<br>";

            if (HasInput("<%=txtFormattedName2.ClientID%>", "<%=txtTitle2.ClientID%>", "<%=txtEmail2.ClientID%>", "<%=txtDateStarted2.ClientID%>", "<%=txtPrevEmployer2.ClientID%>", "<%=rblAddToListing2.ClientID%>", "<%=cbAssignBBOSLicense2%>"))
                if ($("#<%=txtTitle2.ClientID%>").val().length == 0)
                    errMsg += "New Personnel #2 \"Title\" is required.<br>";

            if (HasInput("<%=txtFormattedName3.ClientID%>", "<%=txtTitle3.ClientID%>", "<%=txtEmail3.ClientID%>", "<%=txtDateStarted3.ClientID%>", "<%=txtPrevEmployer3.ClientID%>", "<%=rblAddToListing3.ClientID%>", "<%=cbAssignBBOSLicense3%>"))
                if ($("#<%=txtTitle3.ClientID%>").val().length == 0)
                    errMsg += "New Personnel #3 \"Title\" is required.<br>";

            if (errMsg.length > 0) {
                displayErrorMessage(errMsg);
                return false;
            }

            return true;
        }

        function HasInput(txtFormattedName, txtTitle, txtEmail, txtDateStarted1, txtPrevEmployer1, rblAddToListing1, cbAssignBBOSLicense1) {
            var blnChanged = false;

            if ($("#" + txtFormattedName).val().length > 0) blnChanged = true;
            else if ($("#" + txtTitle).val().length > 0) blnChanged = true;
            else if ($("#" + txtEmail).val().length > 0) blnChanged = true;
            else if ($("#" + txtDateStarted1).val().length > 0) blnChanged = true;
            else if ($("#" + txtPrevEmployer1).val().length > 0) blnChanged = true;
            else if ($("#" + rblAddToListing1 + " input:checked").length > 0 && $("#" + rblAddToListing1 + " input:checked").val() != "No") blnChanged = true;
            else if ($("#" + cbAssignBBOSLicense1).is(":checked")) blnChanged = true;

            return blnChanged;
        }

        // Set the appropriate event handlers.
        window.onload = onFormLoad;
    </script>
</asp:Content>
