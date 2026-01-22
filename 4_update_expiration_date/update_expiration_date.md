# README

## Description

Ce script PowerShell permet de définir une date d’expiration sur les comptes Active Directory d’utilisateurs spécifiques, en fonction de leur département et de leur titre, à partir d’une liste d’utilisateurs importée depuis un fichier CSV.
La date d'expiration sera affichée dans l'onglet "account" sous le format "end of [jour]". Le jour affiché sera un jour avant la date définie:
Ceci est parce que la date d'expiration est définie pour minuit, ce qui compte toujours techniquement comme le jour précédent.

Ce script est destiné à des utilisateurs avec des connaissances de base dans l'utilisation de scripts et de l'Active Directory.

---

## Comment l’utiliser

### Entrées nécessaires

- Un fichier CSV contenant les données utilisateurs, avec au minimum les colonnes suivantes: FirstName;LastName;UserName;Password;Email;Department;JobTitle;dn;tld
- Le fichier CSV doit être au format texte, encodé en UTF-8, avec un séparateur `;`.

### Ce que le script produit

- Pour chaque utilisateur du CSV dont le département et le titre correspondent aux critères, la date d’expiration du compte Active Directory est définie à la date actuelle plus le nombre de jours spécifié.

---

## Description détaillée des paramètres

|Paramètre|Description|Valeurs acceptables|Obligatoire|
|---|---|---|---|
|`-csvFilePath`|Chemin complet vers le fichier CSV contenant les noms d’utilisateur.|Chemin valide vers un fichier `.csv`|Oui|
|`-DepartmentToCheck`|Département cible pour appliquer la date d’expiration (exemple : `Production`).|Chaîne de caractères|Oui|
|`-TitleToCheck`|Titre cible pour appliquer la date d’expiration (exemple : `Assembler`).|Chaîne de caractères|Oui|
|`-DaysToAdd`|Nombre de jours à ajouter à la date actuelle pour fixer la date d’expiration.|Entier (exemple : `-1`)|Oui|

---

## Exemples d’utilisation

```powershell
4_update_expiration_date/update_expiration_date.ps1 -csvFilePath "happy_koalas_employees.csv" -DepartmentToCheck "Production" -TitleToCheck "Assembler" -DaysToAdd -1
```

## Dépendances / prérequis

- PowerShell (présent de base sur Windows Server)
- Module ActiveDirectory installé depuis le script (`Import-Module ActiveDirectory`)
- Droits administratifs sur l’Active Directory
- Fichier CSV encodé en UTF-8 avec séparateur `;`

---

## Licence

Ce script est distribué sous licence [MIT](https://opensource.org/licenses/MIT). Vous pouvez librement l’utiliser, modifier et redistribuer conformément aux termes de cette licence.