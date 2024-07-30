<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CompanySearchCriteriaControl.ascx.cs" Inherits="PRCo.BBOS.UI.Web.CompanySearchCriteriaControl" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<div class="row nomargin" id="pnlCriteria" runat="server">
    <div class="panel panel-primary">
        <div class="panel-heading">
            <h4 class="blu_tab">
                <asp:Panel ID="pnlExpander" runat="server" Visible="false">
                    <i id="imgCriteria" class="more-less glyphicon glyphicon-minus" onclick="Toggle('Criteria');"></i>
                </asp:Panel>
                <%=Resources.Global.SelectedCriteria %>
            </h4>
        </div>
        <div class="row panel-body nomargin">
            <div class="col-md-12 mar_bot" id="Criteria">
                <asp:Label class="Search_Criteria" ID="lblSearchCriteria" runat="server" />
            </div>
        </div>
    </div>
</div>