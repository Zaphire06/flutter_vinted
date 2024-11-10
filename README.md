# Flutter Vinted - Application d'Achat de Vêtements

L'objectif de cette application est de développer une version minimale (MVP) d'une plateforme inspirée de Vinted, permettant aux utilisateurs d'acheter et de gérer leurs vêtements en ligne. Ce projet a été développé dans un contexte de méthodologies agiles, en suivant les critères d'acceptance de chaque fonctionnalité sous forme de user stories. L'application présente une interface simple, centrée sur l'expérience utilisateur avec des options de connexion, navigation, et ajout de produits.

## Utilisateurs de Test

Pour accéder aux différentes pages de l'application, vous pouvez utiliser les comptes de test suivants :

- **Utilisateur 1**:  
  - **Login** : user1  
  - **Password** : password1

- **Utilisateur 2**:  
  - **Login** : user2  
  - **Password** : password1

## Liens pour l'ajout d'articles
Veuillez ajouter les URL des images dans le champ image lors de l'ajout d'article, voici des exemples que vous pouvez utiliser :

1. [URL 1](https://example.com/image1.jpg)
2. [URL 2](https://example.com/image2.jpg)
3. [URL 3](https://example.com/image3.jpg)
4. [URL 4](https://example.com/image4.jpg)

## Fonctionnalités

### Connexion
- Interface de connexion avec **header** contenant le nom de l'application.
- Champs de saisie pour **Login** et **Password** (offusqué).
- Bouton **Se connecter**.
- Validation des champs et connexion en base. Si les informations sont incorrectes, un message d'erreur s'affiche dans la console.

### Liste des Vêtements
- **Liste de vêtements** récupérée de la base de données.
- **BottomNavigationBar** avec les options : **Acheter**, **Panier** et **Profil**.
- Informations affichées pour chaque vêtement :
  - Image, titre, taille et prix.
- Clic sur un vêtement pour accéder au **détail** de celui-ci.

### Détail d'un Vêtement
- Page de détail affichant :
  - Image, titre, catégorie, taille, marque et prix.
- Bouton **Retour** pour revenir à la liste des vêtements.
- Bouton **Ajouter au panier** pour ajouter le vêtement au panier de l'utilisateur (enregistré en base).

### Panier
- Affichage du panier de l'utilisateur avec :
  - Image, titre, taille et prix pour chaque article.
- **Total général** affiché pour tous les articles.
- Bouton de suppression pour retirer un article et mettre à jour le total.
- Pas d'option de paiement pour le moment.

### Profil Utilisateur
- Affichage des informations de l'utilisateur :
  - **Login** (readonly), **Password** (offusqué), date de naissance, adresse, code postal (clavier numérique), ville.
- **Bouton Valider** pour sauvegarder les modifications dans la base de données.
- **Bouton Se déconnecter** pour retourner à la page de connexion.

### Ajout de Vêtements
- Depuis le profil, possibilité d'ajouter un nouveau vêtement avec un formulaire de saisie pour :
  - Image, titre, catégorie (auto-détectée), taille, marque et prix (clavier numérique).
- Bouton **Valider** pour enregistrer le vêtement dans la base de données.

### Notifications Push
- Notifications push pour fournir des informations ou des indications pertinentes à l'utilisateur lors de certaines actions (par exemple, confirmation d'ajout au panier, confirmation de mise à jour de profil, etc.).

---

### Modèle de classification d'image pour la Catégorie
L'application inclut une fonctionnalité d'intelligence artificielle pour détecter automatiquement la catégorie d'un vêtement en fonction de l'image fournie. Bien que l'intégration de l'IA se soit déroulée correctement, un problème persistant avec le modèle lui-même empêche l'obtention de prédictions précises. Malgré de longues recherches et tests, le modèle affiche toujours la même prédiction par défaut. En conclusion, l'erreur provient du modèle en lui-même et non de son intégration dans l'application.

J'ai aussi laissé dans les assets un modèle très performant qui reconnaissait sans aucune erreurs les vetements parmis 9 catégories. Malheureusment, malgrés des heures de tests, je n'ai pas réussi à l'intégrer à l'application ayant des erreurs de redimenssionement et autres...
