<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CompanyDetailsCategoryRemove.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyDetailsCategoryRemove" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
  <title>Remove from Watchdog Category</title>

  <link href="Content/bootstrap3/bootstrap.css" rel="stylesheet" />
  <link href="Content/bootstrap-theme.css" rel="stylesheet" />
  <link href="Content/bootstrap-datepicker.min.css" rel="stylesheet" />
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
  <script type="text/javascript" src="Scripts/bootstrap-datepicker.min.js"></script>
  <script type="text/javascript" src="Scripts/bootstrap3/bootbox.min.js"></script>
  <script type="text/javascript" src="en-us/javascript/formFunctions2.min.js"></script>
  <script type="text/javascript">
    function confirmRemove() {
      if (!IsItemSelected("cbWebUserListDetailID")) {
        displayErrorMessage('Please select a category to remove.');
        return false;
      }

      document.getElementById("tblCategories").style.display = "none";
      return true;
    }
    </script>
  <style type="text/css">
    :root {
      font-size: 16px;
    }
  </style>
</head>
<body class="popup-dialog" tabindex="-1">
  <script type="text/javascript">
    function closeReload() {
      var CompanyID = document.getElementById("<% =hdnCompanyID.ClientID %>").value;
      var pl = parent.location.href.toLowerCase();
      if (pl.includes("company.aspx"))
        parent.location.href = "Company.aspx?CompanyID=" + CompanyID;
      else
        parent.location.href = "CompanyDetailsSummary.aspx?CompanyID=" + CompanyID;
    }
    </script>

  <form id="form1" runat="server" tabindex="-1">
    <div class="popup-body">
      <asp:HiddenField ID="hdnCompanyID" runat="server" />


      <div class="bbs-card-bordered" style="outline: none;">
        <div class="bbs-card-header">
          <h5>
            <asp:Literal runat="server" Text="<%$ Resources:Global, RemoveFromWatchdogGroup %>" /></h5>
        </div>
        <div class="bbs-card-body">
          <div class="tw-grid tw-grid-cols-2 tw-gap-4">
            <asp:Repeater ID="repCategories" runat="server">
              <ItemTemplate>
                <div class="bbs-checkbox-input tw-flex tw-gap-3 tw-items-center">
                  <input type="checkbox"
                    id='<%# Eval("prwuld_WebUserListDetailID") %>'
                    name="cbWebUserListDetailID"
                    value='<%# Eval("prwuld_WebUserListDetailID") %>'
                    <%# GetDisabled((string)Eval("prwucl_TypeCode")) %> />
                  <label class="tw-flex tw-gap-2" for='<%# Eval("prwuld_WebUserListDetailID") %>'>
                    <%# PageControlBaseCommon.GetCategoryIcon(Eval("prwucl_CategoryIcon"), Eval("prwucl_Name"))%><%# Eval("prwucl_Name") %>
                  </label>
                </div>
              </ItemTemplate>
            </asp:Repeater>
          </div>

          <div id="divNoWatchdogGroupsFound" runat="server" visible="false">
            No watchdog groups found.
          </div>
        </div>
      </div>

    </div>
    <div class="popup-footer position-absolute bottom-0 tw-w-full tw-flex p-3 border-top tw-gap-3 tw-justify-end">
      <asp:LinkButton CssClass="bbsButton bbsButton-secondary" ID="btnCancel" runat="server" OnClientClick="closeReload(); return false;">
        <span class="msicon notranslate">cancel</span>
        <asp:Literal runat="server" Text="<%$ Resources:Global, Cancel %>" />
      </asp:LinkButton>
      <asp:LinkButton CssClass="bbsButton bbsButton-primary" ID="btnSave" OnClick="Save_Click" OnClientClick="return confirmRemove();" runat="server">
        <span class="msicon notranslate">delete</span>
        <asp:Literal runat="server" Text="<%$ Resources:Global, Remove2 %>" />
      </asp:LinkButton>
    </div>
  </form>
</body>
</html>
