<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanySearchService.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanySearchService" %>

<%@ Register Src="UserControls/CompanySearchCriteriaControl.ascx" TagName="CompanySearchCriteriaControl" TagPrefix="bbos" %>
<%@ Register Src="UserControls/CheckBoxPanel.ascx" TagName="CheckBoxPanel" TagPrefix="bbos" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Panel ID="pnlSearch" DefaultButton="btnSearch" runat="server">
        <div class="row nomargin panels_box">
            <div class="col-md-3 col-sm-3 col-xs-12 nopadding">
                <%--Search Criteria--%>
                <div class="col-md-12 nopadding">
                    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                        <ContentTemplate>
                            <bbos:CompanySearchCriteriaControl ID="ucCompanySearchCriteriaControl" runat="server" />
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="rblSearchType" EventName="SelectedIndexChanged" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>

                <%--Buttons--%>
                <div class="col-md-12 nopadding">
                    <div class="search_crit">
                        <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn gray_btn" OnClick="btnSearch_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Search %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnClearCriteria" runat="server" CssClass="btn gray_btn" OnClick="btnClearCriteria_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ClearThisCriteria %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnClearAllCriteria" runat="server" CssClass="btn gray_btn" OnClick="btnClearAllCriteria_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ClearAllCriteria %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnSaveSearch" runat="server" CssClass="btn gray_btn" OnClick="btnSaveSearch_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, SaveSearchCriteria %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnLoadSearch" runat="server" CssClass="btn gray_btn" OnClientClick="return confirmOverrwrite('LoadSearch')" OnClick="btnLoadSearch_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, LoadSearchCriteria %>" />
                        </asp:LinkButton>
                    </div>
                </div>
            </div>

            <div class="col-md-9 col-sm-8 col-xs-12 mar_top_15">
                <%--Service Search Type--%>
                <div class="row nomargin ind_typ">
                    <div class="col-md-12">
                        <div style="text-left">
                            <asp:Label ID="lblSearchType" runat="server"><%= Resources.Global.ServiceSearchTypeText %>:</asp:Label>
                            <br />
                            <asp:RadioButtonList ID="rblSearchType" runat="server" RepeatLayout="Table" RepeatDirection="Horizontal" AutoPostBack="True" />
                        </div>
                    </div>
                </div>

                <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                    <ContentTemplate>
                        <div class="clearfix"></div>

                        <div class="panel-group" id="accordion">
                            <asp:PlaceHolder ID="phServiceProvided" runat="server" Visible="true" />
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
    </asp:Panel>

    <div class="row">
        <p>
            <% =GetSearchButtonMsg() %>
        </p>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript" src="en-us/javascript/toggleFunctions.min.js"></script>

    <script type="text/javascript">
        function toggleTable(checkboxID, tableID) {
            var eCheckbox = document.getElementById(checkboxID);
            var eTable = document.getElementById(tableID);

            if (eCheckbox == null || eTable == null)
                return;

            var rows = eTable.rows;

            for (i = 0; i < rows.length; i++) {
                var row = rows[i];

                var cells = row.cells;
                for (j = 0; j < cells.length; j++) {

                    var controls = cells[j].childNodes;
                    for (k = 0; k < controls.length; k++) {
                        var checkbox = controls[k];
                        checkbox.disabled = eCheckbox.checked;
                        if (eCheckbox.checked) {
                            checkbox.checked = false;
                        }
                    }
                }
            }
        }

        btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');
    </script>
</asp:Content>
