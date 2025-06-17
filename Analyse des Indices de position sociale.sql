#requêtes
use ips;

#création des indexes
Create UNIQUE index Lyceeindex on Lycee2(uai);
Create UNIQUE index  IpsIndex on ips(IdIps);
CREATE INDEX idx_academie ON Academie(academie);
#############################################################################################
#############################################################################################
################################### PARTIE 1#################################################
#############################################################################################
#############################################################################################

#requêtes pour comprendre nos données:
Select min(rentree_sco) as DebutDonnées,max(rentree_sco) as FinDonnées from ips;
Select count(uai) as NbLycees from Lycee2;
Select count(IdDepartement) as NbDepartement from Departement;
Select count(CP) as NbCommune from Commune;
select count(IdAcademie) as NbAcademie from Academie;
Select count(uai) as NbLycee , TypeL from Lycee2 natural join Lycee_type natural join typeLycee group by TypeL;

Select max(ips_ens) as MaxIpsens,max(ips_gt) as MaxIpsGt,max(ips_pro) as MaxIpsPro from ips;

Select min(ips_ensemble) as minIps from ips;
Select min(ips_gt) as MinIpsGt from ips where ips_gt!=0;
Select min(ips_pro) as MinIpsPro from ips where ips_pro !=0;

Select max(ecart_type_de_l_ips_voie_gt) as MaxEcGt from ips;
Select max(ecart_type_de_l_ips_voie_pro) as MaxEcPro from ips;

Select min(ecart_type_de_l_ips_voie_gt) as MinEcGt from ips where ecart_type_de_l_ips_voie_gt !=0;
Select min(ecart_type_de_l_ips_voie_pro) as MinEcPro from ips where ecart_type_de_l_ips_voie_pro!=0; 


with tableEph as (
Select count(uai) as nbLycee from departement
natural join commune
natural join lycee2
group by NomDep
)Select avg(NbLycee) as MoyenneNbLyceeParDep from tableEph;


####ajouter ou supprimer des lignes a l'aide transaction
-- Création d'une table temporaire 
CREATE TEMPORARY TABLE T_Lycee AS SELECT * FROM Lycee2 WHERE 1=0;
DESCRIBE T_Lycee;
START TRANSACTION;
INSERT INTO T_Lycee (uai, nomEtablissement, idAcademie, secteur, CP)
VALUES ('UAI002', 'Lycee B', '0', 'Privé', '67890');
SAVEPOINT mon_point_de_sauvegarde;
UPDATE T_Lycee
SET nomEtablissement = 'Lycee A', idAcademie = '5'
WHERE uai = 'UAI001';
DELETE FROM T_Lycee
WHERE secteur = 'Privé';
ROLLBACK TO SAVEPOINT mon_point_de_sauvegarde;
COMMIT;


# Afficher la liste des noms de la commune en majuscules avec le code de la commune 
SELECT UPPER(Nom) AS Nom_commune, CP FROM Commune;

#Afficher la liste de uai (4 premières caractères) et nom de l’établissement correspondantes pour le lycée.
SELECT LEFT(uai, 4), nomEtablissement
FROM Lycee2;

#############################################################################################
#############################################################################################
################################### PARTIE 2 ################################################
#############################################################################################
#############################################################################################

#1    Affiche le nom des établissements et de l'académie pour tous les lycées publics.

SELECT nomEtablissement, academie
FROM Lycee2 
JOIN Academie ON Lycee2.idAcademie = Academie.idAcademie
WHERE Lycee2.secteur = 'Public';

# 2  Affiche les lycées avec un indice de position sociale entre 85 et 100
SELECT L.nomEtablissement
FROM Lycee2 L
JOIN ips I ON L.uai = I.uai
WHERE I.ips_ensemble BETWEEN 85 AND 100;

#2 bis.  Affichez le département avec le meilleur ips et celui avec le pire.

SELECT D.NomDep, MAX(I.ips_ensemble) AS Best_IPS
FROM ips I
JOIN Lycee2 L ON I.uai = L.uai
JOIN commune C ON L.CP = C.CP
JOIN departement D ON C.idDepartement = D.idDepartement
GROUP BY D.NomDep

UNION ALL

SELECT D.NomDep, MIN(I.ips_ensemble) AS Worst_IPS
FROM ips I
JOIN Lycee2 L ON I.uai = L.uai
JOIN commune C ON L.CP = C.CP
JOIN departement D ON C.idDepartement = D.idDepartement
GROUP BY D.NomDep;

# 3  Lister  les indices de position sociale des lycées avec un cursus général à partir de 2020. 


SELECT Lycee2.nomEtablissement, ips.ips_ensemble
FROM Lycee2 
JOIN ips  ON Lycee2.uai = ips.uai
JOIN lycee_type  ON Lycee2.uai = lycee_type.uai
JOIN typeLycee  ON lycee_type.idType = typeLycee.idType
WHERE typeLycee.typeL = 'LEGT' AND ips.rentree_sco >= '2020-2021';



#4  Afficher le nom des établissements, le secteur, et l'IPS ensemble pour tous les lycées situés dans le département de la ‘Somme’. 

