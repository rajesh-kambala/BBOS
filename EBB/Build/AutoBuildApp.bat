cd D:\EBBCRM
copy BBSBuild.config.App.include BBSBuild.config.include /Y
nant.exe -buildfile:.\BBS.build -logfile:.\Build.txt