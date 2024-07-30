<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PRPublicationUpload.aspx.cs" Inherits="PRCo.BBS.CRM.PRPublicationUpload" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title></title>
        <link href="../../prco.css" rel="stylesheet" type="text/css" />
        <link href="../../eware.css" rel="stylesheet" type="text/css" />
</head>
<body class="CONTENT" style="margin: 0px;">

    <script type="text/javascript">
        function Form_Submit() {
            if (document.all.hidIsPublicationEdition.value == "Y") {
                document.getElementById('hidPublicationCode').value = parent.document.all.prpbed_publicationcode.value;
                document.getElementById('hidEditionName').value = parent.document.all.prpbed_name.value;

	    	    document.getElementById('hidOldFile1').value = parent.document.all.prpbed_coverartfilename.value;
	    	    document.getElementById('hidOldFile2').value = parent.document.all.prpbed_coverartthumbfilename.value;
	    	} else if (document.all.hidIsTraining.value == "Y") {
	    	    document.getElementById('hidPublicationCode').value = "TRN";
	    	    document.getElementById('hidOldFile1').value = parent.document.all.prpbar_filename.value;
	    	    document.getElementById('hidOldFile2').value = parent.document.all.prpbar_coverartfilename.value;
	    	} else if (document.all.hidIsNHA.value == "Y") {
	    	    document.getElementById('hidPublicationCode').value = "NHA";
	    	    document.getElementById('hidOldFile1').value = parent.document.all.prpbar_filename.value;
	    	    document.getElementById('hidOldFile2').value = parent.document.all.prpbar_coverartfilename.value;
	    	} else {
                document.getElementById('hidPublicationCode').value = parent.document.all.prpbar_publicationcode.value;
                //document.getElementById('hidEditionName').value = parent.document.all.prpbar_publicationeditionidTEXT.value;

                if (parent.document.all.prpbed_name != null) {
                    document.getElementById('hidEditionName').value = parent.document.all.prpbed_name.value;
                }

                document.getElementById('hidOldFile1').value = parent.document.all.prpbar_filename.value;
                document.getElementById('hidOldFile2').value = parent.document.all.prpbar_coverartfilename.value;
                document.getElementById('hidOldFile3').value = parent.document.all.prpbar_coverartthumbfilename.value;
            }

            //alert("hidPublicationCode=" + document.getElementById('hidPublicationCode').value);
            //alert("hidEditionName=" + document.getElementById('hidEditionName').value);
		}

		function submitParent() {
		    if (document.getElementById('lblMsg').innerHTML != "") {
		        alert(document.getElementById('lblMsg').innerHTML);
		        return;
            }

            var theForm = window.parent.document.forms[0];
            if (theForm.onsubmit) {
                theForm.onsubmit();
            }
            theForm.submit();
        }
		
    </script>

    <form id="form1" runat="server" onsubmit="Form_Submit();">
    <div>
    
        <asp:HiddenField ID="hidPublicationCode" runat="server" />
        <asp:HiddenField ID="hidEditionName" runat="server" />
        <asp:HiddenField ID="hidIsPublicationEdition" runat="server" />
        <asp:HiddenField ID="hidIsTraining" runat="server" />
        <asp:HiddenField ID="hidIsNHA" runat="server" />
        
        <asp:HiddenField ID="hidOldFile1" runat="server" />
        <asp:HiddenField ID="hidOldFile2" runat="server" />
        <asp:HiddenField ID="hidOldFile3" runat="server" />
        
        <asp:HiddenField ID="hidUploadedFileName1" runat="server" Value="" />
        <asp:HiddenField ID="hidUploadedFileName2" runat="server" Value="" />
        <asp:HiddenField ID="hidUploadedFileName3" runat="server" Value="" />
    
    <asp:Label ID="lblMsg" runat="server" Text="" />
    <table>
    <tr>
        <td id="trFile1">
            <span class="VIEWBOXCAPTION"><asp:Literal ID="litFile1" runat="server"/></span><br/>
            <span class="VIEWBOX" ><asp:FileUpload ID="upFile1"  Width="700" CssClass="EDIT"  runat="server" /></span>
        </td>
    </tr>
    <tr>
        <td id="trFile2">
            <span class="VIEWBOXCAPTION"><asp:Literal ID="litFile2" runat="server"/></span><br/>
            <span class="VIEWBOX" ><asp:FileUpload ID="upFile2" Width="700" CssClass="EDIT" runat="server" /></span>
        </td>
    </tr>
    <tr>
        <td id="trFile3">
            <span class="VIEWBOXCAPTION"><asp:Literal ID="litFile3" runat="server"/></span><br/>
            <span class="VIEWBOX" ><asp:FileUpload ID="upFile3" Width="700" CssClass="EDIT" runat="server" /></span>
        </td>
    </tr>
    
    </table>
    
    
    </div>
    </form>
</body>
</html>

