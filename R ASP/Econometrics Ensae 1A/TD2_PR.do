//----------------------------//
// TD2 - MULTIPLE  REGRESSION //
//----------------------------//


// EXERCICE 5 //-------------------------------------------------------------------------------------------------


use "\\ulysse\users\PRossi\TD\Econom�trie 1\Bases\emp2007.dta"

browse

* salred = salaire mensuel net
* hhc = nombre d'heures travaill�es dans la semaine
* eduy = nombre d'ann�es d'�tudes depuis le CP

* OBJECTIF DE L'EXERCICE: d�terminer une �quation de salaire (horaire) � partir de l'�ducation et de l'�ge.

// Question (a)-------------------------------------
/* Corr�lation (�ge, �ducation)
Le coefficient sur eduy change quand on contr�le pour l'�ge (il augmente). Le coefficient de la r�gression "naive", sans contr�le, est donc biais�, � la baisse (sous-estime les returns on education). 
--> le biais introduit par l'omission de l'�ge est n�gatif: comme le coef. sur l'�ge est positif, on en d�duit que cov(age, eduy)<0
Interpr�tation: l'�ge est n�gativement corr�l� � l'�ducation: augmentation constante du niveau moyen d'�ducation avec le temps.*/

/* Calcul de la corr�lation � partir des tables donn�es: rappel corr(eduy, age) = cov(eduy, age)/[sd(eduy)*sd(age)] 
Rappel formule du cours: Biais = Beta2 * Delta1 = Beta2 * cov(x1, x2) / var(x1) donc cov(x1, x2) = Biais * var(x1) / Beta2 */
dis (0.0528-0.0629)*2.69^2/(0.0145*2.69*8.51)
* -0.22 
corr(eduy age)
/*(obs=31237)

             |     eduy      age
-------------+------------------
        eduy |   1.0000
         age |  -0.2205   1.0000
*/

// Question (b)-------------------------------------
// R�gression du log du salaire horaire sur le nombre d'ann�es d'�tudes

* On calcule le log du salaire horaire
gen lnw=ln(12*salred/(52*hhc))

reg lnw eduy age

/*    Source |       SS       df       MS              Number of obs =   31237
-------------+------------------------------           F(  2, 31234) = 4299.80
       Model |  1085.56489     2  542.782447           Prob > F      =  0.0000
    Residual |  3942.80705 31234  .126234458           R-squared     =  0.2159
-------------+------------------------------           Adj R-squared =  0.2158
       Total |  5028.37194 31236  .160980021           Root MSE      =  .35529

------------------------------------------------------------------------------
         lnw |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        eduy |   .0629493   .0007651    82.27   0.000     .0614496    .0644489
         age |   .0145086   .0002423    59.87   0.000     .0140336    .0149836
       _cons |   .9515069   .0142606    66.72   0.000     .9235556    .9794582
------------------------------------------------------------------------------
*/
* Le mod�le pr�dit qu'� niveau d'�ducation constant, avoir un an de plus se traduit par une augmentation du salaire horaire de 1.5%. 

// Question (c)-------------------------------------
// Effet quadratique de l'�ge: objectif: rendre compte d'une relation non-monotone ex: croissante dans la premi�re phase de la vie professionnelle puis d�croissante

gen age2=age^2

reg lnw eduy age age2

/*      Source |       SS       df       MS              Number of obs =   31237
-------------+------------------------------           F(  3, 31233) = 2965.09
       Model |  1114.64492     3  371.548308           Prob > F      =  0.0000
    Residual |  3913.72702 31233  .125307432           R-squared     =  0.2217
-------------+------------------------------           Adj R-squared =  0.2216
       Total |  5028.37194 31236  .160980021           Root MSE      =  .35399

------------------------------------------------------------------------------
         lnw |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        eduy |   .0618749   .0007656    80.82   0.000     .0603744    .0633754
         age |   .0473089   .0021666    21.84   0.000     .0430622    .0515555
        age2 |  -.0004588   .0000301   -15.23   0.000    -.0005178   -.0003997
       _cons |   .4115976   .0381834    10.78   0.000     .3367567    .4864385
------------------------------------------------------------------------------
*/

/* Effet marginal = dy/dx = dlnw/dage = Beta2 + 2*Beta3*age
--> calculer un effet marginal n'a de sens que pour un individu r�f�rent! G�n�ralement, on construit un individu "moyen", qui a pour caract�ristiques les valeurs moyennes de l'�chantillon (ici, �ge moyen: 36 ans)
--> Stata: commande _b[var1]: conserve en m�moire le coefficient beta correspondant � la variable 1 dans la derni�re r�gression effectu�e */

