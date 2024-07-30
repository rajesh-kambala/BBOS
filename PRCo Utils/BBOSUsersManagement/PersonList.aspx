<%@ Page Language="C#" MasterPageFile="~/BBOSUsers.Master" AutoEventWireup="true" CodeBehind="PersonList.aspx.cs" Inherits="PRCo.BBOS.UI.Web.UserManagement.PersonList" Title="Untitled Page" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<script type="text/javascript">
function postStdValidation(form) {
	var oTextboxes = document.body.getElementsByTagName("INPUT");
	for(var i = 0; i < oTextboxes.length; i++) {
		if (oTextboxes[i].type == "text")  {
		    if ((oTextboxes[i].disabled == false) &&
		        (oTextboxes[i].value != "" )) {


                if (oTextboxes[i-1].checked) {

	            szEmail = oTextboxes[i].value

                for(var y = 0; y < oTextboxes.length; y++) {
		            if (oTextboxes[y].type == "text")  {
		                if ((oTextboxes[y].disabled == false) &&
		                    (oTextboxes[y].value != "" )) {
                
                            if (oTextboxes[y-1].checked) {

                
                            if (i != y) {
                                if (szEmail ==  oTextboxes[y].value) {
                                    displayErrorMessage("The e-mail address " + szEmail + " is specified multiple times for different BBOS licensed users.  Each BBOS licensed user requires a unique e-mail address.");
                                    return false;                                                                    
                                }
                            }
                            
                            }
                        }
		            }
		        }
		        
		        }
			}
		}
	}


	var iCheckCount = 0;
	var oCheckboxes = document.body.getElementsByTagName("INPUT");
	for(var i = 0; i < oCheckboxes.length; i++) {
		if (oCheckboxes[i].type == "checkbox")  {
		    if (oCheckboxes[i].disabled == false) {
				if (oCheckboxes[i].checked) {
					iCheckCount++;
				}
			}
		}
	}

	var iMax = new Number(document.getElementById('ctl00$MainContent$hidMaxLicenses').value);
	if (iCheckCount > iMax) {
		displayErrorMessage("Only " + iMax.toString() + " licenses are currently available.  Please deselect the appropriate\nnumber of users or contact Blue Book Services to purchase additional\nlicenses." );
		return false;
	}

    



	return true;
}
</script>

	<input type=hidden id=hidMaxLicenses runat=server />
	
	<asp:Literal ID=litMembershipMsg runat=server />
    <p></p>
    If your enterprise has multiple locations, or you are unsure that the appropriate person has viewed this information, you may want to ask a manager at your corporate headquarters to review the below information. 
	
	<em>
	<p>Note: If there is an individual at your organization that is not listed below and needs access to Blue Book information, or you need to purchase additional BBOS licenses, please contact a Service Associate at <a href="mailto:customerservice@bluebookprco.com">customerservice@bluebookprco.com</a> or 630 668-3500.
    <p>Note: No changes made via this tool will be reflected in your published Blue Book listing. If you wish to also have any changes applied to your Blue Book listing, please contact Blue Book Services at <a href="mailto:listing@bluebookprco.com">listing@bluebookprco.com</a> or 630-668-3500. 

    <asp:Panel ID=pnlMultipePersons runat=server >
	<p>
	Note: If a person with your organization is associated at multiple locations, the person will display below multiple times but with the same person ID (one row for each location). For example, if John Doe is associated at three (3) branch locations, then John Doe will appear three times in the table below.  Please only assign one (1) access license per person/person ID.
	</p>
	</asp:Panel>
    </em>    	
		
	<p>
	
	</p>


    <p></p>
    <u><b>Directions:</b></u> <br />
First, enter the specific individual’s e-mail address. <br />
Second, select the "Grant BBOS License" checkbox. <br />
Last, click the Save button. <br />

   <p></p>
    <table>
        <tr><td class=label>Last Accessed:</td><td><asp:Literal ID=litLastAccessed runat=server Text="Never" /></td></tr>
        <tr><td class=label>Last Saved:</td><td><asp:Literal ID=litLastSaved runat=server Text="Never" /></td></tr>
    </table>
	<table class="formtable" cellspacing="3"  border="0" id="tblPersonAccess" style="width:100%;">
		<tr>
			<th class="colHeader" scope="col" style="height:33px;white-space:nowrap;width:75px;">Person ID</th>
			<th class="colHeader" scope="col" style="white-space:nowrap;">Person Name</th>
			<th class="colHeader" scope="col" style="white-space:nowrap;">Location</th>
			<th class="colHeader" scope="col" style="white-space:nowrap;">Title (at this location)</th>
			<th class="colHeader" scope="col" style="width:50px;white-space:nowrap;">Grant BBOS License</a></th>
			<th class="colHeader" scope="col" style="white-space:nowrap;">Default E-mail Address (Required to access BBOS)<br><span class=annotation>The default e-mail address will be used to access BBOS</span></th>

		</tr>
    <asp:Repeater ID=repPersonList runat=server>
        <ItemTemplate>
		    <%# IncrementRepeaterCount()  %>
		    <tr id="<%# Eval("pers_PersonID") %>" person_linkID="<%# Eval("peli_PersonLinkID") %>" <%# GetRowClass(_iRepeaterCount) %>>
			    <td align="center"><%# Eval("pers_PersonID") %></td>
			    <td align="left"><%# Eval("PersonName") %></td>
			    <td align="left"><%# Eval("CityStateCountryShort") %></td>
			    <td align="left"><%# Eval("peli_PRTitle") %></td>
			    <td align="center"><input type=checkbox name=cb<%# Eval("peli_PersonLinkID") %> value=<%# Eval("peli_PersonLinkID") %> personid="<%# Eval("pers_PersonID") %>" onclick=CheckEmailAddress(this); <%# GetChecked(Eval("peli_PRConvertToBBOS"), Eval("prwu_AccessLevel")) %>></td>
			    <td align="left"><input type=text size=40 value="<%# Eval("emai_EmailAddress") %>" name=txt<%# Eval("peli_PersonLinkID") %> onchange=CheckCheckbox(this); style="text-align:left" tsiEmail=true tsiDisplayName='<%# Eval("PersonName") %> Email' person_linkID="<%# Eval("peli_PersonLinkID") %>"></td>
		    </tr>
        </ItemTemplate>
    </asp:Repeater>
    </table>

    <p></p>
    <div style="height:33px;text-align:center;">
    <asp:HyperLink ID=btnMembership Text="Membership Options" NavigateUrl="Membership.aspx" CssClass=btn-round runat=server />
    <asp:HyperLink ID=btnPrivacy Text="Privacy Policy" NavigateUrl="PrivacyPolicy.aspx"  CssClass=btn-round runat=server />
    </div>

    <div style="height:33px;text-align:center;">
        <asp:LinkButton ID=btnSave Text="Save" CssClass=btn-round OnClick=btnSaveOnClick tsiDisable=true runat=server />
        <asp:LinkButton ID=btnCancel Text="Cancel" CssClass=btn-round OnClick=btnCancelOnClick runat=server />
    </div>    

    <script>
        EnableRowHighlight(document.getElementById('tblPersonAccess'));
    </script>
    
<script>
    OnLoad();
</script>   
</asp:Content>
