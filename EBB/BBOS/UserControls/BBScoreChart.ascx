<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="BBScoreChart.ascx.cs" Inherits="PRCo.BBOS.UI.Web.UserControls.BBScoreChart" %>

<asp:UpdatePanel ID="upnlBBScoreChart" runat="server" ChildrenAsTrigger="true">
    <ContentTemplate>
        <div class="modal fade" id='pnlBBScoreChart<%=panelIndex %>' data-bs-keyboard="false" taxindex="-1" aria-labelledby="BCCS_history_modalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg">
                <!-- Modal content-->
                <div class="modal-content">
                    <div class="modal-header">
                        <h1 class="modal-title fs-5" id="BBCS_history_modalLabel">Blue Book Credit Score History</h1>
                    </div>
                    <div class="modal-body">
                        <p><% =Resources.Global.BlueBookScore %>: <asp:Literal ID="litBBScoreText" runat="server" /></p>
                        <!-- TODO:JMT - remove the old imgBBScoreText from below -->
                        <div class="row tw-hidden">
                            <asp:Image ID="imgBBScoreText" runat="server" Width="60%" />
                        </div>
                         <!-- TODO:JMT - remove the old imgBBScoreText from above -->
                        <div class="tw-w-[400px] tw-m-auto tw-p-4">
                        <chart-slider
                            min="500"
                            max="1000"
                            stops="6"
                            current_value="<%=litBBScoreText.Text %>"
                            begin_label="<%=Resources.Global.HighRisk %>"
                            end_label="<%=Resources.Global.LowRisk %>">
                        </chart-slider>
                            </div>
                        <div class="row bb-guage ">
                            <div class="bb_scr text-center tw-m-auto">
                                <asp:Chart ID="chartBBScore" Width="650px" runat="server" BackColor="LightSteelBlue"
                                    BackGradientStyle="TopBottom" BackSecondaryColor="White">
                                    <Titles>
                                        <asp:Title Font="Times New Roman, 14pt, style=Bold" Name="Title1"
                                            Text="<%$Resources:Global, BlueBookScoreHistory%>">
                                        </asp:Title>
                                    </Titles>
                                    <ChartAreas>
                                        <asp:ChartArea Name="ChartArea1">
                                            <AxisY Title='<%$ Resources:Global,BlueBookScore %>' Maximum="1000" Minimum="500" Interval="100"
                                                IsStartedFromZero="False"
                                                TitleFont="Microsoft Sans Serif, 12pt, style=Bold">
                                                <MajorGrid LineColor="Gainsboro" />
                                                <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 9.75pt, style=Bold" />
                                            </AxisY>
                                            <AxisX Title="<%$ Resources:Global,Date %>" IsLabelAutoFit="False"
                                                TitleFont="Microsoft Sans Serif, 12pt, style=Bold">
                                                <MajorGrid LineColor="Gainsboro" />
                                                <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 9.75pt, style=Bold" />
                                            </AxisX>
                                        </asp:ChartArea>
                                    </ChartAreas>
                                </asp:Chart>
                                <br />
                                <asp:Label ID="lblBBScoreDisclaimer" runat="server" Visible="false" Text="<%$ Resources:Global, BBScoreDisclaimer %>" Font-Size="Smaller">
                                </asp:Label>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="bbsButton bbsButton-secondary" data-bs-dismiss="modal">
                            <div class="text-content">
                                <span class="label"><asp:Literal runat="server" Text="<%$Resources:Global, Close %>" /></span>
                            </div>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>