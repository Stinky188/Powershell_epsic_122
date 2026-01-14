# README

## Description

Ce script PowerShell permet d’automatiser la création d’utilisateurs dans Active Directory (AD) à partir d’un fichier CSV. Il garantit l’unicité des noms d’utilisateur en ajoutant un suffixe numérique en cas de doublon, et organise les comptes dans des unités d’organisation (OU) en fonction des départements. L'utilisateur devra changer son mot de passe lors de sa première connexion. Les utilisateurs créés sont ensuite reexportés au format csv pour gérer les différences en cas de doublons (ex: adale, adale2, adale3, etc.)

---

## Comment l’utiliser

### Entrées nécessaires

- Un fichier CSV contenant les données utilisateurs, avec au minimum les colonnes suivantes: FirstName;LastName;UserName;Password;Email;Department;JobTitle;dn;tld;emailDomain
- Le fichier CSV doit être au format texte, encodé en UTF-8, avec un séparateur `;`.

### Ce que le script produit

- Création des comptes utilisateurs dans AD avec les propriétés renseignées.
- Gestion automatique des doublons de noms d’utilisateur en ajoutant un suffixe numérique.
- Organisation des utilisateurs dans des OU correspondant aux départements.
- Export du fichier CSV mis à jour avec les utilisateurs créés et les informations de domaine.

---

## Description détaillée des paramètres

|Paramètre|Description|Valeurs acceptables|Obligatoire|
|---|---|---|---|
|`-csvFilePath`|Chemin complet vers le fichier CSV contenant les données utilisateurs. Le fichier doit être au format `.csv`.|Chemin valide vers un fichier `.csv`|Oui|

---

## Exemples d’utilisation

```powershell
3_insert_users/insert_users.ps1 -csvFilePath "happy_koalas_employees.csv"
```
## Dépendances / prérequis

- PowerShell (présent de base sur Windows Server)
- Module ActiveDirectory installé depuis le script (`Import-Module ActiveDirectory`)
- Droits administratifs sur l’Active Directory
- Fichier CSV encodé en UTF-8 avec séparateur `;`

---

## Licence

Ce script est distribué sous licence [MIT](https://opensource.org/licenses/MIT). Vous pouvez librement l’utiliser, modifier et redistribuer conformément aux termes de cette licence.