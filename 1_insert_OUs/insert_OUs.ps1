[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]    
    [string]$csvFilePath = $csvinput,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$domainName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$topLevelDomain
)

if ([IO.Path]::GetExtension($csvFilePath) -match ".csv") {
    Write-Output "Le chemin pour le fichier .csv est valable, importation des donnees."
}
else {
    Write-Warning "Chemin invalide. Le nom du fichier doit se terminer en .csv"
    exit
}

# Import CSV data
$userData = Import-Csv -Path $csvFilePath -Delimiter ';'

# Extract email domain from first email in CSV
$emailString = $userData[0].Email
$findchar = $emailString.IndexOf("@")
$emailDomain = $emailString.Substring($findchar + 1)

Write-Host "Le nom de l'active directory est $domainName.$topLevelDomain. Le format de l'adresse mail est <user>@$emailDomain. Informations ajoutees au csv."

# Add domain info to each row
foreach ($row in $userData) { 
    $row | Add-Member -MemberType "NoteProperty" -Name dn -Value $domainName -Force 
    $row | Add-Member -MemberType "NoteProperty" -Name tld -Value $topLevelDomain -Force 
    $row | Add-Member -MemberType "NoteProperty" -Name emailDomain -Value $emailDomain -Force
}

# Export updated CSV
$userData | Export-CSV -Path $csvFilePath -Delimiter ';' -NoTypeInformation

Import-Module ActiveDirectory -ErrorAction Stop

$userData = Import-Csv -Path $csvFilePath -Delimiter ';'

#Loop through each row containing user details in the CSV file
foreach ($organisationalUnit in $userData) {
    #Read user data from each field in each row and assign the data to a variable as below
    $ou = [string]$organisationalUnit.Department
    $dn = [string]$organisationalUnit.dn
    $tld = [string]$organisationalUnit.tld
}
# Check and create root OU if not exists
if (Get-ADOrganizationalUnit -Filter "Name -eq 'OU'") {
    Write-Host "L'OU a la racine a deja ete cree."
}
else {
    #Account will be created in the OU provided by the $OU variable read from the CSV file
    New-ADOrganizationalUnit -Name "OU" -ProtectedFromAccidentalDeletion $False
    Write-Host "Creation de l'OU a la racine."
}

# Create child OUs under the parent "OU"
foreach ($ou in $userData.Department | Select-Object -Unique) {
    if (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'") {
        Write-Host "L'OU $ou a deja ete cree."
    }
    else {
        New-ADOrganizationalUnit -Name $ou -Path "OU=OU,DC=$dn,DC=$tld" -ProtectedFromAccidentalDeletion $False
        Write-Host "Creation de l'OU $ou."
    }
}