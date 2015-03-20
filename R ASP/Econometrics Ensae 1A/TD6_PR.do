//--------------------------//
// TD6 - HETEROSCEDASTICITY //
//--------------------------//

use http://fmwww.bc.edu/ec-p/data/wooldridge/crime1

* Champs : 2 725 hommes californiens n�s en 1960 ou 1961 qui ont �t� arr�t�s au moins une fois avant 1986

* narr86 = nombre d'arrestations en 1986
* nfarr86 = nombre d'arrestations pour crime
* nparr86 = nombre d'arrestations pour vol
* pcnv = proportion de condamnations (vs. acquittement) dans l'histoire des arrestations pr�c�dentes
* avgsen = dur�e moyenne des peines, en mois
* tottime = temps pass� en prison depuis l'�ge de 18 ans, en mois
* ptime86 = nombre de mois pass�s en prison en 1986
* qemp86 = nombre de trimestres en emploi en 1986
* inc86 = revenux l�gaux en 1986, en $100s
* durat = dur�e de ch�mage r�cent
* black = 1 if black
* hispan = 1 if Hispanic
* born60 = 1 if born in 1960
* pcnvsq = pcnv^2
* pt86sq = ptime86^2
* inc86sq = inc86^2

* Obj: identifier les d�terminants d'une nouvelle arrestation en 1986

// Question (a)-------------------------------------
// Mod�le de probabilit� lin�aire de la proba d'�tre arr�t� en 1986 en fonction des condamnations et dur�es d'emplois pass�es

* Calcul de la dummy d'arrestation
gen arr86 =  narr86>0
su arr86
/*    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
       arr86 |      2725    .2770642    .4476306          0          1
*/
* Un peu plus du quart de l'�chantillon a �t� arr�t� au moins 1 fois en 1986

// Syntaxe alternative pour cr�er une dummy
capture drop arr86
gen arr86 = cond(narr86>0, 1, 0)

reg  arr86  pcnv  avgsen  tottime  ptime86  qemp86, robust
* on ajoute l'option 'robust' car le mod�le est h�t�rosc�dastique : Var(y|x) = p(x)(1 - p(x)) avec p(x)= Pr(y=1|x) (cf cours slide 6)
* l'option 'robust' calcule la matrice de variance robuste de White (id�e: remplacer chaque sigma i par le r�sidu estim�: ui chapeau)

/*  
Linear regression                                      Number of obs =    2725
                                                       F(  5,  2719) =   34.19
                                                       Prob > F      =  0.0000
                                                       R-squared     =  0.0474
                                                       Root MSE      =  .43731

------------------------------------------------------------------------------
             |               Robust
       arr86 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        pcnv |  -.1624448   .0192047    -8.46   0.000    -.2001021   -.1247875
      avgsen |   .0061127    .005952     1.03   0.305    -.0055581    .0177836
     tottime |  -.0022616   .0043913    -0.52   0.607    -.0108723    .0063491
     ptime86 |  -.0219664   .0028847    -7.61   0.000    -.0276229   -.0163099
      qemp86 |  -.0428294   .0054627    -7.84   0.000    -.0535408    -.032118
       _cons |   .4406154   .0185348    23.77   0.000     .4042716    .4769592
------------------------------------------------------------------------------
*/



// Question (b)-------------------------------------
/* Interpr�tation

La constante: un individu qui n'a jamais �t� condamn�, n'a jamais �t� emprisonn�, et est sans emploi en 1986 a une probabilit� de 44% de se faire arr�ter en 1986
--> attention: �chantillon s�lectionn�: au moins une arrestation avant 1986.
--> hypoth�se forte de validit� externe si l'on veut appliquer cette pr�diction � l'ensemble de la population.

Le coefficient sur pcnv: toutes choses �gales par ailleurs, un individu qui a toujours �t� condamn� lors des arrestations pr�c�dentes (pcnv=1) a une probabilit� inf�rieure de 16.2% 
d'�tre arr�t� au moins une fois en 1986 compar� � un individu qui a toujours �t� relax� (pcnv=0). 
La magnitude de l'effet n'est pas si grande qu'une lecture rapide du coefficient pourrait le laisser penser car il faut se souvenir que pcnv est compris entre 0 et 1.
Pourquoi un signe n�gatif? Une explication possible: les individus toujours condamn�s sont plus probablement d�j� en prison en 1986 (et donc ne peuvent pas �tre r�arr�t�s cette ann�e-l�).

Le coefficient sur ptime86: passer un mois suppl�mentaire en prison en 1986 diminue de 2.2 points de base la probabilit� d'�tre arr�t� en 1986. 
Passer 12 mois en prison devrait ramener la probabilit� d'�tre arr�t� � 0 (d�j� en prison): si l'on consid�re la probabilit� inconditionnelle d'�tre arr�t� (=27.7%),
on a bien 0.277 - 0.022*12 = 0.013, tr�s proche de 0.
*/



