New-Variable -Name 'app_name' -Value 'cheat' -Option Constant

$root = (Get-Location).Path
$bin = Join-Path -Path $root -ChildPath 'bin'
New-Item -Name 'build' -ItemType 'Directory' -Force
New-Item -Name 'bin' -ItemType 'Directory' -Force
Set-Location -Path 'build'

$asm = Join-Path -Path $root -ChildPath 'src' -AdditionalChildPath '*.asm'
Start-Process -FilePath 'ml' -ArgumentList '/c', '/coff', $asm -NoNewWindow -Wait
Start-Process -FilePath 'link' -ArgumentList '/subsystem:windows', '/dll', "/out:$app_name.dll", '*.obj' -NoNewWindow -Wait

Move-Item -Path "$app_name.dll" -Destination $bin -Force