Select
    lycee2.nomEtablissement,
    lycee2.secteur,
    ips.ips_ensemble,
	departement.NomDep
FROM
    lycee2
JOIN
    ips ON lycee2.uai = ips.uai
JOIN
    commune ON lycee2.CP = commune.CP
JOIN
    departement ON commune.IdDepartement = departement.IdDepartement 
WHERE departement.NomDep = 'Somme';



# 5  Afficher l'académie et la moyenne de l'IPS par voie professionnelle pour tous les établissements. 

SELECT A.academie, AVG(I.ips_pro) AS Avg_IPS_Pro
FROM Academie A
JOIN Lycee2 L ON A.idAcademie = L.idAcademie
JOIN ips I ON L.uai = I.uai
GROUP BY A.academie;


#6    Affiche le nom des établissements, le secteur, l'IPS ensemble, et le département pour tous les lycées. 

Select
    lycee2.nomEtablissement,
    lycee2.secteur,
    ips.ips_ensemble,
	departement.NomDep
FROM
    lycee2
JOIN
    ips ON lycee2.uai = ips.uai
JOIN
    commune ON lycee2.CP = commune.CP
JOIN
    departement ON commune.IdDepartement = departement.IdDepartement;



#7 Afficher les lycées avec le pourcentage d'écart type de l'IPS voie générale par rapport à l'IPS voie professionnelle 

SELECT L.nomEtablissement, 
       I.ecart_type_de_l_ips_voie_gt / I.ips_gt * 100 AS Percentage_GT,
       I.ecart_type_de_l_ips_voie_pro / I.ips_pro * 100 AS Percentage_Pro
FROM Lycee2 L
JOIN ips I ON L.uai = I.uai
WHERE I.ips_gt > 0 AND I.ips_pro > 0;

#8.  Affiche le nombre de lycées dans chaque département ainsi que l'IPS ensemble moyen. 
SELECT NomDep AS Departement, COUNT(uai) AS Nombre_de_Lycee, ROUND(AVG(ips_ensemble), 2) AS IPS_ensemble_moyen
FROM Departement 
NATURAL JOIN Commune 
NATURAL JOIN Lycee2 
NATURAL JOIN IPS 
GROUP BY NomDep;

#9. Afficher le nombre de lycées par académie, trié par ordre décroissant du nombre de lycée.
SELECT A.Academie AS Academie,
       COUNT(L.uai) AS Nombre_de_Lycee
FROM Academie A
LEFT JOIN  Lycee2 L ON A.idAcademie = L.idAcademie
GROUP BY A.Academie
ORDER BY Nombre_de_Lycee DESC;

#10.  Affiche le nom des établissements dans commune le  'Serris'.
SELECT L.nomEtablissement AS Nom_etablissement,
       C.Nom AS Nom_commune
FROM  Lycee2 L
RIGHT JOIN Commune C ON L.CP = C.CP
WHERE C.Nom = 'Serris';   

#11.  Affiche le nom des établissements et leur IPS ensemble pour ceux qui ont un IPS ensemble supérieur 
# à au moins un autre établissement dans la même académie. 
CREATE VIEW VueLyceeSelfJoin AS
SELECT L1.nomEtablissement AS Nom_etablissement,
       I1.ips_ensemble AS IPS_ensemble,
       L2.nomEtablissement AS Nom_etablissement_compare,
       I2.ips_ensemble AS IPS_ensemble_compare
FROM Lycee2 L1
JOIN IPS I1 ON L1.uai = I1.uai
JOIN Lycee2 L2 ON L1.idAcademie = L2.idAcademie
           AND L1.uai <> L2.uai
JOIN IPS I2 ON L2.uai = I2.uai
WITH CHECK OPTION;
#Utilisez la vue pour comparaison
SELECT Nom_etablissement, IPS_ensemble, Nom_etablissement_compare, IPS_ensemble_compare
FROM VueLyceeSelfJoin
WHERE IPS_ensemble > IPS_ensemble_compare;
    
#12.  Affiche le nom des établissements reliés à l’académie ‘Corse’ et leurs informations IPS.
SELECT A.academie, L.nomEtablissement, I.* 
FROM Academie A
NATURAL JOIN Lycee2 L 
NATURAL JOIN IPS I 
WHERE A.academie = 'Corse';   

#13.  Quel est le nom des établissements ayant un IPS ensemble supérieur à la moyenne des Ips ?
SELECT nomEtablissement, ips_ensemble
FROM Lycee2 
NATURAL JOIN IPS 
WHERE ips_ensemble > (SELECT AVG(ips_ensemble) FROM IPS);   

#14.  Affiche les lycées situés dans des communes avec un nombre total d'établissement inferier a 200.
WITH TotalEtablissementsParCommune AS (
    SELECT C.CP, C.Nom AS Nom_commune, COUNT(L.uai) AS Nombre_totals_etablissement
    FROM Commune C
    LEFT JOIN Lycee2 L ON C.CP = L.CP
    GROUP BY  C.CP, C.Nom
)
SELECT L.nomEtablissement, T.Nom_commune, T.Nombre_totals_etablissement
FROM Lycee2 L
LEFT JOIN TotalEtablissementsParCommune T ON L.CP = T.CP
WHERE T.Nombre_totals_etablissement < 200;