// Question (c)-------------------------------------
// Test de significativit� jointe de avgsen et tottime (pas besoin de pr�ciser l'option 'robust', stata l'a gard�e en m�moire depuis la r�gression pr�c�dente)

test avgsen  tottime

/*
 ( 1)  avgsen = 0
 ( 2)  tottime = 0

       F(  2,  2719) =    1.02
            Prob > F =    0.3618

On ne peut pas rejeter H0 � 5%. La dur�e moyenne des peines et le temps pass� en prison depuis l'�ge de 18 ans n'ont pas d'impact conjoint significatif sur la probabilit� d'�tre arr�t� */




// Question (d)-------------------------------------
// Probabilit�s estim�es d'�tre arr�t�

predict p  // commande predict VAR cr�e une nouvelle variale VAR �gale � y chapeau (de la derni�re r�gression en m�moire, comme toujours)
su p

/*  Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
           p |      2725    .2770642    .0974062   .0066431   .5576897

p est bien compris entre 0 et 1: min proche de 0, max environ 1/2. La moyenne est bien �gale � la moyenne empirique: 27.7%	   
		   */

		   
		   
		   
		   
		   
		   

// Question (e)-------------------------------------
// Moindres carr�s pond�r�s

* On conna�t la variance de u: Var(u|x) = p(x)(1 - p(x)) avec p(x) = Pr(y =1|x)
* Pour chaque individu, on calcule Var(ui|xi) = p(xi)(1 - p(xi)) avec p(xi) = Pr(y =1|xi)= pi (valeur pr�dite que l'on vient de calculer)
gen weight=1/(p*(1-p))  

* On pond�re toutes les variables par l'inverse de la racine carr�e de la variance pour transformer le mod�le 
foreach v of varlist arr86  pcnv  avgsen  tottime  ptime86  qemp86  {

gen ww`v' = `v' * sqrt(weight) // cr�er les variables du mod�le transform�
}

gen ww0 = sqrt(weight) // cr�er la variable correspondant � beta0

reg ww*, nocons // option "nocons" = pas de constante

/*      Source |       SS       df       MS              Number of obs =    2725
-------------+------------------------------           F(  6,  2719) =  188.31
       Model |  1109.44323     6  184.907205           Prob > F      =  0.0000
    Residual |  2669.84459  2719  .981921511           R-squared     =  0.2936
-------------+------------------------------           Adj R-squared =  0.2920
       Total |  3779.28782  2725  1.38689461           Root MSE      =  .99092

------------------------------------------------------------------------------
     wwarr86 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      wwpcnv |  -.1678436   .0189122    -8.87   0.000    -.2049272   -.1307599
    wwavgsen |   .0053665   .0051146     1.05   0.294    -.0046624    .0153954
   wwtottime |  -.0017615   .0032514    -0.54   0.588     -.008137     .004614
   wwptime86 |  -.0246188   .0030451    -8.08   0.000    -.0305898   -.0186479
    wwqemp86 |  -.0451885   .0054225    -8.33   0.000    -.0558212   -.0345558
         ww0 |   .4475965   .0179922    24.88   0.000     .4123167    .4828763
------------------------------------------------------------------------------
*/ 

* M�thode alternative: option aweights, or analytic weights: [aw=inverse de la variance de l'erreur pour l'individu i]
* La m�thode permet de pond�rer directement toutes les variables (y compris la constante) par la racine carr�e de la valeur indiqu�e dans l'option.

reg  arr86  pcnv  avgsen  tottime  ptime86  qemp86 [aw=weight]


/*    Source |       SS       df       MS              Number of obs =    2725
-------------+------------------------------           F(  5,  2719) =   43.70
       Model |  36.6318177     5  7.32636354           Prob > F      =  0.0000
    Residual |  455.826896  2719  .167645052           R-squared     =  0.0744
-------------+------------------------------           Adj R-squared =  0.0727
       Total |  492.458713  2724  .180785137           Root MSE      =  .40944

------------------------------------------------------------------------------
       arr86 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        pcnv |  -.1678436   .0189122    -8.87   0.000    -.2049272   -.1307599
      avgsen |   .0053665   .0051146     1.05   0.294    -.0046624    .0153954
     tottime |  -.0017615   .0032514    -0.54   0.588     -.008137     .004614
     ptime86 |  -.0246188   .0030451    -8.08   0.000    -.0305898   -.0186479
      qemp86 |  -.0451885   .0054225    -8.33   0.000    -.0558212   -.0345558
       _cons |   .4475965   .0179922    24.88   0.000     .4123167    .4828763
------------------------------------------------------------------------------
*/
* R�sultats tout � fait similaires � la r�gression OLS avec des �carts-types robustes (question a).
