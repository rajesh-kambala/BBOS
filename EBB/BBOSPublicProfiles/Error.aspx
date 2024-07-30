<%@ Page Title="" Language="C#" MasterPageFile="~/Produce.Master" AutoEventWireup="true" CodeBehind="Error.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PublicProfiles.Error" %>
<asp:Content ID="Content1" ContentPlaceHolderID="BBOSPublicProfilesHead" runat="server">
<style>
	.errorHeader{border-right-style:solid;
			 border-bottom-style:solid;
			 border-width:thin;
			 border-color:#C0C0C0;
			 padding:2pt;
			 font-weight:bold;
			 background-color:#E0E0E0;}

.errorMessage{border-right-style:solid;
			 border-bottom-style:solid;
			 border-width:thin;
			 border-color:#C0C0C0;
			 padding:2pt;}
    

</style>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="BBOSPublicProfilesMain" runat="server">
<asp:Literal ID="litErrorMsg" runat="server" />
</asp:Content>
