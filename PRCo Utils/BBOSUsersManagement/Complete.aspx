<%@ Page Language="C#" MasterPageFile="~/BBOSUsers.Master" AutoEventWireup="true" CodeBehind="Complete.aspx.cs" Inherits="PRCo.BBOS.UI.Web.UserManagement.Complete" Title="Untitled Page" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    Thank you for taking the time to manage your organization's membership, configuring who at your organization is flagged to receive a BBOS license when it is launched (second quarter 2008). It may take a few days for these changes to be applied. If you have any questions, please contact Blue Book Services at <a href="mailto:customerservice@bluebookprco.com">customerservice@bluebookprco.com</a> or 630 668-3500.
	<em>
	<p></p>Note: No changes made via this utility will be reflected in your published Blue Book listing. If you wish to also have any changes applied to your Blue Book listing, please contact Blue Book Services at <a href="mailto:listing@bluebookprco.com">listing@bluebookprco.com</a> or 630-668-3500. 
	</em>
	
	<p></p>
    <div style="height:33px;text-align:center;">
        <asp:HyperLink ID=btnSave Text="Blue Book Services" NavigateUrl="http://www.bluebookprco.com" CssClass=btn-round  runat=server />
    </div>    
	
	
</asp:Content>
