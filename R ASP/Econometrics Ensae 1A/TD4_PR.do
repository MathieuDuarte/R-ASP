//--------------------------------//
// TD4 - PROPRIETES ASYMPTOTIQUES //
//--------------------------------//


// EXERCICE 2 //-------------------------------------------------------------------------------------------------


// Question (a)-------------------------------------
// Question pr�liminaire pour se familiariser avec les commandes: cr�ation des variables x1 et u pour 1000 observations

set obs 1000 
* cr�e une table de 1000 lignes

gen x1=uniform()
* [0,1] par d�faut - Stata cr�e une variable x1 et attribue � chacune des 1000 observations une valeur comprise entre 0 et 1 selon une loi uniforme
su x1

gen u=rchi2(1) - 1
* Stata cr�e une variable u et attribue � chacune des 1000 observations une valeur selon une loi du chi2 de param�tre 1, et lui enl�ve 1
su u
* Check: zero-mean
corr(x1 u)
* Check: zero-covariance

histogram x1

histogram u

histogram x1, normal
* trace l'histogramme de x1 et la densit� d'une normale par desssus

histogram u, normal

// Question (b)-------------------------------------
// Simulation Monte-Carlo: objectif: tester les propri�t�s de la moyenne empirique, comme estimateur de la moyenne dans la population; hypoth�se: beta0=beta1=beta2=0 (donc y = u)
* Premier essai: nb obs dans l'�chantillon: 5; nb r�plications: 10 000

* Etape 1: stata cr�e une variable y et attribue � 5 observations une valeur selon nos hypoth�ses (ici: y = u)

drop _all
set obs 5
gen y=rchi2(1)-1
sum y

* Etape 2: si l'on efface et r�p�te l'op�ration, la moyenne des y sur les 5 observations change. 
drop _all
set obs 5
gen y=rchi2(1)-1
sum y

* Etape 3: r�p�ter l'op�ration 10 000 fois et cr�er une variable ymean �gale � la moyenne obtenue � chaque op�ration 
program define mysim, rclass  // option rclass permet d'extraire des statistiques sur les variables construites ex: r(mean)
drop _all
set obs 5
gen y=rchi2(1)-1
sum y
return scalar mean=r(mean)
end

simulate ymean=r(mean), reps(10000): mysim   // � chaque it�ration i, stata stocke la moyenne des y obtenue dans ymean_i --> � la fin, 10 000 observations pour ymean

browse

su ymean

// Question (c)-------------------------------------
// M�me chose avec des �chantillons de tailles diff�rentes: 10, 100 et 1000 observations (nb r�plications constant � 10 000) 

// de taille n=10

program define mysim10, rclass
drop _all
set obs 10
gen y=rchi2(1)-1
sum y
return scalar mean=r(mean)
end

simulate ymean=r(mean), reps(10000): mysim10
summarize ymean

/* 
    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
       ymean |     10000    .0030032    .4448839  -.9010138   2.516836
*/
* Attention, le tableau ci-dessus n'est qu'un exemple: personne n'obtiendra 2 fois la m�me variable ymean: elle d�pend des 10,000 �chantillons qui ont �t� tir�s, � chaque fois, al�atoirement.


// de taille n=100

program define mysim100, rclass
drop _all
set obs 100
gen y=rchi2(1)-1
sum y
return scalar mean=r(mean)
end

simulate ymean=r(mean), reps(10000): mysim100
summarize ymean

/*
    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
       ymean |     10000    .0005834    .1410371  -.4814137   .6653621
*/


// de taille n=1000

program define mysim1000, rclass
drop _all
set obs 1000
gen y=rchi2(1)-1
sum y
return scalar mean=r(mean)
end

simulate ymean=r(mean), reps(10000): mysim1000
summarize ymean

/*
    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
       ymean |     10000   -.0004671    .0448102  -.1706862   .1738213
*/

* La moyenne des moyennes empiriques E(ymean) est de plus en plus proche de 0 � mesure que N augmente, et son �cart-type sd(ymean) de plus en plus petit 
* --> la distribution de ymean se resserre autour d'un point (loi des grands nombres)

// Question (d)-------------------------------------
// La vitesse de convergence de la moyenne empirique

di 0.4449*sqrt(10)/sqrt(100)
* on obtient l'�cart-type obtenu pour n=100
di 0.4449*sqrt(10)/sqrt(1000)
* on obtient l'�cart-type obtenu pour n=1000

