Intégration continue
====================

L'intégration continue est une méthodologie qui veut fournir des mises à jour fonctionnels régulièrement. Y parvenir nécessite une rigueur de développement soutenue et une bonne compréhension de la méthodologie agile.

Le Process de Developpement
---------------------------

1) Lorsqu'une nouvelle fonctionnalité doit être ajouté, nous la codons sur la branche *dev*.
2) Lorsque la fonctionnalité est fini et que ses tests unitaires sont écrits, nous faisons une pull request sur la branche *master*.
3) Automatiquement travis détecte la pull request, lance tous les tests unitaires et fait un rapport.
4) Si le rapport confirme que tout est ok nous validons la pull request.

Le Process de Mise en Production
--------------------------------

### Diagramme

![diagramme de la mise à jour](maj.png)

### Script

Une cron chez l'utilisateur `www-data` (propriétaire du dossier `/var/www/`) lance le script suivant tous les quarts d'heures. En cas d'une erreur à une quelconque étape, un mail avec le rapport complet est envoyé à l'utilisateur `www-data` et une notification est envoyé sur le téléphone de Julien.

    #!/bin/bash

    air_exit=0

    cd /var/www/api
    git fetch 2>1 1>/dev/null
    if [ -n "$(git diff HEAD FETCH_HEAD)" ]
    then
            echo Update found for API
            systemctl stop air-api

            air_pkg_diff="$(git diff HEAD:package.json FETCH_HEAD:package.json)"

            git merge FETCH_HEAD
            if [ $? -ne 0 ]
            then
                    air_err="git merge"
                    air_exit=1
            else
                    if [ -n $air_pkg_diff ]
                    then
                            echo Installing new packages...
                            npm install
                            if [ $? -ne 0 ]
                            then
                                    air_err="npm update"
                                    air_exit=1
                                    git checkout HEAD~1 && npm update
                                    if [ $? -ne 0 ]
                                    then
                                            echo FATAL ERROR
                                            notify -t "air-update: API FATAL ERROR" 1>2 2>/dev/null
                                            exit 1
                                    fi
                            fi
                    fi
            fi

            systemctl start air-api
            if [ -z $air_err ]
            then
                    notify -t "air-update: API Update successful" 2>1 1>/dev/null
                    echo API Update successful
            else
                    notify -t "air-update: API Updated canceled because of $err error"
                    echo API Update canceled
            fi
    fi

    cd /var/www/pwa
    git fetch 2>1 1>/dev/null
    if [ -n "$(git diff HEAD FETCH_HEAD)" ]
    then
            air_err=""
            air_pkg_diff="$(git diff HEAD:package.json FETCH_HEAD:package.json)"

            git merge FETCH_HEAD
            if [ $? -ne 0 ]
            then
                    air_err="git merge"
            else
                    if [ -n $air_pkg_diff ]
                    then
                            echo Installing new packages...
                            npm install
                            if [ $? -ne 0 ]
                            then
                                    air_exit=1
                                    air_err="npm update"
                            fi
                    fi
                    if [ -z $air_err ]
                    then
                            npm run build
                            if [ $? -ne 0 ]
                            then
                                    air_exit=1
                                    air_err="npm run build"
                                    git checkout HEAD~1 && npm run build
                                    if [ $? -ne 0 ]
                                    then
                                            echo PWA FATAL ERROR
                                            notity -t "air-update: PWA FATAL ERROR" 1>2 2>/dev/null
                                            exit 1
                                    fi
                            fi
                    fi
            fi

            if [ -z $air_err ]
            then
                    notify -t "air-update: PWA Update successful" 2>1 1>/dev/null
                    echo PWA Update successful
            else
                    notify -t "air-update: PWA Updated canceled because of $err error" 2>1 1>/dev/null
                    echo PWA Update canceled
                    exit 1
            fi
    fi

    exit $air_exit

