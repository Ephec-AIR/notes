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

Middlewares
-----------
NodeJS utilise un système de middlewares qui nous permettent à la requète d'enchainer des fonctions 
et de valider la 
Ceci nous permet de par exemple valider un champs de formulaire, authoriser un utilisateur,... et de stopper la requête à l'api si une des condition n'est pas vérifiée.
Ceci permet d'éviter de dupliquer du code de vérification, authorisation à travers le code.

exemple: 
```js
app.post('/sync', parseJWT, requireFields("serial", "user_secret"), catchErrors(doUserOwn), catchErrors(sync));
```

Ici, nous faisons un POST vers `/sync` pour accéder à la fonction `sync` qui va synchroniser l'appareil avec son utilisateur, il faut passer par plusieurs étapes:

1. `parseJWT`: l'utilisateur doit être identifié.
2. `requireFields(...)`: les champs de formulaire `serial` et `user_secret` doivent être présent dans les données du POST.
3. `doUserOwn`: On s'assure que l'appareil existe et appartient bien à l'utilisateur.
4. Une fois ces conditions vérifiées, on synchronise l'appareil avec l'utilisateur. 

> Si une de ces étapes échoue, on ne passe pas à l'étape suivante.


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

const onlyAdmin = (req, res, next) => {
  if (!req.user.isAdmin) {
    res.status(403).send('admin only !');
    return;
  }
  next();
}

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

const onlySyncedUser = (req, res, next) => {
  if (!req.user.serial) {
    res.status(412).end();
    return;
  }
  next();
}

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
Notre API tournant sur un port différent de celui du site, nous avons du activé CORS sur notre serveur
afin d'autoriser tout autre origine tournant sur la même machine que l'api à pouvoir faire des requètes vers celle-ci.
