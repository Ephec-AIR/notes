NodeJS
------
NodeJS permet de réaliser d'écrire du javascript côté serveur. 
Nous l'avons utilisé pour réaliser le backend et plus précisément l'API de notre application.
Un des avantages de celui-ci est qu'il le même langage que le client ce qui nous permet par exemple d'utilisé des librairies identiques autant côté serveur que client.

Base de donnée
--------------
MongoDB est un système de gestion de base de donnée orienté documents.
Chaque nouvelle donnée que l'on rentre dans un modèle (équivalent à une table en SQL) n'est pas une nouvelle ligne 
comme en SQL mais un nouveau document. 
On peut comparer ce document à un objet javascript.
Il fait partie de la famille des bases de données NoSQL (Redis,...)
L'avantage de MongoDB est qu'il est parfaitement intégré à NodeJS via la librairie `mongoose` contrairement
à la plupart des bases de données SQL.

Voici le schéma de notre base de donnée:
![schema-db](https://raw.githubusercontent.com/Ephec-AIR/notes/master/screenshots/schema-db.png)

