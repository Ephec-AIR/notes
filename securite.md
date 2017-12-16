Sécurité du VPS
===============

Les sécurités suivantes ont été mises en place pour assurer l'accès au VPS et à ses ressources uniquement aux personnes abilités.

Sécurité passive : iptables
---------------------------

`iptables` est le par-feu fourni par défaut sur linux, il permet de spécifier les règles pour le sous-système `netfilter` qui est inclus au kernel Linux. Nous l'avons configuré avec la philosophie suivante:

1) Interdire tout ce qui n'est pas autorisé
2) N'autoriser que le strict nécessaire

[`-> /etc/iptables/iptables.rules`](etc/iptables/iptables.rules)

Sécurité active : fail2ban
--------------------------

`fail2ban` est un utilitaire qui détecte des comportements étranges en lisant les fichiers logs de différents services à la volée. Nous avons activé les détections pour les services `ssh` (brute force, dos) et `nginx` (brute force, dos, bot search). Comme nginx est en amont de notre application, chaque erreur http renvoyé par notre application se retrouve dans les logs de nginx et donc est filtré par fail2abn. Notre application web est ainsi protégée de la même manière que nginx.

Lorsqu'un comportement étrange est détecté, la politique est de bannir l'ip du pirate pour 1 jour et d'envoyer une notification sur le téléphone de Julien.

[`/etc/fail2ban/filter.d/nginx-401-403.conf`](etc/fail2ban/filter.d/nginx-401-403.conf)

[`/etc/fail2ban/jail.local`](etc/fail2ban/jail.local)

[`/etc/fail2ban/jail.d/defaults-debian.conf`](etc/fail2ban/jail.d/defaults-debian.conf)

[`/etc/fail2ban/jail.d/nginx-401-403.conf`](etc/fail2ban/jail.d/nginx-401-403.conf)

[`/etc/fail2ban/action.d/notify.conf`](etc/fail2ban/action.d/notify.conf)

Sécurité Linux : Best Pratices
------------------------------

### Création des utilisateurs

La création des utilisateurs a été fait avec la politique suivante:

1) Chaque membre du groupe a reçu un compte à son nom.
2) Chaque utilisateur a été créé avec un mot de passe aléatoire communiqué uniquement à l'intéressé.
3) Le compte a été configuré avec un `age` fixé à `0`. Ceci oblige l'utilisateur a changer son mot de passe lors de la prochaine connexion.
4) Seuls les utilisateurs qui ont enregistré leur clé publique auront les accès admin.

### sshd

* Le démon ssh a été configuré pour ne pas autoriser la connexion sur le compte root
* Les membres du groupe `sudo` ne peuvent accéder à leur compte qu'au moyen de leur clé privée

[`/etc/ssh/sshd_config`](etc/ssh/sshd_config)

Sécurité des utilisateurs
=========================

Les sécurités suivantes ont été mise en place pour garantir la bonne utilisation de nos services par nos utilisateurs.

Mises à jour sécurisées
-----------------------

Les mises à jour sont effectuées automatiquement (voir [`Intégration continue##Le Process de Mise en Production`](integration_continue.md)). C'est souvent une faille logiciel importante qui permet à un attaquant de détourner le système de mise à jour pour forcer l'installation de binaires pirates. Dans un système sécurisé, il faut signer chaque binaire avec le certificat de l'entreprise avant de rendre ce binaire téléchargeable via le processus de mise à jour, processus qui doit vérifier l'authenticité de chaque binaire téléchargé avant de l'installer.

Du fait que vous utilisons directement git dans le processus de mise à jour, chaque est implicitement sécurisé. Du fait que git travaille en https ou en ssh (tout deux des protocoles sécurisés), les fichiers téléchargés sont certains de provenir de github et de nul le part ailleurs.

Reste donc la question de qui est autoriser à modifier les fichiers sur github. La réponse est simple, il faut appartenir à l'organisation [Ephec-AIR](https://github.com/Ephec-AIR), où sont uniquement enregistrés les 6 membres de notre groupes. Une exception notable a été celle de Christophe Van Waesberghe qui a eu accès en écriture au dépôt [Ephec-AIR/ocr](https://github.com/Ephec-AIR/ocr) le temps de réaliser le projet du cours de Traitement du Signal.

Ces septs personnes sont toutes soumises au [rêglement des études de l'EPHEC](http://www.ephec.be/uploads/PLEIN%20EXERCICE/G%C3%A9n%C3%A9ral%202017-2018/Reglement_general_etudes_examens_2017-18.pdf).

Bibliographie
-------------

* AGÉ, M., CROCFER, R., CROCFER, N., DUMAS, D., EBEL, F., FORTUNATO, G., HENNECART, J., LASSON, S., SCHALKWIJK, L. & RAULT, R. (2015). *Sécurité informatique Ethical Hacking Apprendre l'attaque pour mieux se défendre* (4e édition). St Herblain: ENI
* SCHALKWIJK, L., (2017). *Sécurité des réseaux théorie*. Syllabus, EPHEC.
* Van Den Schrieck, V. (2017). *Administration Système et Réseaux II (Théorie)*. Syllabus, EPHEC.
* Kadlecsik, J., McHardy, P., Neira Ayuso, P., Leblond, E. & Westphal, F. (2015). *iptables(8)*. Linux Man Pages.
* fail2ban (2015), *Fail2ban*, En ligne <https://www.fail2ban.org/wiki/index.php/Main_Page> consulté d'octobre à novembre 2017.