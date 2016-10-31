# escape=`

FROM microsoft/aspnet:latest

RUN powershell Invoke-WebRequest https://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi -UseBasicParsing -OutFile C:/webdeploy.msi; `
Start-Process msiexec -ArgumentList '/i C:\webdeploy.msi /qn' -Wait

RUN powershell Invoke-WebRequest https://github.com/hbuckle/NuGetServer/releases/download/v1.0/Deploy.zip -UseBasicParsing -OutFile C:/Deploy.zip; `
Expand-Archive C:/Deploy.zip -DestinationPath C:/Deploy

RUN Invoke-WebRequest https://raw.githubusercontent.com/hbuckle/NuGetServer/master/Docker/Set-Key.ps1 -UseBasicParsing -OutFile C:/Set-Key.ps1

WORKDIR C:/Deploy

RUN NuGetServer.deploy.cmd, /Y

ENTRYPOINT powershell.exe -executionpolicy bypass C:/Set-Key.ps1
