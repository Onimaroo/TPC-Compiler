# TPC-Compiler
Un compilateur de TPC (Très Petit C) fait en C en complément de Flex et Yacc/Bison. Projet scolaire fait avec un binôme.

## Comment l'éxécuter?
Il faut se placer à la racine des fichiers sources du projet (le dossier src) et simplement lancer l'éxécutable `Script.sh` pour lancer les jeux de tests dans le dossier `test`. Le lancement se fait de la façon suivante: 

`./Script.sh`

Si vous cherchez à l'éxécuter manuellement avec un fichier TPC que vous avez, il faut d'abord lancer la commande `make` dans le terminal pour build le projet, puis lancer ceci:

`../bin/tpcc [OPTIONS] NomDeVotreFichier.tpc`

## Liste des options
`-t` = Affiche l’arbre abstrait sur la sortie standard.

`-s` = Affiche toutes les tables des symboles sur la sortie standard.

`-h` = Affiche une description de l’interface utilisateur et termine l’exécution.

## Informations supplémentaires

Lire la documentation (le dossier `doc`) pour plus d'informations sur le déroulement de ce projet.



