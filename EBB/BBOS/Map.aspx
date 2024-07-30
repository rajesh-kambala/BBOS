<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Map.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Map" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>BBOS Map</title>

    <style type="text/css">
        html, body, #map-canvas {
            height: 100%;
            margin: 0;
            padding: 0;
        }

        .infoWindow {
            width: 350px;
            height: 155px;
        }

        @media screen {
            #directionsPanel {
                position: absolute;
                top: 30px;
                right: 0px;
                width: 300px;
                background-color: White;
                border: thin solid gray;
            }
        }

        @media print {
            #map-canvas {
                margin: 0;
            }

            #directionsPanel {
                float: none;
                width: auto;
            }

            #btnPrint {
                display: none !important;
            }
        }
    </style>
    <!-- <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?sensor=false&key=AIzaSyCmZaosbegjxUpootR4425jwp4riiET42g"></script> -->
    <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?sensor=false&key=AIzaSyAN18eWihRWUZDlDZSqAkSoVk5YoWbxeVs"></script>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js?ver=3.8.1"></script>
    <script type="text/javascript" src="en-us/javascript/map.min.js?RESOURCE_VERSION=<%=PRCo.BBOS.UI.Web.Configuration.RESOURCE_VERSION%>"></script>
</head>
<body>
    <script type="text/javascript">
        companies =  <% =mapData %>
    </script>

    <form id="form1" runat="server">
        <asp:ScriptManager runat="server">
            <Services>
                <asp:ServiceReference Path="~/AJAXHelper.asmx" />
            </Services>
        </asp:ScriptManager>
    </form>

    <div id="pnlWait" style="display: none;">
        <p style="text-align: center; font-size: 14pt;">
            Plotting locations, please wait...<br />
            <img src="images/BBOSProgress.gif" /><br />
        </p>
        <table>
            <tr>
                <td>Total Companies</td>
                <td><span id="totalCompanies"></span></td>
            </tr>
            <tr>
                <td>Current Count</td>
                <td><span id="currentCount"></span></td>
            </tr>
            <tr>
                <td>Not Found</td>
                <td><span id="notFound"></span></td>
            </tr>
            <tr>
                <td>Over Limit</td>
                <td><span id="overlimit"></span></td>
            </tr>
        </table>
    </div>

    <div id="map-canvas"></div>
    <div id="directionsPanel"></div>
</body>
</html>
