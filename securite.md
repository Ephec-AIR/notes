Sécurité du VPS
===============

Sécurité passive : iptables
---------------------------

`iptables` est le parfeu fourni par défaut sur linux, il permet de spécifier les règles pour le sous-système `netfilter` qui est inclus au kernel Linux. Nous l'avons configuré avec la philosophie suivante:

1) Interdire tout ce qui n'est pas autorisé
2) N'autoriser que le strict nécessaire

[`-> /etc/iptables/iptables.rules`](etc/iptables/iptables.rules)

Sécurité active : fail2ban
--------------------------

`fail2ban` est un utilitaire qui détecte des comportements étranges en lisant les fichiers logs de différents services à la volé. Nous avons activé les détections pour les services `ssh` (brute force, dos) et `nginx` (brute force, dos, bot search), vu que nginx est un middleware à notre application, elle est protégée de la même manière.

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

Bibliographie
-------------

* AGÉ, M., CROCFER, R., CROCFER, N., DUMAS, D., EBEL, F., FORTUNATO, G., HENNECART, J., LASSON, S., SCHALKWIJK, L. & RAULT, R. (2015). *Sécurité informatique Ethical Hacking Apprendre l'attaque pour mieux se défendre* (4e édition). St Herblain: ENI
* SCHALKWIJK, L., (2017). *Sécurité des réseaux théorie*. Syllabus, EPHEC.
* Van Den Schrieck, V. (2017). *Administration Système et Réseaux II (Théorie)*. Syllabus, EPHEC.
* Kadlecsik, J., McHardy, P., Neira Ayuso, P., Leblond, E. & Westphal, F. (2015). *iptables(8)*. Linux Man Pages.
* fail2ban (2015), *Fail2ban*, En ligne <https://www.fail2ban.org/wiki/index.php/Main_Page> consulté d'octobre à novembre 2017.