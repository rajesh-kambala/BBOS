<%@ Page Title="" Language="C#" MasterPageFile="~/Produce.Master" AutoEventWireup="true" CodeBehind="MembershipUsers.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PublicProfiles.MembershipUsers" %>
<%@ MasterType VirtualPath="~/Produce.Master" %>
<%@ Register TagPrefix="uc" TagName="MembershipHeader" Src="~/Controls/MembershipHeader.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="BBOSPublicProfilesHead" runat="server">
    <style type="text/css">
        .input td {
            padding: 2px;
        }

        .label {
            font-weight: bold;
            white-space: nowrap;
            color: black;
            font-size: 100%;
        }

        .validationError {
            color: Red;
            text-align: left;
        }

            .validationError ul li {
                list-style-type: disc;
                margin-left: 25px;
                color: Red;
            }

        .required {
            font-weight: bold;
            font-size: 12pt;
        }

        .bulletList {
            list-style-type: disc;
            margin-left: 25px;
            margin-top: 0px;
        }

        .bulletListItem {
            margin-top: 5px;
        }

        .colHeader {
            font-weight: bold;
        }
    </style>

    <script type="text/javascript">
        function validateUsers() {

            var emailAddressses = [];
            var emailIndex = 0;

            var index = 1;

            while ($("#txtFirstName" + index).length) {

                // If any field is specified, they all must
                // be specified
                if (($("#txtFirstName" + index).val() != "") ||
                    ($("#txtLastName" + index).val() != "") ||
                    ($("#txtEmail" + index).val() != "")) {

                    var bReqError = false;
                    var bDupEmailError = false;

                    if ($("#txtFirstName" + index).val() == "") {
                        bReqError = true;
                    }

                    if ($("#txtLastName" + index).val() == "") {
                        bReqError = true;
                    }

                    if ($("#txtEmail" + index).val() == "") {
                        bReqError = true;
                    } else {

                        var found = false;
                        for (i = 0; i < emailIndex; i++) {
                            if (emailAddressses[i] == $("#txtEmail" + index).val()) {
                                bDupEmailError = true;
                                found = true;
                            }
                        }

                        if (!found) {
                            emailAddressses[emailIndex] = $("#txtEmail" + index).val();
                            emailIndex++;

                        }
                    }

                    if ((bReqError) ||
                        (bDupEmailError)) {
                        $("#BBOSPublicProfilesMain_validationError").show();


                        if (bReqError) {
                            $("#validReqFields").show();
                        }

                        if (bDupEmailError) {
                            $("#duplicateEmail").show();
                        }

                        return false;
                    }
                }

                index++;
            }

            return true;
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="BBOSPublicProfilesMain" runat="server">
    <h1><%=Resources.Global.MembershipUserSetup%></h1>

    <uc:MembershipHeader ID="membershipHeader" CurrentStep="3" runat="server" />

    <div class="row validationError mar_bot" style="display: none;" id="validationError" runat="server">
        <div class="col-xs-12">
            <p><%=Resources.Global.ErrorsOnPage%>:</p>
            <ul class="bulletList">
                <li class="bulletListItem" id="validReqFields" style="display: none;"><%=Resources.Global.Errors_EmailAddressRequired %></li>
                <li class="bulletListItem" id="duplicateEmail" style="display: none;"><%=Resources.Global.Errors_DuplicateEmailFound %></li>
                <li class="bulletListItem" id="validEmails" runat="server" visible="false"><%=Resources.Global.Errors_FollowingEmailsInvalid %><asp:Literal ID="invalidList" runat="server" /></li>
                <li class="bulletListItem" id="exisitngEmails" runat="server" visible="false"><%=Resources.Global.Errors_FollowingEmailsAlreadyAssociated %><asp:Literal ID="existingList" runat="server" /></li>
            </ul>
        </div>
    </div>

    <div class="row">
        <%=Resources.Global.TellUsNamesAndEmailAddresses %>
    </div>

    <table class="input" style="width: 100%; margin-left: auto; margin-right: auto;">
        <tr>
            <td class="colHeader" style="width: 2%">&nbsp;</td>
            <td class="colHeader" style="width: 23%"><%=Resources.Global.Title %></td>
            <td class="colHeader" style="width: 23%"><%=Resources.Global.FirstName %></td>
            <td class="colHeader" style="width: 23%"><%=Resources.Global.LastName %></td>
            <td class="colHeader" style="width: 29%"><%=Resources.Global.EmailAddress %></td>
        </tr>

        <asp:Repeater ID="repMembershipUsers" runat="server">
            <ItemTemplate>
                <%# IncrementRepeaterCount()  %>
                <tr>
                    <td style="width: 2%; text-align: right"><%# _iRepeaterCount%></td>
                    <td style="width: 23%">
                        <input id="txtTitle<%# _iRepeaterCount %>" name="txtTitle<%# _iRepeaterCount %>" value="<%# Eval("Title2") %>" style="width: 100%" maxlength="30"></td>
                    <td style="width: 23%">
                        <input id="txtFirstName<%# _iRepeaterCount %>" name="txtFirstName<%# _iRepeaterCount %>" value="<%# Eval("FirstName2") %>" style="width: 100%" maxlength="30"></td>
                    <td style="width: 23%">
                        <input id="txtLastName<%# _iRepeaterCount %>" name="txtLastName<%# _iRepeaterCount %>" value="<%# Eval("LastName2") %>" style="width: 100%" maxlength="30"></td>
                    <td style="width: 29%">
                        <input id="txtEmail<%# _iRepeaterCount %>" name="txtEmail<%# _iRepeaterCount %>" value="<%# Eval("Email2") %>" style="width: 100%" maxlength="255"></td>
                </tr>
            </ItemTemplate>
        </asp:Repeater>
    </table>

    <div class="row">
        <div class="col-xs-11 col-xs-offset-1  mar_top_25">
            <strong><%=Resources.Global.SpecialInstructions %>:</strong><br />
            <asp:TextBox ID="txtSpecialInstructions" TextMode="MultiLine" Rows="5" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row text-center">
        <asp:LinkButton ID="LinkButton3" Text="<%$ Resources:Global, Previous%>" class="button" OnClick="btnPreviousOnClick" Style="font-size: 10pt; width: 100px" runat="server" />
        <asp:LinkButton ID="LinkButton1" Text="<%$ Resources:Global, Next%>" class="button" OnClick="btnNextOnClick" Style="font-size: 10pt; width: 100px" OnClientClick="return validateUsers();" runat="server" />
        <asp:HyperLink ID="btnCancel" Text="<%$ Resources:Global, Cancel%>" class="button" Target="_top" Style="font-size: 10pt; width: 100px" runat="server" />
    </div>
</asp:Content>