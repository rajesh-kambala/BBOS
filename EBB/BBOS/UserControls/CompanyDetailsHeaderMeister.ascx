<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CompanyDetailsHeaderMeister.ascx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyDetailsHeaderMeister" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Panel ID="pnlLocalSource" runat="server" Visible="false">
     <div class="bbs-alert alert-info mx-3" role="alert">
         <div class="alert-title">
             <span class="msicon notranslate">info</span>
             <span><%=Resources.Global.DataProvidedBy %>
                 <a href="https://www.meistermedia.com" class="link" target="_blank">Meister Media Worldwide, Inc.</a>
             </span>
         </div>
     </div>
</asp:Panel>