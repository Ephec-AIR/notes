Technologies
============

Framework (VueJS)
-----------------

Nous avons choisi d'utiliser le framework VueJS.
L'utilisation d'un framework est tout d'abord un choix, son utilisation amène une plus grande facilité et rapidité au développement
d'une part tout en ayant un coût au niveau des performances d'autre part.
De plus, VueJS de part son approche qui sera détaillée par après permet une meilleur maintenabilité du code qu'en vanilla 
(en pur javascript, sans l'utilisation d'un framework)

Par ailleurs VueJS est plus facile à apprendre et à utiliser que ses concurrents (React, Angular ou autres) 
et son écosystème (vue-router, vuex) est bien intégré au framework et cohérent avec celui-ci.

Bundling
--------

Lorsque l'on utilise un framework de nos jours, on ne va pas simplement créer un fichier javascript et un fichier css que l'on va importer
dans notre page html (ex: index.html). 

> Technique traditionelle
```html
...
<head>
  <link rel=stylesheet href="style.css">
  <script src=script.js></script>
</head>
...
```

On va plutôt créer différents fichiers (appelés communément des modules) où l'on va importer plusieurs librairies javascript, des images voir même des fichiers de styles, 
on va également souvent utiliser un préprocesseur pour notre css (dans notre cas scss) afin de faciliter l'écriture de celui-ci,...

```js
// moduleA.js
import maSuperLibrairie from 'masuperlibrairie';
const variable = "superstring";

// code...

export default variable;
```

```js
// moduleB.js
import moduleA from 'moduleA';

// code...
```

Au final ce que nous voulons, c'est avoir ces fameux fichiers javascript et css que nous allons intégrer dans notre page html 
au moyen de balises `<script>` et `<link>`.

Pour cela, nous devons utiliser un outils de bundling, le plus populaire étant Webpack.       
Malheureusement, celui-ci a besoin d'un fichier de configuration assez complexe au premier abord du moins. Il existe toutefois 
pour chaque framework une `cli (command line interface)` qui génère automatiquement le fichier de config nécessaire au bon fonctionnement de Webpack.    
Cependant, un membre de notre groupe disposait d'un fichier de config personnalisé.     
L'avantage de créer sa propre configuration de Webpack est qu'elle correspond parfaitement à ses besoins d'une part et d'autre part, si l'on a besoin de la modifier pour telle ou telle raison, il est bien plus facile de le faire que de devoir rentrer dans une config qui n'est pas la notre.

> résultat après le bundling
```html
...
<head>
  <link rel=stylesheet href="bundle.0104254201.css">
  <script src=bundle.01012014021.js></script>
</head>
...
```

