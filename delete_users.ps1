# Import AD Module
Import-Module ActiveDirectory

# Merci de spécifier le chemin complet vers le fichier csv qui contient les informations pour les utilisateurs.
$csvFilePath = "C:\Users\Administrator\Documents\Scripts\happy_koalas_employees.csv"

$userData = Import-Csv -Path $csvFilePath -Delimiter ';'

foreach ($User in $userData) {
    #Read user data from each field in each row and assign the data to a variable as below
    $Username = [string]$User.UserName
    Write-Output $Username
    
    #Check to see if the user already exists in AD
    if (Get-ADUser -F { SamAccountName -eq $Username }) {
        Remove-ADUser -Identity $Username -Verbose -Confirm:$False
    }
}