/* La vitesse de convergence est proportionnelle � l'inverse de la racine carr�e de la taille de l'�chantillon
Si l'on prend comme point de r�f�rence n=10 et sd_10=0.4449, et que l'on augmente la taille de l'�chantillon � n' observations,on aura sd'=sd_10*sqrt(10)/sqrt(n')
On cherche donc n'=(sd_10*sqrt(10)/0.001)^2 */
di (0.4449*sqrt(10)/0.001)^2
* environ 2 millions d'observations sont n�cessaires (r�pliqu�es 10 000 fois!) pour obtenir un �cart-type de 0.001.

// Question (e)-------------------------------------
// Histogramme

// pour n=10
capture simulate ymean=r(mean), reps(10000): mysim10
hist ymean, normal

// pour n=100
capture simulate ymean=r(mean), reps(10000): mysim100
hist ymean, normal

// pour n=1000
capture simulate ymean=r(mean), reps(10000): mysim1000
hist ymean, normal

* La distribution de l'estimateur ymean se rapproche de plus en plus d'une loi normale centr�e r�duite � mesure que N augmente (th�or�me central limite)



// Question (f)-------------------------------------
// Simulation Monte-Carlo: objectif: tester les estimateurs MCO des coefficients et de leurs �carts-types; hypoth�se: beta0=1; beta1=2; beta2=10 (donc y =1+2*x1+10*x2+u)
// m�me nombre de r�plications: 10 000

// pour n=10

program define mysim2, rclass
drop _all
set obs 10
gen x1=runiform()
gen x2=rbinomial(1, 0.3)
gen y=1 + 2*x1 + 10*x2 + (rchi2(1) - 1)
reg y x1 x2  // r�gression MCO
return scalar b0=_b[_cons]  // on stocke les statistiques des estimateurs qui nous int�ressent: la valeur du coefficient et son �cart-type
return scalar b1=_b[x1]
return scalar b2=_b[x2]
return scalar se0=_se[_cons]
return scalar se1=_se[x1]
return scalar se2=_se[x2]
end

capture simulate b0=r(b0) b1=r(b1) b2=r(b2) se0=r(se0) se1=r(se1) se2=r(se2), reps(10000) : mysim2

// pour n=1000

program define mysim21000, rclass
drop _all
set obs 1000
gen x1=runiform()
gen x2=rbinomial(1, 0.3)
gen y=1 + 2*x1 + 10*x2 + (rchi2(1) - 1)
reg y x1 x2
return scalar b0=_b[_cons]
return scalar b1=_b[x1]
return scalar b2=_b[x2]
return scalar se0=_se[_cons]
return scalar se1=_se[x1]
return scalar se2=_se[x2]
end


// Question (g)-------------------------------------
// Convergence des estimateurs MCO 

* Comparaison des moyennes et �carts-types des estimateurs des coeffcients quand n=10 et n=1000
capture simulate b0=r(b0) b1=r(b1) b2=r(b2), reps(10000) : mysim2
su b0 b1 b2 
/*    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
          b0 |     10000    1.001857    1.129081  -6.187531   12.62099
          b1 |     10000    1.998392    1.903847  -13.80215   23.95813
          b2 |     10000    9.706349    2.063246          0   23.41768
*/

capture simulate b0=r(b0) b1=r(b1) b2=r(b2), reps(10000) : mysim21000
su b0 b1 b2 
/*    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
          b0 |     10000    1.001936    .0936518   .5923231   1.417774
          b1 |     10000    1.998434    .1549956   1.384937   2.573035
          b2 |     10000    9.997804    .0974264    9.63007   10.50118
*/
* Valeurs estim�es plus proches du "vrai" param�tre dans la population (�carts-types plus petits).

* Comparaison des distributions des estimateurs des coefficients
capture simulate b0=r(b0) b1=r(b1) b2=r(b2), reps(10000) : mysim2
hist b0, normal
hist b1, normal
hist b2, normal

capture simulate b0=r(b0) b1=r(b1) b2=r(b2), reps(10000) : mysim21000
hist b0, normal
hist b1, normal
hist b2, normal

* Les estimateurs des �carts-types sont-ils convergents? 
* Esp�rance: Moyenne des estimateurs des �carts-types = �carts-types des estimateurs des coefficients quand N est grand? OUI
* Variance: Ecarts-types (des estimateurs des �carts-types) diminuent quand N est grand? OUI
capture simulate se0=r(se0) se1=r(se1) se2=r(se2), reps(10000) : mysim2
su se0 se1 se2
/*    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
         se0 |     10000    .9392506    .5911678   .0331861   5.956776		// On compare 0.94 � 1.13
         se1 |     10000    1.600175    .9845822    .055496   10.06372		// On compare 1.60 � 1.90
         se2 |     10000    .9544125    .6113503          0   7.344592		// On compare 0.95 � 2.06
*/

