# Email Campaign – A/B Testing & Uplift Modeling

## Objectif

L'objectif de ce projet est d'évaluer l'efficacité d'une campagne email et d'identifier les clients pour lesquels cette campagne semble avoir le plus d'impact sur la probabilité d'achat.

L'analyse répond à deux questions :

1. **Est-ce que recevoir un email augmente la probabilité d'achat ?**
2. **Chez quels clients l'effet de l'email semble-t-il le plus important ?**

Pour répondre à ces questions, le projet combine une analyse exploratoire, un A/B test et un modèle d'uplift.

---

## Dataset

Le projet utilise le dataset **Kevin Hillstrom MineThatData E-Mail Analytics**, disponible sur Kaggle.

Les données contiennent notamment :

* l'historique d'achat des clients ;
* la récence ;
* le sexe ;
* la zone géographique ;
* le canal d'acquisition ;
* le statut de nouveau client ;
* l'exposition à la campagne email ;
* la conversion après la campagne.

La variable `treatment` indique si le client a reçu un email :

* `1` : Mens E-Mail ou Womens E-Mail
* `0` : No E-Mail

Ainsi, les deux types d'emails sont regroupés dans un même groupe traité, car l'objectif du projet est d'étudier **l'effet de recevoir un email**, et non de comparer les deux types de campagnes.

---

## Méthodologie

### 1. Analyse exploratoire

Une première analyse exploratoire permet de comprendre la structure des données, les variables disponibles et la distribution de la conversion.

### 2. A/B Test

Une comparaison est réalisée entre :

* le groupe contrôle : clients sans email ;
* le groupe traitement : clients ayant reçu un email.

Les résultats montrent :

| Groupe   | Taux de conversion |
| -------- | -----------------: |
| Contrôle |             0,57 % |
| Email    |             1,07 % |

La différence est d'environ **+0,50 point de pourcentage** en faveur du groupe ayant reçu un email.

Le lift relatif est de **+86,53 %** et le test statistique confirme que cette différence est significative.

**Conclusion :** la campagne email a un effet positif sur la conversion en moyenne.

---

## 3. Uplift Modeling

L'objectif du modèle d'uplift est d'estimer l'impact individuel potentiel de la campagne email sur la probabilité d'achat, afin d'identifier les clients pour lesquels l'effet attendu est le plus important.

Un **T-Learner** est utilisé avec deux modèles Random Forest :

* un modèle entraîné sur les clients ayant reçu un email ;
* un modèle entraîné sur les clients n'ayant pas reçu d'email.

Pour chaque client :

**Uplift = Probabilité d'achat avec email − Probabilité d'achat sans email**

Le modèle estime ainsi l'effet potentiel de l'email pour chaque client.

---

## Résultats du modèle

L'uplift moyen prédit est de **+0,489 point de pourcentage**.

Les scores d'uplift varient selon les clients : certains ont un uplift positif élevé, tandis que d'autres présentent un uplift faible ou négatif.

### Évaluation avec la courbe de Qini

| Métrique            |  Résultat |
| ------------------- | --------: |
| Qini AUC du modèle  |     34,22 |
| Qini AUC aléatoire  |     31,43 |
| Coefficient de Qini | **+2,79** |

Le coefficient de Qini positif indique que le modèle permet un ciblage meilleur que le ciblage aléatoire.

---

## Analyse par décile

Les clients sont classés selon leur score d'uplift.

L'uplift moyen prédit diminue progressivement du décile supérieur au décile inférieur :

| Décile | Uplift moyen prédit |
| -----: | ------------------: |
|      9 |             +1,91 % |
|      8 |             +1,15 % |
|      7 |             +0,84 % |
|      6 |             +0,62 % |
|      5 |             +0,46 % |
|      4 |             +0,33 % |
|      3 |             +0,20 % |
|      2 |             +0,08 % |
|      1 |             −0,10 % |
|      0 |             −0,60 % |

Les premiers déciles correspondent donc aux clients ayant les scores d'uplift les plus élevés.

Les taux de conversion réellement observés ne suivent cependant pas parfaitement cette tendance, ce qui peut s'expliquer par le faible nombre de conversions.

---

## Exemple de ciblage : Top 30 %

À titre d'exemple opérationnel, les **30 % de clients ayant les scores d'uplift les plus élevés** sont sélectionnés, soit **5 760 clients**.

Leur profil moyen est comparé au reste de la population :

| Variable | Top 30 % | Reste |
| -------- | -------: | ----: |
| Recency  |     5,18 |  6,04 |
| History  |    377 $ | 186 $ |
| Newbie   |     66 % |  44 % |

Le Top 30 % est principalement composé de clients utilisant le **Web (47,2 %)** et vivant en zone **Suburban (46,0 %)**.

L'indicateur `womens` est présent chez **68,0 %** des clients du Top 30 %, contre **52,1 %** pour l'indicateur `mens`.

Ces caractéristiques permettent de donner une première description des clients ayant les scores d'uplift les plus élevés.

---

## Conclusion

L'A/B test montre que **la campagne email augmente significativement le taux de conversion**, avec une hausse de 0,57 % à 1,07 %.

Le modèle d'uplift permet ensuite d'aller plus loin en estimant l'effet potentiel de la campagne pour chaque client. Les résultats montrent que l'effet attendu varie selon les individus et que le modèle permet de mieux les classer qu'un ciblage aléatoire selon la métrique de Qini.

Ainsi, l'analyse passe d'une question d'efficacité globale :

> **« Est-ce que l'email fonctionne ? »**

à une question de ciblage :

> **« Chez quels clients l'email semble-t-il avoir le plus d'effet ? »**

L'approche permet donc de passer d'une stratégie consistant à envoyer la campagne à tous les clients à une stratégie de **ciblage des clients ayant le plus fort bénéfice attendu**.

