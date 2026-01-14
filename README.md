# Gestion automatisée d’Active Directory avec PowerShell

Ce dépôt Github vise à simplifier et sécuriser la gestion d’Active Directory par l’automatisation. En suivant ces bonnes pratiques, vous gagnerez en efficacité et fiabilité dans vos opérations administratives.
Les informations nécessaires pour l'automatisation seront extraites d'un fichier CSV.
Les scripts ainsi que les explications associées sont regroupés par dossiers.

## Télécharger les scripts

Vous pouvez facilement télécharger tous les fichiers du projet sous forme d’archive ZIP :

1. Rendez-vous sur la page principale du dépôt GitHub, en l'occurence https://github.com/Stinky188/Powershell_epsic_122#.
2. Cliquez sur le bouton **Code** (en vert) situé en haut à droite.
3. Dans le menu déroulant, cliquez sur **Télécharger ZIP**.
4. Enregistrez le fichier ZIP sur votre ordinateur.
5. Une fois le téléchargement terminé, faites un clic droit sur le fichier ZIP et choisissez **Extraire tout…**.
6. Sélectionnez un dossier de destination (par exemple `C:\ScriptsAD`) où les fichiers seront décompressés.

Note : Si vous choisissez de l'enregistrer sous `C:\ScriptsAD`, il vous suffira de copier-coller les commandes décrites (dans la plupart des cas), ce qui simplifie énormément l'utilisation.

---

## Exécuter un script PowerShell

### Étape 1 : Ouvrir PowerShell avec les droits nécessaires

- Cliquez sur le menu Démarrer, tapez **PowerShell**.
- Faites un clic droit sur **Windows PowerShell** et choisissez **Exécuter en tant qu’administrateur**.
- Cette élévation est souvent nécessaire pour exécuter des scripts qui modifient Active Directory.

### Étape 2 : Autoriser l’exécution des scripts

Par défaut, Windows restreint l’exécution des scripts PowerShell. Pour permettre l’exécution temporaire de scripts, tapez la commande suivante :

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Cette commande autorise l’exécution des scripts uniquement pour la session PowerShell en cours, sans modifier la politique globale.

### Étape 3 : Se positionner dans le dossier du projet

Dans la fenêtre PowerShell, naviguez jusqu’au dossier contenant les scripts. Par exemple :

```powershell
cd C:\ScriptsAD\Powershell_epsic_122-main
```

### Étape 4 : Exécuter un script

Vous trouverez les informations sur le lancement de chaque script dans leurs dossiers respectifs.

## Structure du fichier CSV

Pour que les scripts fonctionnent correctement, le fichier CSV doit respecter la structure suivante au niveau de l’en-tête (header), avec les colonnes séparées par un point-virgule (`;`) :

```
FirstName;LastName;UserName;Password;Email;Department;JobTitle
```

### Détail des colonnes

- **FirstName** : Prénom de l’utilisateur
- **LastName** : Nom de famille de l’utilisateur
- **UserName** : Nom d’utilisateur (login)
- **Password** : Cette colonne doit rester vide, elle sera remplie automatiquement lors de l'éxecution des scripts.
- **Email** : Adresse e-mail professionnelle
- **Department** : Département auquel l’utilisateur appartient
- **JobTitle** : Intitulé du poste de l’utilisateur

### Exemple d’une ligne dans le CSV

```
Wendy;Thompson;wthompson;;wthompson@happykoalas.com;IT;Developer;;;
```
---

## Ressources complémentaires

- [Documentation officielle PowerShell](https://learn.microsoft.com/fr-fr/powershell/)
- [Gestion d’Active Directory avec PowerShell](https://learn.microsoft.com/fr-fr/powershell/module/activedirectory/?view=windowsserver2025-ps)

### Pour aller plus loin

- [Introduction à GIT](https://github.com/git-guides)

---

## Support et contribution

Pour toute question, problème ou suggestion, merci d’ouvrir une "issue" dans ce dépôt GitHub.  
Les contributions sont les bienvenues via des pull requests, merci de respecter les bonnes pratiques et la cohérence du projet.