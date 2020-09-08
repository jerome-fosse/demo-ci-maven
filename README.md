# Demo CI Maven

Projet d'exemple d'une CI avec Gitlab et Maven

## Git
Le worflow Git utilisé s'inspire de gitflow tout en le simplifiant :

- La branche master recoit les différentes releases au fur et à mesure qu'elles sont créées. **Elle pointe toujours sur le commit de la dernière release.**
- La branche develop est la branche de travail sur laquelle on merge les différentes features.
- Les branches de features sont les branches sur lesquelles les développeurs travaillent et dévellopent les nouvelles features. Elles sont mergées sur develop lorsque la feature est terminée.

## CI/CD
La CI/CD est gérée par Gitlab. 5 stages sont définis :
- **build** : prend en charge toutes les taches de compilation du projet
- **test** : prend en charge l'execution des tests
- **publish** : publie les différents artifacts (jar et image docker)
- **deploy** : déploie les artifacts dans les différents environnements
- **release** : prend en charge la création d'une nouvelle release

ces 5 stages sont utilisés dans 2 workflows différents.

### Workflow CI
Ce workflow est executé sur toutes les branches **sauf la branche master**. Il gère donc les versions **SNAPSHOT** du projet.

stages :
- **build** :
    - job *build* : compile le projet (executé automatiquement sur toutes les branches sauf master)
- **test** :
    - job *test* : execute les tests unitaires (executé automatiquement sur toutes les branches sauf master)
- **publish** :
    - job *publish_artifactory* : déploie le jar dans artifactory (executé automatiquement sur la branche develop)
    - job build_docker : build l'image docker et la déploie dans la registry (executé manuellement sur toutes les branches sauf master)
- **deploy** :
    - job deploy_uat : déploie sur l'uat. (executé manuellement sur toutes les branches sauf release)
    - job deploy_preprod : déploie sur la preprod. (executé manuellement sur toutes les branches sauf release)
- **release** :
    - job release: créé une release du projet, tag la release au format X.Y.Z, merge la branche release aux branches master et develop, incrémente la version SNAPSHOT. (executé manuellement sur la branche develop)

### Workflow CD
Ce workflow est executé sur tous les tags au format X.Y.Z. Il gère donc les versions **RELEASE** du projet.

stages :
- **publish** :
    - job build_docker : build l'image docker et la déploie dans la registry (executé automatiquement sur les tags au format X.Y.Z)
- **deploy** :
    - job deploy_uat : déploie sur l'uat. (executé manuellement sur les tags au format X.Y.Z)
    - job deploy_preprod : déploie sur la preprod. (executé manuellement sur les tags au format X.Y.Z)
    - job deploy_prod : déploie sur la prod. (executé manuellement sur les tags au format X.Y.Z)

## Releases
Le job de release fonctionne de la manière suivante :
1. à partir de la branche dévelop, création d'une branche de release. Cette branche reste locale et n'est pas commitée sur le repository distant.
2. execution des goals release:prepare et release:perform en mode local. C'est à dire sans commiter.
3. merge de la branche release sur la branche develop
4. merge de la branche release (jusqu'à l'avant dernier commit) sur la branche master
5. suppression de la branche release
6. push des commits et des tags

### Remarques
- Par défaut, le numéro de version de la release est égal au numéro de version SNAPSHOT sans son suffixe. La version 1.0.0-SNAPSHOT aura comme numéro de release 1.0.0.
- Par défaut, la prochaine version SNAPSHOT est égale au numéro de release dont le numéro de version mineur a été incrémenté. Par exemple, la release 1.0.0 va être suivie par une version 1.1.0-SNAPSHOT
- Il est possible de spécifier le numéro de release et le numéro de snapshot au moyen de variables passées en paramètre au job release. La variable RELESE_VERSION force le numéro de release et la variable SNAPSHOT_VERSION force le numéro de snapshot. **ATTENTION** aucune vérification n'est faite sur le format de ces variables.
