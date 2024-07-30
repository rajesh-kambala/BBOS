<%@ Page Title="" Language="C#" MasterPageFile="~/Corporate.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Login" %>

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

        #txtPasswordControl .fa-eye:before {
          content: "";
        }
        
        #txtPasswordControl.show-password .fa-eye:before {
          content: "";
        }
	</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    
    <asp:Panel ID="pnlMsg" CssClass="alert alert-warning offset-md-2 col-md-8 col-sm-12" runat="server" Visible="false">
        <asp:Literal ID="litMsg" runat="server" Text=""></asp:Literal>
    </asp:Panel>


    <asp:HiddenField ID="lblLoginCount" runat="server" />

    <div class="row nomargin panels_box">
        <div class="col-lg-3 offset-lg-4 offset-md-3 col-md-5 col-sm-8 offset-sm-2 col-xs-12" style="float: none; margin: 0 auto;" id="divLogin" runat="server">
            <asp:Panel ID="pnlRLInfoProduce" runat="server" Visible="false">
                <div class="row" style="color: #235495">
                    <b>Only Blue Book members with a valid login may access this site for company details.</b>
                </div>
                <div class="row" style="color: #235495">
                    <b>For more information about the value of Membership, <a href="https://www.producebluebook.com/why-join/" style="color: #235495">click here</a>.</b>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlRLInfoLumber" runat="server" Visible="false">
                <div class="row" style="color: #235495">
                    <b>Only Blue Book members with a valid login may access this site for company details.</b>
                </div>
                <div class="row" style="color: #235495">
                    <b>For more information about the value of Membership, <a href="https://www.lumberbluebook.com/why-join/" style="color: #235495">click here</a>.</b>
                </div>
            </asp:Panel>

            <div class="panel panel-primary" id="pnlCriteria" runat="server">
                <div class="panel-heading">
                    <h4 class="blu_tab">
                        <asp:Literal ID="litTitle" runat="server" Text='<%$ Resources:Global, BlueBookOnlineServicesMemberLogin%>'/>
                        
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
                        
                            <div class="input-group" id="txtPasswordControl">
                                <asp:TextBox ID="txtPassword" TextMode="Password" CssClass="form-control" placeholder="Password" runat="server" tsiRequired="true" tsiDisplayName="Password" />
                                <div class="input-group-addon"" onclick="togglePassBox()">
								    <span class="input-group-text"><i class="fa fa-eye" aria-hidden="true"></i></span>
								</div>
						    </div>
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

            <p class="msg text-center">
                <asp:Literal ID="litForgotEmail" runat="server" />
            </p>

            <asp:Panel ID="pnlVisitorsFindOutMore" runat="server">
                <div class="row">
                    <p class="msg text-center"><%=Resources.Global.VisitorsFindOutMoreAbout %>&nbsp;<a href="<% =Utilities.GetConfigValue("CorporateWebSite") %>"><%=Resources.Global.MembershipHere %></a>.</p>
                </div>
            </asp:Panel>
        </div>

        <asp:Panel ID="pnlRLSidebarProduce" runat="server" Visible="false">
            <div class="col-lg-3 col-md-3 col-sm-3 col-xs-3 sidebar nomargin">
                <p class="sidebartext">
                    How Membership<br />
                    Can Help You</p>
                <p style="text-align: left; margin-bottom: 1rem;">
                    <img class="aligncenter size-full wp-image-67" src="images/how-membership-can-help-you-img.jpg" alt="how-membership-can-help-you-img" width="151" height="91" />
                </p>
                <p style="font-size: 14px; margin-bottom: 1rem;">As the leading provider of in-depth business and credit information on the global produce industry, a membership with Blue Book Services gives you access to:</p>
                <ul style="font-size: 14px; list-style-type: disc; margin-left: 20px; margin-bottom:16px;">
                    <li style="text-align: left; list-style-type: disc">Ratings &amp; Credit Scores</li>
                    <li style="text-align: left; list-style-type: disc">Dynamic Search Tools</li>
                    <li style="text-align: left; list-style-type: disc">Real-Time Data</li>
                    <li style="text-align: left; list-style-type: disc">Marketing Power</li>
                    <li style="text-align: left; list-style-type: disc">Trading Assistance</li>
                    <li style="text-align: left; list-style-type: disc">Education</li>
                </ul>
                <p style="text-align: center; width:100%;">
                    <a class="button button-border-white" style="width:100%" href="https://www.producebluebook.com/why-join/">Learn More<br/>
                        <small>About The Benefits</small></a>
                </p>
            </div>
        </asp:Panel>
        <asp:Panel ID="pnlRLSidebarLumber" runat="server" Visible="false">
            <div class="col-lg-3 col-md-3 col-sm-3 col-xs-3 sidebar nomargin">
                <p class="sidebartext">
                    The Value of Membership
                </p>
                <p style="text-align: left; margin-bottom: 1rem;">
                    <img class="aligncenter size-full wp-image-2006" src="images/whyjoin-three.jpg" alt="whyjoin-three" />
                </p>
                <p style="font-size: 14px; margin-bottom: 1rem;">As the leading provider of in-depth business and credit information on the domestic lumber &amp; forest products industry, a membership with Blue Book Services gives you access to:</p>
                <ul style="font-size: 14px; list-style-type: disc; margin-left: 20px; margin-bottom: 16px;">
                    <li style="text-align: left; list-style-type: disc">Ratings &amp; Business Reports</li>
                    <li style="text-align: left; list-style-type: disc">Dynamic Search Tools</li>
                    <li style="text-align: left; list-style-type: disc">Real-Time Data</li>
                </ul>
                <p style="text-align: center; width: 100%;">
                    <a class="button button-border-white" style="width: 100%" href="https://www.lumberbluebook.com/join-today/">
                    Learn More<br />
                    <small>About The Benefits</small></a>
                </p>
            </div>
        </asp:Panel>
    </div>

    <div class="clearfix"></div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        function EmailPasswordOnClick() {
            document.getElementById("<% =txtPassword.ClientID %>").removeAttribute("tsiRequired");
        }

        function togglePassBox() {
            var element = document.getElementById('txtPasswordControl');
            var classes = element.className.split(' ');
            var idx = classes.indexOf('show-password');
            if (idx === -1) {
                classes.push('show-password');
                document.getElementById('contentMain_txtPassword').type = 'text';
            } else {
                classes.splice(idx, 1);
                document.getElementById('contentMain_txtPassword').type = 'password';
            }
            element.className = classes.join(' ');
        }
    </script>
</asp:Content>
