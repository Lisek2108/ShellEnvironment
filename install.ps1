function commandExists($command) {
  if (Get-Command -Name $command -ErrorAction SilentlyContinue) {
    return $true
  }
  return $false
}

$PrerequisitesMet = $true

Write-Output ">> Checking prerequisites..."

if (!(commandExists('git'))) {
  Write-Host "Git is not installed. Please install Git and try again." -ForegroundColor Red
  $PrerequisitesMet = $false
}

if (!(commandExists('pwsh'))) {
  Write-Host "PowerShell is not installed. Please install PowerShell and try again." -ForegroundColor Red
  $PrerequisitesMet = $false
}

if (!$PrerequisitesMet) {
  exit 1
}
else {
  Write-Output ">> All Prerequisites met, starting installation..."
}

# Install scoop
if (!(commandExists('scoop'))) {
  Write-Output ">> Installing scoop"
  Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression
}
else {
  Write-Output ">> Scoop already installed"
}



$ProfilePath = Join-Path $Home "\Documents\Powershell\Microsoft.PowerShell_profile.ps1"
$ProfileFolder = Join-Path $env:userprofile \.config\powershell
$AskForProfileConfigurationCreation = $false

# Check if current user profile exists
if (!(Test-Path -Path $ProfilePath)) {
  Write-Output ">> Creating profile for current user inside $ProfilePath"
  New-Item -Path $ProfilePath -ItemType file
  "$env:USERPROFILE\.config\powershell\user_profile.ps1" | Out-File $ProfilePath
}
else {
  Write-Output ">> Profile for current user already exists in $ProfilePath"
  $confirmation = Read-Host ">> Do you want to overwrite it? (y/[N]) "
  if ($confirmation -eq 'y') {
    '&(Join-Path $env:USERPROFILE \.config\powershell\user_profile.ps1)' | Out-File $ProfilePath
  }
  else {
    Write-Output ">> Skipping profile creation"
    $AskForProfileConfigurationCreation = $true
  }
}

$SkipProfileConfiguration = $false

if ($AskForProfileConfigurationCreation) {
  $confirmation = Read-Host ">> Do you want to skip profile configuration? ([Y]/n) "
  $skipProfileConfiguration = !($confirmation -eq 'n')
}

if ($skipProfileConfiguration) {
  Write-Output ">> Skipping profile configuration"
}
else {

  # create profile directory
  if (Test-Path -Path $ProfileFolder) {
    Write-Output ">> Profile configuration folder [$ProfileFolder] already exists"
  }
  else {
    Write-Output ">> Creating profile configuration folder"
    New-Item -ItemType Directory -Path $ProfileFolder -ErrorAction SilentlyContinue
  }

  # create profile file
  $UserProfileFile = "user_profile.ps1"
  $ProfileFile = Join-Path $ProfileFolder $UserProfileFile
  if ( Test-Path -Path $ProfileFile ) {
    Write-Output ">> Profile configuration file [$ProfileFile] already exists!!!"
    $confirmation = Read-Host ">> Do you want to overwrite it? (y/[N]) "
    $SkipProfileConfiguration = !($confirmation -eq 'y')
  }

  if (!$SkipProfileConfiguration) {
    Write-Output ">> Creating profile configuration file"
    New-Item -ItemType File -Path $ProfileFile -ErrorAction SilentlyContinue
    Write-Output ">> Writing profile configuration file"
    Copy-Item -Path $UserProfileFile -Destination $ProfileFile 
  }

}

$SkipModuleInstallation = $false

if ($SkipProfileConfiguration) {
  $confirmation = Read-Host ">> Do you want to install PowerShell modules? ([Y]/n) "
  $skipModuleInstallation = ($confirmation -eq 'n')
}

if ($skipModuleInstallation) {
  Write-Output ">> Skipping module installation"
}
else {
  Write-Output ">> Installing PowerShell modules..."
  # Install oh my posh
  if (!(commandExists('oh-my-posh'))) {
    Write-Output ">> Installing oh my posh"
    Install-Module oh-my-posh -Scope CurrentUser -Force
    Install-Module posh-git -Scope CurrentUser -Force
  }
  else {
    Write-Output ">> Oh my posh already installed"
  }

  # Copy oh-my-posh configuration file
  $OhMyPoshFolder = Join-Path $env:userprofile \.config\oh_my_posh
  $OhMyPoshFile = "config.omp.json"
  $OhMyPoshFilePath = Join-Path $OhMyPoshFolder $OhMyPoshFile

  if (Test-Path -Path $OhMyPoshFolder) {
    Write-Output ">> Oh my posh configuration folder already exists"
  }
  else {
    Write-Output ">> Creating oh my posh configuration folder"
    New-Item -ItemType Directory -Path $OhMyPoshFolder -ErrorAction SilentlyContinue
  }

  if (Test-Path -Path $OhMyPoshFilePath) {
    Write-Output ">> Oh my posh configuration file already exists"
  }
  else {
    Write-Output ">> Creating oh my posh configuration file"
    New-Item -ItemType File -Path $OhMyPoshFilePath -ErrorAction SilentlyContinue
    Copy-Item -Path $OhMyPoshFile -Destination $OhMyPoshFilePath
  }


  # Install TerminalIcons
  if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Write-Output ">> Terminal-Icons already installed"
  }
  else {
    Write-Output ">> Installing Terminal-Icons"
    Install-Module Terminal-Icons -Scope CurrentUser -Force
  }
  # Install PSReadline
  if (Get-Module -ListAvailable -Name PSReadline) {
    Write-Output ">> PSReadline already installed"
  }
  else {
    Write-Output ">> Installing PSReadline"
    Install-Module PSReadline -AllowPrerelease -Scope CurrentUser -Force
  }

  #Install PsFzf
  if (Get-Module -ListAvailable -Name PSFzf) {
    Write-Output ">> PSFzf already installed"
  }
  else {
    Write-Output ">> Installing PSFzf"
    scoop install fzf
    Install-Module PSFzf -Scope CurrentUser -Force
  }
}

Write-Output ">> Configuration finished"
