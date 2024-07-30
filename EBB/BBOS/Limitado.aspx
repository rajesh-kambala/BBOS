<%@ Page Title="" Language="C#" MasterPageFile="~/Corporate.Master" AutoEventWireup="true" CodeBehind="Limitado.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Limitado" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentHead" runat="server">
	<style type="text/css">
        .panels_box .panel {  padding:0;  border:0; }
        .panels_box .panel-heading {   padding:0;  border:0; }
        .panels_box .panel-body { padding:0; border: 1px solid #dfdddd; }
        .pad10 { padding:10px !important;  }
        .panels_box .pad10 { padding:10px !important;  }
        .gray_btn {
           background-color: #68AE00 !important;
            color: #fff !important;
            margin-top: 5px;
        }

        .gray_btn:hover {
            background-color: #3e6800 !important;
            color: #fff !important;
            text-decoration: none !important;
        }
	</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    
    <asp:Panel ID="pnlMsg" CssClass="alert alert-warning offset-md-2 col-md-8 col-sm-12" runat="server" Visible="false">
        <asp:Literal ID="litMsg" runat="server" Text=""></asp:Literal>
    </asp:Panel>


    <asp:HiddenField ID="lblLoginCount" runat="server" />

    <div class="row nomargin panels_box">
        <div class="col-lg-3 offset-lg-4 offset-md-3 col-md-5 col-sm-8 offset-sm-2 col-xs-12" style="margin-right:20px;" id="divLogin" runat="server">
            <div class="panel panel-primary" id="pnlCriteria" runat="server">
                <div class="panel-heading">
                    <h4 class="blu_tab">
                        <asp:Literal ID="litTitle" runat="server" Text='<%$ Resources:Global, BlueBookLimitadoLogin%>'/>
                        
                    </h4>
                </div>
                <div class="row panel-body nomargin pad10 id=pnlCriteriaDetails gray_bg">
                    <div class="col-md-12 nopadding">
                        <div class="form-group">
                            <label class="clr_blu" for="email"><% =Resources.Global.EmailAddress2%>:</label>
                            <asp:TextBox ID="txtUserID" CssClass="form-control" placeholder="Email" runat="server" tsiRequired="true" tsiDisplayName="Email" />
                        </div>

                        <div class="form-group">
                            <label class="clr_blu" for="email"><% =Resources.Global.Password2%>:</label>
                            <asp:TextBox ID="txtPassword" TextMode="Password" CssClass="form-control" placeholder="Password" runat="server" tsiRequired="true" tsiDisplayName="Password" />
                        </div>

                        <div class="form-group nomargin nopadding">
                            <div class="col-md-6 col-sm-4">
                                <label for="<% =cbRememberMe.ClientID %>" class="checkbox-inline">
                                    <asp:CheckBox runat="server" Checked="true" ID="cbRememberMe" />
                                    <% =Resources.Global.KeepMeLoggedIn%>
                                </label>
                            </div>
                            <div class="col-md-6 col-sm-8 text-right">
                                <asp:LinkButton id="btnEmailPassword" OnClick="btnEmailPasswordOnClick" CssClass="explicitlink" Text="<%$Resources:Global, ForgotPasswordQuestionMark %>" runat="server" />
                            </div>
                        </div>

                        <div class="form-group mar_top">
                            <div class="col-md-12 mar_top">
                                <asp:LinkButton ID="btnLogin" runat="server" CssClass="btn gray_btn" OnClick="btnLoginOnClick" Width="100%">
		                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Login %>" />
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <p class="msg">
                <asp:Literal ID="litLimitadoFooter1" runat="server" />
            </p>
            <p class="msg">
                <asp:Literal ID="litLimitadoFooter2" runat="server" />
            </p>
            <p class="msg">
                <asp:Literal ID="litLimitadoFooter3" runat="server" />
            </p>
            <p class="msg">
                <asp:Literal ID="litLimitadoFooter4" runat="server" />
            </p>
        </div>
    </div>

    <div class="clearfix"></div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        function EmailPasswordOnClick() {
            document.getElementById("<% =txtPassword.ClientID %>").removeAttribute("tsiRequired");
        }
    </script>
</asp:Content>