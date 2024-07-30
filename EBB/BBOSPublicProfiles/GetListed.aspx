<%@ Page Title="" MaintainScrollPositionOnPostBack="false" Language="C#" MasterPageFile="~/Produce.Master" EnableEventValidation="false" AutoEventWireup="true" CodeBehind="GetListed.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PublicProfiles.GetListed" %>
<%@ MasterType VirtualPath="~/Produce.Master" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ContentPlaceHolderID="BBOSPublicProfilesHead" runat="server">
	<style type="text/css">
		.input td {padding:2px;}
		.label {font-weight:bold;white-space:nowrap;}
		.validationError {color:Red;text-align:left;}
		.validationError ul {list-style-type:disc;margin-left:15px;}
		.validationError ul li {color:Red;margin-bottom:0px;padding:0px;}
		.required {color:Red;}
		.bulletList {list-style-type:disc;
					 margin-left:25px;
					 margin-top:0px;}
		.bulletListItem {margin-top:5px;}
		.cbLabel input {vertical-align: middle; margin-right: 5px;}
		
	</style>

    <script type="text/javascript">
        function scrollToTop() {
            window.setTimeout("scrollTest()", 500);
        }

        function scrollTest() {
            var el = document.getElementById("BBOSPublicProfilesMain_pnlThankYou");
            el.scrollIntoView(true);
		}

		function ready() {
            var rcres = grecaptcha.getResponse();
			if (rcres.length)
				return true;

			alert("Please verify the reCAPTCHA challenge before clicking Submit.");
			return false;
        }

    </script>

	<script src="https://www.google.com/recaptcha/api.js" async defer></script>
</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="BBOSPublicProfilesMain" runat="server">

<div style="width:100%; max-width:590px;">

