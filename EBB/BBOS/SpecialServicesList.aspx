<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="SpecialServicesList.aspx.cs" Inherits="PRCo.BBOS.UI.Web.SpecialServicesList" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content2" ContentPlaceHolderID="contentHead" runat="server">
  <style>
    .main-content-old {
      max-width: 100%;
      width: 100%;
      padding-inline: 12px;
    }
  </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">

  <div class="tw-flex tw-flex-col tw-gap-3">

  <div class="bbs-alert alert-info" role="alert">
    <div class="alert-title">
      <span class="msicon notranslate">new_releases</span>

      <span>
  <% =Resources.Global.SSFileListingText %>
                           
      </span>
    </div>
  </div>


  <div class="tw-flex tw-gap-3 tw-flex-wrap ">
    <asp:LinkButton ID="btnContactTradingAssistance" runat="server" CssClass="bbsButton bbsButton-primary" OnClick="btnContactTradingAssistanceOnClick">
		    <span class="msicon notranslate" aria-hidden="true" runat="server">live_help</span>
          <asp:Literal runat="server" Text="<%$Resources:Global, btnContactTradingAssistance %>" />
    </asp:LinkButton>
    <asp:LinkButton ID="btnSendCourtesyContact" runat="server" CssClass="bbsButton bbsButton-primary" OnClick="btnSendCourtesyContactOnClick">
		    <span class="msicon notranslate" aria-hidden="true" runat="server">send</span>
          <asp:Literal runat="server" Text="<%$Resources:Global, btnSendCourtesyContact %>" />
    </asp:LinkButton>
    <asp:LinkButton ID="btnFileClaim" runat="server" CssClass="bbsButton bbsButton-primary" OnClick="btnFileClaimOnClick">
		    <span class="msicon notranslate" aria-hidden="true" runat="server">flag</span>
          <asp:Literal runat="server" Text="<%$Resources:Global, btnOpenCollection %>" />
    </asp:LinkButton>
  </div>


  <p >
    <% = Resources.Global.ListInvolvingYourCompany %>
    <%--Below is a list of all Blue Book Services collection and claim activity involving your company.  Click on the File ID for additional detail.--%>
  </p>



  <div class="bbs-card-bordered">
    <div class="bbs-card-header">
      <asp:Label ID="lblRecordCount" runat="server" />
    </div>
    <div class="bbs-card-body no-padding">
      <div class="table-responsive">
        <asp:GridView ID="gvSSFileAccess"
          runat="server"
          AllowSorting="True"
          AutoGenerateColumns="False"
          CellSpacing="3"
          CssClass="  table   table-hover"
          GridLines="None"
          OnRowDataBound="GridView_RowDataBound"
          OnSorting="GridView_Sorting">

          <Columns>
            <asp:TemplateField HeaderText="<%$ Resources:Global, FileID %>" SortExpression="prss_SSFileID" HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" ItemStyle-CssClass="text-left">
              <ItemTemplate>
                <a href='<%# PageConstants.Format(PageConstants.SPECIAL_SERVICES_FILE, Eval("prss_SSFileID")) %>' class="explicitlink"><%# Eval("prss_SSFileID")%></a>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="<%$ Resources:Global, CreatedDate %>" SortExpression="prss_CreatedDate" HeaderStyle-CssClass="text-left vertical-align-top" ItemStyle-CssClass="text-left">
              <ItemTemplate>
                <%# GetStringFromDate(Eval("prss_CreatedDate")) %>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="<%$ Resources:Global, ClosedDate %>" SortExpression="prss_ClosedDate" HeaderStyle-CssClass="text-left vertical-align-top" ItemStyle-CssClass="text-left">
              <ItemTemplate>
                <%# GetStringFromDate(Eval("prss_ClosedDate")) %>
              </ItemTemplate>
            </asp:TemplateField>

            <%--Respondent BBID Column--%>
            <asp:TemplateField HeaderStyle-CssClass="text-left vertical-align-top" ItemStyle-CssClass="text-left" HeaderText="<%$ Resources:Global, RespondentBBID %>" SortExpression="prss_RespondentCompanyID">
              <ItemTemplate>
                <%# UIUtils.GetStringFromInt((int)Eval("prss_RespondentCompanyID"), true )%>
              </ItemTemplate>
            </asp:TemplateField>

            <%--Respondent Icons Column--%>
            <asp:TemplateField HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
              <HeaderTemplate>
                <span class="msicon notranslate">notifications_active</span>
                </HeaderTemplate>
              <ItemTemplate>
                <%# GetCompanyDataForCell((int)Eval("prss_RespondentCompanyID"), 
                                (string)Eval("RespondentName"), 
                                (string)Eval("RespondentLegalName"), 
                                UIUtils.GetBool(Eval("RespondentHasNote")), 
                                UIUtils.GetDateTime(Eval("RespondentLastPublishedCSDate")), 
                                (string)Eval("RespondentListingStatus"), 
                                true, 
                                UIUtils.GetBool(Eval("RespondentHasNewClaimActivity")), 
                                UIUtils.GetBool(Eval("RespondentHasMeritoriousClaim")), 
                                UIUtils.GetBool(Eval("RespondentHasCertification")), 
                                UIUtils.GetBool(Eval("RespondentHasCertification_Organic")), 
                                UIUtils.GetBool(Eval("RespondentHasCertification_FoodSafety")), 
                                true, 
                                false)%>
              </ItemTemplate>
            </asp:TemplateField>

            <%--Respondent Name column--%>
            <asp:TemplateField HeaderText="<%$ Resources:Global, RespondentName %>" HeaderStyle-CssClass="vertical-align-top" SortExpression="RespondentName">
              <ItemTemplate>
                <asp:HyperLink ID="hlCompanyDetailsRespondent" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("prss_RespondentCompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("RespondentName") %></asp:HyperLink>
                <%# Eval("RespondentCityStateCountryShort") %>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:BoundField HeaderText="<%$ Resources:Global, Status %>" DataField="prss_Status" SortExpression="prss_Status" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" />
            <asp:BoundField HeaderText="<%$ Resources:Global, Type %>" DataField="prss_Type" SortExpression="prss_Type" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" />

            <%--Assigned To Column--%>
            <asp:TemplateField HeaderStyle-CssClass="text-left vertical-align-top" HeaderText="<%$ Resources:Global, AssignedTo %>" SortExpression="AssignedUser">
              <ItemTemplate>
                <%# GetFormattedAssignedToEmail(UIUtils.GetString(Eval("AssignedUser")), UIUtils.GetString(Eval("user_EmailAddress")), UIUtils.GetString(Eval("user_Phone")))%>
              </ItemTemplate>
            </asp:TemplateField>

            <%--Respondent Note Column--%>
            <asp:TemplateField HeaderText="<%$ Resources:Global, Note%>" ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="vertical-align-top">
              <ItemTemplate>
                <asp:Image ID="noteImage" runat="server" ImageUrl='<%# UIUtils.GetImageURL("ClaimActivity-Note.png") %>' Visible='<%# DisplayNotes(Eval("prss_PublishedNotes")) %>' Style="cursor: pointer;" />
                <asp:Panel ID="note" Style="width: 400px; min-height: 400px; text-align: left; display: none;" CssClass="Popup" runat="server">
                  <div class="popup_header">
                    <button id="btnClose" type="button" class="close" data-bs-dismiss="modal" runat="server">&times;</button>
                  </div>
                  <div class="popup_content">
                    <%# FormatTextForHTML(Eval("prss_PublishedNotes"))%>
                  </div>
                </asp:Panel>

                <cc1:PopupControlExtender ID="PopupControlExtender4" runat="server"
                  TargetControlID="noteImage"
                  PopupControlID="note"
                  OffsetX="-400"
                  Position="Bottom" />
              </ItemTemplate>
            </asp:TemplateField>

            
          </Columns>
        </asp:GridView>
      </div>
    </div>
  </div>

    </div>
  <br />

</asp:Content>
