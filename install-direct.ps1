# This script installs the webgl-nginx repository directly into the current directory
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/idkmanplsimconfused/webgl-nginx/master/install.ps1') 