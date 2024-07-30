<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CompanyDetailsCustomFieldEdit.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyDetailsCustomFieldEdit" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeaderMeister" Src="UserControls/CompanyDetailsHeaderMeister.ascx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
  <title><%=Resources.Global.EditCustomFields %></title>

  <link href="Content/bootstrap3/bootstrap.css" rel="stylesheet" />
  <link href="Content/bootstrap-theme.css" rel="stylesheet" />
  <link href="Content/bootstrap-datepicker.min.css" rel="stylesheet" />
  <link href="Content/font-awesome.min.css" rel="stylesheet" />
  <link href="Content/bbos.min.css" rel="stylesheet" />
  <link href="Content/font-awesome.min.css" rel="stylesheet" />
  <link href="Content/bbos.min.css" rel="stylesheet" />

  <link
    rel="stylesheet"
    href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />

  <link
    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
    rel="stylesheet"
    integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN"
    crossorigin="anonymous" />
  <link href="Content/styles.css" rel="stylesheet" />

  <script type="text/javascript" src="Scripts/jquery-3.4.1.min.js"></script>
  <script type="text/javascript" src="Scripts/jquery-ui-1.12.1.min.js"></script>
  <script type="text/javascript" src="Scripts/bootstrap3/bootstrap.min.js"></script>
  <script type="text/javascript" src="Scripts/bootstrap3/bootstrap-datepicker.min.js"></script>
  <script type="text/javascript" src="Scripts/bootstrap3/bootbox.min.js"></script>

  <style type="text/css">
    :root {
      font-size: 16px;
    }
  </style>

  <script src="//use.edgefonts.net/abel.js" type="text/javascript"></script>
  <script type="text/javascript" src="Scripts/jquery-3.4.1.min.js"></script>
  <script type="text/javascript" src="Scripts/jquery-ui-1.12.1.min.js"></script>
  <script type="text/javascript" src="Scripts/bootstrap3/bootstrap.min.js"></script>
  <script type="text/javascript" src="Scripts/bootstrap3/bootbox.min.js"></script>

  <script type="text/javascript">
    function closeReload(CompanyID) {
      var pl = parent.location.href.toLowerCase();
      if (pl.includes("company.aspx"))
        parent.location.href = "Company.aspx?CompanyID=" + CompanyID;
      else
        parent.location.href = "CompanyDetailsSummary.aspx?CompanyID=" + CompanyID;
    }
    </script>
</head>

<body>
  <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" EnablePartialRendering="true" EnableScriptGlobalization="true" runat="server">
      <Services>
        <asp:ServiceReference Path="~/AJAXHelper.asmx" />
      </Services>
    </asp:ScriptManager>

    <div class="bbs-card-bordered" style="outline: none;">
      <div class="bbs-card-header tw-flex tw-justify-between">
        <h5>
          <asp:Literal runat="server" Text="<%$ Resources:Global, EditCustomFields %>" /></h5>
        <div>
          <asp:LinkButton ID="btnX" runat="server" OnClick="Cancel_Click" CssClass="bbsButton bbsButton-tertiary small">
          <span class="msicon notranslate">close</span>
          </asp:LinkButton>
        </div>
      </div>
      <div class="bbs-card-body tw-flex tw-flex-col tw-gap-3">
        <asp:HiddenField ID="hidCompanyID" Visible="false" runat="server" />
        <asp:Repeater OnItemCreated="RepCustomFields_ItemCreated" ID="repCustomFields" runat="server">
          <ItemTemplate>
            <div class="tw-grid tw-grid-cols-12 tw-gap-3"><asp:PlaceHolder ID="phCustomField" runat="server" /></div>
          </ItemTemplate>
        </asp:Repeater>
      </div>
    </div>

    <div class="popup-footer position-absolute bottom-0 tw-w-full tw-flex p-3 border-top tw-gap-3 tw-justify-end">
      <asp:LinkButton ID="btnCancel" runat="server" CssClass="bbsButton bbsButton-secondary" OnClick="Cancel_Click">
                  <span class="msicon notranslate">cancel</span>
                  <asp:Literal runat="server" Text="<%$ Resources:Global, Cancel%>" />
      </asp:LinkButton>
      <asp:LinkButton ID="btnSave" runat="server" CssClass="bbsButton bbsButton-primary" OnClick="Save_Click">
                  <span class="msicon notranslate">Save</span>
                  <asp:Literal runat="server" Text="<%$ Resources:Global, Save %>" />
      </asp:LinkButton>
    </div>

  </form>
</body>
</html>

