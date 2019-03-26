
$sourcefileFullpath = "C:\\ykmd.zip"
$cabfile = "YubiKey-Minidriver-4.0.4.164.cab"

$registryPath = "HKLM:\Software\Yubico\YKMD"
$temp = "$env:windir\\temp"
$destination = "ykmd"
$fullpath = $temp+"\"+$destination
$destA = "$env:windir\system32"
$destB = "$env:windir\SysWOW64"

#extact the contents of the zip folder
Expand-Archive -Path $sourcefileFullpath -DestinationPath $fullpath
cmd.exe /c expand $fullpath\$cabfile -F:* $fullpath | Out-Null
Get-ChildItem $fullpath -Recurse -Filter "*inf" | ForEach-Object { PNPUtil.exe /add-driver $_.FullName /install }

#import the registry keys
Invoke-Command {reg import $fullpath\yubikey.reg *>&1 | Out-Null}

#initate the driver
cmd.exe /c DrvInst.exe "2" "11" "ROOT\SMARTCARD\0000" "$fullpath\ykmd.inf" "ykmd.inf:e5735744d5c8dcef:Yubico64_61_install:4.0.4.164:scfilter\cid_597562696b657934" "46c3051cd" "000000000009B4" 

#copy dll's to correct locations
Copy-item $fullpath\ykmd64.dll -Destination $destA\ykmd.dll -Passthru -Force  
Copy-Item $fullpath\ykmd.dll -Destination $destB\ykmd.dll -Passthru -Force

#enable the Smart Card Service
Get-Service -Name "Scardsvr" | Set-Service -StartupType Automatic
