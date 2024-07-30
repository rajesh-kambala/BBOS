<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Advertisements.ascx.cs" Inherits="PRCo.BBOS.UI.Web.Advertisements" EnableViewState="false" %>

<!-- Begin Advertisment -->

<div class="bbs-card-bordered">
  <div class="bbs-card-header">
      <a href="<% =PRCo.BBOS.UI.Web.Configuration.AdvertiserMediaKitURL %>" target="_blank">
    <h5 class="tw-flex tw-justify-between">
      <%= Resources.Global.Advertisement %>
      <span class="msicon notranslate">help</span>
    </h5>
    </a>
  </div>
  <div class="bbs-card-body no-padding">
    <div class="tw-flex tw-gap-3 tw-flex-col">
      <div id="trAdTitleRow" runat="server">
      </div>
      <div class="tw-flex tw-gap-3 tw-flex-col">
        <asp:Literal ID="litAdvertisement" runat="server" />
      </div>
    </div>
  </div>
</div>

<!-- End Advertisment -->
