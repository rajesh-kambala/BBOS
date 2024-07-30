<%@ Page Title="" Language="C#" MasterPageFile="~/BBSI.master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="BBOSMobileSales.Default" %>
<%@ Register Src="~/UserControls/RecentCompanies.ascx" TagName="RecentCompanies" TagPrefix="BBOS" %>
<%@ Register Src="~/UserControls/QuickFind.ascx" TagName="QuickFind" TagPrefix="BBOS" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content1" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Content2" runat="server">
    <div class="row mt-3">
        <div class="col-12 dataItem">
            <BBOS:QuickFind ID="ucQuickFind" EnableViewState="false" runat="server" />
        </div>    
    </div>

    <div class="row mb-3">
        <div class="col-12 text-center">
            <a class="btn btn-sm btn-bbsi" href="CompanySearch.aspx">Advanced Search</a>
        </div>
    </div>

    <BBOS:RecentCompanies id="ucRecentCompanies" runat="server" />
</asp:Content>