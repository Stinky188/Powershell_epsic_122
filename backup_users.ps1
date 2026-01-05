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
#Il est important d'utiliser l'ancien csv pour pouvoir répliquer les headers dans le csv qui sera archivé.

# Import AD Module
Import-Module ActiveDirectory -ErrorAction Stop

$properties = @(
  'givenName',
  'surname',
  'sAMAccountName',
  'emailAddress',
  'title',
  'department'
)

$userData = Import-Csv -Path $csvFilePath -Delimiter ';'
#Read user data from each field in each row and assign the data to a variable as below
$dn = [string]$userData.dn[0]
$tld = [string]$userData.tld[0]

$OUs = 
"OU=Finance,OU=OU,DC=$dn,DC=$tld",
"OU=IT,OU=OU,DC=$dn,DC=$tld",
"OU=Marketing,OU=OU,DC=$dn,DC=$tld",
"OU=Production,OU=OU,DC=$dn,DC=$tld",
"OU=RH,OU=OU,DC=$dn,DC=$tld"

$ADReport =
foreach($OU in $OUs){
    Get-ADUser -filter * -properties $properties -Searchbase $OU
}

$path = "C:\backups\"
If(!(test-path -PathType container $path))
{
      New-Item -ItemType Directory -Path $path
}

$csvOutputName = "$((Get-Date).ToString("yyyy-MM-dd"))_users"
$csvExtension = ".csv"
$zipExtension = ".zip"
$csvOutputPath = "$path$csvOutputName$csvExtension"

$ADReport |
Select-Object -Property @{Name = 'FirstName'; Expression = {$_.givenName}},@{Name = 'LastName'; Expression = {$_.surname}},@{Name = 'Username'; Expression = {$_.sAMAccountName}},@{Name = 'Email'; Expression = {$_.emailAddress}},@{Name = 'Department'; Expression = {$_.department}},@{Name = 'JobTitle'; Expression = {$_.title}} | Export-CSV -path $csvOutputPath -Delimiter ';' -NoTypeInformation

$reimport = Import-Csv -path $csvOutputPath -Delimiter ';'

foreach ($row in $reimport) { 
    $row | Add-Member -MemberType "NoteProperty" -Name dn -Value $dn -Force 
    $row | Add-Member -MemberType "NoteProperty" -Name tld -Value $tld -Force 
}

$reimport | Export-CSV -path $csvOutputPath -Delimiter ';' -NoTypeInformation

# Crée l’archive ZIP
Compress-Archive -Path $csvOutputPath -DestinationPath "$path$csvOutputName" -Force

# Supprime le csv temporaire
Remove-Item $csvOutputPath -Recurse -Force

Write-Host "Sauvegarde compressee effectuee avec succes !" -ForegroundColor Green
Write-Host "Chemin = $path$csvOutputName$zipExtension"gu