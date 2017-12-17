### Technologies

#### Framework (VueJS)

Nous avons choisi d'utiliser le framework VueJS.
L'utilisation d'un framework est tout d'abord un choix, son utilisation amène une plus grande facilité et rapidité au développement
d'une part tout en ayant un coût au niveau des performances d'autre part.
De plus VueJS de part son approche qui sera détaillée par après permet une meilleur maintenabilité du code que du code vanilla 
(en pur javascript, sans l'utilisation d'un framework)

Par ailleurs VueJS est plus facile à apprendre et à utiliser que ses concurrents (React, Angular ou autres) 
et son écosystème (vue-router, vuex) est bien intégré au framework et cohérent avec celui-ci.

#### Bundling

Lorsque l'on utilise un framework de nos jours, on ne va pas simplement créer un fichier javascript et un fichier css que l'on va importer
dans notre page html (ex: index.html). 

On va plutôt créer différents fichiers où l'on va importer plusieurs librairies javascript, des images voir même des fichiers de styles, 
on va souvent utiliser un préprocesseur pour notre css (dans notre cas scss) afin de faciliter l'écriture de celui-ci,...

Au final ce que nous voulons c'est avoir ces fameux fichiers javascript et css que nous allons intégrer dans notre page html 
au moyen de balises `<script>` et `<link>`.

Pour cela, nous devons utiliser un outils de bundling, le plus populaire étant Webpack.
Malheureusement, celui-ci a besoin d'un fichier de configuration assez complexe au premier abord du moins. Il existe toutefois 
pour chaque framework une `cli (command line interface)` qui génère automatiquement le fichier de config nécessaire au bon fonctionnement de Webpack.
Cependant, un membre de notre groupe disposait d'un fichier de config perso, l'avantage de créer sa propre configuration de Webpack 
est qu'elle correspond parfaitement à ses besoins d'une part et d'autre part, si l'on a besoin de la moifier pour telle ou telle raison, 
il est bien plus facile de le faire que de devoir rentrer dans une config qui n'est pas la notre.


![Webpack](https://dab1nmslvvntp.cloudfront.net/wp-content/uploads/2017/01/1484692838webpack-dependency-tree.png)

#### Mise en cache

// Cache nginx
// Service Worker

### Explication

#### Architecture de la plateforme Web

#### Exemple d'un fichier Vue

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

#### Librairie pour les graphes (Chartist)
