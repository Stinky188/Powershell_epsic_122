#exemple pour lancer le script  C:\Users\Administrator\Documents\Scripts\generate_password.ps1 "C:\Users\Administrator\Documents\Scripts\happy_koalas_employees.csv"

    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]    
        [string]$csvFilePath = $csvinput
    )
    if ([IO.Path]::GetExtension($csvFilePath) -match ".csv") {
        Write-Output "Le chemin pour le fichier .csv est valable"
    }
    Else {
        Write-Warning "Chemin invalide. Le nom du fichier doit se terminer en .csv"
    }


$csvFilePath
$userData = Import-Csv -Path $csvFilePath -Delimiter ';'

Function Create-String([Int]$Size = 8, [Char[]]$CharSets = "ULNS", [Char[]]$Exclude) {
    $Chars = @(); $TokenSet = @()
    If (!$TokenSets) {
        $Global:TokenSets = @{
            U = [Char[]]'ABCDEFGHIJKLMNOPQRSTUVWXYZ'                                #Upper case
            L = [Char[]]'abcdefghijklmnopqrstuvwxyz'                                #Lower case
            N = [Char[]]'0123456789'                                                #Numerals
            S = [Char[]]'!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~'                         #Symbols
        }
    }
    $CharSets | ForEach {
        $Tokens = $TokenSets."$_" | ForEach { If ($Exclude -cNotContains $_) { $_ } }
        If ($Tokens) {
            $TokensSet += $Tokens
            If ($_ -cle [Char]"Z") { $Chars += $Tokens | Get-Random }             #Character sets defined in upper case are mandatory
        }
    }
    While ($Chars.Count -lt $Size) { $Chars += $TokensSet | Get-Random }
    ($Chars | Sort-Object { Get-Random }) -Join ""                                #Mix the (mandatory) characters and output string
}; Set-Alias Create-Password Create-String -Description "Generate a random string (password)"

foreach ($row in $userData) { 
    $newPwd = Create-Password 8 ULNS
    $row | Add-Member -MemberType "NoteProperty" -Name Password -Value $newPwd -Force 
}
$userData | Export-CSV -Path $csvFilePath -Delimiter ';' -NoTypeInformation | % { $_ -replace '"', '' }
