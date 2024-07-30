<%@ Page Language="C#" MasterPageFile="~/BBOSUsers.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="PRCo.BBOS.UI.Web.UserManagement.Login" Title="Untitled Page" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
      <asp:Label ID=lblLoginCount Visible=false runat=server />
        
Blue Book Online Services (BBOS) will be available in early 2008.  BBOS succeeds the Electronic Blue Book (EBB) as a new web-based platform.  This comprehensive business tool will provide you with new features, utilities, analytics and content that will truly empower your organization.

<p>Use this page to login to the BBOS Access Management Tool and assign BBOS login information to the associates at your company.

<p>Reviewing this information today, assures a smooth transition and uninterrupted access to Blue Book information.
        
    <p>    
      <table width="240" border="0" cellpadding="0" cellspacing="0" align=center>
        <tr>
          <td class=label>BB #:</td>
          <td align="center"><asp:TextBox ID=txtUserID tsiRequired="true" tsiDisplayName="BB #" tsiInteger=true runat=server /></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td colspan="3"><img src="images/spacer.gif" alt="" name="spacer3" width="10" height="10" /></td>
          </tr>
        <tr>
          <td class=label>Password:</td>
          <td align="center"><asp:TextBox ID=txtPassword  TextMode=Password runat=server tsiRequired=true tsiDisplayName="Password" /></td>
          <td><asp:ImageButton ID=btnLogin OnClick="btnLoginOnClick" ImageUrl="images/btn-redArrow.gif" runat=server /></td>
        </tr>
      </table>

</asp:Content>