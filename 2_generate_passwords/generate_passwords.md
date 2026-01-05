# README

## Description

Ce script PowerShell génère des mots de passe aléatoires sécurisés pour chaque utilisateur listé dans un fichier CSV. Il ajoute ces mots de passe en tant que nouvelle colonne dans le fichier CSV, facilitant ainsi la gestion et la distribution des identifiants temporaires ou initiaux. Le script garantit que chaque mot de passe contient au minimum une majuscule, une minuscule, un chiffre et un symbole, renforçant ainsi la sécurité.

---

## Comment l’utiliser

### Entrées nécessaires

- Un fichier CSV avec au minimum une colonne contenant les utilisateurs (le script s’appuie sur la structure du CSV, notamment la colonne `Email` ou autres données utilisateurs).
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

### Exemple 1 : Générer des mots de passe pour les utilisateurs dans `users.csv`

```powershell
powershell
```

```powershell
.\GeneratePasswords.ps1 -csvFilePath "C:\Users\admin\users.csv"
```

### Exemple 2 : Utilisation avec un chemin relatif

```powershell
powershell
```

```powershell
.\GeneratePasswords.ps1 -csvFilePath ".\data\utilisateurs.csv"
```

---

## État d’avancement

- [x] Validation du fichier CSV en entrée
- [x] Import des données utilisateurs depuis le CSV
- [x] Génération de mots de passe aléatoires incluant plusieurs types de caractères
- [x] Ajout des mots de passe dans la structure de données
- [x] Export du fichier CSV mis à jour sans guillemets inutiles
- [ ] Ajout de la gestion des erreurs (fichier introuvable, format incorrect)
- [ ] Paramétrage de la longueur et des types de caractères des mots de passe
- [ ] Ajout de logs détaillés pour le suivi des opérations

---

## Dépendances / prérequis

- PowerShell version 5.1 ou supérieure
- Le script doit être exécuté avec des droits suffisants pour lire et écrire le fichier CSV
- Le fichier CSV doit utiliser le point-virgule (`;`) comme séparateur

---

## Licence

Ce script est distribué sous licence [MIT](https://opensource.org/licenses/MIT). Vous pouvez librement l’utiliser, le modifier et le redistribuer conformément aux termes de cette licence.