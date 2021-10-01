FROM microsoft/dotnet-framework:4.7.2-runtime-windowsservercore-ltsc2016

COPY bin C:/inetpub/wwwroot
COPY Default.aspx C:/inetpub/wwwroot
COPY web.config C:/inetpub/wwwroot
COPY favicon.ico C:/inetpub/wwwroot

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Add-WindowsFeature Web-Server \
    Add-WindowsFeature NET-Framework-45-ASPNET \
    Add-WindowsFeature Web-Asp-Net45 \
    Remove-Item -Recurse C:\inetpub\wwwroot \
    Invoke-WebRequest -Uri https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.3/ServiceMonitor.exe -OutFile C:\ServiceMonitor.exe

#download Roslyn nupkg and ngen the compiler binaries
RUN Invoke-WebRequest https://api.nuget.org/packages/microsoft.net.compilers.2.8.2.nupkg -OutFile c:\microsoft.net.compilers.2.8.2.zip \
    Expand-Archive -Path c:\microsoft.net.compilers.2.8.2.zip -DestinationPath c:\RoslynCompilers \
    Remove-Item c:\microsoft.net.compilers.2.8.2.zip -Force \
    &C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe update \
    &C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe update  \
    &C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\csc.exe /ExeConfig:c:\RoslynCompilers\tools\csc.exe | \ 
    &C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\vbc.exe /ExeConfig:c:\RoslynCompilers\tools\vbc.exe  | \ 
    &C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\VBCSCompiler.exe /ExeConfig:c:\RoslynCompilers\tools\VBCSCompiler.exe | \ 
    &C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\csc.exe /ExeConfig:c:\RoslynCompilers\tools\csc.exe | \ 
    &C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\vbc.exe /ExeConfig:c:\RoslynCompilers\tools\vbc.exe | \ 
    &C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\VBCSCompiler.exe  /ExeConfig:c:\RoslynCompilers\tools\VBCSCompiler.exe 

ENV ROSLYN_COMPILER_LOCATION c:\\RoslynCompilers\\tools

EXPOSE 80