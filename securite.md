Sécurité du VPS
===============

Sécurité passive : iptables
---------------------------

`iptables` est le parfeu fourni par défaut sur linux, il permet de spécifier les règles pour le sous-système `netfilter` qui est inclus au kernel Linux. Nous l'avons configuré avec la philosophie suivante:

1) Interdire tout ce qui n'est pas autorisé
2) N'autoriser que le strict nécessaire

`/etc/iptables/iptables.rules`

    *filter

    # Default policy to drop (if none rule match, use the policy)
    :INPUT DROP [2:80]
    :FORWARD DROP [0:0]
    :OUTPUT DROP [0:0]

    # authorize everything on the loopback
    -A INPUT -i lo -j ACCEPT
    -A OUTPUT -o lo -j ACCEPT

    # authorize icmp
    -A INPUT -p icmp -j ACCEPT
    -A OUTPUT -p icmp -j ACCEPT

    # authorize http/https as server (nginx)
    -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
    -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
    -A OUTPUT -p tcp -m tcp --sport 80 -j ACCEPT
    -A OUTPUT -p tcp -m tcp --sport 443 -j ACCEPT

    # authorise http/https as client (apt)
    -A INPUT -p tcp -m tcp --sport 80 -j ACCEPT
    -A INPUT -p tcp -m tcp --sport 443 -j ACCEPT
    -A OUTPUT -p tcp -m tcp --dport 80 -j ACCEPT
    -A OUTPUT -p tcp -m tcp --dport 443 -j ACCEPT

    # authorize ssh as server (sshd)
    -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
    -A OUTPUT -p tcp -m tcp --sport 22 -j ACCEPT

    # authorize ssh as client (ssh)
    -A INPUT -p tcp -m tcp --sport 22 -j ACCEPT
    -A OUTPUT -p tcp -m tcp --dport 22 -j ACCEPT

    # authorize dns as client (*)
    -A INPUT -p udp -m udp --sport 53 -j ACCEPT
    -A INPUT -p tcp -m tcp --sport 53 -j ACCEPT
    -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
    -A OUTPUT -p tcp -m tcp --dport 53 -j ACCEPT

    COMMIT

Sécurité active : fail2ban
--------------------------

`fail2ban` est un utilitaire qui détecte des comportements étranges en lisant les fichiers logs de différents services à la volé. Nous avons activé les détections pour les services `ssh` (brute force, dos) et `nginx` (brute force, dos, bot search), vu que nginx est un middleware à notre application, elle est protégée de la même manière.

Lorsqu'un comportement étrange est détecté, la politique est de bannir l'ip du pirate pour 1 jour et d'envoyer une notification sur le téléphone de Julien.

`/etc/fail2ban/action.d/notify.conf`

    [INCLUDES]

    [Definition]
    actionban = sudo -u julien notify -t "fail2ban (<name>): <ip> has been banned from $(hostname) on port <port> for <bantime>s"

    [Init]

`/etc/fail2ban/jail.local`

    [DEFAULT]

    bantime  = 86400
    findtime  = 300
    maxretry = 10

    notifyaction = notify
    action_n = %(banaction)s[name=%(__name__)s, bantime="%(bantime)s", port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
            %(notifyaction)s[name=%(__name__)s, bantime="%(bantime)s", port="%(port)s"]

    action = %(action_n)s

`/etc/fail2ban/jail.d/defaults-debian.conf`

    [sshd]
    enabled = true

    [sshd-ddos]
    enabled = true

    [nginx-botsearch]
    enabled = true

    [nginx-limit-req]
    enabled = true

    [nginx-http-auth]
    enabled = true

    [nginx-401-403]
    enabled = true

`/etc/fail2ban/jail.d/nginx-401-403.conf`
    [nginx-401-403]

    port = http,https
    filter = nginx-401-403
    logpath = /var/log/nginx/access.log

`/etc/fail2ban/filter.d/nginx-401-403.conf`

    [Definition]
    failregex = ^<HOST> -.*"(HEAD|GET|POST|PUT|DELETE).*HTTP.*" 40(1|3)
    ignoreregex =

Sécurité Linux : Best Pratices
------------------------------

### User Creation

La création des utilisateurs a été fait avec la politique suivante:

1) Chaque membre du groupe a reçu un compte à son nom.
2) Chaque utilisateur a été créé avec un mot de passe aléatoire communiqué uniquement à l'intéressé.
3) Le compte a été configuré avec un `age` fixé à `0`. Ceci oblige l'utilisateur a changer son mot de passe lors de la prochaine connexion.
4) Seuls les utilisateurs qui ont enregistré leur clé publique auront les accès admin.

### sshd

* Le démon ssh a été configuré pour ne pas autoriser la connexion sur le compte root
* Les membres du groupe `sudo` ne peuvent accéder à leur compte qu'au moyen de leur clé privée

`/etc/ssh/sshd_config`

    PermitRootLogin no
    Match group sudo
        PasswordAuthentication no

Bibliographie
-------------

* AGÉ, M., CROCFER, R., CROCFER, N., DUMAS, D., EBEL, F., FORTUNATO, G., HENNECART, J., LASSON, S., SCHALKWIJK, L. & RAULT, R. (2015). *Sécurité informatique Ethical Hacking Apprendre l'attaque pour mieux se défendre* (4e édition). St Herblain: ENI
* SCHALKWIJK, L., (2017). *Sécurité des réseaux théorie*. Syllabus, EPHEC.
* Van Den Schrieck, V. (2017). *Administration Système et Réseaux II (Théorie)*. Syllabus, EPHEC.
* Kadlecsik, J., McHardy, P., Neira Ayuso, P., Leblond, E. & Westphal, F. (2015). *iptables(8)*. Linux Man Pages.
* fail2ban (2015), *Fail2ban*, En ligne <https://www.fail2ban.org/wiki/index.php/Main_Page> consulté d'octobre à novembre 2017.