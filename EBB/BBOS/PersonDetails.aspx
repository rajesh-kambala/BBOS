<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="PersonDetails.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PersonDetails" MaintainScrollPositionOnPostback="true" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
    </script>
    <style>
        a.gray_btn {
            display: inline-block;
            width: 170px;
            margin-right: 10px;
            margin-bottom: 20px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Label ID="hidPersonID" Visible="false" runat="server" />
    <asp:Label Width="100%" runat="server" ID="lblPersonName" CssClass="bbos_blue_title" />

    <div class="table-responsive">
        <asp:GridView ID="gvCompanies"
            AllowSorting="true"
            runat="server"
            AutoGenerateColumns="false"
            CssClass="sch_result table table-striped table-hover"
            GridLines="none"
            OnSorting="GridView_Sorting"
            OnRowDataBound="GridView_RowDataBound">

            <Columns>

              <asp:TemplateField HeaderText="<%$ Resources:Global, vCard %>" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top">
                <ItemTemplate>
                  <asp:ImageButton ImageUrl='<%# UIUtils.GetImageURL("icon-vcard.gif") %>' ToolTip="<%$ Resources:Global, DownloadVCard %>" value='<%# Eval("comp_CompanyID") %>' OnClick="btnVCardOnClick" runat="server" />
                </ItemTemplate>
              </asp:TemplateField>

                <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left" DataField="comp_CompanyID" />

                <%--Icons Column--%>
                <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
                    <ItemTemplate>
                        <%# GetCompanyDataForCell((int)Eval("comp_CompanyID"), 
                                (string)Eval("comp_PRBookTradestyle"), 
                                (string)Eval("comp_PRLegalName"), 
                                UIUtils.GetBool(Eval("HasNote")), 
                                UIUtils.GetDateTime(Eval("comp_PRLastPublishedCSDate")), 
                                (string)Eval("comp_PRListingStatus"), 
                                true, 
                                UIUtils.GetBool(Eval("HasNewClaimActivity")), 
                                UIUtils.GetBool(Eval("HasMeritoriousClaim")), 
                                UIUtils.GetBool(Eval("HasCertification")), 
                                UIUtils.GetBool(Eval("HasCertification_Organic")), 
                                UIUtils.GetBool(Eval("HasCertification_FoodSafety")), 
                                true, 
                                false)%>
                        <br />
                    </ItemTemplate>
                </asp:TemplateField>

                <%--Company Name column--%>
                <asp:TemplateField HeaderText="<%$ Resources:Global, CompanyName %>" HeaderStyle-CssClass="vertical-align-top" SortExpression="comp_PRBookTradestyle">
                    <ItemTemplate>
                        <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                        <asp:Literal ID="litLegalName" runat="server" Text='<%# PageBase.ParenWrap(Eval("comp_PRLegalName"))%>' />
                        <%# Eval("CityStateCountryShort") %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField HeaderText="<%$ Resources:Global, Title %>" ItemStyle-CssClass="text-nowrap text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top" DataField="peli_PRTitle" SortExpression="peli_PRTitle" />

                <asp:TemplateField HeaderText="<%$ Resources:Global, EmailAddress %>" ItemStyle-CssClass="text-nowrap text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top">
                    <ItemTemplate>
                        <a href='mailto:<%#Eval("Email")%>' class="explicitlink"><%#Eval("Email")%></a>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField HeaderText="<%$ Resources:Global, Phone2 %>" ItemStyle-CssClass="text-nowrap text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top" DataField="Phone" />
            </Columns>
        </asp:GridView>
    </div>

    <%--Person Notes (collapsible) --%>
    <div class="row nomargin">
        <div class="mar_top panel-default">
            <div class="panel-heading" role="tab" id="headingPersonNotes">
                <h4 class="panel-title bbos_bg commodityPanelTitle">
                    <% =Resources.Global.ViewPersonNotes %>
                    <i id="imgPersonNotes" class="more-less glyphicon glyphicon-minus" onclick="Toggle('PersonNotes');"></i>
                </h4>
            </div>
            <div class="panel-body norm_lbl" id="PersonNotes">
                <div class="col-md-12">
                    <asp:Literal ID="litPrivateNote" runat="server" />
                    <p>
                        <asp:Label ID="lblPrivateNoteAudit" runat="server" CssClass="annotation" />
                    </p>

                    <%--Buttons--%>
                    <div class="row nomargin_lr text-left mar_top20">
                        <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn gray_btn" OnClick="btnEditOnClick">
	                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnEdit %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="Print" runat="server" CssClass="btn gray_btn" OnClick="btnPrintNote_Click">
	                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Print %>" />
                        </asp:LinkButton>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>
