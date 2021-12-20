#!/bin/bash

echo -e "\e[1;33m==== COMPILATION DU PROGRAMME ====\e[0m"
make
echo -e "\e[1;33m==== FIN DE LA COMPILATION ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 1 (avec VTest1.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;32mVALIDE (SEULEMENT ESPACE + INSTRUCTIONS VIDES) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/good/VTest1.tpc
echo -e "\e[1;36m==== FIN DU TEST 1 ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 1Bis (avec VTest2.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;32mVALIDE (SEULEMENT TAB) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/good/VTest2.tpc
echo -e "\e[1;36m==== FIN DU TEST 1Bis ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 2 (avec VTest3.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;32mVALIDE (USAGE DES STRUCTURES + COMMENTAIRE IMBRIQUE) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/good/VTest3.tpc
echo -e "\e[1;36m==== FIN DU TEST 2 ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 3 (avec FTest1.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;31mINVALIDE (DECLARATION DE STRUCTURE DANS FONCTION) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/syn-err/FTest1.tpc
echo -e "\e[1;36m==== FIN DU TEST 3 ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 4 (avec FTest2.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;31mINVALIDE (ERREUR EN FIN DE LIGNE (OUBLI DU POINT VIRGULE) ) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/syn-err/FTest2.tpc
echo -e "\e[1;36m==== FIN DU TEST 4 ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 5 (avec FTest3.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;31mINVALIDE (ERREUR EN MILIEU DE LIGNE (VIRGULE MANQUANT) ) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/syn-err/FTest3.tpc
echo -e "\e[1;36m==== FIN DU TEST 5 ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 6 (avec FTest4.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;31mINVALIDE (ERREUR EN DEBUT DE LIGNE (OUBLI DE TYPE) ) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/syn-err/FTest4.tpc
echo -e "\e[1;36m==== FIN DU TEST 6 ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 7 (avec FTest5.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;31mINVALIDE (DECLARATION DE STRUCTURE SANS VARIABLE) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/syn-err/FTest5.tpc
echo -e "\e[1;36m==== FIN DU TEST 7 ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 8 (avec FTest6.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;31mINVALIDE (OPERATION MANQUANTE) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/syn-err/FTest6.tpc
echo -e "\e[1;36m==== FIN DU TEST 8 ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 9 (avec FTest7.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;31mINVALIDE (ERREUR DANS LE CORPS DE LA STRUCTURE) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/syn-err/FTest7.tpc
echo -e "\e[1;36m==== FIN DU TEST 9 ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 10 (avec SemTest1.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;33mERREUR SEMANTIQUE (VARIABLE OU FONCTION NON DECLARE) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/sem-err/SemTest1.tpc
echo -e "\e[1;36m==== FIN DU TEST 10 ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 11 (avec SemTest2.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;33mERREUR SEMANTIQUE (REDECLARATION DE VARIABLE) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/sem-err/SemTest2.tpc
echo -e "\e[1;36m==== FIN DU TEST 11 ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 12 (avec SemTest3.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;33mERREUR SEMANTIQUE (PAS D'OPERATION SUR STRUCTURE) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/sem-err/SemTest3.tpc
echo -e "\e[1;36m==== FIN DU TEST 12 ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 13 (avec SemTest4.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;33mERREUR SEMANTIQUE (TROP OU PEU D'ARGUMENTS DANS L'APPEL DE FONCTION) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/sem-err/SemTest4.tpc
echo -e "\e[1;36m==== FIN DU TEST 13 ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 14 (avec WarnTest1.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;35mWARNING (CONFLIT DE TYPE + MAUVAIS TYPE D'ARGUMENT POUR READE/READC) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/warn/WarnTest1.tpc
echo -e "\e[1;36m==== FIN DU TEST 14 ====\e[0m"
echo " "

echo -e "\e[1;36m==== TEST 15 (avec WarnTest2.tpc) ====\e[0m"
echo -e "\e[1;34m==== RESULTAT ATTENDU : \e[1;35mWARNING (MAUVAISE VALEUR DE RETOUR) \e[1;34m====\e[0m"
../bin/tpcc -t -s ../test/warn/WarnTest2.tpc
echo -e "\e[1;36m==== FIN DU TEST 15 ====\e[0m"
echo " "