<asp:Panel ID="pnlForm" runat="server">
   
	<hr/>

	<div style="margin:10px;">
		<asp:ValidationSummary ID="ValidationSummary1" CssClass="validationError" ValidationGroup="Required" HeaderText="One or more required fields are missing" DisplayMode="BulletList" runat="server"/>
		<asp:ValidationSummary ID="ValidationSummary2" CssClass="validationError" ValidationGroup="InvalidEmail" HeaderText="The specified email address is invalid." DisplayMode="BulletList" runat="server"/>
	</div>

	<p>Please provide the following information related to you and your business:</p>

    <p style="color:red;">Fields marked with * are required.</p>

	<p><div class="registertitle">Your Full Name <span class="required">*</span></div>
	   <div class="registerinput"><asp:TextBox ID="txtSubmitterName" Columns="30" MaxLength="100" runat="server" />
	   <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ValidationGroup="Required" ControlToValidate="txtSubmitterName" Display="None" runat="server" /></div>
	</p>
	<p><div class="registertitle">Your Phone Number <span class="required">*</span></div>
	   <div class="registerinput"><asp:TextBox ID="txtSubmitterPhone" Columns="30" MaxLength="25" runat="server" />
			<asp:RequiredFieldValidator ID="RequiredFieldValidator2" ValidationGroup="Required"  ControlToValidate="txtSubmitterPhone" Display="None" runat="server" /></div>
	</p>
	<p><div class="registertitle">Your Email Address <span class="required">*</span></div>
	   <div class="registerinput"><asp:TextBox ID="txtSubmitterEmail" Columns="30" MaxLength="255" runat="server" />
	   <asp:RequiredFieldValidator ID="RequiredFieldValidator3" ValidationGroup="Required" ControlToValidate="txtSubmitterEmail" Display="None" runat="server" />
	   <asp:RegularExpressionValidator ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" Display="None"  ValidationGroup="InvalidEmail" ControlToValidate="txtSubmitterEmail" ID="RegularExpressionValidator1" runat="server" />
	   </div>
	</p>

	<hr/>

	<p>Please enter the following information for your company:</p>

	<p><div class="registertitle">Company Name <span class="required">*</span></div>
	   <div class="registerinput"><asp:TextBox ID="txtCompanyName" Columns="30" MaxLength="200" runat="server" />
	   <asp:RequiredFieldValidator ID="RequiredFieldValidator4" ValidationGroup="Required" ControlToValidate="txtCompanyName" Display="None" runat="server" /></div>
	</p>
	<p><div class="registertitle">Company Address Line 1 <span class="required">*</span></div>
	   <div class="registerinput"><asp:TextBox ID="txtStreet1" Columns="30" MaxLength="40" runat="server" />
	   <asp:RequiredFieldValidator ID="RequiredFieldValidator5" ValidationGroup="Required" ControlToValidate="txtStreet1" Display="None" runat="server" /></div>
	</p>
	<p><div class="registertitle">Company Address Line 2 </div>
	   <div class="registerinput"><asp:TextBox ID="txtStreet2" Columns="30" MaxLength="40" runat="server" /></div>
	</p>
	<p><div class="registertitle">Company City <span class="required">*</span></div>
	   <div class="registerinput"><asp:TextBox ID="txtCity" Columns="30" MaxLength="34" runat="server" />
	   <asp:RequiredFieldValidator ID="RequiredFieldValidator6" ValidationGroup="Required" ControlToValidate="txtStreet1" Display="None" runat="server" /></div>
	</p>
	<p><div class="registertitle">Company State/Province<span class="required">*</span></div>
	   <div class="registerinput"><asp:DropDownList ID="ddlState" Width="205" runat="server" />
	   <asp:RequiredFieldValidator ID="RequiredFieldValidator8" ValidationGroup="Required"  ControlToValidate="ddlState" InitialValue=""  Display="None" runat="server" />
	   <cc1:CascadingDropDown ID="cddCountry" TargetControlID="ddlCountry" ServiceMethod="GetCountries" Category="Country" runat="server" />
	   <cc1:CascadingDropDown ID="cddState"   TargetControlID="ddlState"   ServiceMethod="GetStates"    Category="State" ParentControlID="ddlCountry" runat="server" /></div>
	</p>
	<p><div class="registertitle">Company Country <span class="required">*</span></div>
	   <div class="registerinput"><asp:DropDownList ID="ddlCountry" Width="205" runat="server" />
	   <asp:RequiredFieldValidator ID="RequiredFieldValidator7" ValidationGroup="Required" ControlToValidate="ddlCountry" Display="None" runat="server" /></div>
	</p>
	<p><div class="registertitle">Company Postal Code <span class="required">*</span></div>
	   <div class="registerinput"><asp:TextBox ID="txtPostalCode" Columns="10" MaxLength="10" runat="server" />
	   <asp:RequiredFieldValidator ID="RequiredFieldValidator9" ValidationGroup="Required" ControlToValidate="txtPostalCode" Display="None" runat="server" /></div>
	</p>
	<p><div class="registertitle">Company Phone Number <span class="required">*</span></div>
	   <div class="registerinput"><asp:TextBox ID="txtCompanyPhone" Columns="30" MaxLength="25" runat="server" />
	   <asp:RequiredFieldValidator ID="RequiredFieldValidator10" ValidationGroup="Required" ControlToValidate="txtCompanyPhone" Display="None" runat="server" /></div>
	</p>
	<p><div class="registertitle">Company Email Address </div>
	   <div class="registerinput"><asp:TextBox ID="txtCompanyEmail" Columns="30" MaxLength="255" runat="server" />
	   <asp:RegularExpressionValidator ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" Display="None"  ValidationGroup="InvalidEmail" ControlToValidate="txtCompanyEmail" ID="RegularExpressionValidator2" runat="server" /></div>
	</p>
	<p><div class="registertitle">Company Web Site </div>
	   <div class="registerinput"><asp:TextBox ID="txtCompanyWeb" Columns="30" MaxLength="255" runat="server" /></div>
	</p>
	<p><div class="registertitle">Please provide your company's primary function <span class="required">*</span></div>
	   <div class="registerinput"><asp:DropDownList ID="ddlPrimaryFunction" Width="205" runat="server" />
	   <asp:RequiredFieldValidator ID="RequiredFieldValidator11" ValidationGroup="Required" ControlToValidate="ddlPrimaryFunction" Display="None" runat="server" /></div>
	</p>
	<p><div class="registertitle">How did you learn about us?<span class="required">*</span></div>
	   <div class="registerinput"><asp:DropDownList ID="ddlHowLearned" Width="265" runat="server" />
	   <asp:RequiredFieldValidator ID="RequiredFieldValidator12" ValidationGroup="Required" ControlToValidate="ddlHowLearned" Display="None" runat="server" /></div>
	</p>
	<p class="cbLabel">Are you the Owner? 
	   <input type="radio" style="vertical-align: middle; padding-right: 3px;"  name="owner" onclick="document.getElementById('trOwner1').style.display='none';" checked="checked" value="Y" />Yes 
	   <input type="radio" style="vertical-align: middle; padding-right: 3px;"  name="owner" onclick="document.getElementById('trOwner1').style.display='';" value="" />No
	</p>

	<p id="trOwner1" style="display:none;">Please provide the names & titles of the principals of the company<br />
	   <asp:TextBox TextMode="MultiLine" Rows="5" Columns="70" ID="txtPrincipals" runat="server" />
	</p>

	<p class="cbLabel"><asp:CheckBox ID="cbMoreInfo" Text="I would like more information about Blue Book Services Membership." runat="server" />
	</p>

	<hr/>

	<div class="g-recaptcha" data-sitekey='<%=ReCaptchaSiteKey()%>'></div>
				
	<p><asp:LinkButton Text="Submit" class="button" OnClientClick="return ready();" OnClick="btnSubmitOnClick" CausesValidation="false" runat="server" /></p>


</asp:Panel>

<asp:Panel ID="pnlThankYou" Visible="false" style="width:100%; max-width: 590px; margin-left:auto;margin-right:auto;" runat="server">
    <p style="margin-top:10px;">Thank you for entering data into our system. Your information has been submitted. Businesses throughout the <asp:Literal ID="industrytype" runat="server" /> supply chain rely on Blue Book information to make profitable business decisions. This also provides valuable exposure for your company.</p>

	<p style="margin-top:10px;">A <em>Blue Book Services</em> representative will contact you to verify and finalize your listing information prior to publication. For more information about how a Blue Book Membership can help you manage risk and grow sales, review the membership information on our site, or call a representative today at 630 668-3500.</p>

    <p style="margin-top:10px;">- Your Blue Book Team</p>
</asp:Panel>

</div>
<style>
@media(max-width:800px){
	#BBOSPublicProfilesMain_pnlForm > div {
		display: block;
		width: 100%;
	}
	.registerinput {
		margin-left:0;
	}
	#BBOSPublicProfilesMain_pnlForm > p {
		width: 300px;
	}
}
</style>
</asp:Content>