#15.  Quels départements ont un nombre d'établissements supérieurs à la moyenne (avec leur nombre d'établissements) ? Quels sont leur ips moyen ?
with tableEph as (
Select count(uai) as nbLycee from departement
natural join commune
natural join lycee2
group by NomDep
)
Select NomDep, count(uai)  as Nb_Lycee, avg(ips_ensemble) as MoyenneIps from Departement 
natural join commune
natural join  lycee2 
natural join ips
group by NomDep 
having count(uai)> (Select avg(NbLycee) from tableEph);

#16.Quelle est la moyenne des ips des lycées pro et des lycées généraux et l'ips moyen total?
Select round(avg(ips_gt)) as ipsGeneral, round(avg(ips_pro)) as ipsPro, round(avg(ips_ensemble),0) as ipsMoyen
from ips;

#17.  Afficher les dix académies et leur nombre total d'établissements avec le meilleur ips moyen.
Select academie, count(uai) as nbLycee, round(avg(ips_ensemble)) as ipsMoyen from academie
natural join lycee2
natural join ips
group by academie
order by ipsMoyen DESC
limit 10;

#18. Afficher le nombre de lycées polyvalents pour lesquels l'ips pro est supérieur à l'ips général et inversement. 
Select count(uai) NbLycees from lycee2
natural join lycee_type
natural join typelycee 
natural join ips
where typel = "LPO"
and ips_gt<ips_pro;
Select count(uai) NbLycees from lycee2
natural join lycee_type
natural join typelycee 
natural join ips
where typel = "LPO"
and ips_gt>ips_pro;

#19. De quelle année à quelle année va l'étude?  
select max(rentree_sco),min(rentree_sco) from ips;

#20.  AAfficher les écarts-types et ips des  communes où le nombre total d'établissements est inférieur à 10.
Select CP, Nom, count(uai) as Nb_Lycee, round(avg(ips_ensemble)) as ipsMoyen,
round(avg(ecart_type_de_l_ips_voie_gt)) as EcGeneralMoyen,round(avg(ecart_type_de_l_ips_voie_pro)) as EcProMoyen 
from Commune 
natural join Lycee2
natural join ips
group by  CP, Nom
having count(uai)<10
order by Nb_Lycee DESC;

#21.  Afficher le nom des départements ayant un ips supérieur à la moyenne des ips.
Select round(avg(ecart_type_de_l_ips_voie_gt)) as `Ecart type voie générale`,
round(avg(ecart_type_de_l_ips_voie_pro)) as `Ecart type voie professionnelle`
from ips;

#22.Quels sont les 20 lycées avec le plus d'hétérogénéité sociale?
(Select NomDep,Nom,nomEtablissement, ecart_type_de_l_ips_voie_gt,ecart_type_de_l_ips_voie_pro, ips_gt,ips_pro from 
Departement natural join Commune 
natural join Lycee2 
natural join ips)
UNION
(Select NomDep,Nom,nomEtablissement, ecart_type_de_l_ips_voie_gt,ecart_type_de_l_ips_voie_pro,ips_gt,ips_pro from 
Departement natural join Commune 
natural join Lycee2 
natural join ips
)order by ecart_type_de_l_ips_voie_gt,ecart_type_de_l_ips_voie_pro  DESC
limit 20;

#D'après l'insee, voici la liste des 10 départements les plus pauvres de France
#"Seine-Saint-Denis","Pas-de-Calais","Aube","Aisne","Creuse","Cher","Haute-Marne","Hautes-Alpes","Corrèze","Vosges"
#comparez leurs ips et écarts types avec les 10 départements les plus riches:
#"Hauts-de-Seine","Paris","Yvelines","Rhône","Essonne","Alpes-Maritimes","Val-de-Marne","Seine-et-Marne","Bouches-du-Rhône","Val-d'Oise"

Select round(avg(ips_ensemble)) as ipsMoyen, round(avg(ecart_type_de_l_ips_voie_gt)) as ecart_type_gen,
round(avg(ecart_type_de_l_ips_voie_pro)) as ecart_type_pro
from ips 
natural join lycee2
natural join commune
natural join departement
where NomDep in("Seine-Saint-Denis","Pas-de-Calais","Aube","Aisne","Creuse","Cher","Haute-Marne","Hautes-Alpes","Corrèze","Vosges");


Select round(avg(ips_ensemble)) as ipsMoyen, round(avg(ecart_type_de_l_ips_voie_gt)) as ecart_type_gen,
round(avg(ecart_type_de_l_ips_voie_pro)) as ecart_type_pro
from ips 
natural join lycee2
natural join commune
natural join departement
where NomDep in("Hauts-de-Seine","Paris","Yvelines","Rhône","Essonne","Alpes-Maritimes","Val-de-Marne","Seine-et-Marne","Bouches-du-Rhône","Val-d'Oise");

#on supprime les indexes
drop index Lyceeindex on Lycee2;
drop index IpsIndex on Ips;
DROP INDEX idx_academie ON Academie;