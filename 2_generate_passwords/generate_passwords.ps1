<#
SYNOPSIS
This script generates random passwords for users listed in a CSV file and appends these passwords as a new column.

DESCRIPTION
The script reads user data from a CSV file, generates a secure random password for each user using a customizable function, 
and exports the updated data back to the CSV. It ensures that the generated passwords include mandatory character sets 
(uppercase, lowercase, numbers, symbols) for stronger security.

AUTHOR
Alice Dale - alice.dale@eduvaud.ch

LIMITATIONS
- The script assumes the CSV uses ';' as delimiter.
- Password length and character sets are currently fixed but could be parameterized.
- The script overwrites the original CSV file, so backup is recommended.
- No error handling implemented for file access or CSV format issues.

EXAMPLES
# Generate passwords for users in users.csv with default parameters
.\GeneratePasswords.ps1 -csvFilePath "C:\path\to\users.csv"

# Description of usage and expected input/output is in the README file.
#>

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]    
    [string]$csvFilePath = $csvinput
)

# Validate that the input file has a .csv extension to avoid processing unsupported formats.
if ([IO.Path]::GetExtension($csvFilePath) -match ".csv") {
    Write-Output "Le chemin pour le fichier .csv est valable"
}
else {
    # Warn the user early to prevent downstream errors related to invalid file types.
    Write-Warning "Chemin invalide. Le nom du fichier doit se terminer en .csv"
}

# Import user data from the CSV file using the specified delimiter to correctly parse fields.
$userData = Import-Csv -Path $csvFilePath -Delimiter ';'

# This function generates a random password string of given length.
# It ensures mandatory inclusion of uppercase, lowercase, numerals, and symbols by design.
Function Create-String([Int]$Size = 8, [Char[]]$CharSets = "ULNS", [Char[]]$Exclude) {
    $Chars = @()
    $TokenSet = @()

    # Cache the token sets globally to avoid rebuilding them on each function call, improving performance.
    If (!$TokenSets) {
        $Global:TokenSets = @{
            U = [Char[]]'ABCDEFGHIJKLMNOPQRSTUVWXYZ'                                # Upper case
            L = [Char[]]'abcdefghijklmnopqrstuvwxyz'                                # Lower case
            N = [Char[]]'0123456789'                                                # Numerals
            S = [Char[]]'!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~'                         # Symbols
        }
    }

    # Build the pool of allowed characters while excluding specified characters for compliance or readability.
    $CharSets | ForEach {
        $Tokens = $TokenSets."$_" | ForEach { If ($Exclude -cNotContains $_) { $_ } }
        If ($Tokens) {
            $TokensSet += $Tokens
            # Ensure at least one character from each mandatory set is included by adding one guaranteed character.
            If ($_ -cle [Char]"Z") { $Chars += $Tokens | Get-Random }
        }
    }

    # Fill the remaining password length with random characters from the combined pool.
    While ($Chars.Count -lt $Size) { $Chars += $TokensSet | Get-Random }

    # Shuffle the mandatory characters with the rest to avoid predictable patterns.
    ($Chars | Sort-Object { Get-Random }) -Join ""
}

# Create an alias for easier invocation of the password generation function.
Set-Alias Create-Password Create-String -Description "Generate a random string (password)"

# For each user in the CSV, generate a new password and add it as a property to the user object.
foreach ($row in $userData) { 
    $newPwd = Create-Password 8 ULNS
    # Add the generated password as a new property named 'Password' to be exported later.
    $row | Add-Member -MemberType "NoteProperty" -Name Password -Value $newPwd -Force 
}

# Export the updated user data back to the CSV file, removing quotes to simplify file readability.
$userData | Export-CSV -Path $csvFilePath -Delimiter ';' -NoTypeInformation
