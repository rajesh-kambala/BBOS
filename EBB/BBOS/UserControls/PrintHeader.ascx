<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PrintHeader.ascx.cs" Inherits="PRCo.BBOS.UI.Web.PrintHeader" EnableViewState="false" %>

<div class="row nomargin d-none" id="printHeader">
    <div class="col-sm-3 col-xs-3 tw-text-sm">
        Blue Book Services<br />
        845 E. Geneva Road<br />
        Carol Stream, IL 60188<br />
        Phone 630 668-3500<br />
        FAX 630 668-0303<br />
        info@bluebookservices.com<br />
        www.bluebookservices.com<br />
    </div>
    <div class="col-sm-6 col-xs-6 text-center large bold">
        <b>Blue Book Services<br />
            <asp:Literal id="litCompanyDetails" runat="server" Text="<%$ Resources:Global, CompanyDetails%>"/>&nbsp;/&nbsp;<asp:Literal id="litTitle" runat="server" Text="Listing"/><br />
            <asp:Literal id="litSubTitle" runat="server" />
        </b>
    </div>
    <div class="col-sm-3 col-xs-3 d-flex align-items-start justify-content-end">
        <asp:Image ID="imgBBLogo" runat="server" ImageUrl="~/images/blue_book_logo_outline.svg" Width="125" CssClass="seal" />
    </div>
</div>
