Sécurité
========

VPS
---

### iptables

`iptables` est le parfeu fourni par défaut sur linux, il permet de spécifier les règles pour le sous-système `netfilter` qui est inclus au kernel Linux. Nous l'avons configuré avec la philosophie suivante:

1) Interdire tout ce qui n'est pas autorisé
2) N'autoriser que le strict nécessaire

Cette protection est *passive*.

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

### PAM

La création des utilisateurs a été fait avec la politique suivante:

1) Chaque membre du groupe a reçu un compte à son nom.
2) Chaque utilisateur a été créé avec un mot de passe aléatoire (mot de passe communiqué uniquement avec l'intéressé).
3) Le compte a été configuré avec un `age` fixé à `0`. Ceci oblige l'utilisateur a changer son mot de passe lors de la prochaine connexion.
4) Seuls les utilisateurs qui ont enregistré leur clé publique auront les accès admin.

Script:

    # useradd -m -s /bin/bash <user>
    # passwd <user>
    Password: <aléatoire sur 8 lettres>
    Retype password: <le même mot de passe>
    # chage -d 0 <user>

### sshd

* Le démon ssh a été configuré pour ne pas autoriser la connexion sur le compte root
* Les membres du groupe `sudo` ne peuvent accéder à leur compte qu'au moyen de leur clé privée

`/etc/ssh/sshd_config` (only diff)

    PermitRootLogin no
    PubkeyAuthentication yes
    Match group sudo
	    PasswordAuthentication no