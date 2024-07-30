<%@ Page Title="" Language="C#" MasterPageFile="~/Produce.Master" AutoEventWireup="true" CodeBehind="MembershipOptions.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PublicProfiles.MembershipOptions" %>
<%@ MasterType VirtualPath="~/Produce.Master" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc" TagName="MembershipHeader"     Src="~/Controls/MembershipHeader.ascx" %>

<asp:Content ContentPlaceHolderID="BBOSPublicProfilesHead" runat="server">
	<style type="text/css">
		/*.input td {padding:2px;}*/
        .mar_bot {margin-bottom: 10px;}
		.label {font-weight:bold;white-space:nowrap; color:black; font-size:100%;}
        .validationError {color:Red;text-align:left;}
        .validationError ul {list-style-type:disc;margin-left:15px;}
        .validationError ul li {color:Red;margin-bottom:0px;padding:0px;}
		.required {font-weight:bold;font-size:12pt;}
		.bulletList {list-style-type:disc;
		             list-style-position:inside;
					 margin-left:25px;
					 margin-top:0px;}T
					 
		.bulletListItem {margin-top:5px;}
	</style>

	<script type="text/javascript">
        function toggleCompanyUpdates(cbCompanyUpdates) {

            if ($("#<% =rbExpressUpdateTypeFax.ClientID %>").length > 0)
                document.getElementById("<% =rbExpressUpdateTypeFax.ClientID %>").disabled = true;
            if ($("#<% =txtExpressUpdateFaxAreaCode.ClientID %>").length > 0)
                document.getElementById("<% =txtExpressUpdateFaxAreaCode.ClientID %>").disabled = true;
            if ($("#<% =txtExpressUpdateFaxNumber.ClientID %>").length > 0)
                document.getElementById("<% =txtExpressUpdateFaxNumber.ClientID %>").disabled = true;
            if ($("#<% =rbExpressUpdateTypeEmail.ClientID %>").length > 0)
                document.getElementById("<% =rbExpressUpdateTypeEmail.ClientID %>").disabled = true;
            if ($("#<% =txtExpressUpdateEmail.ClientID %>").length > 0)
                document.getElementById("<% =txtExpressUpdateEmail.ClientID %>").disabled = true;

            if (cbCompanyUpdates.checked) {
                if ($("#<% =rbExpressUpdateTypeFax.ClientID %>").length > 0)
                    document.getElementById("<% =rbExpressUpdateTypeFax.ClientID %>").disabled = false;
                if ($("#<% =rbExpressUpdateTypeEmail.ClientID %>").length > 0)
                    document.getElementById("<% =rbExpressUpdateTypeEmail.ClientID %>").disabled = false;

                if ($("#<% =rbExpressUpdateTypeFax.ClientID %>").length > 0) {
                    if (document.getElementById("<% =rbExpressUpdateTypeFax.ClientID %>").checked) {
                        if ($("#<% =txtExpressUpdateFaxAreaCode.ClientID %>").length > 0)
                            document.getElementById("<% =txtExpressUpdateFaxAreaCode.ClientID %>").disabled = false;
                        if ($("#<% =txtExpressUpdateFaxNumber.ClientID %>").length > 0)
                            document.getElementById("<% =txtExpressUpdateFaxNumber.ClientID %>").disabled = false;
                    }
                }
                if ($("#<% =rbExpressUpdateTypeEmail.ClientID %>").length > 0) {
                    if (document.getElementById("<% =rbExpressUpdateTypeEmail.ClientID %>").checked) {
                        document.getElementById("<% =txtExpressUpdateEmail.ClientID %>").disabled = false;
                    }
                }
			}
		}

	    function toggleLSS(cbLSS) {
	        document.getElementById("<% =txtLSSAdditional.ClientID %>").disabled = true;

	        if (cbLSS.checked) {
	            document.getElementById("<% =txtLSSAdditional.ClientID %>").disabled = false;
	        }
        }

        function togglePublishedLogo() {
            if ($("#<%=cbPublishedLogo.ClientID%>").is(":checked"))
                $("#trPublishedLogoFileUpload").show();
            else
                $("#trPublishedLogoFileUpload").hide();
        }

        function validate() {
            if ($('#<% =cbExpressUpdates.ClientID %>').prop('checked')) {

                if ($('#<% =rbExpressUpdateTypeEmail.ClientID %>').prop('checked')) {
                    if ($('#<% =txtExpressUpdateEmail.ClientID %>').val() == '') {
                        $("#liErrEmail").show();
                        $("#liErrFax").hide();
                        $("#validationError").show();
                        return false;
                    }
                }

                if ($('#<% =rbExpressUpdateTypeFax.ClientID %>').prop('checked')) {
                    if ($('#<% =txtExpressUpdateFaxNumber.ClientID %>').val() == '') {
                        $("#liErrEmail").hide();
                        $("#liErrFax").show();
                        $("#validationError").show();
                        return false;
                    }
                }
            }

            if ($('#<% =cbPublishedLogo.ClientID %>').is(':checked')) {
                if ($('#<% =fuPublishedLogo.ClientID %>').val() == '') {
                        $("#liErrPublishedLogo").show();
                        $("#validationError").show();
                        return false;
                    }
                }

            $("#validationError").hide();
            return true;
        }

		$(document).ready(function () {
            toggleCompanyUpdates(document.getElementById("<% =cbExpressUpdates.ClientID %>"));
            toggleLSS(document.getElementById("<% =cbLSS.ClientID %>"));
            togglePublishedLogo();
        });
    </script>

