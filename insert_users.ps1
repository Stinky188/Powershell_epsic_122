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


# Import AD Module
Import-Module ActiveDirectory -ErrorAction Stop

# Merci de spécifier le chemin complet vers le fichier csv qui contient les informations pour les utilisateurs.
$csvFilePath

$userData = Import-Csv -Path $csvFilePath -Delimiter ';'

foreach ($User in $userData) {
    #Read user data from each field in each row and assign the data to a variable as below
    $GivenName = [string]$User.FirstName
    $Surname = [string]$User.LastName
    $Username = [string]$User.UserName
    $emailDomain = [string]$User.emailDomain
    $Title = [string]$User.JobTitle
    $Department = [string]$User.Department
    $InitialPassword = [string]$User.Password
    $dn = [string]$User.dn
    $tld = [string]$User.tld
    Write-Output $Username
    
    $count = 2
    while (Get-ADUser -Filter "SamAccountName -eq '$Username'") {
        $Username = '{0}{1}' -f $User.UserName, $count++

    }
    #User does not exist then proceed to create the new user account 
      
    $newUserInfo = @{
        SamAccountName        = $Username
        Name                  = $Username
        GivenName             = $GivenName
        Surname               = $Surname
        DisplayName           = "$Surname $GivenName"
        UserPrincipalName     = "$Username@$companyDomain"
        EmailAddress          = "$Username@$emailDomain"
        Enabled               = $True
        ChangePasswordAtLogon = $true
        Path                  = "OU=$Department,OU=OU,DC=$dn,DC=$tld" #ne pas hard coder le nom de l'AD, possible de faire un csv ou de le demander en paramètre.
        Company               = "$dn.$tld"
        AccountPassword       = (ConvertTo-SecureString $InitialPassword -AsPlainText -Force)
        Title                 = $Title
        Department            = $Department
        Description           = $Title
    }

    New-ADUser @newUserInfo -Verbose
} 

$properties = @(
  'givenName',
  'surname',
  'sAMAccountName',
  'emailAddress',
  'title',
  'department'
)

$dn = [string]$userData.dn[0]
$tld = [string]$userData.tld[0]
Write-Host "OU=OU,DC=$dn,DC=$tld"

Get-ADUser -filter * -properties $properties -SearchBase "OU=OU,DC=$dn,DC=$tld" | Select-Object -Property @{Name = 'FirstName'; Expression = {$_.givenName}},@{Name = 'LastName'; Expression = {$_.surname}},@{Name = 'Username'; Expression = {$_.sAMAccountName}},@{Name = 'Email'; Expression = {$_.emailAddress}},@{Name = 'Department'; Expression = {$_.department}},@{Name = 'JobTitle'; Expression = {$_.title}} | Export-CSV -path $csvFilePath -Delimiter ';' -NoTypeInformation

$reimport = Import-Csv -Path $csvFilePath -Delimiter ';'

foreach ($row in $reimport) { 
    $row | Add-Member -MemberType "NoteProperty" -Name dn -Value $dn -Force 
    $row | Add-Member -MemberType "NoteProperty" -Name tld -Value $tld -Force 
}

$reimport | Export-CSV -path $csvFilePath -Delimiter ';' -NoTypeInformation