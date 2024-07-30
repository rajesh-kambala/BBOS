<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="SpecialServicesFile.aspx.cs" Inherits="PRCo.BBOS.UI.Web.SpecialServicesFile" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
  <style>
    .main-content-old {
      width: 100%;
      padding-inline: 12px;
    }

    .text-right {
      text-align: right;
    }
  </style>
  <asp:Label ID="hidSSFileID" Visible="false" runat="server" />
  <br />

  <asp:LinkButton ID="btnBack" runat="server" CssClass="bbsButton bbsButton-primary mb-3" OnClick="btnBackOnClick">
		    <span class="msicon notranslate">arrow_back</span>
    <asp:Literal runat="server" Text="<%$Resources:Global, btnBack %>" />
  </asp:LinkButton>

  <div class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 tw-gap-3">

    <div class="bbs-card-bordered">
      <div class="bbs-card-header">
        <h5><%= Resources.Global.Details%></h5>
      </div>
      <div class="bbs-card-body no-padding">
        <ul class="list-group list-group-flush">
          <li class="list-group-item d-flex justify-content-between align-items-center">
            <span>
              <% =Resources.Global.FileID %>:
          <br />
              <asp:Label ID="lblFileID" runat="server" CssClass="annotation" />
            </span>
            <span>
              <asp:Literal ID="litFileID" runat="server" />
            </span>
          </li>

          <li class="list-group-item d-flex justify-content-between align-items-center">
            <span>
              <% =Resources.Global.CreatedDate %>:
              <br />
              <asp:Label ID="lblCreatedDate" runat="server" CssClass="annotation" />
            </span>
            <span>
              <asp:Literal ID="litCreatedDate" runat="server" />
            </span>
          </li>

          <li class="list-group-item d-flex justify-content-between align-items-center">
            <span>
              <% =Resources.Global.ClosedDate %>:
              <br />
              <asp:Label ID="lblClosedDate" runat="server" CssClass="annotation" />
            </span>
            <span>
              <asp:Literal ID="litClosedDate" runat="server" />
            </span>
          </li>

          <li class="list-group-item d-flex justify-content-between align-items-center">
            <span>
              <% =Resources.Global.Status %>:
              <br />
              <asp:Label
                ID="lblStatus"
                runat="server"
                CssClass="annotation" />
            </span>
            <span>
              <asp:Literal
                ID="litStatus"
                runat="server" />
            </span>
          </li>

          <li class="list-group-item d-flex justify-content-between align-items-center">
            <span>
              <% =Resources.Global.Type %>:
              <br />
              <asp:Label
                ID="lblType"
                runat="server"
                CssClass="annotation" />
            </span>
            <span>
              <asp:Literal
                ID="litType"
                runat="server" /></span>
          </li>

          <li class="list-group-item d-flex justify-content-between align-items-center">
            <span>
              <% =Resources.Global.AssignedTo %>:
                <br />
              <asp:Label
                ID="lblAssignedTo"
                runat="server"
                CssClass="annotation" />
            </span>
            <span>
              <asp:Literal
                ID="litAssignedTo"
                runat="server" /></span>
          </li>

          <li class="list-group-item d-flex justify-content-between align-items-center">
            <span>
              <% =Resources.Global.OldestInvoiceDate %>:
              <br />
              <asp:Label
                ID="lblOldestInvoiceDate"
                runat="server"
                CssClass="annotation" />
            </span>
            <span>
              <asp:Literal
                ID="litOldestInvoiceDate"
                runat="server" /></span>
          </li>

          <li class="list-group-item d-flex justify-content-between align-items-center">
            <span>
              <% =Resources.Global.ClaimantContact %>:
              <br />
              <asp:Label
                ID="lblClaimantContact"
                runat="server"
                CssClass="annotation" />
            </span>
            <span>
              <asp:Literal
                ID="litClaimantContact"
                runat="server" /></span>
          </li>

          <li class="list-group-item d-flex justify-content-between align-items-center">
            <span>
              <% =Resources.Global.IssueDescription %>:
                <br />
              <asp:Label
                ID="lblIssueDescription"
                runat="server"
                CssClass="annotation" />
            </span>
            <span>
              <asp:Literal
                ID="litIssueDescription"
                runat="server" /></span>
          </li>

          <li class="list-group-item d-flex justify-content-between align-items-center">
            <span><% =Resources.Global.TotalAmountOwing %>:
                                    <br />
              <asp:Label ID="lblTotalAmountOwing" runat="server" CssClass="annotation" />

            </span>
            <span>
              <asp:Literal ID="litTotalAmountOwing" runat="server" />
            </span>
          </li>

          <li class="list-group-item d-flex justify-content-between align-items-center">
            <span><% =Resources.Global.AmountPRCoCollected %>:
                                    <br />
              <asp:Label ID="lblAmountPRCoCollected" runat="server" CssClass="annotation" />

            </span>
            <span>
              <asp:Literal ID="litAmountPRCoCollected" runat="server" />
            </span>
          </li>

          <li class="list-group-item d-flex justify-content-between align-items-center">
            <span>
              <% =Resources.Global.AmountStillOwing %>:
                                    <br />
              <asp:Label ID="lblAmountStillOwing" runat="server" CssClass="annotation" />

            </span>
            <span>
              <asp:Literal ID="litAmountStillOwing" runat="server" />
            </span>
          </li>

        </ul>
      </div>
    </div>

    <div class="bbs-card-bordered">
      <div class="bbs-card-header">
        <%= Resources.Global.PartiesSummary%>
      </div>
      <div class="bbs-card-body tw-flex tw-flex-col tw-gap-3">
        <div class="bbs-card-bordered">
          <div class="bbs-card-header">
            <%= Resources.Global.Claimant%>
          </div>
          <div class="bbs-card-body no-padding">
            <asp:GridView ID="gvClaimant"
              AllowSorting="false"
              runat="server"
              AutoGenerateColumns="false"
              CssClass="table  table-hover "
              GridLines="None"
              DataKeyNames="prss_ClaimantCompanyId">

              <Columns>
                <%--BBNumber Column--%>
                <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left" DataField="prss_ClaimantCompanyId" SortExpression="prss_ClaimantCompanyId" />

                <%--Icons Column--%>
                <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
                  <ItemTemplate>
                    <%# GetCompanyDataForCell((int)Eval("prss_ClaimantCompanyId"), 
                                      (string)Eval("ClaimantName"), 
                                      (string)Eval("ClaimantLegalName"), 
                                      UIUtils.GetBool(Eval("ClaimantHasNote")), 
                                      UIUtils.GetDateTime(Eval("ClaimantLastPublishedCSDate")), 
                                      (string)Eval("ClaimantListingStatus"), 
                                      true, 
                                      UIUtils.GetBool(Eval("ClaimantHasNewClaimActivity")), 
                                      UIUtils.GetBool(Eval("ClaimantHasMeritoriousClaim")), 
                                      UIUtils.GetBool(Eval("ClaimantHasCertification")), 
                                      UIUtils.GetBool(Eval("ClaimantHasCertification_Organic")), 
                                      UIUtils.GetBool(Eval("ClaimantHasCertification_FoodSafety")), 
                                      true, 
                                      false)%>
                  </ItemTemplate>
                </asp:TemplateField>

                <%--Company Name column--%>
                <asp:TemplateField HeaderText="<%$ Resources:Global, CompanyName %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" SortExpression="ClaimantName">
                  <ItemTemplate>
                    <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("prss_ClaimantCompanyId", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("ClaimantName") %></asp:HyperLink>
                    <asp:Literal ID="litLegalName" runat="server" Text='<%# PageBase.ParenWrap(Eval("ClaimantLegalName"))%>' />
                  </ItemTemplate>
                </asp:TemplateField>

                <%--Location Column--%>
                <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" DataField="ClaimantCityStateCountryShort" SortExpression="ClaimantCityStateCountryShort" />
              </Columns>
            </asp:GridView>
          </div>
        </div>
        <div class="bbs-card-bordered">
          <div class="bbs-card-header">
            <%= Resources.Global.Respondent %>
          </div>
          <div class="bbs-card-body no-padding">
            <asp:Literal ID="litRespondentCompanyId" runat="server" Visible="false" />
            <asp:GridView ID="gvRespondent"
              AllowSorting="false"
              runat="server"
              AutoGenerateColumns="false"
              CssClass="table  table-hover "
              GridLines="None"
              DataKeyNames="prss_RespondentCompanyId">

              <Columns>
                <%--BBNumber Column--%>
                <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left" DataField="prss_RespondentCompanyId" SortExpression="prss_RespondentCompanyId" />

                <%--Icons Column--%>
                <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
                  <ItemTemplate>
                    <%# GetCompanyDataForCell((int)Eval("prss_RespondentCompanyId"), 
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

                <%--Company Name column--%>
                <asp:TemplateField HeaderText="<%$ Resources:Global, CompanyName %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" SortExpression="RespondentName">
                  <ItemTemplate>
                    <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("prss_RespondentCompanyId", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("RespondentName") %></asp:HyperLink>
                    <br />
                    <asp:Literal ID="litLegalName" runat="server" Text='<%# PageBase.ParenWrap(Eval("RespondentLegalName"))%>' />
                  </ItemTemplate>
                </asp:TemplateField>

                <%--Location Column--%>
                <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" DataField="RespondentCityStateCountryShort" SortExpression="ClaimantCityStateCountryShort" />
              </Columns>
            </asp:GridView>

          </div>
        </div>
      </div>
    </div>

    <div class="bbs-card-bordered">
      <div class="bbs-card-header">
        <%= Resources.Global.Activity%>
      </div>
      <div class="bbs-card-body">
        <ul class="list-group list-group-flush">
          <%--                                
            <li class="list-group-item d-flex justify-content-between align-items-center">
                <span >
                    <% =Resources.Global.FirstLetterToRespondentSentDate %>:
                <br />
                    <asp:Label ID="lblA1LetterSentDate" runat="server" CssClass="annotation" />
                </span>
                <span><asp:Literal ID="litA1LetterSentDate" runat="server" /></span>
            </li>
                   
            <li class="list-group-item d-flex justify-content-between align-items-center">
                <span >
                    <% =Resources.Global.FormalWarningLetterSentDate %>:
                <br />
                    <asp:Label ID="lblWarningLetterSentDate" runat="server" CssClass="annotation" />
                </span>
                <span><asp:Literal ID="litWarningLetterSentDate" runat="server" /></span>
            </li>
                    
            <li class="list-group-item d-flex justify-content-between align-items-center">
                <span >
                    <% =Resources.Global.FormalReportLetterSentDate %>:
                <br />
                    <asp:Label ID="lblReportLetterSentDate" runat="server" CssClass="annotation" />
                </span>
                <span>
                <asp:Literal ID="litReportLetterSentDate" runat="server" /></span>

            </li>
          --%>

          <li class="list-group-item d-flex justify-content-between align-items-center">
            <span>
              <% =Resources.Global.LastActivity %>:
                        <asp:Label ID="lblLastActivityDate" runat="server" CssClass="annotation" />
            </span>
            <span>
              <asp:Literal ID="litLastActivityDate" runat="server" />
            </span>
          </li>
        </ul>
      </div>
    </div>

  </div>
<br />

</asp:Content>
