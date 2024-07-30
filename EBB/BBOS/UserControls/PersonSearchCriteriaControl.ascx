<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PersonSearchCriteriaControl.ascx.cs" Inherits="PRCo.BBOS.UI.Web.PersonSearchCriteriaControl" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<div id="pnlCriteria" runat="server">
  <div class="bbs-card-bordered">
    <div class="bbs-card-header tw-flex tw-justify-between">
      <h5>
        <asp:Panel ID="pnlExpander" runat="server" Visible="false">
          <i id="imgCriteria" class="more-less glyphicon glyphicon-minus" onclick="Toggle('Criteria');"></i>
        </asp:Panel>
        <%=Resources.Global.SelectedCriteria %>
      </h5>
    </div>
    <div class="bbs-card-body" id="Criteria">
      <asp:Label class="Search_Criteria" ID="lblSearchCriteria" runat="server" />
    </div>
  </div>
</div>

