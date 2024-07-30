<%@ Page Title="" Language="C#" MasterPageFile="~/Produce.Master" AutoEventWireup="true" CodeBehind="MembershipSelect.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PublicProfiles.MembershipSelect" %>
<%@ MasterType VirtualPath="~/Produce.Master" %>
<%@ Register TagPrefix="uc" TagName="MembershipHeader"     Src="~/Controls/MembershipHeader.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="BBOSPublicProfilesHead" runat="server">
    <style type="text/css">
        .input td {padding:2px;}
        .label {font-weight:bold;white-space:nowrap; color:black; font-size:100%;}
        .validationError {color:Red;text-align:left;}
        .validationError ul {list-style-type:disc;margin-left:15px;}
        .validationError ul li {color:Red;margin-bottom:0px;padding:0px;}
        .required {color:Red;}
        .bulletList {list-style-type:disc;
                     margin-left:25px;
                     margin-top:0px;}
        .bulletListItem {margin-top:0px;margin-bottom:0px;}
    </style>
    <script type="text/javascript">
        function validate() {

            var selected = $(':radio:checked[name=rbProductID]');
            if (!selected.length) {
                $("#validationError").show();
                return false;
            }

            $("#validationError").hide();
            return true;

        }

        $(document).ready(function () {
            var selectedValue = $("#<% =productID.ClientID %>").val();
            if (selectedValue != "") {
                $('input[name="rbProductID"][value="' + selectedValue + '"]').prop('checked', true);
            }
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="BBOSPublicProfilesMain" runat="server">
    <asp:HiddenField ID="productID" runat="server" />
    
    <h1><%=Resources.Global.SelectMembershipPackage %></h1>
    
    <uc:MembershipHeader id="membershipHeader" CurrentStep="1" runat="server" />

    <div style="width:350px;margin-left:auto;margin-right:auto;margin:10px;display:none;" class="validationError" id="validationError">
        <p><%=Resources.Global.ErrorsOnPage %>:</p>
        <ul class="bulletList">
            <li class="bulletListItem"><%=Resources.Global.PleaseSelectAMembership %></li>
        </ul>
    </div>

    <asp:Repeater ID="repMemberships" runat="server">
        <HeaderTemplate>
            <table border=1>
        </HeaderTemplate>
        <ItemTemplate>
            <tr>
                <td style="padding:5px;width:15px;vertical-align:top;">
                    <input type="radio" name="rbProductID" id="rbProductID<%# Eval("prod_ProductID") %>" value="<%# Eval("prod_ProductID") %>"  />
                </td>
                <td style="padding:5px;vertical-align:top;width:350px;"> 
                    <label for="rbProductID<%# Eval("prod_ProductID") %>"><b><%# Eval("prod_Name") %></b>, <%# GetProductPrice((string)Eval("prod_Code"), (Eval("StandardUnitPrice")==System.DBNull.Value)?0:(decimal)Eval("StandardUnitPrice"))%>&nbsp;<%=Resources.Global.Annually %></label><br />
                     <%# Eval("prod_PRDescription")%>
                </td>
                <td>
                    <div class="overrideDescription" style="<%# GetOverrideDescriptionDisplay((string)Eval("prod_Code")) %>"><%# GetOverrideDescription((string)Eval("prod_Code")) %></div>
                </td>
            </tr>			        
        </ItemTemplate>
        <FooterTemplate>
            </table>
        </FooterTemplate>
    </asp:Repeater>

    <asp:Panel ID="LumberMsg" Visible="false" runat="server">
        <p>Use these Membership benefits to perform advanced company searches, locate industry personnel, store personnel contact information to build your network, and view important 
        company and personnel changes to make timely business decisions. <em>Please call 630 668-3500 for more information on available Membership discounts and additional benefits for 
        which your company may be eligible.</em></p>
    </asp:Panel>

    <p style="text-align:center;">
       <asp:LinkButton Text="<%$ Resources:Global, Next%>" class="button" OnClick="btnSelectOnClick" style="font-size:10pt;width:100px" OnClientClick="return validate();" runat="server" />
       <asp:HyperLink ID="btnCancel" Text="<%$ Resources:Global, Cancel%>" class="button" Target="_top"  style="font-size:10pt;width:100px"   runat="server"  />
    </p>
 	<style>
		@media screen and (max-width: 600px) { 
			table td { display: inline-block; }
			table td:nth-child(2) {width:270px !important; margin-left: 10px;}
			#BBOSPublicProfilesMain_membershipHeader_tblLumber td { display: table-cell !important; }
		}
	</style>    
</asp:Content>
