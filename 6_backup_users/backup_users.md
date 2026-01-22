# README

## Description

Ce script PowerShell permet d’exporter les informations des utilisateurs Active Directory présents dans les unités d’organisation (OU) listées dans un fichier CSV. Il crée un nouveau fichier CSV contenant les données des utilisateurs avec les informations de domaine, puis compresse ce fichier dans une archive ZIP.

Ce script est destiné à des utilisateurs avec des connaissances de base dans l'utilisation de scripts et de Windows Server.

---

## Comment l’utiliser

### Entrées nécessaires

- Un fichier CSV contenant les données utilisateurs, avec au minimum les colonnes suivantes: FirstName;LastName;UserName;Password;Email;Department;JobTitle;dn;tld
- Le fichier CSV doit être au format texte, encodé en UTF-8, avec un séparateur `;`.

### Ce que le script produit

- Un fichier CSV exporté dans le dossier `C:\backups\`, nommé avec la date du jour (exemple : `2026-01-05_users.csv`).
- Une archive ZIP contenant ce fichier CSV.
- Affichage dans la console de la confirmation de la sauvegarde.

---

## Description détaillée des paramètres

|Paramètre|Description|Valeurs acceptables|Obligatoire|
|---|---|---|---|
|`-csvFilePath`|Chemin complet vers le fichier CSV contenant les informations de domaine et départements.|Chemin valide vers un fichier `.csv`|Oui|

---

## Exemples d’utilisation

```powershell
6_backup_users/backup_users.ps1 -csvFilePath "happy_koalas_employees.csv"
```

---

## Planification de la sauvegarde quotidienne à 23:00 avec le Planificateur de tâches Windows

### Installation

1. Appuyez sur la touche Windows (ou cliquez sur l’icône Windows en bas à gauche) et cherchez **Planification de tâches** (ou **Task Scheduler**). Lancez l’application.
    
2. Dans le volet droit, cliquez sur **Créer une tâche** (ou **Create Task**).
    
3. Donnez un nom à la tâche, par exemple "Sauvegarde AD Utilisateurs".
    
4. Dans l’onglet **Déclencheurs** (ou **Triggers**), cliquez sur **Nouveau…**, puis :
    
    - Choisissez **Quotidien** (ou **Daily**).
    - Réglez l’heure sur **23:00:00**.
    - Cliquez sur **OK**.
5. Dans l’onglet **Actions**, cliquez sur **Nouveau…** puis :
    
    - Pour **Programme/script**, entrez `powershell.exe`.
    - Dans **Ajouter des arguments (facultatif)**, entrez la commande suivante en adaptant le chemin du script et du CSV :
    

6. ```
    -ExecutionPolicy Bypass -Command "& 'C:\ScriptsAD\Powershell_epsic_122-main\6_backup_users\backup_users.ps1' -csvFilePath 'C:\ScriptsAD\Powershell_epsic_122-main\happy_koalas_employees.csv'"
    ```
    
    - Veillez à conserver les guillemets simples autour des chemins.
    - Si vous devez modifier l'emplacement des scripts ou du csv, il est recommandé de modifier la commande dans un éditeur de texte externe puis de le recopier dans le planificateur de tâches.
7. Cliquez sur **OK** pour valider l’action.
    
8. Vérifiez les autres paramètres de la tâche (exécution avec les droits administrateurs si nécessaire).
    
9. Cliquez sur **OK** pour créer la tâche.
    

### Utilisation de la tâche

1. Dans la **Bibliothèque du Planificateur de tâches** (ou **Task Scheduler Library**), trouvez la tâche créée.
2. Si elle n’apparaît pas, cliquez sur le bouton **Rafraîchir**.
3. Sélectionnez la tâche et cliquez sur **Propriétés** pour modifier si besoin.
4. Pour modifier la commande, copiez-collez la ligne PowerShell dans un éditeur de texte, ajustez les chemins, puis remplacez-la dans l’onglet **Actions**.
5. Pour lancer manuellement la sauvegarde, sélectionnez la tâche puis cliquez sur **Exécuter** dans le volet droit.
6. En cas d’erreur, vérifiez :
    - La politique d’exécution PowerShell (`ExecutionPolicy`) : la commande ci-dessus contourne cette limite pour ce script uniquement.
    - L’exactitude des chemins et des noms de fichiers.
    - Les permissions nécessaires pour exécuter le script et accéder aux fichiers.

---

## Dépendances / prérequis

- PowerShell (présent de base sur Windows Server)
- Module ActiveDirectory installé depuis le script (`Import-Module ActiveDirectory`)
- Droits administratifs sur l’Active Directory
- Fichier CSV encodé en UTF-8 avec séparateur `;`
- Planificateur de tâches Windows

---

## Licence

Ce script est distribué sous licence [MIT](https://opensource.org/licenses/MIT). Vous pouvez librement l’utiliser, modifier et redistribuer conformément aux termes de cette licence.