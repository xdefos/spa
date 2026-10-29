# SPA — Maison SPA de Bordeaux (org de production)

Métadonnées Salesforce de l'org **SPA Prod** (`xdefossez@spa.com`), versionnées avec Salesforce DX.
L'application « Maison SPA de Bordeaux » gère le suivi des **signalements**, des **enquêtes**, des
**délégués enquêteurs**, des **cessions d'animaux** et des **visites post-adoption**.

> `main` reflète la production. Le projet pointe par défaut sur la prod (`.sf/config.json`) :
> **toujours passer `-o "SPA DEV2"` (ou un autre alias) pour déployer ou tester.**

## Contenu du dépôt

```
force-app/main/default/   métadonnées déployables (objets, Apex, LWC/Aura, flows, profils, rapports...)
manifest/package.xml      liste des composants récupérés de la prod
data/                     enregistrements de configuration versionnés (Google Maps, templates S-Docs)
scripts/data/sfdata.py    export / import de ces enregistrements
scripts/apex, soql        scripts d'investigation (Tinify, callouts, requêtes)
```

### Modèle de données

| Objet | Rôle |
|---|---|
| `Signalement__c` | Signalement reçu |
| `Enquete__c` | Enquête ouverte à partir d'un signalement |
| `DelegueEnqueteur__c` | Délégué enquêteur (référent / binôme) |
| `Animal__c` | Animal cédé |
| `VisitePostAdoption__c` | Visite de suivi après adoption |
| `ContactLocal__c`, `Acteur__c` | Contacts et acteurs locaux |
| `Commentaire__c`, `Rappel__c` | Commentaires et rappels liés aux enquêtes |
| `ParametreGoogleMap__c` | Configuration des couches de la carte |
| `FilePostProcessSetting__mdt` | Paramètres du traitement des fichiers (custom metadata) |

### Code Apex (convention de nommage)

| Préfixe | Usage |
|---|---|
| `TRG0x_*Handler` | Handlers des triggers `TRG01` à `TRG07` (un par objet) |
| `CMP0x_*` | Contrôleurs des composants Aura/LWC (carte, éligibilité DE, envoi d'email) |
| `VFP01_*` | Contrôleur de la page Visualforce de la carte |
| `WRP0x_*` | Appels externes : Google Geocode, Distance Matrix, Tinify |
| `QUE0x_*` | Traitements asynchrones des fichiers (`FilePostProcess`) |
| `UTI0x_*` | Utilitaires et mocks de tests |
| `dlrs_*` | Triggers/tests générés par Declarative Lookup Rollup Summaries |

Automatisations : 15 flows actifs (préfixes `ENQ_`, `SIG_`, `VPA_`, `COM_`, plus `EnvoiRappels`,
`DatePriseEnCharge`, `VPA_clore`, `Relance_Enquete_inactive`).

### Intégrations externes

- **Google Maps** (géocodage, distances, carte) : remote site, CSP et CORS déclarés.
- **Tinify** (compression d'images, `TRG07_ContentVersionHandler`) : remote site `Tinify`.
- **S-Docs** (génération des rapports PDF d'enquête et de visite post-adoption).

## Démarrage

Prérequis : [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli), Node.js, Python 3.

```bash
git clone https://github.com/xdefos/spa.git && cd spa
npm install
sf org login web --alias "SPA DEV2" --instance-url https://test.salesforce.com   # sandbox
```

### Déployer et tester

```bash
sf project deploy start -o "SPA DEV2" --dry-run     # validation sans déploiement
sf project deploy start -o "SPA DEV2"
sf apex run test -o "SPA DEV2" --test-level RunLocalTests --wait 20
npm test                                            # tests Jest des LWC
npm run lint
```

### Mettre le dépôt à jour depuis la prod

```bash
sf project retrieve start -x manifest/package.xml -o "SPA Prod"
python3 -I scripts/data/sfdata.py export --org "SPA Prod"
git diff        # relire avant de committer
```

Les enregistrements de `data/` (couches Google Maps, templates S-Docs) ne sont pas de la métadonnée :
voir [`data/README.md`](data/README.md) pour l'export et l'import (simulation par défaut, `--apply` pour écrire).

## Ce qui n'est volontairement pas dans le dépôt

- **Clés API** : les custom labels `GoogleAPIKey` et `TinifyAPIKey` contiennent des clés en clair.
  `CustomLabels` est dans `.forceignore` ; ne jamais le versionner. À renseigner à la main dans chaque org.
- **NPSP** et ses restes (pages, app, permission sets, rapports) : non utilisé à la SPA.
- **Objets standard inutilisés** (Opportunity, Campaign, Lead, Case...), rapports d'exemple Salesforce,
  flows inactifs, traductions auto-générées.
- **Données** (enregistrements métier), hors le contenu de `data/`.

## Points d'attention

- `sourceApiVersion` est à 50.0 alors que la prod est en 68.0.
- Un déploiement vers la prod écrase la configuration en place : valider d'abord sur `SPA DEV2`.
- Éléments listés par la prod mais non récupérés : `NetworkBranding`, `Settings:Email`, la page
  `SDoc_Template_Page` et l'app externe `SEAP`.
