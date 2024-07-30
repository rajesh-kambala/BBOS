<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PRPublicationUpload2.aspx.cs" Inherits="PRCO.BBS.CRM.PRPublicationUpload2" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">	
    <title>Publication Upload File</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
		<asp:HiddenField ID="hdnUploadBaseDir" runat="server" Value="" />
		<asp:HiddenField ID="hdnOldUploadFileName" runat="server" Value="" />
		<asp:HiddenField ID="hdnUploadedFileName" runat="server" Value="" />
		<asp:HiddenField ID="hdnPublicationCode" runat="server" Value="" />
		<asp:HiddenField ID="hdnPublicationEdition" runat="server" Value="" />
		<asp:HiddenField ID="hdnSubmitChainFlag" runat="server" Value="false" />
		<asp:Label ID="msg" runat="server" Text=""></asp:Label>
		<asp:FileUpload ID="upPublicationFile" Width="100%" runat="server" />
    </div>
    <script type="text/javascript">
		(function() {
			var onload = function() {
				var submit_sibling = document.getElementById("<%= hdnSubmitChainFlag.ClientID %>").value != "false";
				if (submit_sibling) {
					// find the form on the second page.
<% if (Request["IsPublicationEdition"] == "Y") { %>		
					var sibling_form = parent.frames["_Frameprpbed_coverartfilename_upload"].document.forms["EntryForm"]
<% } else { %>			
					var sibling_form = parent.frames["_Frameprpbar_coverartfilename_upload"].document.forms["EntryForm"]
<% } %>
					if (sibling_form.onsubmit) {
						sibling_form.onsubmit();
					}
					sibling_form.submit();
				}

				// attach the handler			
				var frm = document.forms[0];
				frm.onsubmit = Form_Submit;
			}

			// attach the event (you are out of luck if these don't work)
			if (window.addEventListener) {
				window.addEventListener("load", onload)
			} else if (window.attachEvent) {
				window.attachEvent("onload", onload);
			}
		})();

		function Form_Submit()
		{
		    // Populate the hidden fields prior to submitting the main form
		    document.getElementById('hdnUploadBaseDir').value = parent.document.all._uploadbasedir.value;
		    
		    

<% if (Request["IsPublicationEdition"] == "Y") { %>
		    document.getElementById('hdnOldUploadFileName').value = parent.document.all.prpbed_coverartthumbfilename.value;		    
		    document.getElementById('hdnPublicationCode').value = parent.document.all.prpbed_publicationcode.value;
		    document.getElementById('hdnPublicationEdition').value = parent.document.all.prpbed_name.value;
<% } else { %>
            document.getElementById('hdnOldUploadFileName').value = parent.document.all.prpbar_filename.value;		    
            document.getElementById('hdnPublicationCode').value = parent.document.all.prpbar_publicationcode.value;
            document.getElementById('hdnPublicationEdition').value = parent.document.all.prpbar_publicationeditionidTEXT.value;
<% } %>
		}
    </script>
    </form>
</body>
</html>
