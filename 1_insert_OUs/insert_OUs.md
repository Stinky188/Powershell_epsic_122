# README

## Description

Ce script PowerShell permet d’automatiser l’importation d’utilisateurs depuis un fichier CSV et la création d’Unités d’Organisation (OU) dans un Active Directory (AD). Il ajoute également des informations sur le domaine et le TLD (Top-Level Domain) aux données importées, et crée une structure d’OU basée sur les départements présents dans le CSV. Ce script facilite la gestion et la structuration des comptes utilisateurs dans un environnement AD.

---

## Comment l’utiliser

### Entrées nécessaires

- Un fichier CSV contenant les données utilisateurs, avec au minimum une colonne `Email` et une colonne `Department`.
- Le nom de domaine (domain name) de l’Active Directory (exemple : `myAD`).
- Le TLD du domaine (exemple : `com`).

### Sorties

- Mise à jour du fichier CSV avec des colonnes supplémentaires : `dn` (nom de domaine), `tld` (top-level domain), et `emailDomain` (domaine des emails extraits).
- Création d’une OU racine nommée `OU` si elle n’existe pas.
- Création d’Unités d’Organisation enfants correspondant aux départements présents dans le CSV.

---

## Description détaillée des paramètres

|Paramètre|Description|Valeurs acceptables|Obligatoire|
|---|---|---|---|
|`-csvFilePath`|Chemin complet vers le fichier CSV à importer. Le fichier doit être au format `.csv`.|Chemin valide vers un fichier `.csv`|Oui|
|`-domainName`|Nom du domaine Active Directory (exemple : `myAD`).|Chaîne de caractères non vide|Oui|
|`-topLevelDomain`|TLD du domaine Active Directory (exemple : `com`).|Chaîne de caractères non vide|Oui|

---

## Exemples d’utilisation

### Importer un fichier CSV et créer les OU pour le domaine `laboad.vd`

```powershell
powershell
```

```powershell
1_insert_OUs/insert_OUs.ps1 -csvFilePath "happy_koalas_employees.csv" -domainName "laboad" -topLevelDomain "vd"
```

## État d’avancement

- [x] Importation et validation du fichier CSV
- [x] Extraction du domaine email depuis la première adresse mail
- [x] Ajout des propriétés domaine et tld aux données CSV
- [x] Export du CSV modifié
- [x] Création de l’OU racine si inexistante
- [x] Création des OU enfants basés sur les départements
- [ ] Gestion avancée des erreurs et validation des entrées
- [ ] Ajout de logs détaillés
- [ ] Optimisation pour gros volumes de données

---

## Dépendances / prérequis

- PowerShell version 5.1 ou supérieure (PowerShell Core recommandé pour compatibilité multiplateforme)
- Module ActiveDirectory installé et accessible (`Import-Module ActiveDirectory`)
- Droits administratifs sur l’Active Directory pour créer des OU
- Fichier CSV encodé en UTF-8 avec séparateur `;`

---

## Licence

Ce script est distribué sous licence [MIT](https://opensource.org/licenses/MIT). Vous êtes libre de l’utiliser, modifier et redistribuer conformément aux termes de cette licence.