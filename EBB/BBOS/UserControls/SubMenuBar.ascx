<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SubMenuBar.ascx.cs" Inherits="PRCo.BBOS.UI.Web.SubMenuBar" EnableViewState="false" %>

<div id="subMenuBar" style="margin-bottom: 50px;">
  <button class="bbsButton bbsButton-secondary tw-rounded-r-none" type="button"
    onclick="scrollX(this, -200, 'custom_menu_links')">
    <span class="msicon notranslate">chevron_left</span>
  </button>
  <div class="items" id="custom_menu_links" role="group">
    <asp:PlaceHolder ID="phSubMenu" runat="server" />
  </div>
  <button class="bbsButton bbsButton-secondary tw-rounded-l-none" type="button"
    onclick="scrollX(this, 200, 'custom_menu_links')">
    <span class="msicon notranslate">chevron_right</span>
  </button>
</div>

<script type="text/javascript">
  $(document).ready(function () {
    //40 is the width of the left button, so offsetting to line up with that + some margin
    // on load scroll to the submenu button that is selected
    $("#subMenuBar #custom_menu_links").scrollLeft($("#subMenuBar #custom_menu_links  .bbsButton.bbsButton-secondary.selected").offset().left - 80)
  });
</script>
<!-- end submenu bar -->
