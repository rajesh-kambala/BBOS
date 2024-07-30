<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="SpecialServicesFileClaim.aspx.cs" Inherits="PRCo.BBOS.UI.Web.SpecialServicesFileClaim" Title="Untitled Page" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Register TagPrefix="bbos" TagName="TESLongForm" Src="UserControls/TESLongForm.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function cbIAgree_Click() {
            if (true == (cbIAgree2.checked && cbIAgree3.checked && cbIAgree4.checked)) {
                <%= btnSubmit.ClientID%>.disabled = false;
                <%= btnSubmit.ClientID%>.href = "javascript:" + PostBackURL.value;
                <%= btnSubmit.ClientID%>.className = "btn gray_btn"
            }
            else {
                <%= btnSubmit.ClientID%>.disabled = true;
                <%= btnSubmit.ClientID%>.href = "";
                <%= btnSubmit.ClientID%>.className = "aspNetDisabled btn gray_btn"
            }
        }

        function OnBeginRequest(sender, args) {
            var postBackElement = args.get_postBackElement();

            if ((postBackElement.id == "<%= btnAttachFile.ClientID %>") ||
                (postBackElement.id == "<%= btnRemoveFile.ClientID %>")) {
                manager._scrollPosition = null;
            }
        }
    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Label ID="ReturnURL" Visible="false" runat="server" />
    <asp:HiddenField ID="PostBackURL" runat="server" />

    <asp:Panel ID="pnlFileClaim" runat="server">
        <div class="form-group">
            <div class="row">
                <div class="col-md-9 offset-md-3">
                    <asp:Literal ID="litClaimAuthForm" runat="server" />
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.RespondentCompanyName %>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:Label ID="lblRespondentCompanyName" runat="server" />&nbsp;
                    <asp:LinkButton ID="btnAddRespondent" runat="server" CssClass="btn gray_btn" OnClick="btnAddRespondentClick">
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnSelect %>" />
                    </asp:LinkButton>
                    <asp:HiddenField ID="hdnRespondentCompanyID" runat="server" />
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.RespondentContactName %>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:TextBox ID="txtRespondentContactName" Columns="30" MaxLength="50" tsiDisplayName='<%$Resources:Global, RespondentContactName %>' 
                        runat="server" CssClass="form-control" />
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.ClaimantCompanyName %>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:Label ID="lblClaimantCompanyName" runat="server" />
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.IssueDescription %>:</div>
                </div>
                <div class="col-md-6 form-inline">
                    <asp:TextBox ID="txtIssueQuestion" runat="server" Rows="5" MaxLength="500"
                        TextMode="MultiLine" onkeypress="ValidateTextAreaLength(this, 500);" CssClass="form-control" width="100%" />
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.TotalAmountOwing %>: *</div>
                </div>
                <div class="col-md-6">
                    <div class="input-group mb-3">
                        <span class="input-group-text">$</span>
                        <asp:TextBox ID="txtInitialAmountOwed" Columns="8" tsiCurrency="true" tsiDisplayName="<%$ Resources:Global, TotalAmountOwing %>" runat="server" CssClass="form-control" />
                        <span class="input-group-text"><%= Resources.Global.inusdollars %></span>
                    </div>
                </div>
            </div>
            <div class="row mar_top">
                <div class="col-md-9 offset-md-3">
                    <asp:Label ID="lblSSFileUploadFaxSupportingDocMsg" Text="<%$Resources:Global, SSFileUploadFaxSupportingDocMsg %>" runat="server" />
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.Documentation %>:</div>
                </div>
                <div class="col-md-5">
                    <asp:FileUpload ID="FileUpload1" ClientIDMode="Static" runat="server" tsiDisplayName="<%$Resources:Global, AdditionalFile1 %>" Width="100%" onchange="this.form.submit()" />
                </div>
                <div class="col-md-2">
                    <asp:LinkButton ID="btnAttachFile" runat="server" CssClass="btn gray_btn" OnClick="btnAttach_Click" Visible="false">
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnAttachFile %>" />
                    </asp:LinkButton>
                </div>
            </div>

            <asp:UpdatePanel ID="pnlAttachedFiles" UpdateMode="Always" ChildrenAsTriggers="true" runat="server">
                <ContentTemplate>
                    <div class="row mar_top_5">
                        <div class="col-md-5 offset-md-3">
                            <asp:ListBox ID="lbAttachedFiles" Width="100%" Rows="2" runat="server" />
                        </div>
                        <div class="col-md-2">
                            <asp:LinkButton ID="btnRemoveFile" runat="server" CssClass="btn gray_btn" OnClick="btnRemove_Click">
		                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnRemoveFile %>" />
                            </asp:LinkButton>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>

            <div class="row mar_top">
                <div class="col-md-8 offset-md-3 bold">
                    <%= Resources.Global.ContactInformation %>
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.AddressLine1 %>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:TextBox ID="txtStreet1" Columns="30" MaxLength="40" tsiDisplayName="<%$ Resources:Global, AddressLine1 %>" runat="server"
                        CssClass="form-control"/>
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.AddressLine2 %>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:TextBox ID="txtStreet2" Columns="30" MaxLength="40" tsiDisplayName="<%= $ Resources:Global, AddressLine2 %>" runat="server" 
                        CssClass="form-control"/>
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.AddressLine3 %>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:TextBox ID="txtStreet3" Columns="30" MaxLength="40" tsiDisplayName="<%= $ Resources:Global, AddressLine3 %>" runat="server"
                        CssClass="form-control"/>
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.City %>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:TextBox ID="txtCity" Columns="30" MaxLength="50" tsiDisplayName="<%$ Resources:Global, City %>" runat="server"
                        CssClass="form-control"/>
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.Country %>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:DropDownList ID="ddlCountry" tsiDisplayName="<%$ Resources:Global, Country %>" runat="server"
                        CssClass="form-control"/>
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.State %>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:DropDownList ID="ddlState" Width="215" tsiDisplayName="<%$ Resources:Global, State %>" runat="server" 
                        CssClass="form-control"/>

                    <cc1:CascadingDropDown ID="cddCountry" TargetControlID="ddlCountry" ServicePath="AJAXHelper.asmx" ServiceMethod="GetCountries" Category="Country" runat="server" />
                    <cc1:CascadingDropDown ID="cddState" TargetControlID="ddlState" ServicePath="AJAXHelper.asmx" ServiceMethod="GetStateAbbreviations" Category="State" ParentControlID="ddlCountry" runat="server" />
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.PostalCode %>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:TextBox ID="txtPostalCode" Columns="10" MaxLength="10" tsiDisplayName="<%$ Resources:Global, PostalCode %>" runat="server" 
                        CssClass="form-control"/>
                    <asp:Literal ID="litPostalCodeReq" runat="server" />
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.ContactName %>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:TextBox ID="txtContact" runat="server" Columns="30" CssClass="form-control"/>
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.Phone2 %>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:TextBox ID="txtPhoneNumber" Columns="20" MaxLength="20" runat="server" tsiDisplayName="<%$ Resources:Global, PhoneNumber %>"  
                        CssClass="form-control"/>
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.Fax2 %>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:TextBox ID="txtFaxNumber" Columns="20" MaxLength="20" runat="server"
                        CssClass="form-control"/>
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                    <div class="clr_blu"><% =Resources.Global.EmailAddress %>:</div>
                </div>
                <div class="col-md-9 form-inline">
                    <asp:TextBox ID="txtEmail" Columns="30" MaxLength="255" tsiRequired="true" tsiEmail="true" tsiDisplayName="<%$ Resources:Global, EmailAddress %>" runat="server"
                        CssClass="form-control"/>
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                </div>
                <div class="col-md-9 form-inline">
                    <asp:CheckBox ID="cbSpanish" Text='<%$ Resources:Global, PreferSpanishRep %>' runat="server" CssClass="space" />
                </div>
            </div>

            <asp:UpdatePanel ID="pnlAuthParagraph" runat="server">
                <ContentTemplate>
                    <div class="row mar_top">
                        <div class="col-md-3 text-right">
                            <asp:LinkButton ID="btnAuthParagraphToggle" runat="server" CssClass="btn gray_btn" OnClick="btnAuthParagraphToggle_Click">
    		            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" />
                            </asp:LinkButton>
                            <asp:HiddenField ID="hidAuthParagraphLanguage" runat="server" />
                        </div>
                        <div class="col-md-9 col-xs-8 form-inline">
                            <asp:Label ID="lblSSFileAuthorizationAgreementMsg" Text="<%$Resources:Global, SSFileAuthorizationAgreementMsg %>" runat="server" Style="font-weight: bold;" />
                        </div>
                    </div>
                </ContentTemplate>
                <Triggers>
                    <asp:PostBackTrigger ControlID="btnAuthParagraphToggle" />
                </Triggers>
            </asp:UpdatePanel>

            <div class="row mar_top_5">
                <div class="col-md-3">
                </div>
                <div class="col-md-9 form-inline">
                    <asp:CheckBox ID="cbIAgree2" runat="server" Text="<%$Resources:Global, IAgree2 %>" CssClass="d-flex space" />
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                </div>
                <div class="col-md-9 form-inline">
                    <asp:CheckBox ID="cbIAgree3" runat="server" Text="<%$Resources:Global, IAgree3 %>" CssClass="d-flex space" />
                </div>
            </div>
            <div class="row mar_top_5">
                <div class="col-md-3">
                </div>
                <div class="col-md-9 form-inline">
                    <asp:CheckBox ID="cbIAgree4" runat="server" Text="<%$Resources:Global, IAgree4 %>" CssClass="d-flex space" />
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-9 offset-md-3">
                <asp:LinkButton ID="btnSubmit" runat="server" CssClass="btn gray_btn" OnClick="btnSubmitOnClick" OnClientClick="return Submit();">
		            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnSubmit %>" />
                </asp:LinkButton>
                <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancelOnClick">
		            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnCancel %>" />
                </asp:LinkButton>
            </div>
        </div>

        <br />
         
        <div class="row d-flex">
            <div class="col-md-9 offset-md-3">
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th scope="col"></th>
                            <th scope="col" class="p-0 border-0 text-center" style="font-size:larger; background-color:#FFFFFF"><strong><%=Resources.Global.Basic %></strong></th>
                            <th scope="col" class="p-0 border-0 text-center" style="font-size:larger; background-color:#BFBFBF; color:white"><strong><%=Resources.Global.Standard%></strong></th>
                            <th scope="col" class="p-0 border-0 text-center" style="font-size:larger; background-color:#FFCE00; color:white"><strong><%=Resources.Global.Premium%></strong></th>
                            <th scope="col" class="p-0 border-0 text-center" style="font-size:larger; background-color:#00C400; color:white"><strong><%=Resources.Global.Enterprise %></strong></th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <th scope="row" class="p-2 border-0 text-center"><%=Resources.Global.DisputeResolutionSuccessFee %></th>
                            <td class="p-2 border-0 text-center"><%=Resources.Global.FeeSpanish %>10%<%=Resources.Global.FeeEnglish %></td>
                            <td class="p-2 border-0 text-center" style="background-color: #F2F2F2"><%=Resources.Global.FeeSpanish %>5%<%=Resources.Global.FeeEnglish %></td>
                            <td class="p-2 border-0 text-center" style="background-color: #FFF0B3"><%=Resources.Global.FeeSpanish %>2%<%=Resources.Global.FeeEnglish %></td>
                            <td class="p-2 border-0 text-center" style="background-color: #B3EDB3"><%=Resources.Global.FeeSpanish %>2%<%=Resources.Global.FeeEnglish %></td>
                        </tr>
                        <tr>
                            <th scope="row" class="p-2 border-0 text-center"><%=Resources.Global.DisputeResolutionWithARAging %></th>
                            <td class="p-2 border-0 text-center"><%=Resources.Global.FeeSpanish %>5%<%=Resources.Global.FeeEnglish %></td>
                            <td class="p-2 border-0 text-center" style="background-color: #F2F2F2"><%=Resources.Global.FeeSpanish %>2%<%=Resources.Global.FeeEnglish %></td>
                            <td class="p-2 border-0 text-center" style="background-color: #FFF0B3"><%=Resources.Global.Complimentary %></td>
                            <td class="p-2 border-0 text-center" style="background-color: #B3EDB3"><%=Resources.Global.Complimentary %></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <br />
    </asp:Panel>

    <asp:Panel ID="pnlThankYou" Visible="false" runat="server">
        <div class="row">
            <div class="col-md-12">
                <asp:Label ID="lblThankYouMsg" runat="server" />
            </div>
        </div>

        <div class="row nomargin_lr mar_top">
            <asp:LinkButton ID="btnSubmitTES" CssClass="btn gray_btn" runat="server">
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, SubmitTradeSurveyonRespondentCompany %>" />
            </asp:LinkButton>
        </div>
        <div class="row nomargin">
            <asp:LinkButton ID="btnFileClaim" runat="server" CssClass="btn gray_btn" OnClick="btnFileClaimClick">
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, FileAnotherClaim %>" />
            </asp:LinkButton>
            <asp:LinkButton ID="btnDone" runat="server" CssClass="btn gray_btn" OnClick="btnDoneClick">
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnDone %>" />
            </asp:LinkButton>
        </div>

        <bbos:TESLongForm ID="TESLongForm" runat="server" />
    </asp:Panel>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        var manager = Sys.WebForms.PageRequestManager.getInstance();
        manager.add_beginRequest(OnBeginRequest);

        function Submit() {
            if ($("#<%=hdnRespondentCompanyID.ClientID%>").val() == "") {
                bbAlert('<% =Resources.Global.RespondentCompanyName %> <%=Resources.Global.RequiredFieldsMsg2%>');
                return false;
            }
            return true;
        }
    </script>
</asp:Content>


