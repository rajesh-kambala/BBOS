<%@ Page Title="" Language="C#" MasterPageFile="~/Produce.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PublicProfiles.Index" %>

<asp:Content ID="Content2" ContentPlaceHolderID="BBOSPublicProfilesMain" runat="server">
<script type="text/javascript">
    if (!inIframe()) {
        var expiredate = new Date();
        expiredate.setDate(expiredate.getDate() + 1);
        document.cookie = "ndx=" + vars['ndx'] + ";path=/;expires=" + expiredate.toUTCString();

        if (document.location.hostname != "localhost") {
            window.location.href = "<% =GetMarketingSiteURL() %>/find-companies/company-directory/";
        }
    }
</script>
    
    <p>The purpose of this page is to provide all listed companies in the Blue Book Services database extra exposure and 
    branding via search engines. If you have come to this page for a specific company or a list of companies and you are a Blue Book Member, please <asp:HyperLink ID="hlLogin" runat="server" Text="sign into Blue Book Online Services"  Target="_top" /> 
 (BBOS) for more comprehensive information and search capabilities.</p>

    
    <div style="height:450px;overflow-y: scroll;">
    <asp:Repeater ID="repCompanies" runat="server">
        <HeaderTemplate>
            <table style="width:100%">
        </HeaderTemplate>
        <ItemTemplate>
            <%# IncrementRepeaterCount() %>
		    <%# GetBeginSeparator(_iRepeaterCount, 3, "33%") %>
                <a href="<%# GetMarketingSiteURL() %>/find-companies/company-profile/?ID=<%# (int)Eval("comp_CompanyID") %>" target="_top"><%# Eval("comp_PRCorrTradestyle")%></a>
            <%# GetEndSeparator(_iRepeaterCount, 3) %>	    
    </ItemTemplate>
    <FooterTemplate>
        </table>
    </FooterTemplate>
    </asp:Repeater>
    </div>

    <p>For those seeking more information about Blue Book membership, please contact us.  Our representatives will be happy to help determine how a Blue Book Services membership can best be used to expand and support any business.</p>

</asp:Content>
