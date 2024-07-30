<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="NoteEdit.aspx.cs" Inherits="PRCo.BBOS.UI.Web.NoteEdit" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit.HtmlEditor" TagPrefix="HTMLEditor" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" style="font-size: 16px">
<head runat="server">
  <meta http-equiv="X-UA-Compatible" content="IE=10,chrome=1" />
  <title>
    <asp:Literal runat="server" Text="<%$ Resources:Global, NoteEdit%>" /></title>

  <link href="Content/bootstrap3/bootstrap.css" rel="stylesheet" />
  <link href="Content/bootstrap-theme.css" rel="stylesheet" />
  <link href="Content/bootstrap-datepicker.min.css" rel="stylesheet" />
  <link href="Content/font-awesome.min.css" rel="stylesheet" />
  <link href="Content/bbos.min.css" rel="stylesheet" />
  <link href="Content/styles.css" rel="stylesheet" />

  <script type="text/javascript" src="Scripts/jquery-3.4.1.min.js"></script>
  <script type="text/javascript" src="Scripts/jquery-ui-1.12.1.min.js"></script>
  <script type="text/javascript" src="Scripts/bootstrap3/bootstrap.min.js"></script>
  <script type="text/javascript" src="Scripts/bootstrap-datepicker.min.js"></script>
  <script type="text/javascript" src="Scripts/bootstrap3/bootbox.min.js"></script>

  <script src="//use.edgefonts.net/abel.js"></script>

  <script type="text/javascript" src="en-us/javascript/formFunctions2.min.js"></script>
  <script type="text/javascript">
    function closeReload() {
      $("#btnSave").addClass("aspNetDisabled");
      parent.location.href = document.getElementById("returnURL").value;
    }
    </script>
