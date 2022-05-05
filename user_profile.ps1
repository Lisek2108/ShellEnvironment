
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Prompt 
Import-Module posh-git
Import-Module oh-my-posh
oh-my-posh --init --shell pwsh --config ~/.config/oh_my_posh/config.omp.json | Invoke-Expression


Import-Module -Name Terminal-Icons

# Autocompletion
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# Fuzzy finder
Import-Module PSFzf
Set-PSFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Alias
Set-Alias -Name ll -Value ls
Set-Alias g git



