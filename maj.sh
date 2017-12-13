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