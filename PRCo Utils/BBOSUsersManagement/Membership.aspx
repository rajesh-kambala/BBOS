<%@ Page Language="C#" MasterPageFile="~/BBOSUsers.Master" AutoEventWireup="true" CodeBehind="Membership.aspx.cs" Inherits="PRCo.BBOS.UI.Web.UserManagement.Membership" Title="Untitled Page" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web.UserManagement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

	<p>
	<asp:Literal ID=litMembershipMsg runat=server />
	</p>

<table width=100%>
<tr>
	<td colspan=4 align=center class=colHeader>Membership Packages</td>
</tr>
    <asp:Repeater ID=repMemberships runat=server>
    <ItemTemplate>
        <!-- <%# IncrementRepeaterCount()  %>-->
        <%# GetBeginSeparator(_iRepeaterCount, 2, "50%")%>
            <b><label for=rbMembership<%# _iRepeaterCount %>><%# Eval("prod_Name") %></label>: <%# UIUtils.GetFormattedCurrency((decimal)Eval("pric_Price")) %>  Annually</b><br />
            <%# Eval("prod_PRDescription")%>
        <%# GetEndSeparator(_iRepeaterCount, 2)%>			        
    </ItemTemplate>
    </asp:Repeater>
    <% =GetCompleteSeparator(_iRepeaterCount, 2)%>
</table>

<p></p>


<table width=100%>
<tr>
	<td colspan=4 align=center class=colHeader>Additional Licenses</td>
</tr>
    <asp:Repeater ID=repAdditionalLicenses runat=server>
    <ItemTemplate>
        <!-- <%# IncrementRepeaterCount()  %>-->
        <%# GetBeginSeparator(_iRepeaterCount, 2, "50%")%>
            <b><label for=rbMembership<%# _iRepeaterCount %>><%# Eval("prod_Name") %></label>: <%# UIUtils.GetFormattedCurrency((decimal)Eval("pric_Price")) %> Annually</b><br />
            <%# Eval("prod_PRDescription")%>
        <%# GetEndSeparator(_iRepeaterCount, 2)%>			        
    </ItemTemplate>
    </asp:Repeater>
    <% =GetCompleteSeparator(_iRepeaterCount, 2)%>
</table>

<p></p>
    <div style="height:33px;text-align:center;">
    <asp:HyperLink ID="HyperLink2" Text="Done" NavigateUrl="PersonList.aspx" CssClass=btn-round runat=server />
    </div>

</asp:Content>
