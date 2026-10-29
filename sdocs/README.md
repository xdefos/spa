# S-Docs templates

Les templates S-Docs ne sont pas de la métadonnée Salesforce : ce sont des enregistrements
`SDOC__SDTemplate__c` du package S-Docs. Ils sont exportés ici depuis l'org `SPA Prod`.

- `templates/<Nom>.json` : tous les champs du template (source de vérité, valeurs vides omises).
- `templates/<Nom>.html` : le corps (`SDOC__Template_XML__c` à `XML10__c` concaténés), pour des diffs lisibles.

Exclus de l'export : `OwnerId`, `SDOC__Preview_ID__c`, `SDOC__SD_K__c` (chiffré) et les champs formule.

## Ré-export

    sf data query -o "SPA Prod" --json -q "SELECT Id, <champs> FROM SDOC__SDTemplate__c"

Les 2 templates actuels : `RapportEnquete` (Enquete__c) et `RapportVisitePostAdoption` (VisitePostAdoption__c).
