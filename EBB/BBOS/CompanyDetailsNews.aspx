<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyDetailsNews.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyDetailsNews" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls\CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="NewsArticles" Src="UserControls/NewsArticles.ascx" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        var imgRead = '<% =UIUtils.GetImageURL("read.png") %>';
    </script>
    <style>
        img {
            display: inline;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box">
        <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
    
        <div class="row nomargin">
            <div class="col-lg-5 col-md-5 col-sm-12 nopadding_l">
                <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" />
            </div>
        </div>

        <div class="col-xs-12 nopadding">	            <bbos:NewsArticles ID="ucNewsArticles" runat="server" Visible="true" DisplayAbstract="false" />        </div>
    </div>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>
