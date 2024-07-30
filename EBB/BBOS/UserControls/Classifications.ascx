<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Classifications.ascx.cs" Inherits="PRCo.BBOS.UI.Web.Classifications" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Label ID="hidCompanyID" Visible="false" runat="server" />

<%--Classifications--%>
<div class="col-md-12 text-center nopadding" id="pnlClassifications1" runat="server" visible="true">
    <asp:UpdatePanel ID="updpnlClassifications1" runat="server">
        <ContentTemplate>
            <a name="Classifications" class="anchor"></a>

            <h4 class="blu_tab">
                <asp:PlaceHolder ID="phClassifications" runat="server"><%=Resources.Global.Classifications %></asp:PlaceHolder>
            </h4>

            <div class="pad5">
                <asp:GridView ID="gvClassifications1"
                    AllowSorting="true"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="table table-striped table-hover tab_bdy"
                    GridLines="None"
                    OnSorting="GridView_Sorting"
                    OnRowDataBound="GridView_RowDataBound">
                    <Columns>
                        <asp:BoundField HeaderText='<%$ Resources:Global, Abbreviation %>' HeaderStyle-CssClass="text-nowrap explicitlink" DataField="prcl_Abbreviation" SortExpression="prcl_Abbreviation" ItemStyle-CssClass="text-left" />
                        <asp:BoundField HeaderText='<%$ Resources:Global, Description %>' HeaderStyle-CssClass="text-nowrap explicitlink" DataField="Name" SortExpression="Name" ItemStyle-CssClass="text-nowrap text-left" />
                        <asp:BoundField HeaderText='<%$ Resources:Global, Definition %>' HeaderStyle-CssClass="text-nowrap" DataField="Description" ItemStyle-CssClass="text-left" />
                        <asp:BoundField HeaderText='<%$ Resources:Global, Sequence%>' HeaderStyle-CssClass="text-nowrap" DataField="prc2_Sequence" SortExpression="prc2_Sequence" ItemStyle-CssClass="text-left" Visible="false" />
                    </Columns>
                </asp:GridView>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>

<div class="accordion-item" id="pnlClassifications2" runat="server" visible="false">
    <asp:UpdatePanel ID="updpnlClassifications2" runat="server">
        <ContentTemplate>
            <div class="accordion-header">
                <button
                    class="accordion-button collapsed"
                    type="button"
                    data-bs-toggle="collapse"
                    data-bs-target="#flush_classifications"
                    aria-expanded="false"
                    aria-controls="flush_classifications">
                    <h5><%=Resources.Global.Classifications %></h5>
                </button>
            </div>
            <div
                id="flush_classifications"
                class="accordion-collapse collapse tw-p-4">
                <div class="bbs-card-body no-padding">
                    <asp:GridView ID="gvClassifications2"
                        AllowSorting="true"
                        runat="server"
                        AutoGenerateColumns="false"
                        CssClass="table"
                        GridLines="None"
                        OnSorting="GridView_Sorting"
                        OnRowDataBound="GridView_RowDataBound">
                        <Columns>
                            <asp:BoundField HeaderText='<%$ Resources:Global, Abbreviation %>' HeaderStyle-CssClass="text-nowrap explicitlink" DataField="prcl_Abbreviation" SortExpression="prcl_Abbreviation" ItemStyle-CssClass="text-left" />
                            <asp:BoundField HeaderText='<%$ Resources:Global, Description %>' HeaderStyle-CssClass="text-nowrap explicitlink" DataField="Name" SortExpression="Name" ItemStyle-CssClass="text-nowrap text-left" />
                            <asp:BoundField HeaderText='<%$ Resources:Global, Definition %>' HeaderStyle-CssClass="text-nowrap" DataField="Description" ItemStyle-CssClass="text-left" />
                            <asp:BoundField HeaderText='<%$ Resources:Global, Sequence%>' HeaderStyle-CssClass="text-nowrap" DataField="prc2_Sequence" SortExpression="prc2_Sequence" ItemStyle-CssClass="text-left" Visible="false" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
