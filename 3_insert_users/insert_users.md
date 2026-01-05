# README

## Description

Ce script PowerShell permet d’automatiser la création d’utilisateurs dans Active Directory (AD) à partir d’un fichier CSV. Il garantit l’unicité des noms d’utilisateur en ajoutant un suffixe numérique en cas de doublon, et organise les comptes dans des unités d’organisation (OU) en fonction des départements. L'utilisateur devra changer son mot de passe lors de sa première connexion. Les utilisateurs créés sont ensuite reexportés au format csv pour gérer les différences en cas de doublons (ex: adale, adale2, adale3, etc.)

---

## Comment l’utiliser

### Entrées nécessaires

- Un fichier CSV contenant les informations utilisateurs, avec au minimum les colonnes suivantes :  
    `FirstName`, `LastName`, `UserName`, `emailDomain`, `JobTitle`, `Department`, `Password`, `dn`, `tld`.
- La variable `$companyDomain` doit être définie dans l’environnement d’exécution du script, correspondant au domaine principal AD (exemple : `mycompany.com`).

### Ce que le script produit

- Création des comptes utilisateurs dans AD avec les propriétés essentielles renseignées.
- Gestion automatique des doublons de noms d’utilisateur en ajoutant un suffixe numérique.
- Organisation des utilisateurs dans des OU correspondant aux départements.
- Export du fichier CSV mis à jour avec les utilisateurs créés et enrichi des informations de domaine.

---

## Description détaillée des paramètres

|Paramètre|Description|Valeurs acceptables|Obligatoire|
|---|---|---|---|
|`-csvFilePath`|Chemin complet vers le fichier CSV contenant les données utilisateurs. Le fichier doit être au format `.csv`.|Chemin valide vers un fichier `.csv`|Oui|

---

## Exemples d’utilisation

### Création d’utilisateurs à partir du fichier `users.csv`

```powershell
powershell
```

```powershell
3_insert_users/insert_users.ps1 -csvFilePath "happy_koalas_employees.csv"
```

## État d’avancement

- [x] Validation du fichier CSV en entrée
- [x] Import des données utilisateurs depuis le CSV
- [x] Gestion des doublons de noms d’utilisateur
- [x] Création des comptes utilisateurs dans Active Directory
- [x] Export des utilisateurs créés dans le fichier CSV
- [ ] Gestion avancée des erreurs et validation des données
- [ ] Paramétrage dynamique du domaine principal (`$companyDomain`)
- [ ] Sauvegarde automatique du fichier CSV avant écrasement

---

## Dépendances / prérequis

- PowerShell version 5.1 ou supérieure
- Module ActiveDirectory installé et accessible (`Import-Module ActiveDirectory`)
- Droits administratifs suffisants pour créer des utilisateurs et des OU dans Active Directory
- Fichier CSV encodé en UTF-8 avec séparateur `;`
- Variable d’environnement `$companyDomain` définie avant l’exécution du script

---

## Licence

Ce script est distribué sous licence [MIT](https://opensource.org/licenses/MIT). Vous pouvez librement l’utiliser, modifier et redistribuer conformément aux termes de cette licence.