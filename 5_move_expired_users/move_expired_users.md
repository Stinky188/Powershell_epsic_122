# README

## Description

Ce script PowerShell automatise la gestion des comptes Active Directory expirés en les déplaçant dans une unité d’organisation (OU) dédiée nommée "Retired". Il importe les informations de domaine depuis un fichier CSV, crée l’OU si elle n’existe pas, puis centralise tous les comptes expirés non désactivés dans cette OU.

Ce script est destiné à des utilisateurs avec des connaissances de base dans l'utilisation de scripts et de l'Active Directory.

---

## Comment l’utiliser

### Entrées nécessaires

- Un fichier CSV contenant les données utilisateurs, avec au minimum les colonnes suivantes: FirstName;LastName;UserName;Password;Email;Department;JobTitle;dn;tld
- Le fichier CSV doit être au format texte, encodé en UTF-8, avec un séparateur `;`.

### Ce que le script produit

- Vérifie et crée si nécessaire une OU nommée "Retired" sous l’OU parent définie dans le domaine.
- Déplace tous les comptes Active Directory expirés (mais toujours activés) dans cette OU.

---

## Description détaillée des paramètres

|Paramètre|Description|Valeurs acceptables|Obligatoire|
|---|---|---|---|
|`-csvFilePath`|Chemin complet vers le fichier CSV contenant les informations de domaine.|Chemin valide vers un fichier `.csv`|Oui|

---

## Exemples d’utilisation

### Exemple : déplacer les comptes expirés vers l’OU "Retired"

```powershell
5_move_expired_users/move_expired_users.ps1 -csvFilePath "happy_koalas_employees.csv"
```

## Dépendances / prérequis

- PowerShell (présent de base sur Windows Server)
- Module ActiveDirectory installé depuis le script (`Import-Module ActiveDirectory`)
- Droits administratifs sur l’Active Directory
- Fichier CSV encodé en UTF-8 avec séparateur `;`

---

## Licence

Ce script est distribué sous licence [MIT](https://opensource.org/licenses/MIT). Vous pouvez librement l’utiliser, modifier et redistribuer conformément aux termes de cette licence.