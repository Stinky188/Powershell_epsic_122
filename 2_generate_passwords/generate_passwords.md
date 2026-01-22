# README

## Description

Ce script PowerShell génère des mots de passe aléatoires sécurisés pour chaque utilisateur listé dans un fichier CSV. Il ajoute ces mots de passe en tant que nouvelle colonne dans le fichier CSV. Le script garantit que chaque mot de passe contient au minimum une majuscule, une minuscule, un chiffre et un symbole.

Ce script est destiné à des utilisateurs avec des connaissances de base dans l'utilisation de scripts et de l'Active Directory.

---

## Comment l’utiliser

### Entrées nécessaires

- Un fichier CSV contenant les données utilisateurs, avec au minimum les colonnes suivantes: FirstName;LastName;UserName;Password;Email;Department;JobTitle
- Le fichier CSV doit être au format texte, encodé en UTF-8, avec un séparateur `;`.

### Ce que le script produit

- Le fichier CSV original est mis à jour en ajoutant une colonne `Password` contenant un mot de passe généré aléatoirement pour chaque utilisateur.
- Les mots de passe générés respectent des critères de complexité (majuscules, minuscules, chiffres, symboles).

---

## Description détaillée des paramètres

|Paramètre|Description|Valeurs acceptables|Obligatoire|
|---|---|---|---|
|`-csvFilePath`|Chemin complet vers le fichier CSV à traiter. Le fichier doit être au format `.csv`.|Chemin valide vers un fichier `.csv`|Oui|

---

## Exemples d’utilisation

```powershell
2_generate_passwords/generate_passwords.ps1 -csvFilePath "happy_koalas_employees.csv"
```

## Dépendances / prérequis

- PowerShell (présent de base sur Windows Server)
- Module ActiveDirectory installé depuis le script (`Import-Module ActiveDirectory`)
- Droits administratifs sur l’Active Directory
- Fichier CSV encodé en UTF-8 avec séparateur `;`

---

## Licence

Ce script est distribué sous licence [MIT](https://opensource.org/licenses/MIT). Vous pouvez librement l’utiliser, le modifier et le redistribuer conformément aux termes de cette licence.