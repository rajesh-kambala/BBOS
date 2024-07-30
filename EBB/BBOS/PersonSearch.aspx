<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PersonSearch.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PersonSearch" MasterPageFile="~/BBOS.Master" MaintainScrollPositionOnPostback="true" %>

<%@ Register Src="UserControls/PersonSearchCriteriaControl.ascx" TagName="PersonSearchCriteriaControl" TagPrefix="uc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
  <style>
    .main-content-old {
      width: 100%;
    }
  </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
  <asp:Panel ID="pnlSearch" DefaultButton="btnSearch" runat="server" CssClass="tw-px-4">
    <div class="row g-3">
      <%--Buttons--%>
      <div class="tw-flex tw-flex-wrap tw-gap-2 tw-justify-end">

        <asp:LinkButton ID="btnLoadSearch" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClientClick="return confirmOverrwrite('LoadSearch')" OnClick="btnLoadSearch_Click">
                    <span class="msicon notranslate">input</span>
                    <span><asp:Literal runat="server" Text="<%$ Resources:Global, LoadSearch %>" /></span>
        </asp:LinkButton>

        <asp:LinkButton ID="btnClearAllCriteria" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnClearAllCriteria_Click">
                    <span class="msicon notranslate">clear_all</span>
                    <span><asp:Literal runat="server" Text="<%$ Resources:Global, ClearAll %>" /></span>
        </asp:LinkButton>
        <asp:LinkButton ID="btnSaveSearch" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnSaveSearch_Click">
                    <span class="msicon notranslate">saved_search</span>
                    <span><asp:Literal runat="server" Text="<%$ Resources:Global, SaveSearch %>" /></span>
        </asp:LinkButton>

        <asp:LinkButton ID="btnSearch" runat="server" CssClass="bbsButton bbsButton-primary" OnClick="btnSearch_Click">
                    <span class="msicon notranslate">search</span>
                    <span><asp:Literal runat="server" Text="<%$ Resources:Global, Search %>" /></span>
        </asp:LinkButton>
      </div>

      <div class=" bbslayout_splitView tw-gap-3 bbslayout_second_onTop">
        <div class="bbslayout_first_split">
          <%--Search Form--%>
          <div>
            <asp:Panel ID="pnlIndustryType" runat="server" Style="margin-bottom: 15px;" Visible="false">
              <div class="col-md-12 nopadding ind_typ gray_bg">
                <div class="col-md-2 text-nowrap">
                  <a id="popIndustryType" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                    <img src="images/info_sm.png" />
                  </a>
                  <span class="fontbold"><strong class=""><%= Resources.Global.IndustryType %>:</strong></span>
                </div>
                <div class="col-md-9">
                  <asp:UpdatePanel ID="UpdatePanel3" runat="server">
                    <ContentTemplate>
                      <asp:RadioButtonList ID="rblIndustryType" runat="server" RepeatColumns="3" AutoPostBack="True" />
                    </ContentTemplate>
                    <Triggers>
                      <asp:AsyncPostBackTrigger ControlID="rblIndustryType" EventName="SelectedIndexChanged" />
                    </Triggers>
                  </asp:UpdatePanel>
                </div>
              </div>
            </asp:Panel>

            <div class="bbs-card-bordered" id="pnlCriteria" runat="server">
              <div class="bbs-card-header tw-flex tw-justify-between">
                <h5><%=Resources.Global.PersonSearchCriteria %>
                </h5>
                <asp:LinkButton ID="btnClearCriteria" runat="server" CssClass="bbsButton bbsButton-secondary filled small" OnClick="btnClearCriteria_Click">
            <span class="msicon notranslate">clear</span>
            <span><asp:Literal runat="server" Text="<%$ Resources:Global, ClearThisCriteria %>" /></span>
                </asp:LinkButton>
              </div>
              <div class="bbs-card-body" id="pnlCriteriaDetails">
                <div class="container">
                  <div class="row">
                    <div class="col-md-6">
                      <div class="form-group">
                        <div class="row" runat="server">
                          <label class="clr_blu col-md-4" for="<%= txtLastName.ClientID%>"><%= Resources.Global.LastName %>:</label>
                          <div class="col-md-8">
                            <asp:TextBox ID="txtLastName" runat="server" AutoPostBack="True" CssClass="form-control" />
                          </div>
                        </div>

                        <div class="row mar_top_5" runat="server">
                          <label class="clr_blu col-md-4" for="<%= txtFirstName.ClientID%>"><%= Resources.Global.FirstName %>:</label>
                          <div class="col-md-8">
                            <asp:TextBox ID="txtFirstName" runat="server" AutoPostBack="True" CssClass="form-control" />
                          </div>
                        </div>

                        <div class="row mar_top_5" runat="server">
                          <label class="clr_blu col-md-4" for="<%= txtTitle.ClientID%>"><%= Resources.Global.Title %>:</label>
                          <div class="col-md-8">
                            <asp:TextBox ID="txtTitle" runat="server" AutoPostBack="True" CssClass="form-control" />
                          </div>
                        </div>

                        <div class="row mar_top_5" runat="server">
                          <label class="clr_blu col-md-4" for="<%= txtPhoneAreaCode.ClientID%>"><%= Resources.Global.Phone2 %>:</label>
                          <div class="col-md-8">
                            <div class="input-group">
                              <asp:TextBox ID="txtPhoneAreaCode" runat="server" CssClass="form-control" AutoPostBack="True" Columns="5" />
                              <span class="input-group-addon">-</span>
                              <asp:TextBox ID="txtPhoneNumber" runat="server" CssClass="form-control" AutoPostBack="True" Columns="20" />
                            </div>
                          </div>
                        </div>

                        <div class="row mar_top_5" runat="server">
                          <label class="clr_blu col-md-4" for="<%= txtEmail.ClientID%>"><%= Resources.Global.Email_Cap %>:</label>
                          <div class="col-md-8">
                            <asp:TextBox ID="txtEmail" runat="server" AutoPostBack="True" CssClass="form-control" />
                          </div>
                        </div>

                        <div class="row mar_top_5" runat="server">
                          <label class="clr_blu col-md-4" for="<%= txtCompanyName.ClientID%>"><%= Resources.Global.CompanyName %>:</label>
                          <div class="col-md-8">
                            <asp:TextBox ID="txtCompanyName" runat="server" AutoPostBack="True" CssClass="form-control" />
                          </div>
                        </div>

                        <div class="row mar_top_5" id="trBBID" runat="server">
                          <label class="clr_blu col-md-4" for="<%= txtBBNum.ClientID%>"><%= Resources.Global.BBNumber %>:</label>
                          <div class="col-md-8">
                            <div class="input-group tw-flex">
                              <asp:TextBox ID="txtBBNum" runat="server" CssClass="form-control numbersOnly tw-flex-grow" MaxLength="8" AutoPostBack="True" />
                              <cc1:FilteredTextBoxExtender ID="ftbeBBID" runat="server" TargetControlID="txtBBNum" FilterType="Numbers" />
                              <a id="popBBNumber" runat="server" class="input-group-text" data-bs-trigger="hover" data-bs-html="true" data-bs-toggle="popover" data-bs-placement="bottom">
                                <span class="msicon notranslate">help</span>
                              </a>
                            </div>
                          </div>
                        </div>

                        <div class="row mar_top_5" id="trIndustry" runat="server">
                          <label class="clr_blu col-md-4" for="<%= ddlIndustryType.ClientID%>"><%= Resources.Global.IndustryType %>:</label>
                          <div class="col-md-8">
                            <asp:DropDownList ID="ddlIndustryType" runat="server" AutoPostBack="True" CssClass="form-control"></asp:DropDownList>
                          </div>
                        </div>
                      </div>
                    </div>

                    <%--Role Checkboxes--%>
                    <div class="col-md-6">
                      <div class="form-group">
                        <div class="row" runat="server">
                          <label class="clr_blu col-md-3 text-right" for="<%= txtCompanyName.ClientID%>" style="text-align: right;" id="lblRole" runat="server"><%= Resources.Global.Role %>:</label>
                          <div class="col-md-9">
                            <asp:CheckBoxList ID="cblRole" runat="server" RepeatColumns="1" RepeatDirection="Vertical" AutoPostBack="true" RepeatLayout="Table" CssClass="smallcheck space" />
                          </div>
                        </div>
                      </div>
                    </div>

                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="bbslayout_second_split">
          <%--Selected Criteria--%>
          <div>
            <asp:UpdatePanel ID="UpdatePanel1" runat="server">
              <ContentTemplate>
                <uc1:PersonSearchCriteriaControl ID="ucPersonSearchCriteriaControl" runat="server" />
              </ContentTemplate>
              <Triggers>
                <asp:AsyncPostBackTrigger ControlID="txtCompanyName" EventName="TextChanged" />
                <asp:AsyncPostBackTrigger ControlID="txtBBNum" EventName="TextChanged" />
                <asp:AsyncPostBackTrigger ControlID="txtPhoneAreaCode" EventName="TextChanged" />
                <asp:AsyncPostBackTrigger ControlID="txtPhoneNumber" EventName="TextChanged" />
                <asp:AsyncPostBackTrigger ControlID="txtEmail" EventName="TextChanged" />
                <asp:AsyncPostBackTrigger ControlID="txtLastName" EventName="TextChanged" />
                <asp:AsyncPostBackTrigger ControlID="txtFirstName" EventName="TextChanged" />
                <asp:AsyncPostBackTrigger ControlID="txtTitle" EventName="TextChanged" />
                <asp:AsyncPostBackTrigger ControlID="cblRole" EventName="SelectedIndexChanged" />
              </Triggers>
            </asp:UpdatePanel>
          </div>
        </div>
      </div>







    </div>
  </asp:Panel>
  <br />
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
  <script type="text/javascript">
    btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');
    </script>
</asp:Content>
