<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SearchEditPopup.aspx.cs" Inherits="PRCo.BBOS.UI.Web.SearchEditPopup" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit.HtmlEditor" TagPrefix="HTMLEditor" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=10,chrome=1" />
    <title>
        <asp:Literal runat="server" Text="<%$ Resources:Global, SaveSearchCriteria%>" /></title>

    <link href="Content/bootstrap3/bootstrap.css" rel="stylesheet" />
    <link href="Content/bootstrap-theme.css" rel="stylesheet" />
    <link href="Content/bootstrap-datepicker.min.css" rel="stylesheet" />
    <link href="Content/font-awesome.min.css" rel="stylesheet" />
    <link href="Content/styles.css" rel="stylesheet" />
    <link href="Content/bbos.min.css" rel="stylesheet" />

    <script type="text/javascript" src="Scripts/jquery-3.4.1.min.js"></script>
    <script type="text/javascript" src="Scripts/jquery-ui-1.12.1.min.js"></script>
    <script type="text/javascript" src="Scripts/bootstrap3/bootstrap.min.js"></script>
    <script type="text/javascript" src="Scripts/bootstrap3/bootstrap-datepicker.min.js"></script>
    <script type="text/javascript" src="Scripts/bootbox.min.js"></script>

    <link href="https://fonts.googleapis.com/css?family=Open+Sans+Condensed:300" rel="stylesheet" type="text/css" />
  <link
    rel="stylesheet"
    href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <style type="text/css">
        @font-face {
            font-family: 'helvetica_neuelightcond';
            src: url("fonts/helveneuligcon-webfont.eot");
            src: url("fonts/helveneuligcon-webfont.eot?#iefix") format("embedded-opentype"), url("fonts/helveneuligcon-webfont.woff") format("woff"), url("fonts/helveneuligcon-webfont.ttf") format("truetype"), url("fonts/helveneuligcon-webfont.svg#helvetica_neuelightcond") format("svg");
            font-weight: normal;
            font-style: normal;
        }

        @font-face {
            font-family: 'helvetica_neuemediumcond';
            src: url("fonts/helveneumedcon-webfont.eot");
            src: url("fonts/helveneumedcon-webfont.eot?#iefix") format("embedded-opentype"), url("fonts/helveneumedcon-webfont.woff") format("woff"), url("fonts/helveneumedcon-webfont.ttf") format("truetype"), url("fonts/helveneumedcon-webfont.svg#helvetica_neuemediumcond") format("svg");
            font-weight: normal;
            font-style: normal;
        }
        .gray_btn {
            background-color: #68ae00 !important;
            color: #fff !important;
            margin-top: 5px;
        }
    </style>

    <script src="//use.edgefonts.net/abel.js"></script>

    <script type="text/javascript" src="en-us/javascript/formFunctions2.min.js"></script>
    <script type="text/javascript">
        function closeReload() {
            parent.location.href = document.getElementById("returnURL").value;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <input type="hidden" id="returnURL" runat="server" />
        <input type="hidden" id="NoteID" runat="server" />
        <input type="hidden" id="PinAvailable" runat="server" />

        <asp:ScriptManager runat="server" />

        <div class="col-md-12">
            <div class="row">
                <div class="col-md-2">
                    <asp:Label CssClass="bbos_blue_title" for="<%= txtSearchName.ClientID%>" runat="server"><%= Resources.Global.SearchName %>:</asp:Label>
                </div>
                <div class="col-md-8">
                    <asp:TextBox ID="txtSearchName" runat="server" Columns="50" MaxLength="50" CssClass="form-control" tsiDisplayName="<%$ Resources:Global, SearchName%>" tsiRequired="true" />
                </div>
            </div>

            <div class="row mar_top">
                <div class="col-md-2">
                    <asp:Label CssClass="bbos_blue_title" for="<%= chkPrivate.ClientID%>" runat="server"><%= Resources.Global.Private %>:</asp:Label>
                </div>
                <div class="col-md-10 form-inline">
                    <asp:CheckBox ID="chkPrivate" runat="server" Checked="true" />
                    <asp:Label runat="server" Text="<%$ Resources:Global, OnlyICanEditThisSearch %>" />
                </div>
            </div>
            
            <br />

            <%--Buttons--%>
            <div class="tw-flex tw-gap-3 tw-justify-end">
                <asp:LinkButton ID="btnCancel" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnCancel_Click">
	                <span class="msicon notranslate" runat="server">cancel</span>    
                  <asp:Literal runat="server" Text="<%$ Resources:Global, Cancel %>" />
                </asp:LinkButton>
                <asp:LinkButton ID="btnSave" runat="server" CssClass="bbsButton bbsButton-primary" OnClick="btnSave_Click">
	                <span class="msicon notranslate" runat="server">save</span>    
                  <asp:Literal runat="server" Text="<%$ Resources:Global, Save %>" />
                </asp:LinkButton>
            </div>
        </div>
    </form>
</body>
</html>
