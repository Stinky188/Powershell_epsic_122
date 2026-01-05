# README

## Description

Ce script PowerShell automatise la gestion des comptes Active Directory expirés en les déplaçant dans une unité d’organisation (OU) dédiée nommée "Retired". Il importe les informations de domaine depuis un fichier CSV, crée l’OU si elle n’existe pas, puis centralise tous les comptes expirés non désactivés dans cette OU pour faciliter leur suivi et gestion.

---

## Comment l’utiliser

### Entrées nécessaires

- Un fichier CSV contenant au minimum les colonnes `dn` et `tld` permettant de construire le chemin LDAP de l’OU cible.
- Le fichier CSV doit être au format texte, encodé en UTF-8, avec un séparateur `;`.

### Ce que le script produit

- Vérifie et crée si nécessaire une OU nommée "Retired" sous l’OU parent définie dans le domaine.
- Déplace tous les comptes Active Directory expirés (mais toujours activés) dans cette OU.
- Affiche dans la console la progression avec les noms des comptes déplacés.

---

## Description détaillée des paramètres

|Paramètre|Description|Valeurs acceptables|Obligatoire|
|---|---|---|---|
|`-csvFilePath`|Chemin complet vers le fichier CSV contenant les informations de domaine.|Chemin valide vers un fichier `.csv`|Oui|

---

## Exemples d’utilisation

### Exemple : déplacer les comptes expirés vers l’OU "Retired"

```powershell
powershell
```

```powershell
.\MoveExpiredUsers.ps1 -csvFilePath "C:\Users\Admin\domain_info.csv"
```

---

## État d’avancement

- [x] Validation du fichier CSV en entrée
- [x] Chargement du module Active Directory
- [x] Vérification et création conditionnelle de l’OU "Retired"
- [x] Recherche des comptes expirés non désactivés
- [x] Déplacement des comptes dans l’OU dédiée
- [ ] Gestion avancée des erreurs (droits insuffisants, comptes introuvables)
- [ ] Paramétrage dynamique des noms d’OU et chemins LDAP

---

## Dépendances / prérequis

- PowerShell version 5.1 ou supérieure
- Module ActiveDirectory installé et accessible (`Import-Module ActiveDirectory`)
- Droits administratifs suffisants pour créer des OU et déplacer des comptes dans Active Directory
- Fichier CSV encodé en UTF-8 avec séparateur `;`
- Le fichier CSV doit contenir les colonnes `dn` et `tld` correspondant à la structure du domaine AD

---

## Licence

Ce script est distribué sous licence [MIT](https://opensource.org/licenses/MIT). Vous pouvez librement l’utiliser, modifier et redistribuer conformément aux termes de cette licence.