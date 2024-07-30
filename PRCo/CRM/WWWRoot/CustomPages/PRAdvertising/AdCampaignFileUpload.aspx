<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdCampaignFileUpload.aspx.cs" Inherits="PRCo.BBS.CRM.AdCampaignFileUpload" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../prco.css" rel="stylesheet" type="text/css" />
    <link href="../../eware.css" rel="stylesheet" type="text/css" />
</head>
<body class="CONTENT" style="margin: 0px;">
    <script type="text/javascript">
        function Form_Submit() {
            document.getElementById('hidBBID').value = parent.document.getElementById('_HIDDENpradc_companyid').value;

            if (document.getElementById('hidAdType').value == 'KYC') {
                if (document.getElementById('hidFileTypeCode').value == 'DI')
                    document.getElementById('hidOldFile1').value = parent.document.getElementById('_HIDDENpracf_filename').value;
                else
                    document.getElementById('hidOldFile1').value = parent.document.getElementById('_HIDDENpracf_filename2').value;
            }
            else {
                document.getElementById('hidOldFile1').value = parent.document.getElementById('_HIDDENpracf_filename').value;
            }

            var fld = parent.document.getElementById('pradch_typecode') || parent.document.getElementById('_HIDDENpradc_adcampaigntype');
            document.getElementById('hidAdType').value = fld.value;
        }

        function submitParent() {
            if (document.getElementById('lblMsg').innerHTML != "") {
                alert(document.getElementById('lblMsg').innerHTML);
                return;
            }

            var oParentForm = window.parent.document.forms["EntryForm"];
            if (oParentForm.onsubmit) {
                oParentForm.onsubmit();
            }
            oParentForm.submit();
        }
    </script>

    <form id="form1" runat="server" onsubmit="Form_Submit();">
        <div>
            <asp:HiddenField ID="hidAdType" runat="server" />
            <asp:HiddenField ID="hidBBID" runat="server" />
            <asp:HiddenField ID="hidOldFile1" runat="server" />
            <asp:HiddenField ID="hidUploadedFileName1" runat="server" Value="" />
            
            <asp:HiddenField ID="hidFileTypeCode" runat="server" Value="" />
            <asp:HiddenField ID="hidSubmitFlag" runat="server" Value="" />


            <asp:HiddenField ID="hidSubmitParent" runat="server" Value="" />

            <asp:Label ID="lblMsg" runat="server" Text="" />
            <table>
                <tr>
                    <td>
                        <span class="VIEWBOXCAPTION">
                            <asp:Literal ID="litFile1" runat="server" />
                        </span>
                        <span class="VIEWBOX">
                            <asp:FileUpload ID="upFile1" Width="700" CssClass="EDIT" runat="server" />
                        </span>
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
