<%@ Page Title="" Language="C#" MasterPageFile="~/Produce.Master" AutoEventWireup="true" CodeBehind="BORComplete.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PublicProfiles.BORComplete" EnableEventValidation="false" %>

<%@ Register TagPrefix="uc" TagName="MembershipHeader" Src="~/Controls/MembershipHeader.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="BBOSPublicProfilesHead" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="BBOSPublicProfilesMain" runat="server">
    <script type="text/javascript">
        var url = '<% =URL()%>';
        if(url.length>0)
            top.location.href = url;
    </script>
</asp:Content>