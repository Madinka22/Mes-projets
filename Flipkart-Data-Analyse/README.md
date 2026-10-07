## Flipkart — Analyse de données E-Commerce

### Présentation du projet

Ce projet présente une analyse complète de données e-commerce, réalisée de bout en bout afin de transformer des données produits brutes en informations exploitables pour la prise de décision business.

L'objectif est d'analyser:

* la performance des produits ;
* la performance des vendeurs ;
* le chiffre d'affaires estimé ;
* les volumes de ventes ;
* les prix ;
* les notes clients ;
* les remises ;
* la performance des stocks ;
* les risques de rupture de stock.

Le projet suit une démarche complète :

Python -> PostgreSQL -> PowerBI -> Insight Business

-------------------------------------------------------------------------------------------------------------------------
### Technologies utilisées

* Python : Nettoyage, validation et transformation des données
* PostgreSQL : Stockage et modélisation des données
* Power BI : Dashboard interactif et visualisation
* Git / GitHub : Versionnement et documentation du projet  

-------------------------------------------------------------------------------------------------------------------------
### 1.Nettoyage et préparation des données — Python

La première étape consiste à effectuer une analyse de la qualité des données avec package Pandas.

#### Contrôles réalisés

Les données ont été contrôlées sur plusieurs dimensions :
* valeurs manquantes ;
* doublons ;
* types de données ;
* valeurs numériques ;
* cohérence générale du dataset.

#### Résultats

Le dataset contient :

* 5 000 produits
* 4 catégories principales
* 16 sous-catégories
* 8 vendeurs
* aucune valeur manquante ;
* aucun doublon.

#### Feature Engineering

Quatre indicateurs/features ont été créés.

##### Estimated Revenue
Estimated Revenue = Price × Total Sold

Cet indicateur fournit une estimation de la valeur générée par un produit à partir de son prix actuel et de son volume cumulé de ventes.
Il s'agit d'un revenu estimé à des fins analytiques et non d'un chiffre d'affaires comptable.

##### Sell-Through Rate
Sell-Through Rate =
Total Sold / (Total Sold + Available Stock)

Cet indicateur mesure la proportion du stock disponible qui a déjà été vendue.

##### Stock Status
Les produits ont été catégorisés selon leur situation de stock afin d'identifier les situations nécessitant une attention particulière.

##### Discount Band
Les remises ont été regroupées en plusieurs catégories :

0–10 %\
10–20 %\
20–30 %\
30–40 %\
40 %+

------------------------------------------------------------------------

### 2.Modélisation des données — PostgreSQL

Les données nettoyées ont ensuite été intégrées dans PostgreSQL selon une architecture :

##### Staging → Analytics

#### Modèle analytique

analytics \
├── dim_category\
├── dim_subcategory\
├── dim_seller\
├── dim_product\
└── fact_product_performance

#### Dimensions

Le modèle contient plusieurs tables de dimension :
* dim_category
* dim_subcategory
* dim_seller
* dim_product

#### Table de faits
La table fact_product_performance contient les principales mesures de performance :
* prix ;
* rating ;
* nombre d'acheteurs ;
* unités vendues ;
* stock disponible ;
* remise ;
* politique de retour ;
* estimated revenue ;
* sell-through rate ;
* stock status ;
* discount band.

Cette modélisation permet de séparer les informations descriptives des mesures de performance et facilite les analyses SQL et Power BI.

------------------------------------------------------------------------

### 3.Analyse business 
L'analyse SQL permet d'explorer la performance globale, les catégories, les vendeurs, les produits et les stocks.

[Voir l'analyse](04_resultats/analyse.md)

------------------------------------------------------------------------

### 4.Dashboard PowerBI 

Le dashboard Power BI a été développé à partir du modèle de données PostgreSQL construit dans ce projet.
Le fichier .pbix est disponible dans le dossier 03_powerbi/ afin de permettre l'accès au rapport Power BI et d'examiner sa structure.
Pour permettre une consultation rapide du dashboard sans avoir à installer Power BI, configurer PostgreSQL ou reproduire l'environnement de données, des captures des différentes pages du dashboard sont également disponibles dans 04_results/images/.
Les captures permettent ainsi de visualiser directement les principaux indicateurs, analyses et résultats du dashboard.

Il est organisé en 3 pages analytiques.

[Voir l'analyse du dashboard](04_resultats/analyse_dashboard.md)

------------------------------------------------------------------------
### Recommadation business

Sur la base des analyses SQL et du dashboard Power BI, plusieurs pistes d'action peuvent être proposées :

#### 1. Sécuriser les produits à forte valeur

**Electronics représente 48,51 % du CA estimé (₹437,93 Md).**
Prioriser le suivi des références à forte valeur et de leur disponibilité afin de limiter les risques de rupture.

#### 2. Optimiser la gestion des stocks

**95,54 % des produits sont classés "High Stock"** selon la classification du dashboard.
Identifier les produits à faible rotation et stock élevé afin de réduire les stocks excédentaires et améliorer leur rotation.

#### 3. Anticiper les ruptures

Surveiller les produits combinant **sell-through élevé, stock faible et volume de ventes important** afin de prioriser les éventuels réapprovisionnements.

#### 4. Optimiser les remises

Les produits avec **0–10 % de remise génèrent environ 9 M d'unités vendues**, tandis que ceux avec **40 % et plus** en génèrent environ 8 M.
La remise ne doit donc pas être considérée comme le seul levier de performance : analyser conjointement **prix, volume, CA et marge**.

#### 5. Suivre les vendeurs et produits clés

RetailNet génère le CA estimé le plus élevé (**₹125,34 Md**), tandis que certains produits dépassent **₹2 Md de CA estimé**.
Mettre en place un suivi régulier des **vendeurs, produits à forte valeur, sell-through et satisfaction client** permettrait de mieux prioriser les actions commerciales.

#### Priorités

**Stocks → Produits à forte valeur → Remises → Vendeurs → Satisfaction client**

L'objectif est de trouver un équilibre entre **croissance des ventes, disponibilité des produits, rotation des stocks et valeur générée**.


------------------------------------------------------------------------
### Limite d'analyse

Le dataset utilisé correspond à un snapshot produit e-commerce.

Il ne contient pas de dimension temporelle.
Par conséquent :
* il n'est pas possible d'analyser les tendances mensuelles ;
* il n'est pas possible de calculer une croissance YoY ou MoM ;
* il n'est pas possible d'établir une évolution historique des ventes ;
* l'Estimated Revenue repose sur le prix actuel × les unités vendues cumulées ;
* les relations entre remise, rating et ventes sont descriptives et ne permettent pas d'établir de causalité.

Ces limites sont prises en compte dans l'interprétation des résultats.

------------------------------------------------------------------------
### Conclusion

Ce projet démontre la mise en œuvre d'un pipeline complet d'analyse de données, depuis la préparation des données jusqu'à la restitution des résultats sous forme de dashboard interactif.

L'objectif n'était pas uniquement de créer des visualisations, mais de construire une démarche analytique complète :

##### Données brutes → Données propres → Modèle analytique → Analyse SQL → Dashboard → Insights Business

Le projet met particulièrement en évidence l'importance de croiser plusieurs indicateurs afin de mieux comprendre la performance des produits, des catégories, des vendeurs et des stocks.



