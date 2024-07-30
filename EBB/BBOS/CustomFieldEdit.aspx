<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CustomFieldEdit.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CustomFieldEdit" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function onRemove() {
            var bRemovedChecked = false;
            var valueCount = document.getElementById("<% =hdnValueCount.ClientID %>").value;
            for (i = 0; i < valueCount; i++) {
                var cbRemove = document.getElementById("contentMain_cbDelete" + i.toString());
                if (cbRemove.checked) {
                    bRemovedChecked = true;
                }
            }

            if (bRemovedChecked) {
                //return confirm("Some field values have been selected for removal.  These values will be removed from any company they are associated with.  Do you want to continue?");
                return confirm("<%= Resources.Global.SomeFieldValuesSelectedForRemoval1 %>");
            }
        }

        function toggleFieldType() {

            var fieldType = document.getElementById("<% =ddlFieldType.ClientID %>").value;
            if (fieldType == "DDL") {
                document.getElementById("<% =trFieldValues.ClientID %>").style.display = "";
            } else {
                document.getElementById("<% =trFieldValues.ClientID %>").style.display = "none";
            }
        }

        function preStdValidation(form) {
            alert(document.getElementById("<% =hdnValueCount.ClientID %>").value);

            var fieldType = document.getElementById("<% =ddlFieldType.ClientID %>").value;
            if (fieldType == "DDL") {

                if (document.getElementById("<% =hdnValueCount.ClientID %>").value == "0") {
                    //displayErrorMessage("To save this cusotm data field as a Drop Down List, at least one data field value must be specified.");
                    displayErrorMessage("<%= Resources.Global.ToSaveCustomDataAsDropDownList%>");
                    return false;
                }
            }

            return true;
        }
    </script>
    <style>
        .required {
            width: 10px;
            z-index: 9;
            top: -30px;
            float: right;
            border: none;
            left: -10px;
        }
        .clr_blu {
            background: transparent !important;
            border: none;
        }
        .col-md-4 {
            text-align: right;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    <div style="text-align: left;">
        <div class="Title">
        </div>

        <div class="table table-hover">

            <div class="row mar_top">
                <div class="col-md-4">
                    <label runat="server" class="clr_blu"><%= Resources.Global.DataFieldLabel %>:</label>
                </div>
                
                <div class="col-md-8 form-inline">
                    <asp:TextBox MaxLength="50" Columns="45" ID="txtFieldLabel" tsiRequired="true" tsiDisplayName="Field Label" runat="server" CssClass="form-control" />
                    <% =PageBase.GetRequiredFieldIndicator() %>
                </div>
            </div>

            <div class="row mar_top_7">
                <div class="col-md-4">
                    <label runat="server" class="clr_blu vertical-align-top"><%= Resources.Global.DataFieldType %>:</label>
                </div>
                <div class="col-md-8 form-inline">
                    <asp:DropDownList ID="ddlFieldType" onchange="toggleFieldType()" runat="server" CssClass="form-control" />
                </div>
            </div>

            <div class="row mar_top_7" id="trFieldValues" runat="server">
                <div class="col-md-4">
                    <label runat="server" class="clr_blu vertical-align-top"><%= Resources.Global.DataFieldValues %>:</label>
                </div>
                <div class="col-md-5 col-sm-7 col-xs-12 form-inline">
                    <asp:UpdatePanel ID="updpnlFieldValues" runat="server" ChildrenAsTriggers="true" UpdateMode="Conditional">
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="btnNew" EventName="Click" />
                        </Triggers>
                        <ContentTemplate>
                            <asp:Table ID="tblFieldValues" runat="server" CssClass="table table-striped table-hover tab_bdy">
                                <asp:TableRow>
                                    <asp:TableCell Text="<%$Resources:Global, Values %>" />
                                    <asp:TableCell Text="<%$Resources:Global, Remove2 %>" CssClass="text-center" />
                                </asp:TableRow>
                            </asp:Table>

                            <asp:LinkButton ID="btnNew" runat="server" CssClass="btn gray_btn" OnClick="btnNewRow_Click">
		                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnNewValue %>" />
                            </asp:LinkButton>

                            <asp:HiddenField ID="hdnValueCount" runat="server" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>

            <div class="row nomargin text-left">
                <div class="col-md-12 mar_top">
                    <asp:LinkButton ID="btnSave" runat="server" CssClass="btn gray_btn" OnClick="btnSave_Click" OnClientClick="return onRemove();">
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnSave %>" />
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancel_Click" OnClientClick="bDirty=false; DisableValidation();">
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnCancel %>" />
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnSaveDummy" runat="server" CssClass="btn gray_btn" OnClientClick="return onRemove();" OnClick="btnSave_Click" Style="display: none;">
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnCancel %>" />
                    </asp:LinkButton>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptSection" runat="server">
</asp:Content>