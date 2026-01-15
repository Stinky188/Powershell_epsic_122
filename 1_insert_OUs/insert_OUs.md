# README

## Description

Ce script PowerShell permet d’automatiser la création d’Unités d’Organisation (OU) dans un Active Directory (AD). Il ajoute des informations sur le domaine et le TLD (Top-Level Domain) de l'AD aux données importées et crée une structure d’OU basée sur les départements présents dans le CSV.

---

## Comment l’utiliser

### Entrées nécessaires

- Un fichier CSV contenant les données utilisateurs, avec au minimum les colonnes suivantes: FirstName;LastName;UserName;Password;Email;Department;JobTitle
- Le fichier CSV doit être au format texte, encodé en UTF-8, avec un séparateur `;`.

### Sorties

- Mise à jour du fichier CSV avec des colonnes supplémentaires : `dn` (nom de domaine), `tld` (top-level domain).
- Création d’une OU racine nommée `OU` si elle n’existe pas.
- Création d’Unités d’Organisation enfants correspondant aux départements présents dans le CSV.

---

## Description détaillée des paramètres

|Paramètre|Description|Valeurs acceptables|Obligatoire|
|---|---|---|---|
|`-csvFilePath`|Chemin complet vers le fichier CSV à importer. Le fichier doit être au format `.csv`.|Chemin valide vers un fichier `.csv`|Oui|

---

## Exemples d’utilisation

### Importer un fichier CSV et créer les OU pour le domaine `laboad.vd`

```powershell
1_insert_OUs/insert_OUs.ps1 -csvFilePath "happy_koalas_employees.csv"
```
## Dépendances / prérequis

- PowerShell (présent de base sur Windows Server)
- Module ActiveDirectory installé depuis le script (`Import-Module ActiveDirectory`)
- Droits administratifs sur l’Active Directory
- Fichier CSV encodé en UTF-8 avec séparateur `;`

---

## Licence

Ce script est distribué sous licence [MIT](https://opensource.org/licenses/MIT). Vous êtes libre de l’utiliser, modifier et redistribuer conformément aux termes de cette licence.