</head>
<body>
  <form id="form1" runat="server">
    <input type="hidden" id="returnURL" runat="server" />
    <input type="hidden" id="NoteID" runat="server" />
    <input type="hidden" id="PinAvailable" runat="server" />

    <asp:ScriptManager runat="server" EnableScriptGlobalization="true" />

    <div class="appBody" style="overflow: hidden;">
      <div class="pagecontainer" style="overflow: hidden;">
        <div style="overflow: auto; height: 100vh; padding: 16px; padding-bottom: 60px">
          <table style="width: 100%; margin-bottom: 15px;" class="table table_bbos">
            <tr>
              <td colspan="3" align="left">
                <label runat="server" class="bbos_blue">
                  <asp:Literal runat="server" Text="<%$ Resources:Global, Notefor%>" />:</label>
                BB#
                  <asp:Literal ID="lblCompanyID" runat="server" />,
                  <asp:Literal ID="lblCompanyName" runat="server" />,
                  <asp:Literal ID="lblLocation" runat="server" />
              </td>
            </tr>
            <tr>
              <td class="">
                <label runat="server" class="bbos_blue">
                  <asp:Literal runat="server" Text="<%$ Resources:Global, LastUpdated%>" />:</label>
                <asp:Literal ID="lblUpdatedDate" runat="server" />&nbsp;&nbsp;&nbsp;&nbsp;
                               
                <label runat="server" class="bbos_blue">
                  <asp:Literal runat="server" Text="<%$ Resources:Global, By%>" />:</label>
                <asp:Literal ID="lblUpdatedBy" runat="server" />
              </td>
            </tr>
          </table>

          <asp:TextBox TextMode="MultiLine" Rows="8" Width="100%" CssClass="form-control" runat="server" ID="txtNote" tsiRequired="true" tsiDisplayName="<%$ Resources:Global, NoteText %>" />

          <div class=" tw-flex tw-gap-4 tw-flex-col tw-my-4">
            <label class="checkbox-inline">
              <asp:CheckBox ID="cbIsPrivate" onchange="togglePrivate();" runat="server" />
              <asp:Label ID="lblCustomHeaderText" for="<%= cbIsPrivate.ClientID%>" runat="server" CssClass="blacktext smaller" Text="<%$Resources:Global, PrivatePublicNotesCannotBeChangedToPrivate %>" />
            </label>
            <label class="checkbox-inline">
              <asp:CheckBox ID="cbPinned" runat="server" onchange="pinnedChecked();" />

              <asp:Label for="<%= cbPinned.ClientID%>" runat="server" CssClass="blacktext smaller">
                                <asp:Literal runat="server" Text="<%$ Resources:Global, PinThisNote%>" />
              </asp:Label>
            </label>

            <div class="bbs-alert alert-info" role="alert">
              <div class="alert-title">
                <span>
                  <asp:Literal ID="litWhatIsPinned" runat="server" Text="<%$ Resources:Global, OneNotePinned%>" />
                </span>
              </div>
            </div>


            <label class="checkbox-inline">
              <span>
                <asp:CheckBox ID="cbRemindMe" onclick="toggleReminder();" runat="server" /></span>
              <asp:Label for="<%= cbRemindMe.ClientID%>" runat="server" CssClass="blacktext smaller">
                                <asp:Literal runat="server" Text="<%$ Resources:Global, SetReminder%>" />
              </asp:Label>
            </label>

            <div class="row">
              <div class="col-xs-3">
                <asp:Label for="<%= txtDate.ClientID%>" runat="server" CssClass="bbos_blue smaller">
                                    <asp:Literal runat="server" Text="<%$Resources:Global, ReminderDate %>" />:
                </asp:Label>
              </div>
              <div class="col-xs-6">
                <asp:TextBox ID="txtDate" Columns="15" MaxLength="10" tsiDate="true" tsiRequired="true" tsiDisplayName="<%$Resources:Global, ReminderDate %>" runat="server" CssClass="form-control" />
                <cc1:CalendarExtender ID="ceDate" TargetControlID="txtDate" runat="server" />
              </div>
            </div>

            <div class="row mar_top_10">
              <div class="col-xs-3">
                <asp:Label for="<%= ddlHour.ClientID%>" runat="server" CssClass="bbos_blue smaller">
                                    <asp:Literal runat="server" Text="<%$Resources:Global, ReminderTime %>" />:
                </asp:Label>
              </div>
              <div class="col-xs-2">
                <asp:DropDownList ID="ddlHour" runat="server" CssClass="form-control" /></div>
              :
                            <div class="col-xs-2">
                              <asp:DropDownList ID="ddlMinute" runat="server" CssClass="form-control" /></div>
              <div class="col-xs-2">
                <asp:DropDownList ID="ddlAMPM" runat="server" CssClass="form-control" /></div>

              <div class="col-xs-2 text-nowrap">
                <asp:Label CssClass="blacktext small" runat="server">
                  <asp:Literal ID="litTimeZone" runat="server" />
                </asp:Label>
              </div>
            </div>

            <div class="row mar_top_10">
              <div class="col-xs-3">
                <asp:Label for="<%= ReminderType.ClientID%>" runat="server" CssClass="bbos_blue smaller">
                                    <asp:Literal runat="server" Text="<%$Resources:Global, ReminderType %>" />:
                </asp:Label>
              </div>
              <div class="col-xs-6">
                <asp:CheckBoxList RepeatLayout="UnorderedList" ID="ReminderType" runat="server" CssClass="tw-flex tw-gap-4">
                  <asp:ListItem Value="BBOS" Text="BBOS" Selected="False" />
                  <asp:ListItem Value="Email" Text="Email" Selected="False" />
                  <asp:ListItem Value="Text" Text="Text Message" Selected="False" />
                </asp:CheckBoxList>
              </div>
            </div>

            <div class="row mar_top_10">
              <div class="col-xs-3">
                <asp:Label for="<%= txtEmail.ClientID%>" runat="server" CssClass="bbos_blue smaller">
                                    <asp:Literal runat="server" Text="<%$Resources:Global, EmailAddress2 %>" />:
                </asp:Label>
              </div>
              <div class="col-xs-6">
                <asp:TextBox ID="txtEmail" Columns="30" MaxLength="255" tsiRequired="true" tsiEmail="true" tsiDisplayName="<%$Resources:Global, EmailAddress2 %>" runat="server" CssClass="form-control" />
              </div>
            </div>

            <div class="row mar_top_10" id="trCell" runat="server">
              <div class="col-xs-3">
                <asp:Label for="<%= txtCell.ClientID%>" runat="server" CssClass="bbos_blue smaller">
                                    <asp:Literal runat="server" Text="Cell Phone" />:
                </asp:Label>
              </div>
              <div class="col-xs-6">
                <asp:TextBox ID="txtCell" Columns="30" MaxLength="25" tsiRequired="true" tsiDisplayName="Cell Phone" runat="server" CssClass="form-control" />
              </div>
            </div>
          </div>

        </div>
        <div class="tw-flex tw-gap-2 tw-w-full tw-bg-bg-secondary tw-border-t tw-justify-between" style="position: absolute; bottom: 0px; padding: 8px;">
          <div class="tw-flex tw-gap-2">
            <asp:LinkButton ID="Print" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnPrintNote_Click" CommandArgument='<%# Eval("prwun_WebUserNoteID")%>'>
		                  
                      <span><asp:Literal runat="server" Text="<%$ Resources:Global, Print %>" /></span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnDelete" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnDelete_Click" OnClientClick="DisableValidation();return confirm('Are you sure you want to delete this Note?');">
		                  
                      <span><asp:Literal runat="server" Text="<%$ Resources:Global, Delete %>" /></span>
            </asp:LinkButton>

          </div>
          <div class="tw-flex tw-gap-2">

            <asp:LinkButton ID="btnCancel" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnCancel_Click" OnClientClick="DisableValidation();">
		                  
                      <span><asp:Literal runat="server" Text="<%$ Resources:Global, Cancel %>" /></span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnSave" runat="server" CssClass="bbsButton bbsButton-primary" OnClick="btnSave_Click" OnClientClick="return PreventDoubleClick();">
		                  
                      <span><asp:Literal runat="server" Text="<%$ Resources:Global, Save %>" /></span>
            </asp:LinkButton>
          </div>
        </div>
      </div>

      <script type="text/javascript">
        function pinnedChecked() {
          if (document.getElementById("<% =PinAvailable.ClientID %>").value == "true") {
            return;
          }

<%--          if (document.getElementById("<% =cbPinned.ClientID %>").checked) {
            if (!confirm("Do you want to replace the previous pinned note with this current new note?")) {
              document.getElementById("<% =cbPinned.ClientID %>").checked = false;
            }
          }--%>
        }

        function togglePrivate() {

          if (document.getElementById("<% =PinAvailable.ClientID %>").value == "false") {
                    return;
                  }

                  if (document.getElementById("<% =cbIsPrivate.ClientID %>").checked) {
                    document.getElementById("<% =cbPinned.ClientID %>").checked = false;
                      document.getElementById("<% =cbPinned.ClientID %>").disabled = true;
                    } else {
                      document.getElementById("<% =cbPinned.ClientID %>").disabled = false;
          }
        }

        function toggleTimeOnDateSelected(cb) {
          toggleTime();
        }

        function toggleTime() {

          if (document.getElementById("txtDate").value == "") {

            document.getElementById("<%=cbRemindMe.ClientID %>").disabled = true;

                      document.getElementById("<%=cbRemindMe.ClientID %>").checked = false;
                      toggleReminder();
                    } else {
                      document.getElementById("<%=ddlHour.ClientID %>").disabled = false;
                      document.getElementById("<%=ddlMinute.ClientID %>").disabled = false;
                      document.getElementById("<%=ddlAMPM.ClientID %>").disabled = false;
                      document.getElementById("<%=cbRemindMe.ClientID %>").disabled = false;
          }

        }

        function toggleReminder() {

          if (document.getElementById("<%=cbRemindMe.ClientID %>").checked) {

                    document.getElementById("<%=ReminderType.ClientID %>").disabled = false;
                      document.getElementById("<%=txtDate.ClientID %>").disabled = false;
                      document.getElementById("<%=ddlHour.ClientID %>").disabled = false;
                      document.getElementById("<%=ddlMinute.ClientID %>").disabled = false;
                      document.getElementById("<%=ddlAMPM.ClientID %>").disabled = false;

                      var iReminderChecked = 0;
                      if (document.getElementById("ReminderType_0").checked)
                        iReminderChecked++;
                      if (document.getElementById("ReminderType_1").checked)
                        iReminderChecked++;
                      if (document.getElementById("ReminderType_2")) {
                        if (document.getElementById("ReminderType_2").checked)
                          iReminderChecked++;
                      }

                      if (iReminderChecked == 0)
                        document.getElementById("ReminderType_0").checked = true;

                    } else {
                      document.getElementById("<%=ReminderType.ClientID %>").disabled = true;
                      document.getElementById("<%=txtDate.ClientID %>").disabled = true;
                      document.getElementById("<%=ddlHour.ClientID %>").disabled = true;
                      document.getElementById("<%=ddlMinute.ClientID %>").disabled = true;
                      document.getElementById("<%=ddlAMPM.ClientID %>").disabled = true;

            document.getElementById("ReminderType_0").checked = false;
            document.getElementById("ReminderType_1").checked = false;

            if (document.getElementById("ReminderType_2")) {
              document.getElementById("ReminderType_2").checked = false;
            }

          }

          toggleDelivery();
        }

        function toggleDelivery() {
          if (IsItemSelected("ReminderType$1")) {
            document.getElementById("<%=txtEmail.ClientID %>").disabled = false;
                    } else {
                      document.getElementById("<%=txtEmail.ClientID %>").disabled = true;
                  }

                  if (document.getElementById("ReminderType_2")) {
                    if (IsItemSelected("ReminderType$2")) {
                      document.getElementById("<%=txtCell.ClientID %>").disabled = false;
                        } else {
                          document.getElementById("<%=txtCell.ClientID %>").disabled = true;
            }
          }
        }

        var oCheckboxes = document.body.getElementsByTagName("INPUT");
        for (var i = 0; i < oCheckboxes.length; i++) {
          if ((oCheckboxes[i].type == "checkbox") &&
            (oCheckboxes[i].name.indexOf("ReminderType") == 0)) {

            oCheckboxes[i].onclick = toggleDelivery;
          }
        }

        toggleReminder();
        toggleDelivery();
        togglePrivate();

        function PreventDoubleClick() {
          if ($("#btnSave").hasClass("aspNetDisabled")) {
            return false;
          }
          else {
            $("#btnSave").addClass("aspNetDisabled");
            return true;
          }
        }

        $(document).keydown(function (e) {
          $("#btnSave").removeClass("aspNetDisabled");
        });

        $(document).ready(function () {
          $('.reminder').change(function () {
            var iReminderChecked = 0;
            if (document.getElementById("ReminderType_0").checked)
              iReminderChecked++;
            if (document.getElementById("ReminderType_1").checked)
              iReminderChecked++;
            if (document.getElementById("ReminderType_2")) {
              if (document.getElementById("ReminderType_2").checked)
                iReminderChecked++;
            }

            if (iReminderChecked > 0)
              $('#cbRemindMe').prop('checked', true);
            else
              $('#cbRemindMe').prop('checked', false);

            toggleReminder();
          });
        });
            </script>
    </div>
  </form>
</body>
</html>
