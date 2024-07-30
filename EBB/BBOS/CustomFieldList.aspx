<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CustomFieldList.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CustomFieldList" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    <div class="Title mar_bot">
    </div>

    <div class="row nomargin">
        <asp:Label ID="lblRecordCount" CssClass="RecordCnt" runat="server" />
        <span class="RecordCnt" id="lblSelectedCount"></span>
    </div>

    <br />

    <asp:GridView ID="gvCustomFields"
        runat="server"
        AutoGenerateColumns="false"
        CssClass="sch_result table table-striped table-hover"
        GridLines="None">
        <Columns>
            <asp:TemplateField ItemStyle-CssClass="text-center vertical-align-top" HeaderStyle-CssClass="text-center vertical-align-top">
                <HeaderTemplate>
                    <% =Resources.Global.Select%><br />
                    <% =PageBase.GetCheckAllCheckbox("cbCustomField", "setSelectedCount();") %>
                </HeaderTemplate>
                <ItemTemplate>
                    <input type="checkbox" name="cbCustomField" value="<%# Eval("prwucf_WebUserCustomFieldID") %>" onclick="setSelectedCount();" />
                </ItemTemplate>
            </asp:TemplateField>

            <asp:BoundField HeaderText="<%$ Resources:Global, CustomData %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" DataField="prwucf_Label" SortExpression="prwucf_Label" />

            <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" HeaderText="<%$ Resources:Global, Type %>">
                <ItemTemplate>
                    <%# GetReferenceValue("prwucf_FieldTypeCode", (string)Eval("prwucf_FieldTypeCode")) %>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:BoundField HeaderText="<%$ Resources:Global,NumOfValues %>" DataFormatString="{0:###,##0}" HeaderStyle-CssClass="text-nowrap text-center vertical-align-top" ItemStyle-CssClass="text-center" DataField="ValueCount" SortExpression="CompanyCount" />
            <asp:BoundField HeaderText="<%$ Resources:Global,NumOfCompanies %>" DataFormatString="{0:###,##0}" HeaderStyle-CssClass="text-nowrap text-center vertical-align-top" ItemStyle-CssClass="text-center" DataField="CompanyCount" SortExpression="ValueCount" />
        </Columns>
    </asp:GridView>

    <div class="row nomargin text-left mar_top">
        <asp:LinkButton ID="btnNew" OnClick="btnNew_Click" CssClass="btn gray_btn" runat="server">
            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, NewCustomData %>" />
        </asp:LinkButton>
        <asp:LinkButton ID="btnEdit" OnClick="btnEdit_Click" CssClass="btn gray_btn" runat="server">
            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Edit %>" />
        </asp:LinkButton>
        <asp:LinkButton ID="btnDelete" OnClick="btnDelete_Click" CssClass="btn gray_btn" runat="server">
            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Delete %>" />
        </asp:LinkButton>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        function setSelectedCount() {
            setSelectedCountInternal("cbCustomField", "lblSelectedCount");
        }

        setSelectedCount();
    </script>
</asp:Content>
