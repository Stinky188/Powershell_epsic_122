[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]    
    [string]$csvFilePath = $csvinput
)
if ([IO.Path]::GetExtension($csvFilePath) -match ".csv") {
    Write-Output "Le chemin pour le fichier .csv est valable, importation des donnees."
}
Else {
    Write-Warning "Chemin invalide. Le nom du fichier doit se terminer en .csv"
}

# à ajouter dans les paramètres : DC et DC

# Cette variable est utile pour stocker les informations du csv dans un format utilisable par Powershell.
$userData = Import-Csv -Path $csvFilePath -Delimiter ';'

$domainName = Read-Host "Ecrivez le nom de domaine de votre AD (exemple : myAD)"
$topLevelDomain = Read-Host "Ecrivez le tld de votre AD (exemple : com)"
#$emailDomain = Read-Host "Ecrivez le nom de domaine apres le arobase de l'adresse mail (exemple : gmail.com)"

$emailString = $userData[0].Email
$findchar = $emailString.IndexOf("@")
$emailDomain = $emailString.Substring($findchar+1)

Write-Host "Le nom de l'active directory est $domainName.$topLevelDomain. Le format de l'adresse mail est <user>@$emailDomain. Informations ajoutees au csv."

#demander le nom de l'active directory
foreach ($row in $userData) { 
    $row | Add-Member -MemberType "NoteProperty" -Name dn -Value $domainName -Force 
    $row | Add-Member -MemberType "NoteProperty" -Name tld -Value $topLevelDomain -Force 
    $row | Add-Member -MemberType "NoteProperty" -Name emailDomain -Value $emailDomain -Force
}

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
        #OU will be created according to the $ou variable read from the CSV file
        New-ADOrganizationalUnit -Name $ou -Path "OU=OU,DC=$dn,DC=$tld" -ProtectedFromAccidentalDeletion $False
        Write-Host "Creation de l'OU $ou."
    }
}