* Calcul de l'effet marginal pour une personne �g�e de 20 ans
display _b[age] + 2*_b[age2]*20
*.02895878

* Pour une personne �g�e de 50 ans
display _b[age] + 2*_b[age2]*50
*.00143365

* A quel �ge l'effet devient n�gatif ? il faut calculer l'�ge tel que dy/dx = Beta2 + 2*Beta3*age =0
display -_b[age]/(2*_b[age2])
* 51.562552 --> Au-del� de 52 ans, plus une personne est �g�e, moins son salaire est �lev�, � niveau d'�ducation constant.  


// Question (d)-------------------------------------
// M�thode alternative ("partialling out"): construire une nouvelle variable qui ne capture que la part de l'�ducation non expliqu�e par l'�ge --> les r�sidus d'une r�gression OLS de edu sur age

reg eduy age age2

/*      Source |       SS       df       MS              Number of obs =   31237
-------------+------------------------------           F(  2, 31234) =  938.32
       Model |  12845.9019     2  6422.95093           Prob > F      =  0.0000
    Residual |  213800.707 31234  6.84512732           R-squared     =  0.0567
-------------+------------------------------           Adj R-squared =  0.0566
       Total |  226646.609 31236  7.25594214           Root MSE      =  2.6163

------------------------------------------------------------------------------
        eduy |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         age |   .1898534   .0159773    11.88   0.000     .1585372    .2211696
        age2 |  -.0036236   .0002216   -16.35   0.000     -.004058   -.0031892
       _cons |   10.22516   .2762183    37.02   0.000     9.683763    10.76656
------------------------------------------------------------------------------
*/

predict residedu, res
/* Stata: 	commande predict newvar cr�e une nouvelle variable �gale aux valeurs de y pr�dites par la derni�re regression
			commande predict newvar, res cr�e une nouvelle variable �gale aux valeurs des r�sidus pr�dites par la derni�re regression 
Nouvelle variable residedu ne capture que la part de l'�ducation non expliqu�e par l'�ge */

reg lnw residedu

/*      Source |       SS       df       MS              Number of obs =   31237
-------------+------------------------------           F(  1, 31235) = 6073.16
       Model |  818.536791     1  818.536791           Prob > F      =  0.0000
    Residual |  4209.83515 31235  .134779419           R-squared     =  0.1628
-------------+------------------------------           Adj R-squared =  0.1628
       Total |  5028.37194 31236  .160980021           Root MSE      =  .36712

------------------------------------------------------------------------------
         lnw |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    residedu |   .0618749    .000794    77.93   0.000     .0603187    .0634311
       _cons |   2.240249   .0020772  1078.50   0.000     2.236178    2.244321
------------------------------------------------------------------------------

--> c'est le m�me coefficient beta1 qu'en question c) mais bien entendu pas la m�me constante. Les 2 m�thodes sont �quivalentes mais la premi�re est plus facile � interpr�ter.
*/


// Question (e)-------------------------------------
// L'exp�rience potentielle: approch�e par sa borne sup�rieure: le nombre d'ann�es depuis que l'individu a quitt� l'�cole (hypoth�se (forte...): entr�e directe dans la vie professionnelle, pas d'interruption de carri�re)

gen pexp=age- eduy-6

reg  lnw eduy age pexp

/*      Source |       SS       df       MS              Number of obs =   31237
-------------+------------------------------           F(  2, 31234) = 4299.80
       Model |  1085.56489     2  542.782447           Prob > F      =  0.0000
    Residual |  3942.80705 31234  .126234458           R-squared     =  0.2159
-------------+------------------------------           Adj R-squared =  0.2158
       Total |  5028.37194 31236  .160980021           Root MSE      =  .35529

------------------------------------------------------------------------------
         lnw |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        eduy |   .0774579    .000852    90.91   0.000     .0757879    .0791278
         age |  (dropped)
        pexp |   .0145086   .0002423    59.87   0.000     .0140336    .0149836
       _cons |   1.038558   .0131857    78.76   0.000     1.012714    1.064403
------------------------------------------------------------------------------

--> Violation de l'hypoth�se de non-colin�arit� parfaite: pexp est une CL de age et eduy. Cons�quence: Stata �limine une variable (ici l'�ge). 
Interpr�tation math�matique: X'X est non-invertible donc on ne peut pas calculer Beta = (X'X)-1 X'Y
Interpr�tation intuitive: impossible de calculer l'effet d'une variable "toutes choses �gales par ailleurs" car on ne peut pas garder l'�ducation et l'exp�rience constantes, et faire varier l'�ge.
*/