> Webpack
![Webpack](https://dab1nmslvvntp.cloudfront.net/wp-content/uploads/2017/01/1484692838webpack-dependency-tree.png)

Performance
-----------

Lorsque l'on veut faire un site ou une application web utilisable autant sur pc que sur mobile, il est important de prendre du temps pour optimiser ses performances. Un mobile lorsqu'il est connecté au réseau n'a pas toujours la vitesse de connexion d'un pc connecté au wifi ou au cable ni les performances de cette machine.  
Dans une enquête menée par Google _(https://www.marketingdive.com/news/google-53-of-mobile-users-abandon-sites-that-take-over-3-seconds-to-load/426070/)_, il en est ressortit que **53%** des utilisateurs quittent un site s'il met plus de **3 secondes** à charger.
Ne pas se concentrer sur les performances de son site signifie une perte importante d'utilisateurs et donc par conséquent une perte d'argent.

On peut remarquer que notre site se charge rapidement et ce même en 3G. Ceci est encore plus vrai après une première visite où le temps de chargement devient alors quasi instantané.    
Lors de récent tests avec [webpagetest](https://www.webpagetest.org) avec un téléphone moyen (Moto4G) et une connectivité 3G, nous avons un temps de chargement de ~4.2s lors de la première visite et de ~1-2s lors de visites répétées.    
Nous voyons que bien que ces résultats sont corrects, des améliorations restent toujours possibles. _(https://www.webpagetest.org/result/171217_W3_c4d3f643bf030d233ed13638ce7c0a63/)_

Autrement, nous avons un score de 100/100 sur [pagespeed insight](https://developers.google.com/speed/pagespeed/insights/?hl=fr&url=air.ephec-ti.org), un outil de google permettant de mesurer la performance d'un site web sur desktop et mobile.   

Nous avons mis en place différentes choses pour arriver à un tel résultat.

Gzip et cache nginx
-------------------

Du côté du serveur web (nginx), nous avons compressé tout nos assets (css, js, html) au format gzip.    
Ceci permet de réduire la taille de ces fichiers et donc de réduire le besoin en bande passante.    
Par exemple, ceci nous permet de réduire d'un facteur de 3 la taille de nos fichiers javascript.     

De plus, nous avons également mis en cache et ce pour 1 an tout nos fichiers statiques (js, css, images,...).  
Comme on peut le remarquer sur la capture ci-dessous, le nom de fichier contient un numéro de révision _(a4d99281258b98247084)_.    
Celui-ci change lors de chaque nouvelle build (mise à jour du site ndlr), ce qui veut dire que dès que ce fichier est mis à jour, son numéro de révision change et donc le navigateur web considère ceci comme un nouveau fichier et ne va pas chercher le fichier mis en cache mais plutôt celui présent sur le serveur.    
Il supprime l'ancien fichier du cache et place le nouveau dans celui-ci.

> Gzip et mise en cache
![Gzip et Cache](https://raw.githubusercontent.com/Ephec-AIR/notes/master/screenshots/cache-nginx.png)

Service Worker
--------------

![Service Worker](https://blog.keycdn.com/blog/wp-content/uploads/2017/05/service-worker-diagram.png)

Un service worker est un proxy se plaçant entre le site web et le réseau. Pour expliquer de manière très simple, il intercepte toute les requètes faites au réseau et peut choisir de soit passer la requête au réseau, soit récupérer une copie depuis le cache.    
Il faut noter que des stratégies bien plus complexe peuvent être implémentées (téléchargement en arrière plan, synchronisation avec un serveur de notifications push,... -  https://jakearchibald.com/2014/offline-cookbook/).

Celui-ci nous permet de mettre en cache l'intégralité de notre site web (excepté les données de consommations bien que cela soit possible mais nous avons manqué de temps pour le faire).   
Il en résulte un temps de chargement quasi instantané.

![SW precache](https://raw.githubusercontent.com/Ephec-AIR/notes/master/screenshots/sw-precache.png)

![SW route](https://raw.githubusercontent.com/Ephec-AIR/notes/master/screenshots/sw-route-cache.png)

PRPL pattern et code-splitting 
------------------------------

![Code splitting](https://cdn-images-1.medium.com/max/1000/1*VgdNbnl08gcetpqE1t9P9w.png)

Nous nous sommes inspirés du _PRPL pattern (Push, Render, Pre-cache, Lazy-load)_ pour réaliser notre application.    

Il faut être conscient que si l'on charge un unique bundle javascript au chargement de notre application, celui-ci va ralentir le chargement de la page.    

Nous faisons du code-splitting pour découper notre bundle javascript en plusieurs petits morceaux, bien plus rapide à charger :
- Extraction du code "commun" (framework, librairies utilisées) afin de le séparer du code de notre application.    
- Extraction du code des différentes routes (/home, /parameters, /admin). Il est en effet inutile de charger le code de la route _/admin_ lorsque l'on se trouve sur la page _home_ ce qui ne ferait qu'allonger le temps de chargement de la page.

![code splitting](https://raw.githubusercontent.com/Ephec-AIR/notes/master/screenshots/code-splitting.png)

Enfin, le code des différentes route est préchargé via la balise `<link rel=prefetch>`.    
Ce préchargement est réalisé durant les "temps libres" du navigateur sans toutefois bloquer le chargement de la page comme le chargement normale d'une ressource.

![link rel prefetch](https://raw.githubusercontent.com/Ephec-AIR/notes/master/screenshots/link-rel-prefetch.png)

![prefetch timeline](https://raw.githubusercontent.com/Ephec-AIR/notes/master/screenshots/prefetch-timeline.png)

> Note: au dela d'être plus lent à télécharger, un plus gros bundle retarde le moment où la page est utilisable par l'utilisateur. En effet, après être chargé, le javascript doit être parsé et le temps de parsage est plus lent plus le bundle est volumineux. Cette dernière affirmation est d'autant plus vrai sur mobile où ce temps peut être multiplié par 10.

Images
------

Une autre manière d'obtenir de meilleur performances fût de ne pas charger des images ayant des tailles trop grandes et inadaptées et d'utiliser les formats **svg** ou **webp** (plus légers) dès que possible.

Explications
============

Architecture de l'application
-----------------------------

VueJS organise l'application en composant, ceux-ci sont placés dans des fichiers `.vue`.    
Un composant peut être n'importe quel élément de l'interface (formulaire d'inscription, graph, barre de navigation,...).
Chaque composant contient à la fois sa structure html, sa logique (javascript) et son style.     
Ceci permet une meilleur maintenabilité du code.

Cette architecture est également adoptée par des concurrents de Vue tels que React et Angular.
Elle a d'ailleurs été standardisée par le **W3C** sous le nom de _Web Component_.

Exemple d'un fichier Vue
------------------------

```vue
<template>
  <div class="air-toast-container">
    <transition name="toast-animate">
      <div class="air-toast" v-show="toast.show">
        <p class="air-toast--content" v-for="(message, index) in toast.messages" :key="index">{{message}}</p>
      </div>
    </transition>
  </div>
</template>

<script>
export default {
  computed: {
    toast () {
      return this.$store.state.toast;
    }
  }
}
</script>

<style lang="scss">
  $text-color: rgba(0, 0, 0, 0.54);
  $nav-text-color: #464A3F;
  $button-color: rgb(255, 23, 68);
  $placeholder-color: rgba(255, 23, 68, 0.27);
  .air-toast {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    word-wrap: break-word;
    position: fixed;
    padding: 0 5px;
    margin-right: 10px;
    color: #fff;
    bottom: 15px;
    left: 15px;
    padding: 10px;
    background: #333;
    border-radius: 3px;
    box-shadow: 0px 0px 5px rgba(0, 0, 0, 0.4);
    transform: none;
    will-change: opacity, transform;
    opacity: 1;
    z-index: 1;
    &--content {
      margin: 0;
    }
  }
  .toast-animate-enter-active, .toast-animate-leave-active {
    transition: opacity .3s cubic-bezier(0, 0, 0.3, 1),
      transform .5s cubic-bezier(0, 0, 0.3, 1);
  }
  .toast-animate-enter, .toast-animate-leave-to {
    transform: translateY(100px);
    opacity: 0;
  }
</style>
```

Ensuite, on injecte ce composant dans notre html.
```html
...
<section>
  <air-toast><!-- composant Vue -->
</section>
...
```

Pour ce qui est des différentes routes de notre application, elles sont gérées par notre framework via _vue-router_ qui est une libraire de l'écosystème **Vue**.   
A chaque route (ex: /home), on associe une vue qui est elle-même un composant (ex: Home.vue).

Enfin, chaque composant contient ses propres données, elles peuvent propagées de parent à enfant via ce qu'on appelle des _props_ (semblable à des attributs html)

> On propage les données contenue dans la variable data via la props "data"
```
<composant-parent>
  <composant-enfant :data="data"></composant-enfant>
</composnant-parent>

```

Le problème vient lorsqu'on veut propager ces données d'enfant à parent ou bien avec des composants voisins.

> comment partager les données de composant-un avec composant-deux ?
```
<composant-un></composant-un>
<composant-deux></composant-deux>
```

Pour régler, ce problème, nous avons utilisé **Vuex**.    
Vuex permet de créer un store global qui contiendra l'entiereté des données de notre application.   
Celles-ci pouvant désormais être injectées dans n'importe quel composant et partagées entre eux.

Librairie pour les graphiques (Chartist)
----------------------------------------

Lorsque nous avons commencé à intégrer les graphiques dans notre site web, nous avions d'abord pensé utiliser **anychart**.    
Cette librairie posait 2 problèmes:    
Le premier était qu'elle était payante et que la version gratuite au dela d'être limitée, plaçait un petit filigrane _"trial version"_ en dessous du graphique.    
Le second était que cette librairie est bien trop volumineuse et ralentissait considérablement notre site web.

Nous nous sommes finalement rabattus sur **chartist**.   
Chartist est une librairie permettant de facilement créer des graphiques simples, elle est très légère _(10kb gzip)_, responsive et fait le rendu des graphiques en svg.

Son utilisation est assez simple, il suffit de remplir un array contenant les différents labels de l'axe des abscisses et un autre array contenant un ou plusieurs array.
Chaque array représentant un type de donnée (ex: ma consommation, la consommation moyenne des utilisateurs,...).

```js
labels: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
series: [
  [12, 9, 7, 8, 5],
  [2, 1, 3.5, 7, 3],
  [1, 3, 4, 5, 6]
]
```

Bibliographie
-------------

* Matt GAUNT, 
Service Workers: an Introduction, En ligne
<https://developers.google.com/web/fundamentals/primers/service-workers/> consulté le 17/12/17

* Addy OSMANI, Preload, Prefetch And Priorities in Chrome, En ligne    
<https://medium.com/reloading/preload-prefetch-and-priorities-in-chrome-776165961bbf> consulté le 17/12/17

* Addy OSMANI, The cost of javascript, En ligne    
<https://medium.com/dev-channel/the-cost-of-javascript-84009f51e99e> consulté le 17/12/17

* Addy OSMANI, The PRPL Pattern, En ligne    
<https://developers.google.com/web/fundamentals/performance/prpl-pattern/> consulté le 17/12/17

* David KIRKPATRICK, Google: 53% of mobile users abandon sites that take over 3 seconds to load, En ligne    
<https://www.marketingdive.com/news/google-53-of-mobile-users-abandon-sites-that-take-over-3-seconds-to-load/426070/>, consulté le 17/12/17
