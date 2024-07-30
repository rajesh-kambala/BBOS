<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EMCW_ReferenceList.aspx.cs" EnableViewStateMac="false" EnableEventValidation="false" Inherits="PRCo.BBOS.UI.Web.EMCW_ReferenceList" MasterPageFile="~/BBOS.Master" %>

<%@ Register TagPrefix="bbos" TagName="EMCW_CompanyHeader" Src="~/UserControls/EMCW_CompanyHeader.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="bbos" TagName="TESLongForm" Src="UserControls/TESLongForm.ascx" %>
<%@ Register TagPrefix="bbos" TagName="BBScoreChart" Src="~/UserControls/BBScoreChart.ascx" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <style>
        table.tight td {
            margin: 0;
            padding: 0;
        }

        table.tight {
            border-collapse: collapse;
            border-spacing: 0;
            border: none;
        }

        .tight input {
            margin-left: 5px;
            margin-right: 3px;
        }

        .tight label {
            margin: 0 0 0 0;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <bbos:EMCW_CompanyHeader ID="ucCompanyDetailsHeader" runat="server" />
    <asp:HiddenField ID="hidCompanyID" runat="server" />

    <asp:Panel ID="pnlNoEdit" CssClass="Title" Style="margin-left: 12px; margin-top: 10px; margin-bottom: 20px;" runat="server" Visible="false">
        <div class="row nomargin">
            <div class="col-md-12 clr_blu">
                <%= Resources.Global.NoEditRole %>
            </div>
        </div>
    </asp:Panel>

    <div class="row nomargin">
        <div class="col-md-12 clr_blu">
            <%= Resources.Global.ToDoMoreWithReferenceList %> <a href="#buttons" class="explicitlink2"><%= Resources.Global.ToDoMoreWithResultsJump %></a>.
        </div>
    </div>

    <div class="row nomargin_lr mar_top">
        <div class="col-md-12 text-center">
            <%=Resources.Global.BusinessReferencesOf %>:<br />
            <asp:Label ID="lblCompanyInfo" runat="server" Style="font-weight: bold;"></asp:Label><br />
            <span style="color: red; text-decoration: underline"><%= Resources.Global.INFORMATIONKEPTSTRICTLYCONFIDENTIAL %></span>

            <br />
            <br />

            <span><%=Resources.Global.LastUpdatedDate %>:</span>
            <asp:Label ID="lblConnListDate" runat="server"></asp:Label>
        </div>
    </div>

    <asp:UpdatePanel ID="upnlConnections" runat="server" ChildrenAsTrigger="true" >
        <ContentTemplate>
            <bbos:TESLongForm ID="TESLongForm" runat="server" />
            <asp:Button ID="btnRateCompany" runat="server" Visible="false" />

            <div class="row nomargin_lr">
                <div class="col-md-12">
                    <asp:GridView ID="gvConnections"
                        AllowSorting="true"
                        runat="server"
                        AutoGenerateColumns="false"
                        CssClass="sch_result table table-striped table-hover"
                        GridLines="none"
                        DataKeyNames="CompanyRelationshipID,RelatedCompanyID"
                        OnSorting="GridView_Sorting"
                        OnRowDataBound="GridView_RowDataBound">

                        <Columns>
                            <asp:TemplateField HeaderStyle-Wrap="false" ItemStyle-CssClass="text-center vertical-align-top" HeaderStyle-CssClass="text-center vertical-align-top">
                                <HeaderTemplate>
                                    <% =Resources.Global.Select%>
                                    <br />
                                    <% =GetCheckAllCheckbox("chkSelect")%>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# GetCheckbox((string)Eval("ListingStatus"), (int)Eval("RelatedCompanyID"))%>
                                    <input type="hidden" value="<%# Eval("RelationshipIDList") %>" name="hdnRelationshipIDList_<%# Eval("RelatedCompanyID") %>" />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%--BBNumber Column--%>
                            <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>"
                                HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left vertical-align-top"
                                DataField="RelatedCompanyID"
                                SortExpression="prcr_RightCompanyID" />

                            <%--Icons Column--%>
                            <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
                                <ItemTemplate>
                                    <%# GetCompanyDataForCellForUnlistedCompanies((int)Eval("RelatedCompanyID"), 
                                                (string)Eval("RelatedCompanyName"), 
                                                string.Empty, 
                                                (bool)Eval("HasNote"), 
                                                UIUtils.GetDateTime(Eval("LastPublishedCSDate")), 
                                                (string)Eval("ListingStatus"), 
                                                (bool)Eval("HasNewClaimActivity"), 
                                                (bool)Eval("HasMeritoriousClaim"),
                                                (bool)Eval("HasCertification"),
                                                (bool)Eval("HasCertification_Organic"), 
                                                (bool)Eval("HasCertification_FoodSafety"),
                                                true, 
                                                false)%>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%--Related Company Name column--%>
                            <asp:TemplateField HeaderText="<%$ Resources:Global, RelatedCompanyName %>"
                                HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="vertical-align-top"
                                SortExpression="comp_PRBookTradestyle">

                                <ItemTemplate>
                                    <asp:HyperLink ID="hlRelatedCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("RelatedCompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("RelatedCompanyName") %></asp:HyperLink>
                                    <asp:Label ID="lblRelatedCompanyDetails" runat="server" Visible="false"><%# Eval("RelatedCompanyName") %></asp:Label>
                                    <%# Eval("Location") %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderStyle-CssClass="text-nowrap vertical-align-top"
                                ItemStyle-CssClass="vertical-align-top">
                                <HeaderTemplate>
                                    <%= Resources.Global.Relationship %>
                                    <a id="popWhatIsRelationship" runat="server" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                                        <img src="images/info_sm.png" />
                                    </a>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <a href="javascript:editRelationshipTypes('<%# escapeJSString((string)Eval("RelatedCompanyName")) %>', <%# Eval("RelatedCompanyID") %>, '<%# Eval("RelationshipTypeCodeList") %>');" class="explicitlink"><%# Eval("RelationshipTypeList") %></a><br />
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
                                        <asp:LinkButton ID="lbBBScore" runat="server" CssClass="PopupLink2" OnClick="lbBBScore_Click"/>

                                        <asp:Panel ID="pnlWhatIsBBScore" Style="display: none" CssClass="Popup" Width="400px" runat="server">
                                            <asp:Image ID="WhatIsBBScore" CssClass="PopupLink" ImageUrl="~/en-us/images/info_icon.png" runat="server" Visible="false" Style="vertical-align: middle;" ToolTip="<%$ Resources:Global, WhatIsThis %>" />
                                            <cc1:PopupControlExtender ID="pceWhatIsBBScore" runat="server" TargetControlID="WhatIsBBScore" PopupControlID="pnlWhatIsBBScore" Position="Bottom" />
                                        </asp:Panel>
                                    </p>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderStyle-CssClass="text-nowrap vertical-align-top"
                                ItemStyle-CssClass="vertical-align-top">
                                <HeaderTemplate>
                                    <%= Resources.Global.RateCompany %>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:LinkButton id="lbRateCompany" runat="server" CssClass="btn gray_btn" OnClick="lbRateCompany_Click" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <a name="buttons" class="anchor"></a>

    <div class="row nomargin">
        <div class="col-md-12">
            <asp:LinkButton ID="btnConfirmAllConnections" runat="server" CssClass="btn gray_btn" OnClick="btnConfirmRelationships_Click">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ConfirmAllReferences %>" /> 
            </asp:LinkButton>
            <a id="popWhatIsConfirmConnections" runat="server" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                <img src="images/info_sm.png" />
            </a>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <asp:LinkButton ID="btnConfirmConnections" runat="server" CssClass="btn gray_btn" OnClick="btnConfirmRelationships_Click">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ConfirmSelectedReferences %>" />
            </asp:LinkButton>
            <a id="popWhatIsConfirmConnections2" runat="server" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                <img src="images/info_sm.png" />
            </a>
        </div>
    </div>

    <div class="row nomargin_lr mar_top_5">
        <div class="col-md-12">
            <asp:LinkButton ID="btnAddConnection" runat="server" CssClass="btn gray_btn" OnClick="btnAddConnection_Click">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, AddConnection %>" />
            </asp:LinkButton>

            <asp:LinkButton ID="btnRemoveConnections" runat="server" CssClass="btn gray_btn" OnClick="btnRemoveRelationships_Click">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, RemoveReferences %>" />
            </asp:LinkButton>

            <asp:LinkButton ID="btnSubmitSurvey" runat="server" CssClass="btn gray_btn" OnClick="btnSubmitSurvey_Click">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, RateCompany %>" />
            </asp:LinkButton>
        </div>
    </div>

    <cc1:ModalPopupExtender ID="mdlExtAddConnection" runat="server"
        TargetControlID="btnAddConnection" BehaviorID="mdlExtAddConnection"
        PopupControlID="pnlAddReference" CancelControlID="LinkButton3"
        BackgroundCssClass="modalBackground" />

    <div style="display: none;">
        <asp:Button ID="btnCompanyNotFoundDummy" runat="server" Text="dummy" />
    </div>

    <cc1:ModalPopupExtender ID="mdlCompanyNotFound" runat="server"
        TargetControlID="btnCompanyNotFoundDummy" BehaviorID="mdlCompanyNotFound"
        PopupControlID="pnlCompanyNotFound" CancelControlID="btnCancel3" OnCancelScript="cancelCompanyNotFound()"
        BackgroundCssClass="modalBackground" />

    <div style="display: none;">
        <asp:Button ID="btnEditDummy" runat="server" Text="dummy" />
    </div>

    <cc1:ModalPopupExtender ID="mdlEditRelationship" runat="server"
        TargetControlID="btnEditDummy" BehaviorID="mdlEditRelationship"
        PopupControlID="pnlEditRelationship" CancelControlID="btnCancel4"
        BackgroundCssClass="modalBackground" />

    <asp:Panel ID="pnlAddReference" Style="display: none;" CssClass="Popup" runat="server" Width="550px">
        <div class="row nomargin_lr mar_top_5">
            <div class="col-md-4">
                <div class="clr_blu"><% =Resources.Global.CompanyName %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <asp:TextBox ID="txtCompany" runat="server" Width="90%" tsiRequired="true" tsiDisplayName="<%$ Resources:Global, CompanyName %>" CssClass="form-control"></asp:TextBox>
                <%= PageBase.GetRequiredFieldIndicator() %>

                <asp:HiddenField ID="hSelectedCompanyID" runat="server" />
                <cc1:AutoCompleteExtender ID="aceCompanyName" runat="server"
                    TargetControlID="txtCompany"
                    ServiceMethod="GetQuickFindCompletionListHQ"
                    ServicePath="AJAXHelper.asmx"
                    CompletionInterval="100"
                    MinimumPrefixLength="2"
                    CompletionSetCount="30"
                    CompletionListCssClass="AutoCompleteFlyout"
                    CompletionListItemCssClass="AutoCompleteFlyoutItem"
                    CompletionListHighlightedItemCssClass="AutoCompleteFlyoutHilightedItem"
                    CompletionListElementID="pnlAutoComplete"
                    OnClientItemSelected="CompanyNameSelected"
                    OnClientPopulated="acePopulated"
                    EnableCaching="True"
                    UseContextKey="True"
                    FirstRowSelected="true">
                </cc1:AutoCompleteExtender>

                <div id="pnlAutoComplete" style="z-index: 5000;">
                </div>
            </div>
        </div>
        <div class="row nomargin_lr mar_top_5">
            <div class="col-md-4">
                <div class="clr_blu"><% =Resources.Global.ConnectionType %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <asp:DropDownList ID="ddlConnTypeSearch" runat="server" CssClass="form-control" Width="90%" />
            </div>
        </div>

        <div class="row nomargin">
            <div class="col-md-12">
                <asp:LinkButton ID="LinkButton1" runat="server" CssClass="btn gray_btn" OnClick="btnSaveReference_Click" OnClientClick="handleAddReference();">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, AddConnection %>" />
                </asp:LinkButton>
                <asp:LinkButton ID="LinkButton2" runat="server" CssClass="btn gray_btn" OnClientClick="ShowCompanyNotFound();return false;">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, CompanyNotFound %>" />
                </asp:LinkButton>
                <asp:LinkButton ID="LinkButton3" runat="server" CssClass="btn gray_btn" OnClick="btnSubmitSurvey_Click">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
                </asp:LinkButton>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlCompanyNotFound" CssClass="Popup" runat="server" Width="750px" Height="100%" ScrollBars="Vertical" Style="display: none;">
        <div class="row nomargin">
            <div class="col-md-12 bold">
                <%= Resources.Global.AddManualConnText %>
            </div>
        </div>

        <div class="row nomargin_lr mar_top_10">
            <div class="col-md-4">
                <div class="clr_blu"><% =Resources.Global.CompanyName %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <asp:TextBox ID="txtCompanyNameManual" runat="server" Width="90%" tsiDisplayName="<%$ Resources:Global, CompanyName %>" CssClass="form-control"></asp:TextBox>
                <%= PageBase.GetRequiredFieldIndicator() %>
            </div>
        </div>
        <div class="row nomargin_lr mar_top_10">
            <div class="col-md-4">
                <div class="clr_blu"><% =Resources.Global.ContactName %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <asp:TextBox ID="txtContactNameManual" runat="server" Width="90%" tsiDisplayName="<%$ Resources:Global, ContactName %>" CssClass="form-control"></asp:TextBox>
                <%= PageBase.GetRequiredFieldIndicator() %>
            </div>
        </div>
        <div class="row nomargin_lr">
            <div class="col-md-4">
                <div class="clr_blu"><% =Resources.Global.AddressLine1 %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <asp:TextBox ID="txtMailStreet1" runat="server" Width="90%" CssClass="form-control" />
            </div>
        </div>
        <div class="row nomargin_lr">
            <div class="col-md-4">
                <div class="clr_blu"><% =Resources.Global.City %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <asp:TextBox ID="txtCityManual" runat="server" Width="90%" CssClass="form-control" />
            </div>
        </div>
        <div class="row nomargin_lr">
            <div class="col-md-4">
                <div class="clr_blu"><% =Resources.Global.Country %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <asp:DropDownList ID="ddlMailCountry" Width="90%" tsiDisplayName="<%$ Resources:Global, Country %>" runat="server" CssClass="form-control" />
                <%= PageBase.GetRequiredFieldIndicator() %>
            </div>
        </div>
        <div class="row nomargin_lr">
            <div class="col-md-4">
                <div class="clr_blu"><% =Resources.Global.State %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <asp:DropDownList ID="ddlMailState" Width="90%" tsiDisplayName="<%$ Resources:Global, State %>" runat="server" CssClass="form-control" />
                <%= PageBase.GetRequiredFieldIndicator() %>
                <cc1:CascadingDropDown ID="cddMailCountry" TargetControlID="ddlMailCountry" ServicePath="AJAXHelper.asmx" ServiceMethod="GetCountries" Category="Country" runat="server" />
                <cc1:CascadingDropDown ID="cddMailState" TargetControlID="ddlMailState" ServicePath="AJAXHelper.asmx" ServiceMethod="GetStates" Category="State" ParentControlID="ddlMailCountry" runat="server" />
            </div>
        </div>
        <div class="row nomargin_lr">
            <div class="col-md-4">
                <div class="clr_blu"><% =Resources.Global.PostalCode %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <asp:TextBox ID="txtMailPostal" runat="server" Columns="10" CssClass="form-control"/>
            </div>
        </div>
        <div class="row nomargin_lr">
            <div class="col-md-4">
                <div class="clr_blu"><% =Resources.Global.Phone2 %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <asp:TextBox ID="txtPhoneAreaCode" runat="server" Columns="5" tsiDisplayName="<%$ Resources:Global, PhoneAreaCode %>" CssClass="form-control"/>
                <asp:TextBox ID="txtPhone" runat="server" Columns="15" tsiDisplayName="<%$ Resources:Global, Phone2 %>" CssClass="form-control"/>
                <%= PageBase.GetRequiredFieldIndicator() %>
            </div>
        </div>
        <div class="row nomargin_lr">
            <div class="col-md-4">
                <div class="clr_blu"><% =Resources.Global.Fax2 %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <asp:TextBox ID="txtFaxAreaCode" runat="server" Columns="5" CssClass="form-control"/>
                <asp:TextBox ID="txtFax" runat="server" Columns="15" CssClass="form-control"/>
            </div>
        </div>
        <div class="row nomargin_lr">
            <div class="col-md-4">
                <div class="clr_blu"><% =Resources.Global.Email_Cap %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <asp:TextBox ID="txtEmail" runat="server" Width="90%" CssClass="form-control"/>
            </div>
        </div>
        <div class="row nomargin_lr">
            <div class="col-md-4">
                <div class="clr_blu"><% =Resources.Global.ConnectionType %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <asp:DropDownList ID="ddlConnTypeManual" Width="90%" runat="server" CssClass="form-control" />
            </div>
        </div>
        <div class="row nomargin_lr">
            <div class="col-md-2">
                <div class="clr_blu"><%=Resources.Global.TESGridIntegrityAbility %>:</div>
            </div>
            <div class="col-md-4 d-flex">
                <asp:RadioButtonList ID="rdLstIntegrity" CssClass="tight space notbold" runat="server" RepeatDirection="Vertical" RepeatColumns="1" />
            </div>
            <div class="col-md-2">
                <div class="clr_blu"><%=Resources.Global.PayPerformance %>:</div>
            </div>
            <div class="col-md-4 d-flex">
                <asp:RadioButtonList ID="rdLstPayPerformance" CssClass="tight space notbold" runat="server" RepeatDirection="Vertical" RepeatColumns="2" />
            </div>
        </div>
        <div class="row nomargin_lr">
            <div class="col-md-2">
                <div class="clr_blu"><%=Resources.Global.TESGridHighCredit %>:</div>
            </div>
            <div class="col-md-4 d-flex">
                <asp:RadioButtonList ID="rdLstHighCredit" runat="server" CssClass="tight space notbold" RepeatDirection="Vertical" RepeatColumns="2" />
            </div>
            <div class="col-md-2">
                <div class="clr_blu"><%=Resources.Global.TESGridLastDealt %>:</div>
            </div>
            <div class="col-md-4 d-flex">
                <asp:RadioButtonList ID="rdLstLastDealt" runat="server" CssClass="tight space notbold" RepeatDirection="Vertical" RepeatColumns="1" />
            </div>
        </div>
        <div class="row nomargin_lr">
            <div class="col-md-4">
                <div class="clr_blu"><%=Resources.Global.Comments %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <textarea id="txtAreaComments" runat="server" rows="4" class="form-control" style="width:100%"></textarea>
            </div>
        </div>

        <div class="row nomargin_lr mar_top">
            <div class="col-12">
                <asp:LinkButton ID="btnReport" runat="server" CssClass="btn gray_btn" OnClick="btnReport_Click">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Report %>" />
                </asp:LinkButton>

                <asp:LinkButton ID="btnCancel3" runat="server" CssClass="btn gray_btn">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
                </asp:LinkButton>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlEditRelationship" CssClass="Popup" runat="server" Width="600px" Style="display: none;">
        <div class="row nomargin_lr">
            <div class="col-md-4">
                <div class="clr_blu"><% =Resources.Global.RelatedCompany %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <asp:Label ID="txtCompanyName4" runat="server" />
                <asp:HiddenField ID="hRelatedCompanyID" runat="server" />
            </div>
        </div>
        <div class="row nomargin_lr">
            <div class="col-md-4">
                <div class="clr_blu"><% =Resources.Global.Relationship %>:</div>
            </div>
            <div class="col-md-8 d-flex">
                <asp:CheckBoxList ID="chkListRelationshipTypes" runat="server" CssClass="space" />
            </div>
        </div>

        <div class="row nomargin_lr mar_top">
            <asp:LinkButton ID="btnSave4" runat="server" CssClass="btn gray_btn" OnClick="btnSave_Click">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Save %>" />
            </asp:LinkButton>

            <asp:LinkButton ID="btnCancel4" runat="server" CssClass="btn gray_btn">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
            </asp:LinkButton>
        </div>
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
<!-- Modal END -->


    </span>
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        var isCompanyLookup = false;

        function CompanyNameSelected(source, eventArgs) {
            if (eventArgs.get_value() != null) {

                document.getElementById("<% =txtCompany.ClientID %>").value = eventArgs.get_text();
                    document.getElementById("<% =hSelectedCompanyID.ClientID %>").value = eventArgs.get_value();

                    if (document.getElementById("<% =txtCompany.ClientID %>").value == "") {
                        document.getElementById("<% =txtCompany.ClientID %>").value = eventArgs.get_item().firstChild.innerHTML;
                    }
            }
        }

        function ShowCompanyNotFound() {
            $find('mdlExtAddConnection').hide();
            $find('mdlCompanyNotFound').show();

            document.getElementById('<% =txtCompany.ClientID %>').removeAttribute("tsiRequired");
            document.getElementById('<% =txtCompanyNameManual.ClientID %>').setAttribute("tsiRequired", "true");
            document.getElementById('<% =txtContactNameManual.ClientID %>').setAttribute("tsiRequired", "true");
            document.getElementById('<% =ddlMailState.ClientID %>').setAttribute("tsiRequired", "true");
            document.getElementById('<% =txtPhoneAreaCode.ClientID %>').setAttribute("tsiRequired", "true");
            document.getElementById('<% =txtPhone.ClientID %>').setAttribute("tsiRequired", "true");
            
            isCompanyLookup = false;
        }

        function handleAddReference() {
            isCompanyLookup = true;
            document.getElementById('<% =txtCompanyNameManual.ClientID %>').removeAttribute("tsiRequired");
            document.getElementById('<% =txtContactNameManual.ClientID %>').removeAttribute("tsiRequired");
            document.getElementById('<% =ddlMailState.ClientID %>').removeAttribute("tsiRequired");
            document.getElementById('<% =txtPhoneAreaCode.ClientID %>').removeAttribute("tsiRequired");
            document.getElementById('<% =txtPhone.ClientID %>').removeAttribute("tsiRequired");
        }

        function cancelCompanyNotFound() {
            document.getElementById('<% =txtCompanyNameManual.ClientID %>').removeAttribute("tsiRequired");
            document.getElementById('<% =txtContactNameManual.ClientID %>').removeAttribute("tsiRequired");
            document.getElementById('<% =ddlMailState.ClientID %>').removeAttribute("tsiRequired");
            document.getElementById('<% =txtPhoneAreaCode.ClientID %>').removeAttribute("tsiRequired");
            document.getElementById('<% =txtPhone.ClientID %>').removeAttribute("tsiRequired");
        }

        function editRelationshipTypes(companyName, companyID, relationshipTypes) {
            document.getElementById('<% =txtCompanyName4.ClientID %>').innerHTML = companyName;
            document.getElementById('<% =hRelatedCompanyID.ClientID %>').value = companyID;


            var relTypes = relationshipTypes.split(",");

            var controlName = "chkListRelationshipTypes"
            var oCheckboxes = document.body.getElementsByTagName("INPUT");
            for (var j = 0; j < oCheckboxes.length; j++) {
                if (oCheckboxes[j].id.indexOf(controlName) >= 0) {
                    oCheckboxes[j].checked = false;
                }
            }

            for (var i = 0; i < relTypes.length; i++) {
                for (var j = 0; j < oCheckboxes.length; j++) {
                    if ((oCheckboxes[j].id.indexOf(controlName) >= 0) &&
                        (oCheckboxes[j].value == relTypes[i].trim())) {
                        oCheckboxes[j].checked = true;
                    }
                }
            }

            $find('mdlEditRelationship').show();
        }

        function preStdValidation(form) {
            if (!isCompanyLookup) {
                document.getElementById('<% =txtCompany.ClientID %>').removeAttribute("tsiRequired");

                var country = document.getElementById('<% =ddlMailCountry.ClientID %>').options[document.getElementById('<% =ddlMailCountry.ClientID %>').selectedIndex].value;
                if (country >= 4) {
                    var state = document.getElementById('<% =ddlMailState.ClientID %>');
                    state.removeAttribute("tsiRequired");
                }
            }

            return true;
        }

        function postStdValidation(form) {
            if (isCompanyLookup) {
                if (document.getElementById('<% =hSelectedCompanyID.ClientID %>').value == "") {
                    displayErrorMessage("Please select a company from the list.");
                    return false;
                }
            }
            return true;
        }

        function ShowTESPopup() {
            Sys.Application.add_load(function () {
                var obj = $find("mpeTESSurvey");
                if(obj != null)
                    obj.show();
            });
        }
    </script>
</asp:Content>