cd D:\EBBCRM
copy BBSBuild.config.All.include BBSBuild.config.include /Y
nant.exe -buildfile:.\BBS.build -logfile:.\Build.txt