capture simulate se0=r(se0) se1=r(se1) se2=r(se2), reps(10000) : mysim21000
su se0 se1 se2
/*    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
         se0 |     10000    .0940288    .0057854   .0744345   .1183672		// On compare 0.0940 � 0.0937
         se1 |     10000    .1548322    .0093604   .1231831   .1921677		// On compare 0.1548 � 0.1550
         se2 |     10000    .0975255    .0058475    .078394   .1206568		// On compare 0.0975 � 0.0974
*/

// Question (h)-------------------------------------
//  Simulation Monte-Carlo: objectif: tester la distribution de la F-stat g�n�r�e par le test de H0: beta0 = 1 et beta1 = 2 ; m�me hypoth�se: beta0=1; beta1=2; beta2=10 (donc y =1+2*x1+10*x2+u)
// m�me nombre de r�plications: 10 000 

program define mysim3, rclass
drop _all
set obs 10
gen x1=runiform()
gen x2=rbinomial(1,0.3)
gen y=1 + 2*x1 + 10*x2 + (rchi2(1)-1)
reg y x1 x2 // r�gression MCO
test (_cons=1) (x1=2) // F-test beta0 = 1 et beta1 = 2: ce sont les vraies valeurs des param�tres donc on ne devrait pas rejeter H0.
return scalar F=r(F) // on stocke les valeurs des statistiques qui nous int�ressent: la F-stat
end

capture simulate F=r(F), reps(10000) : mysim3

browse
* On obtient bien 10 000 valeurs diff�rentes pour la F-stat (une � chaque r�plication)

sum F

count if F>2.1
* 2573: On compte le nombre de r�plications o� la stat de test simul�e est sup�rieure � 2.1 - Attention, ce chiffre sera diff�rent � chaque simulation. 
* en proportion: 2573/10000=0.26

di Ftail(2, 7, 2.1)
* 0.19
/* Sous l'hypoth�se de normalit� des r�sidus, l'estimateur de la F-stat suit une loi de Fischer de param�tres q=2 (nombre de restrictions), n-k-1=7 (degr�s de libert�)
On calcule la probabilit� d'obsever 2.1 ou plus pour une variable suivant une telle loi: 0.19 � comparer � 0.26
Ici, les r�sidus ne suivent pas une loi normale, mais une loi du chi2 --> quand n est petit (=10), l'estimateur de la F-stat ne suit pas exactement une loi de Fischer.*/

count if F>6.1
* 799; en proportion: 0.08 --> en utilisant la distribution simul�e des estimateurs de F (proche de la distribution r�elle de F), on observe F>6.1 dans 8% des cas
* donc on ne rejette pas H0 au seuil de 5% si on observe F>6.1. 

di Ftail(2, 7, 6.1)
* 0.03: en faisant l'hypoth�se (fausse) que les r�sidus sont gaussiens et que la F-stat suit une loi de Fischer, on rejetterait H0 � 5% si on observait F>6.1, ce qui serait une erreur �tant donn�s les param�tres dans la population.

// Question (i)-------------------------------------
// Idem en asymptotique : n=1000

program define mysim31000, rclass
drop _all
set obs 1000
gen x1=runiform()
gen x2=rbinomial(1,0.3)
gen y=1 + 2*x1 + 10*x2 + (rchi2(1)-1)
reg y x1 x2
test (_cons=1) (x1=2)
return scalar F=r(F)
end

capture simulate F=r(F), reps(10000) : mysim31000

count if F>2.1
* proportion: 0.124
di Ftail(2, 997, 2.1)
*0.123

count if F>6.1
*proportion: 0.003
di Ftail(2, 997, 6.1)
*0.002
* les p-values simul�es (proches de la distribution r�elle) se rapprochent des valeurs th�oriques d'une loi de Fischer: les risques d'erreur sont moins �lev�es 
* ici, on ne rejette pas H0 si on observe 2.1 et on rejette si on observe 6.1, ce qui est coh�rent avec les simulations. 

* Conclusion: l'approximation par une loi de Fischer n'est valable que (i) si l'on a de bons arguments pour justifier que les r�sidus sont gaussiens (rare...); ou (ii) si n est grand.
