param([Parameter(Mandatory=$true)][string]$GodotPath)
$projectFolder = Split-Path -Parent $PSScriptRoot
$webFolder = Join-Path (Split-Path -Parent $projectFolder) 'cafe-com-patas-web'
New-Item -ItemType Directory -Force -Path $webFolder | Out-Null
& $GodotPath --headless --path $projectFolder --export-release 'Web' (Join-Path $webFolder 'index.html')
if ($LASTEXITCODE -ne 0) { throw 'Exportação falhou. Confira se os modelos Web da mesma versão do Godot estão instalados.' }
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'serve.py') -Destination (Join-Path $webFolder 'serve.py')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'GODOT-LICENSE.txt') -Destination (Join-Path $webFolder 'GODOT-LICENSE.txt')
Write-Host "Exportado em $webFolder. Para testar: python serve.py"
