<%@ Page Title="" Language="C#" MasterPageFile="~/Produce.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PublicProfiles.Default" %>
<asp:Content ID="Content1" ContentPlaceHolderID="BBOSPublicProfilesHead" runat="server">
<style type="text/css">
.index {text-align:center;
        width:25px;}
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="BBOSPublicProfilesMain" runat="server">
<h1>Company Directory</h1>
<p>The purpose of this page is to provide all listed companies in the Blue Book Services database extra exposure and branding 
via search engines.  We have intentionally published this comprehensive list so customers can promote their businesses.  As 
the <asp:Literal ID="industrytype" runat="server" /> industry’s premier credit and marketing agency, Blue Book Services is committed to providing new tools to help 
customers succeed; this specific method may increase online visibility.</p>
 
<p>Only publicly available information like address and phone number are included in the condensed Blue Book listings.  
All other information will continue to be shielded by password protection and guided by our <asp:HyperLink ID="hlPrivacyPolicy" runat="server" Text="Privacy Policy" NavigateUrl="/privacy-policy/" Target="_top" />.</p>

<p>If you have come to this page for a specific company or a list of companies and you are a Blue Book Member, please <asp:HyperLink ID="hlLogin" runat="server" Text="sign into Blue Book Online Services" Target="_top" /> 
 (BBOS) for more comprehensive information and search capabilities.</p>

  
<table style="margin-left:auto;margin-right:auto;margin-top:25px;margin-bottom:25px">
<tr><td colspan="26"><strong>Blue Book Listings:</strong></td></tr>
<tr>
<td class="index"><a href="Index.aspx?ndx=1">A</a></td>  <td class="index"><a href="Index.aspx?ndx=2">B</a></td>  
<td class="index"><a href="Index.aspx?ndx=3">C</a></td>  <td class="index"><a href="Index.aspx?ndx=4">D</a></td>  
<td class="index"><a href="Index.aspx?ndx=5">E</a></td>  <td class="index"><a href="Index.aspx?ndx=6">F</a></td>  
<td class="index"><a href="Index.aspx?ndx=7">G</a></td>  <td class="index"><a href="Index.aspx?ndx=8">H</a></td>  
<td class="index"><a href="Index.aspx?ndx=9">I</a></td>  <td class="index"><a href="Index.aspx?ndx=10">J</a></td>
<td class="index"><a href="Index.aspx?ndx=11">K</a></td><td class="index"><a href="Index.aspx?ndx=12">L</a></td>
<td class="index"><a href="Index.aspx?ndx=13">M</a></td><td class="index"><a href="Index.aspx?ndx=14">N</a></td>
<td class="index"><a href="Index.aspx?ndx=15">O</a></td><td class="index"><a href="Index.aspx?ndx=16">P</a></td>
<td class="index"><a href="Index.aspx?ndx=17">Q</a></td><td class="index"><a href="Index.aspx?ndx=18">R</a></td>
<td class="index"><a href="Index.aspx?ndx=19">S</a></td><td class="index"><a href="Index.aspx?ndx=20">T</a></td>
<td class="index"><a href="Index.aspx?ndx=21">U</a></td><td class="index"><a href="Index.aspx?ndx=22">V</a></td>
<td class="index"><a href="Index.aspx?ndx=23">W</a></td><td class="index"><a href="Index.aspx?ndx=24">X</a></td>
<td class="index"><a href="Index.aspx?ndx=25">Y</a></td><td class="index"><a href="Index.aspx?ndx=26">Z</a></td>
<td class="index"><a href="Index.aspx?ndx=27">Other</a></td>
</tr></table>

<p>For those seeking more information about Blue Book membership, please contact us.  Our representatives will be happy to help determine how a Blue Book Services membership can best be used to expand and support any business.</p>

</asp:Content>
