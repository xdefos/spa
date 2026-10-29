# Donnees de configuration versionnees

Enregistrements qui sont de la configuration mais pas de la metadonnee Salesforce
(le retrieve classique ne les recupere pas). Source de verite : l'org `SPA Prod`.

```
data/
  datasets.json                 registre : objet, champ cle, champs exclus, vue HTML
  records/<Objet>/<Cle>.json    un fichier par enregistrement (sans Id, valeurs nulles omises)
  records/<Objet>/<Cle>.html    vue lisible du corps (S-Docs uniquement), generee a l'export
scripts/data/sfdata.py          export / import (stdlib Python + sf CLI)
```

| Objet | Contenu | Cle |
|---|---|---|
| `ParametreGoogleMap__c` | Couches de la carte Google Maps | `Name` |
| `SDOC__SDTemplate__c` | Templates S-Docs (RapportEnquete, RapportVisitePostAdoption) | `Name` |

## Utilisation

```bash
# Mettre le depot a jour depuis la prod (puis git diff / commit)
python3 -I scripts/data/sfdata.py export --org "SPA Prod"

# Voir ce qui changerait dans une org (simulation, n'ecrit rien)
python3 -I scripts/data/sfdata.py import --org "SPA DEV2"

# Appliquer (cree ou met a jour par la cle, ne supprime jamais)
python3 -I scripts/data/sfdata.py import --org "SPA DEV2" --apply
```

`--org` est obligatoire : il n'y a volontairement pas d'org par defaut (le projet pointe sur la prod).
`--dataset <Objet>` limite a un seul objet. L'export supprime du depot les fichiers dont
l'enregistrement n'existe plus dans l'org.

## Ajouter un jeu de donnees

1. Ajouter l'objet dans `datasets.json` (`key` = champ unique et stable, `exclude` = champs a ne pas versionner).
2. `export`, relire le diff, verifier qu'aucun secret n'est present (cles API, tokens).
3. Commit.

## Limites

- Les champs lookup (`reference`), formules et chiffres sont ignores : un jeu de donnees avec
  relations (ex. `SDOC__Master_Template__c`) demande une evolution du script.
- L'import ne cree pas d'objets ni de champs : le deploiement de la metadonnee doit passer d'abord.
- Le champ `Id` n'est jamais versionne ; la correspondance se fait par la cle.
