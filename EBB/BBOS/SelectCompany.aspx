<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SelectCompany.aspx.cs"
    Inherits="PRCo.BBOS.UI.Web.SelectCompany" MasterPageFile="~/BBOS.Master" EnableEventValidation="false" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function CompanyNameSelected(source, eventArgs) {
            if (eventArgs.get_value() != null) {
                document.getElementById('<% =aceSelectedID.ClientID %>').value = eventArgs.get_value();
                document.getElementById('<% =btnACESelect.ClientID %>').click()
            }
        }
    </script>
    <style>
    .content-container div.row a.gray_btn {
        display: inline;
        width: auto;
        margin-right: 10px;
        margin-bottom: 20px;
    }
    .col-md-5 {
        text-align: right;
    }
    sup {
        top: 5px;
    }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="contentMain" runat="server">
    <div style="text-align: left;">
        <asp:HiddenField ID="ReturnURL" runat="server" />
        <asp:HiddenField ID="aceSelectedID" runat="server" />

        <div class="row nomargin">
            <div class="col-md-8 nopadding ind_typ gray_bg blacktext">
                <div class="row nomargin_lr">
                    <div class="col-md-5 text-nowrap clr_blu">
                        <a id="popBBNumber" runat="server" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                            <img src="images/info_sm.png" />
                        </a>
                        <%= Resources.Global.BBNumber %>:
                    </div>
                    <div class="col-md-7">
                        <asp:TextBox ID="txtBBNum" runat="server" MaxLength="8" CssClass="form-control numbersOnly" />
                        <cc1:FilteredTextBoxExtender ID="ftbeBBID" runat="server" TargetControlID="txtBBNum" FilterType="Numbers" />
                    </div>
                </div>
                <div class="row nomargin_lr">
                    <asp:Label CssClass="clr_blu col-md-5" for="<%= txtCompanyName.ClientID%>" runat="server"><%= Resources.Global.CompanyName %>:</asp:Label>
                    <div class="col-md-7">
                        <asp:TextBox ID="txtCompanyName" runat="server" CssClass="form-control" Columns="40" MaxLength="104" autocomplete="off" />
                    </div>

                    <cc1:AutoCompleteExtender ID="aceCompanyName" runat="server"
                        TargetControlID="txtCompanyName"
                        ServiceMethod="GetQuickFindCompletionList"
                        ServicePath="AJAXHelper.asmx"
                        CompletionInterval="100"
                        MinimumPrefixLength="2"
                        CompletionSetCount="30"
                        CompletionListCssClass="AutoCompleteFlyout"
                        CompletionListItemCssClass="AutoCompleteFlyoutItem"
                        CompletionListHighlightedItemCssClass="AutoCompleteFlyoutHilightedItem"
                        OnClientItemSelected="CompanyNameSelected"
                        OnClientPopulated="acePopulated"
                        CompletionListElementID="pnlAutoComplete"
                        EnableCaching="True"
                        UseContextKey="False"
                        FirstRowSelected="true">
                    </cc1:AutoCompleteExtender>
                    
                    <div style="display: none;">
                        <asp:Button ID="btnACESelect" OnClick="btnSelect_Click" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="row nomargin_lr">
                    <asp:Label CssClass="clr_blu col-md-5" for="<%= txtCompanyName.ClientID%>" runat="server"><%= Resources.Global.City %>:</asp:Label>
                    <div class="col-md-7">
                        <asp:TextBox ID="txtCity" runat="server" CssClass="form-control" Columns="30" MaxLength="104" autocomplete="off" />
                    </div>
                </div>
                <div class="row nomargin_lr">
                    <asp:Label CssClass="clr_blu col-md-5" for="<%= txtCompanyName.ClientID%>" runat="server"><%= Resources.Global.Country %>:</asp:Label>
                    <div class="col-md-7">
                        <asp:DropDownList ID="ddlCountry" runat="server" CssClass="form-control" />
                        <cc1:CascadingDropDown ID="cddCountry" TargetControlID="ddlCountry" ServicePath="AJAXHelper.asmx" ServiceMethod="GetCountries" Category="Country" runat="server" />
                    </div>
                </div>
                <div class="row nomargin_lr">
                    <asp:Label CssClass="clr_blu col-md-5" for="<%= txtCompanyName.ClientID%>" runat="server"><%= Resources.Global.State %>:</asp:Label>
                    <div class="col-md-7">
                        <asp:DropDownList ID="ddlState" runat="server" CssClass="form-control" />
                        <cc1:CascadingDropDown ID="cddState" TargetControlID="ddlState" ServicePath="AJAXHelper.asmx" ServiceMethod="GetStates" Category="State" ParentControlID="ddlCountry" runat="server" />
                    </div>
                </div>
            </div>
            <div id="pnlAutoComplete" style="z-index: 5000;"></div>
        </div>

        <div class="row nomargin text-left mar_top">
            <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn gray_btn" OnClick="btnSearch_Click">
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Search %>" />
            </asp:LinkButton>
            <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancel_Click">
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
            </asp:LinkButton>
        </div>
        <asp:Panel ID="pnlSearchResults" runat="server" Visible="false">
            <div class="row nomargin panels_box">
                <div class="col-md-10">
                    <%--Record Count--%>
                    <div class="row mar_top nomargin_lr text-left">
                        <div class="col-md-4 bold">
                            <asp:Label ID="lblRecordCount" runat="server" class="RecordCnt" />
                        </div>
                    </div>

                    <div class="table-responsive">
                        <asp:GridView ID="gvSearchResults"
                            AllowSorting="true"
                            runat="server"
                            AutoGenerateColumns="false"
                            CssClass="sch_result table table-striped table-hover"
                            GridLines="none"
                            OnSorting="GridView_Sorting"
                            OnRowDataBound="GridView_RowDataBound"
                            SortField="comp_PRBookTradestyle">

                            <Columns>
                                <asp:TemplateField ItemStyle-CssClass="text-center vertical-align-top" HeaderStyle-CssClass="text-center vertical-align-top">
                                    <HeaderTemplate>
                                        <asp:Literal runat="server" Text="<%$ Resources:Global, Select%>" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <input type="radio" name="rbCompanyID" value="<%# Eval("comp_CompanyID") %>" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <%--BBNumber Column--%>
                                <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="text-nowrap vertical-align-top"
                                    DataField="comp_CompanyID" SortExpression="comp_CompanyID" />

                                <%--Icons Column--%>
                                <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
                                    <ItemTemplate>
                                        <%# GetCompanyDataForCell((int)Eval("comp_CompanyID"), 
                                                (string)Eval("comp_PRBookTradestyle"), 
                                                (string)Eval("comp_PRLegalName"), 
                                                UIUtils.GetBool(Eval("HasNote")), 
                                                UIUtils.GetDateTime(Eval("comp_PRLastPublishedCSDate")), 
                                                (string)Eval("comp_PRListingStatus"), 
                                                true, 
                                                UIUtils.GetBool(Eval("HasNewClaimActivity")), 
                                                UIUtils.GetBool(Eval("HasMeritoriousClaim")), 
                                                UIUtils.GetBool(Eval("HasCertification")), 
                                                UIUtils.GetBool(Eval("HasCertification_Organic")), 
                                                UIUtils.GetBool(Eval("HasCertification_FoodSafety")), 
                                                true, 
                                                false)%>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <%--Company Name column--%>
                                <asp:TemplateField HeaderText="<%$ Resources:Global, CompanyName %>" HeaderStyle-CssClass="vertical-align-top" SortExpression="comp_PRBookTradestyle">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <%--Location Column--%>
                                <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left"
                                    DataField="CityStateCountryShort" SortExpression="CityStateCountryShort" />

                                <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-left vertical-align-top">
                                    <HeaderTemplate>
                                        <%# PageControlBaseCommon.GetIndustryTypeHeader(_oUser) %>
                                    </HeaderTemplate>

                                    <ItemTemplate>
                                        <%# PageControlBaseCommon.GetIndustryTypeData((string)Eval("CompanyType"), (string)Eval("IndustryType"), Eval("comp_PRLocalSource"), _oUser)%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                    <div class="row nomargin text-left mar_top">
                        <asp:LinkButton ID="btnSelect" runat="server" CssClass="btn gray_btn" OnClick="btnSelect_Click">
		                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Select %>" />
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnCancel2" runat="server" CssClass="btn gray_btn" OnClick="btnCancel_Click">
		                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
                        </asp:LinkButton>
                    </div>
                </div>
            </div>
            <div class="row mar_top">
                <div class="col-md-12">
                    <%= Resources.Global.IfUnableToFindPleaseFillOutForm %> 
                </div>
            </div>

            <div class="row nomargin_lr mar_top">
                <div class="col-md-12 nopadding ind_typ gray_bg blacktext">
                    <div class="row nomargin_lr">
                        <div class="col-md-3 text-nowrap clr_blu">
                            <%= Resources.Global.CompanyName %>:
                        </div>
                        <div class="col-md-6 form-inline">
                            <asp:TextBox ID="txtCompanyNameManual" runat="server" tsiRequired="true" Width="95%" CssClass="form-control float-left" tsiDisplayName="<%$ Resources:Global, CompanyName %>" />
                            <%= PageBase.GetRequiredFieldIndicator() %>
                        </div>
                    </div>
                    <div class="row nomargin_lr">
                        <div class="col-md-3 text-nowrap clr_blu">
                            <%= Resources.Global.AddressLine1 %>:
                        </div>
                        <div class="col-md-6 form-inline">
                            <asp:TextBox ID="txtMailStreet1" runat="server" Width="100%" CssClass="form-control" />
                        </div>
                    </div>
                    <div class="row nomargin_lr">
                        <div class="col-md-3 text-nowrap clr_blu">
                            <%= Resources.Global.AddressLine1 %>:
                        </div>
                        <div class="col-md-6 form-inline">
                            <asp:TextBox ID="TextBox1" runat="server" Width="100%" CssClass="form-control" />
                        </div>
                    </div>
                    <div class="row nomargin_lr">
                        <div class="col-md-3 text-nowrap clr_blu">
                            <%= Resources.Global.AddressLine2 %>:
                        </div>
                        <div class="col-md-6 form-inline">
                            <asp:TextBox ID="txtMailStreet2" runat="server" Width="100%" CssClass="form-control" />
                        </div>
                    </div>
                    <div class="row nomargin_lr">
                        <div class="col-md-3 text-nowrap clr_blu">
                            <%= Resources.Global.AddressLine3 %>:
                        </div>
                        <div class="col-md-6 form-inline">
                            <asp:TextBox ID="txtMailStreet3" runat="server" Width="100%" CssClass="form-control" />
                        </div>
                    </div>
                    <div class="row nomargin_lr">
                        <div class="col-md-3 text-nowrap clr_blu">
                            <%= Resources.Global.AddressLine4 %>:
                        </div>
                        <div class="col-md-6 form-inline">
                            <asp:TextBox ID="txtMailStreet4" runat="server" Width="100%" CssClass="form-control" />
                        </div>
                    </div>
                    <div class="row nomargin_lr">
                        <div class="col-md-3 text-nowrap clr_blu">
                            <%= Resources.Global.City %>:
                        </div>
                        <div class="col-md-6 form-inline">
                            <asp:TextBox ID="txtCityManual" runat="server" Width="100%" CssClass="form-control" />
                        </div>
                    </div>
                    <div class="row nomargin_lr">
                        <div class="col-md-3 text-nowrap clr_blu">
                            <%= Resources.Global.Country %>:
                        </div>
                        <div class="col-md-6 form-inline">
                            <asp:DropDownList ID="ddlMailCountry" Width="250" tsiRequired="true" CssClass="form-control float-left" tsiDisplayName="<%$ Resources:Global, Country %>" runat="server" />
                            <%= PageBase.GetRequiredFieldIndicator() %>
                        </div>
                    </div>
                    <div class="row nomargin_lr">
                        <div class="col-md-3 text-nowrap clr_blu">
                            <%= Resources.Global.State %>:
                        </div>
                        <div class="col-md-6 form-inline">
                            <asp:DropDownList ID="ddlMailState" Width="250" tsiRequired="true" CssClass="form-control float-left" tsiDisplayName="<%$ Resources:Global, State %>" runat="server" />
                            <%= PageBase.GetRequiredFieldIndicator() %>

                            <cc1:CascadingDropDown ID="cddMailCountry" TargetControlID="ddlMailCountry" ServicePath="AJAXHelper.asmx" ServiceMethod="GetCountries" Category="Country" runat="server" />
                            <cc1:CascadingDropDown ID="cddMailState" TargetControlID="ddlMailState" ServicePath="AJAXHelper.asmx" ServiceMethod="GetStates" Category="State" ParentControlID="ddlMailCountry" runat="server" />
                        </div>
                    </div>
                    <div class="row nomargin_lr">
                        <div class="col-md-3 text-nowrap clr_blu">
                            <%= Resources.Global.PostalCode %>:
                        </div>
                        <div class="col-md-6 form-inline">
                            <asp:TextBox ID="txtMailPostal" runat="server" Columns="10" CssClass="form-control" />
                        </div>
                    </div>
                    <div class="row nomargin_lr">
                        <div class="col-md-3 text-nowrap clr_blu">
                            <%= Resources.Global.ContactName %>:
                        </div>
                        <div class="col-md-6 form-inline">
                            <asp:TextBox ID="txtContact" runat="server" Columns="30" CssClass="form-control" />
                        </div>
                    </div>
                    <div class="row nomargin_lr">
                        <div class="col-md-3 text-nowrap clr_blu">
                            <%= Resources.Global.Phone2 %>: 
                        </div>
                        <div class="col-md-6 form-inline">
                            <asp:TextBox ID="txtPhoneAreaCode" runat="server" Columns="5" CssClass="form-control" />
                            <asp:TextBox ID="txtPhone" runat="server" Columns="15" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="row nomargin_lr">
                        <div class="col-md-3 text-nowrap clr_blu">
                            <%= Resources.Global.Fax2 %>: 
                        </div>
                        <div class="col-md-6 form-inline">
                            <asp:TextBox ID="txtFaxAreaCode" runat="server" Columns="5" CssClass="form-control" />
                            <asp:TextBox ID="txtFax" runat="server" Columns="15" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="row nomargin_lr">
                        <div class="col-md-3 text-nowrap clr_blu">
                            <%= Resources.Global.EmailAddress %>: 
                        </div>
                        <div class="col-md-6 form-inline">
                            <asp:TextBox ID="txtEmailAddress" runat="server" Columns="30" CssClass="form-control" />
                        </div>
                    </div>
                    <div class="row nomargin_lr">
                        <div class="col-md-12">
                            <asp:LinkButton ID="btnSubmit" runat="server" CssClass="btn gray_btn" OnClick="btnSubmit_Click">
		                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Select %>" />
                            </asp:LinkButton>

                            <asp:LinkButton ID="btnCancel3" runat="server" CssClass="btn gray_btn" OnClick="btnCancel_Click">
		                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
</script>
</asp:Content>
