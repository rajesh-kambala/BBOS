<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CheckBoxPanel.ascx.cs" Inherits="PRCo.BBOS.UI.Web.UserControls.CheckBoxPanel" %>

<div class="row nomargin">
    <div class="mar_top panel-default">
        <div class="panel-heading" role="tab" id="heading<%=PanelID %>">
            <h4 class="panel-title bbos_bg commodityPanelTitle nopadding_tb">
                <asp:CheckBox ID="cbID" AutoPostBack="true" CssClass="commodityAllCheckbox" runat="server" />
                <i id="img<%=PanelID %>" class="more-less glyphicon glyphicon-minus mar_top_5" onclick="Toggle_Hid('<%=PanelID %>', document.getElementById('<%=hidID.ClientID%>'), 'img<%=PanelID %>');"></i>
            </h4>
        </div>
        <div class="panel-body norm_lbl">
            <asp:HiddenField ID="hidID" runat="server" Value="true" />
            <div class="col-md-12 gray_bg" id="<%=PanelID %>">
                <asp:PlaceHolder id="phID" runat="server" />
            </div>
        </div>
    </div>
</div>

<div class="clearfix"></div>

<script type="text/javascript">
    function initPageDisplay() {
        var c = document.getElementById('<%=hidID.ClientID%>');
        if (c != null) {
            Set_Hid_Display('<%=PanelID %>', c, 'img<%=PanelID %>');
            toggleTable('contentMain_<%=cbID.ClientID%>', 'contentMain_<%=phID.ClientID%>');
        }
    }

    Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(initPageDisplay);
</script>