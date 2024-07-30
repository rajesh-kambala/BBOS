@Echo off
set SRSServer=Dev1

"D:\Program Files\Microsoft SQL Server\90\Tools\Binn\rs.exe" -i d:\\applications\build\DeployReports.rss   -s http://%SRSServer%/ReportServer -b -t -v reportfolder="ProdMirror/BBOSMemberReports" -v filepath="D:\Applications\Reporting\BBOSMemberReports"
"D:\Program Files\Microsoft SQL Server\90\Tools\Binn\rs.exe" -i d:\\applications\build\LinkDataSources.rss -s http://%SRSServer%/ReportServer -b -t -v reportfolder="ProdMirror/BBOSMemberReports" -v filepath="D:\Applications\Reporting\BBOSMemberReports" -v dsName="Data Sources/ProdMirror"

"D:\Program Files\Microsoft SQL Server\90\Tools\Binn\rs.exe" -i d:\\applications\build\DeployReports.rss   -s http://%SRSServer%/ReportServer -b -t -v reportfolder="ProdMirror/BBOSUsageReports" -v filepath="D:\Applications\Reporting\BBOSUsageReports"
"D:\Program Files\Microsoft SQL Server\90\Tools\Binn\rs.exe" -i d:\\applications\build\LinkDataSources.rss -s http://%SRSServer%/ReportServer -b -t -v reportfolder="ProdMirror/BBOSUsageReports" -v filepath="D:\Applications\Reporting\BBOSUsageReports" -v dsName="Data Sources/ProdMirror"

"D:\Program Files\Microsoft SQL Server\90\Tools\Binn\rs.exe" -i d:\\applications\build\DeployReports.rss   -s http://%SRSServer%/ReportServer -b -t -v reportfolder="ProdMirror/BBScoreReports" -v filepath="D:\Applications\Reporting\BBScoreReports"
"D:\Program Files\Microsoft SQL Server\90\Tools\Binn\rs.exe" -i d:\\applications\build\LinkDataSources.rss -s http://%SRSServer%/ReportServer -b -t -v reportfolder="ProdMirror/BBScoreReports" -v filepath="D:\Applications\Reporting\BBScoreReports" -v dsName="Data Sources/ProdMirror"

"D:\Program Files\Microsoft SQL Server\90\Tools\Binn\rs.exe" -i d:\\applications\build\DeployReports.rss   -s http://%SRSServer%/ReportServer -b -t -v reportfolder="ProdMirror/BBSReporting" -v filepath="D:\Applications\Reporting\BBSReporting"
"D:\Program Files\Microsoft SQL Server\90\Tools\Binn\rs.exe" -i d:\\applications\build\LinkDataSources.rss -s http://%SRSServer%/ReportServer -b -t -v reportfolder="ProdMirror/BBSReporting" -v filepath="D:\Applications\Reporting\BBSReporting" -v dsName="Data Sources/ProdMirror"

"D:\Program Files\Microsoft SQL Server\90\Tools\Binn\rs.exe" -i d:\\applications\build\DeployReports.rss   -s http://%SRSServer%/ReportServer -b -t -v reportfolder="ProdMirror/BusinessReport" -v filepath="D:\Applications\Reporting\BusinessReport"
"D:\Program Files\Microsoft SQL Server\90\Tools\Binn\rs.exe" -i d:\\applications\build\LinkDataSources.rss -s http://%SRSServer%/ReportServer -b -t -v reportfolder="ProdMirror/BusinessReport" -v filepath="D:\Applications\Reporting\BusinessReport" -v dsName="Data Sources/ProdMirror"

pause