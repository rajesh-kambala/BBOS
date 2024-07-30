<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PinnedNote2.ascx.cs" Inherits="PRCo.BBOS.UI.Web.UserControls.PinnedNote2" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<div class="bbs-card bbs-card-alert">
  <div class="bbs-card-body">
    <h5 class="card-title">
      <span class="msicon notranslate">push_pin</span> <%= Resources.Global.PinnedNote %>
    </h5>
    <div>
      <p class="text-clipped clip-2">
        <asp:Literal ID="litKeyNote" runat="server" />
      </p>
      <div class="tw-flex tw-items-center">
        <p class="tw-flex-grow tw-text-text-secondary">
          <span class="text-xxs"><%=Resources.Global.LastUpdated %>: </span><span class="tw-text-xs">
            <asp:Literal ID="litKeyNoteLastUpdated" runat="server" /></span>
        </p>
        <button type="button" class="bbsButton bbsButton-secondary small" id="btnShowMore" runat="server" data-bs-toggle="modal" data-bs-target="#pinnedNoteModal">
          <span><%=Resources.Global.ShowMore %></span>
        </button>
      </div>
    </div>
  </div>
</div>

<!-- Modal -->
<asp:Panel ID="KeyNote" runat="server">
  <div class="modal fade" id="pinnedNoteModal" tabindex="-1" aria-labelledby="pinnedNoteModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
      <div class="modal-content">
        <div class="modal-header">
          <h1 class="modal-title fs-5" id="pinnedNoteModalLabel">
            <asp:Literal ID="litPanelTitle" runat="server" Text="Note" /></h1>
          <button type="button" class="bbsButton bbsButton-secondary" data-bs-dismiss="modal" aria-label="Close">
            <span class="msicon notranslate">close</span>
          </button>
        </div>
        <div class="modal-body">
          <p class="tw-text-sm"><%=Resources.Global.LastUpdated %>:
            <asp:Literal ID="litKeyNoteLastUpdated2" runat="server" /></p>
          <p class="tw-text-sm"><%=Resources.Global.By %>:
            <asp:Literal ID="litKeyNoteLastUpdatedBy" runat="server" /></p>
          <hr />
          <p>
            <asp:Literal ID="litKeyNote2" runat="server" />
          </p>
        </div>
        <div class="modal-footer">
          <button type="button" class="bbsButton bbsButton-secondary" data-bs-dismiss="modal">Close</button>
        </div>
      </div>
    </div>
  </div>
</asp:Panel>

