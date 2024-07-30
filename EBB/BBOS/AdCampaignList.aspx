<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="AdCampaignList.aspx.cs" Inherits="PRCo.BBOS.UI.Web.AdCampaignList" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row">
        <asp:Label ID="lblRecordCount" runat="server" CssClass="RecordCnt" />
    </div>

    <div class="table-responsive">
        <asp:GridView ID="gvAdCampaigns"
            AllowSorting="true"
            Width="100%"
            CellSpacing="3"
            runat="server"
            AutoGenerateColumns="false"
            CssClass="sch_result table table-striped table-hover"
            GridLines="none"
            OnSorting="GridView_Sorting"
            OnRowDataBound="GridView_RowDataBound">

            <Columns>
                <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center" HeaderText="<%$ Resources:Global, Select %>">
                    <ItemTemplate>
                        <input type="radio" name="rbAdCampaignID" value="<%# Eval("pradc_AdCampaignID") %>" />
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField HeaderText="<%$ Resources:Global, AdCampaignName %>" HeaderStyle-CssClass="vertical-align-top" DataField="pradch_Name" SortExpression="pradch_Name" />
                <asp:BoundField HeaderText="<%$ Resources:Global, Type %>" HeaderStyle-CssClass="vertical-align-top" DataField="AdCampaignType" SortExpression="AdCampaignType" />
                <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" HeaderStyle-CssClass="vertical-align-top" DataField="CityStateCountryShort" SortExpression="CityStateCountryShort" />

                <asp:TemplateField HeaderStyle-CssClass="vertical-align-top text-center" ItemStyle-CssClass="text-center" HeaderText="<%$ Resources:Global, StartDate %>" SortExpression="pradc_StartDate">
                    <ItemTemplate>
                        <%# PageBase.GetStringFromDate(Eval("pradc_StartDate"))%>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderStyle-CssClass="vertical-align-top text-center" ItemStyle-CssClass="text-center" HeaderText="<%$ Resources:Global, EndDate %>" SortExpression="pradc_EndDate">
                    <ItemTemplate>
                        <%# PageBase.GetStringFromDate(Eval("pradc_EndDate"))%>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField HeaderText="<%$ Resources:Global, ImpressionCount %>" HeaderStyle-CssClass="vertical-align-top text-center" ItemStyle-CssClass="text-center" DataField="pradc_ImpressionCount" SortExpression="pradc_ImpressionCount" DataFormatString="{0:N0}" HtmlEncode="false" />
                <asp:BoundField HeaderText="<%$ Resources:Global, ClickCount %>" HeaderStyle-CssClass="vertical-align-top text-center" ItemStyle-CssClass="text-center" DataField="pradc_ClickCount" SortExpression="pradc_ClickCount" DataFormatString="{0:N0}" HtmlEncode="false" />
                <asp:TemplateField HeaderStyle-CssClass="vertical-align-top" ItemStyle-CssClass="text-left" HeaderText="<%$ Resources:Global, AdImage %>">
                    <ItemTemplate>
                        <asp:HyperLink ID="hlAdImage" runat="server" Visible="false" CssClass="explicitlink" Target="_blank" />
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>

    <div class="row nomargin text-left mar_top">
        <asp:LinkButton ID="btnAdCampaignReport" runat="server" CssClass="btn gray_btn" OnClick="btnAdCampaignReportOnClick">
		    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, AdCampaignReport %>" />
        </asp:LinkButton>
        <asp:LinkButton ID="btnDone" runat="server" CssClass="btn gray_btn" OnClick="btnDoneOnClick">
		    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Done %>" />
        </asp:LinkButton>
    </div>
</asp:Content>