</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="BBOSPublicProfilesMain" runat="server">

	<h1><%=Resources.Global.SelectMembershipOptions %></h1>

	<uc:MembershipHeader id="membershipHeader" CurrentStep="2" runat="server" />

    <div class="row validationError mar_bot" style="display: none;" id="validationError">
        <div class="col-xs-12">
            <p><%=Resources.Global.ErrorsOnPage %>:</p>
            <ul class="bulletList">
                <li class="bulletListItem" id="liErrEmail" style="display: none;"><%=Resources.Global.PleaseSpecifyExpressUpdateEmail %></li>
                <li class="bulletListItem" id="liErrFax" style="display: none;"><%=Resources.Global.PleaseSpecifyExpressUpdateFax %></li>
                <li class="bulletListItem" id="liErrPublishedLogo" style="display: none;"><%=Resources.Global.PleaseSpecifyPublishedLogoJPGFile %></li>
            </ul>
        </div>
    </div>

    <div class="row">
        <strong><%=Resources.Global.YourMembershipIncludes %>:</strong>
    </div>
	
    <div class="row">
        <ul class="bulletList">
            <li class="bulletListItem"><%=Resources.Global.MembershipIncludes_1%></li>
            <li class="bulletListItem"><%=Resources.Global.MembershipIncludes_2%></li>
        </ul>
    </div>

    <div class="row">
        <strong><%=Resources.Global.ExtraServicesAvailableForPurchase%></strong>
    </div>

    <div class="row mar_bot">
        <div class="col-xs-2 col-sm-2 col-md-1 text-right">
            <asp:CheckBox ID="cbLSS" onclick="toggleLSS(this);" runat="server" />
        </div>
        <div class="col-xs-10 col-sm-10 col-md-11">
            <strong><%=Resources.Global.LocalSourceLicense %>:&nbsp;<asp:Literal ID="litLSSPrice" runat="server" />&nbsp;<%=Resources.Global.Annually_LC %></strong>.
            <%=Resources.Global.LocalSourceLicense_Description %>
        </div>
    </div>

    <div class="row mar_bot">
        <div class="col-xs-2 col-sm-2 col-md-1">
            <asp:TextBox ID="txtLSSAdditional" CssClass="form-control" MaxLength="3" runat="server" /><cc1:FilteredTextBoxExtender TargetControlID="txtLSSAdditional" FilterType="Numbers" runat="server" />
        </div>
        <div class="col-xs-10 col-sm-10 col-md-11">
            <strong>
                <asp:Literal ID="litLSSAddtionalPrice" runat="server" />&nbsp;<%=Resources.Global.Annually_LC %></strong>.
                <%=Resources.Global.AdditionalLocalSourceLicense%>
        </div>
    </div>

    <div class="row mar_bot hidden">
        <div class="col-xs-2 col-sm-2 col-md-1">
            <asp:TextBox ID="txtBlueBook" CssClass="form-control" MaxLength="3" runat="server" />
            <cc1:FilteredTextBoxExtender TargetControlID="txtBlueBook" FilterType="Numbers" runat="server" />
        </div>
        <div class="col-xs-10 col-sm-10 col-md-11">
            <strong><%=Resources.Global.HardCoverBlueBook %>:&nbsp;<asp:Literal ID="litBlueBookPrice" runat="server" />&nbsp;<%=Resources.Global.Annually_LC %></strong>.
            <%=Resources.Global.HardCoverBlueBook_Description %>
        </div>
    </div>

    <div class="row">
        <div class="col-xs-2 col-sm-2 col-md-1 text-right">
            <asp:CheckBox ID="cbExpressUpdates" onclick="toggleCompanyUpdates(this);" runat="server" />
        </div>
        <div class="col-xs-10 col-sm-10 col-md-11">
            <strong><%=Resources.Global.ExpressUpdateReports %>:&nbsp;<asp:Literal ID="litExpressUpdatePrice" runat="server" />&nbsp;<%=Resources.Global.Annually_LC %></strong>. 
            <%=Resources.Global.ExpressUpdateReports_Description %>
        </div>
    </div>

    <div class="row" id="trCompanyUpdateEmail" runat="server" visible="true">
        <div class="col-lg-2 col-md-2 col-sm-2 col-xs-3 col-xs-offset-2 col-sm-offset-2 col-md-offset-1">
            <asp:RadioButton ID="rbExpressUpdateTypeEmail" GroupName="rbExpressUpdateType" onclick="toggleCompanyUpdates(document.getElementById('<% =cbExpressUpdates.ClientID %>'));" runat="server" />
            <strong><%=Resources.Global.Email %>:</strong>
        </div>
        <div class="col-lg-3 col-md-4 col-sm-5 col-xs-6 nopadding_lr">
            <asp:TextBox ID="txtExpressUpdateEmail" CssClass="form-control" MaxLength="255" runat="server" />
        </div>
    </div>

    <div class="row mar_top_7" id="trCompanyUpdateFax" runat="server" visible="true">
        <div class="col-lg-2 col-md-2 col-sm-2 col-xs-3 col-xs-offset-2 col-sm-offset-2 col-md-offset-1">
            <asp:RadioButton ID="rbExpressUpdateTypeFax" GroupName="rbExpressUpdateType" runat="server" />
            <strong><%=Resources.Global.FAX %>:</strong>
        </div>
        <div class="col-lg-3 col-md-4 col-sm-5 col-xs-6 input-group">
            <asp:TextBox ID="txtExpressUpdateFaxAreaCode" CssClass="form-control" Columns="3" MaxLength="5" runat="server" />
            <span class="input-group-addon">-</span>
            <asp:TextBox ID="txtExpressUpdateFaxNumber" CssClass="form-control" Columns="7" MaxLength="10" runat="server" />
        </div>
    </div>

    <div class="row">
        <div class="col-xs-2 col-sm-2 col-md-1 text-right">
            <asp:CheckBox ID="cbPublishedLogo" onclick="togglePublishedLogo();" runat="server" />
        </div>
        <div class="col-xs-10 col-sm-10 col-md-11">
            <strong><asp:Literal ID="litCompanyLogoTitle" runat="server" /><asp:Literal ID="litPublishedLogoPrice" runat="server" /><asp:Literal ID="litAnnually" runat="server" /></strong>. 
            <%=Resources.Global.YourCompanyLogo_Description %>
        </div>
    </div>
    <div class="row" id="trPublishedLogoFileUpload">
        <div class="col-lg-2 col-md-2 col-sm-2 col-xs-3 col-xs-offset-2 col-sm-offset-2 col-md-offset-1 text-right">
            <strong><%=Resources.Global.LogoFile %>:</strong>
        </div>
        <div class="col-lg-3 col-md-4 col-sm-5 col-xs-6 nopadding_lr">
            <asp:FileUpload id="fuPublishedLogo" runat="server"  accept=".jpg" />
        </div>
    </div>

    <div class="row text-center">
	   <asp:LinkButton ID="LinkButton3" Text="<%$ Resources:Global, Previous%>" class="button" OnClick="btnPreviousOnClick" style="font-size:10pt;width:100px" runat="server" />
	   <asp:LinkButton ID="LinkButton1"  Text="<%$ Resources:Global, Next%>"    class="button" OnClick="btnNextOnClick"     style="font-size:10pt;width:100px" OnClientClick="return validate();" runat="server" />
       <asp:HyperLink ID="btnCancel" Text="<%$ Resources:Global, Cancel%>" class="button" Target="_top"  style="font-size:10pt;width:100px"   runat="server" />
    </div>
</asp:Content>