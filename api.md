Web API
=======

NodeJS
------

NodeJS permet d'écrire du javascript côté serveur. 
Nous l'avons utilisé pour réaliser le backend et plus précisément l'API de notre application.
Un des avantages de celui-ci est qu'il a le même langage que le client ce qui nous permet par exemple d'utiliser des librairies identiques autant côté serveur que client (ce fût le cas pour une librairie de gestion de dates).

Base de donnée
--------------

MongoDB est un système de gestion de base de donnée orienté documents.
Chaque nouvelle donnée que l'on rentre dans un modèle (équivalent à une table en SQL) n'est pas une nouvelle ligne 
comme en SQL mais un nouveau document. 
On peut comparer ce document à un objet javascript.
Ce système fait partie de la famille des bases de données NoSQL (Redis,...)
L'avantage de MongoDB est qu'il est parfaitement intégré à NodeJS via la librairie `mongoose` contrairement
à la plupart des bases de données SQL.

Voici le schéma de notre base de donnée:

![schema-db](https://raw.githubusercontent.com/Ephec-AIR/notes/master/screenshots/schema-db.png)

Json Web Token
--------------

Historiquement, lorsqu'un utilisateur se connecte sur un site, ses informations sont enregistrées dans une session et il y accède au moyen d'un cookie. Cette approche a des lacunes qui rend difficile son utilisation au sain d'une application web.

Les Json Web Tokens permettent de pallier aux lacunes du système de session traditionnel en stokant les informations utilisateur de manière sécurisée chez le client. Après une authentification réussie, le serveur va envoyer un JWT pour le client dans sa réponse HTTP, le client est alors responsable de fournir ce jeton d'accès à chaque nouvelle requête HTTP (dans la variable `Authentication` des entêtes HTTP).

Un JWT est en fait une chaine de caractère séparée en trois par un point:

1) Une entête qui fourni les informations sur la nature du JWT.
2) La charge utile qui contient les infos de l'utilisateur.
3) La signature de la charge (avec une clée privée au serveur) pour s'assurer de l'authenticité du JWT.

Chaque partie étant encodée en base64

Middlewares
-----------

NodeJS utilise un système de middlewares qui permettent à la requête de passer par différentes fonctions qui nous permettent de valider cette dite requête.    
Pour appeler la fonction de middleware suivante, on utilise la fonction `next()`.    
Ceci nous permet par exemple de valider un champs de formulaire, autoriser un utilisateur,... et de stopper la requête à l'api si une des condition n'est pas vérifiée.    
Ceci permet notamment d'éviter de dupliquer du code de vérification, autorisation à travers le code et de plus facilement s'y retrouver dans nos différents patternes d'autorisation.

exemple : 
```js
app.post('/sync', parseJWT, requireFields("serial", "user_secret"), catchErrors(doUserOwn), catchErrors(sync));
```

Ici, nous faisons un POST vers `/sync` pour accéder à la fonction `sync` qui va synchroniser l'appareil avec son utilisateur, il faut passer par plusieurs étapes:

1. `parseJWT`: l'utilisateur doit être identifié.
2. `requireFields(...)`: les champs de formulaire `serial` et `user_secret` doivent être présent dans les données du POST.
3. `doUserOwn`: On s'assure que l'appareil existe et appartient bien à l'utilisateur.
4. Une fois ces conditions vérifiées, on synchronise l'appareil avec l'utilisateur. 

> Si une de ces étapes échoue, on ne passe pas à l'étape suivante.

Voici nos différents middlewares : 

> Vérifie qu'un json web token a bien été placé dans l'en tête "authorization" et qu'il est valide.
```js
const parseJWT = jwt({
  secret: JWT_SECRET,
  getToken: function (req) {
    if (req.headers.authorization && req.headers.authorization.split(' ')[0] === 'Bearer') {
      return req.headers.authorization.split(' ')[1];
    }
    return null;
  }
});
```

> Vérifie que l'utilisateur connecté est bien administrateur
```js
const onlyAdmin = (req, res, next) => {
  if (!req.user.isAdmin) {
    res.status(403).send('admin only !');
    return;
  }
  next();
}
```

> Vérifie que l'appareil OCR appartient à l'utilisateur
```js
const doUserOwn = async (req, res, next) => {
  const {user_secret, serial} = req.body;
  const product = await Product.findOne({serial});

  if (!product) {
    res.status(404).end();
    return;
  }

  if (product.user_secret !== user_secret) {
    res.status(403).end();
    return
  }
  next();
}
```

> Vérifie que l'OCR est bien actif
```js
const onlyActiveOCR = async (req, res, next) => {
  const {ocr_secret, serial} = req.body;
  const product = await Product.findOne({serial});

  if (!product) {
    res.status(404).end();
    return;
  }

  if (product.ocr_secret != ocr_secret) {
    res.status(403).end();
    return;
  }

  if (!product.isActive) {
    res.status(410).end();
    return;
  }
  next();
}
```

> Vérifie que l'appareil est bien synchronisé avec l'utilisateur
```js
const onlySyncedUser = (req, res, next) => {
  if (!req.user.serial) {
    res.status(412).end();
    return;
  }
  next();
}
```

> Vérifie que l'utilisateur a bien mis à jour son compte avec son code postal et son fournisseur d'électricité.
```js
const onlyUpdatedUser = (req, res, next) => {
  if (!req.user.postalCode || !req.user.supplier) {
    res.status(412).end();
    return;
  }
  next();
}
```

CORS (Cross Origin Resource Sharing)
------------------------------------
Notre API tournant sur un port différent de celui du site, nous avons du activer CORS sur notre serveur afin d'autoriser tout autre origine tournant sur la même machine que l'api à pouvoir faire des requêtes vers celle-ci.

Bibliographie
-------------

JWT, *JSON Web Token Introduction*, en ligne <https://jwt.io/introduction/> consulté de septembre 2017 à octobre 2017.
