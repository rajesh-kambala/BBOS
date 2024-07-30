<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="BlueBookScoreDistribution.ascx.cs" Inherits="PRCo.BBOS.UI.Web.Widgets.BlueBookScoreDistribution" %>
<div class="bbs-list-panel">
    <div class="bbs-list-panel-heading">
        <h3 style="margin-right:auto"><%=Resources.Global.BlueBookScoreDistribution %></h3>
        <h3 style="margin-left:auto; font-size:smaller; white-space:nowrap;">
            <asp:HyperLink ID="hlChangeWidgets" runat="server" NavigateUrl="~/UserProfile.aspx" Text='<%$ Resources:Global, ChangeWidgets %>' />
        </h3>
        <br style="clear:both;" />
    </div>
    <div class="bbs-list-group">
        <div class="d-flex justify-content-center py-3">
            <span>
                <asp:Chart ID="chartBBScoreDistribution" runat="server" CssClass="chart">
                    <Legends>
                        <asp:Legend Alignment="Center" Docking="Bottom" IsTextAutoFit="false" Name="Legend" LegendStyle="Table" TableStyle="Wide"
                            Font="Microsoft Sans Serif, 8.0pt" />
                    </Legends>
                    <Series>
                        <asp:Series Name="Series1" ChartType="Pie" XValueMember="Bracket"
                            YValueMembers="BracketCount" IsVisibleInLegend="true" IsValueShownAsLabel="true"
                            MarkerStyle="Square" Color="Black" Font="Microsoft Sans Serif, 10.0pt">
                        </asp:Series>
                    </Series>
                    <ChartAreas>
                        <asp:ChartArea Name="ChartArea1">
                            <AxisX Title="Bracket" IsLabelAutoFit="True"
                                TitleFont="Microsoft Sans Serif, 9.0pt">
                                <MajorGrid LineColor="Gainsboro" />
                                <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 9.0pt" />
                            </AxisX>
                            <AxisY Title='BracketCount' Maximum="1000" Minimum="500" Interval="100"
                                IsStartedFromZero="False"
                                TitleFont="Microsoft Sans Serif, 9.0pt">
                                <MajorGrid LineColor="Gainsboro" />
                                <LabelStyle Interval="Auto" Font="Microsoft Sans Serif, 9.0pt" />
                            </AxisY>
                        </asp:ChartArea>
                    </ChartAreas>
                </asp:Chart>
            </span>
        </div>
    </div>
</div>
