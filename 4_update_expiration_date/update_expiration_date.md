# README

## Description

Ce script PowerShell permet de définir une date d’expiration sur les comptes Active Directory d’utilisateurs spécifiques, en fonction de leur département et de leur titre, à partir d’une liste d’utilisateurs importée depuis un fichier CSV. Il facilite la gestion des comptes temporaires ou sensibles en automatisant la désactivation programmée.

---

## Comment l’utiliser

### Entrées nécessaires

- Un fichier CSV contenant les noms d’utilisateur dans une colonne `Username`.
- Les paramètres suivants doivent être spécifiés lors de l’exécution du script :
    - Le département cible (exemple : `Production`)
    - Le titre cible (exemple : `Assembler`)
    - Le nombre de jours avant expiration (exemple : `-1` pour une expiration immédiate ou dans le passé)

### Ce que le script produit

- Pour chaque utilisateur du CSV dont le département et le titre correspondent aux critères, la date d’expiration du compte Active Directory est définie à la date actuelle plus le nombre de jours spécifié.
- Un message est affiché pour chaque compte traité, indiquant si la date d’expiration a été appliquée ou si l’utilisateur ne correspond pas aux critères.

---

## Description détaillée des paramètres

|Paramètre|Description|Valeurs acceptables|Obligatoire|
|---|---|---|---|
|`-csvFilePath`|Chemin complet vers le fichier CSV contenant les noms d’utilisateur.|Chemin valide vers un fichier `.csv`|Oui|
|`-DepartmentToCheck`|Département cible pour appliquer la date d’expiration (exemple : `Production`).|Chaîne de caractères|Oui|
|`-TitleToCheck`|Titre cible pour appliquer la date d’expiration (exemple : `Assembler`).|Chaîne de caractères|Oui|
|`-DaysToAdd`|Nombre de jours à ajouter à la date actuelle pour fixer la date d’expiration. Peut être négatif.|Entier (exemple : `-1`)|Oui|

---

## Exemples d’utilisation

### Exemple : appliquer une date d’expiration immédiate aux utilisateurs du département "Production" avec le titre "Assembler"

```powershell
powershell
```

```powershell
4_update_expiration_date/update_expiration_date.ps1 -csvFilePath "happy_koalas_employees.csv" -DepartmentToCheck "Production" -TitleToCheck "Assembler" -DaysToAdd -1
```

---

## État d’avancement

- [x] Import du fichier CSV et validation du chemin
- [x] Chargement du module Active Directory
- [x] Fonction de définition de la date d’expiration conditionnée au département et titre
- [x] Application de la date d’expiration pour chaque utilisateur correspondant
- [ ] Gestion avancée des erreurs (fichier introuvable, utilisateur AD inexistant)
- [ ] Ajout de logs détaillés et export des résultats

---

## Dépendances / prérequis

- PowerShell version 5.1 ou supérieure
- Module ActiveDirectory installé et accessible (`Import-Module ActiveDirectory`)
- Droits suffisants pour modifier les comptes dans Active Directory
- Fichier CSV encodé en UTF-8 avec séparateur `;`
- Le fichier CSV doit contenir une colonne `Username` correspondant au SamAccountName dans AD

---

## Licence

Ce script est distribué sous licence [MIT](https://opensource.org/licenses/MIT). Vous pouvez librement l’utiliser, modifier et redistribuer conformément aux termes de cette licence.