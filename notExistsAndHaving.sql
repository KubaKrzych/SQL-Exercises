/*
Z4 Kuba, Krzychowiec, 319058, Gr 2

Z4.1 - poazaæ osoby z województwa o odzie X, które nigdy
nie pracowa³y / nie pracuja tez obecnie w firmie z woj o tym samym kodzie (lub innym - jakie dane lepsze)

czyli jezeli jaikolwiek etat spe³niaj¹cy warunek powy¿ej to osoby nie pokazujemy

Czyli jak Osoba MS mieszka w woj o kodzie X a pracuje w firmie z woj X
a drugi etat w firmie z woj Y
to takiej osoby NIE POKOZUJEMY !!!
A nie, ¿e poka¿emy jeden etat a drugi nie

Z4.2 - pkoazaæ liczbê mieszkañców w województwach ale tylko w tych maj¹cych wiecej jak jednego mieszkañca

Z4,3 - pokazaæ sredni¹ pensjê w miastach ale tylko tych posiadaj¹cych wiêcej ja jednego mieszkañca

*/

/* ----- Z4.1 ----- */
SELECT * FROM OSOBY o 
	JOIN MIASTA m ON m.id_miasta=o.id_miasta 
	JOIN WOJ w on w.kod_woj=m.kod_woj 
	WHERE NOT EXISTS (SELECT * FROM ETATY eW 
		JOIN FIRMY fW on eW.id_firmy=fW.nazwa_skr
		JOIN MIASTA mW on mW.id_miasta=fW.id_miasta
		JOIN WOJ wW on wW.kod_woj=mW.kod_woj AND wW.kod_woj=w.kod_woj
		WHERE eW.id_osoby=o.id_osoby)

/* Wynik 
id_osoby    imie                                     nazwisko                                                     id_miasta   NIP osoby            IN                     id_miasta   nazwa                kod_woj kod_woj nazwa
----------- ---------------------------------------- ------------------------------------------------------------ ----------- -------------------- ---------------------- ----------- -------------------- ------- ------- --------------------
1           Marcin                                   Przybylski                                                   3           NULL                 M/Przybylski           3           Warszawa             MAZ     MAZ     Mazowieckie
2           Kuba                                     Krzychowiec                                                  1           NULL                 K/Krzychowiec          1           Gdañsk               POM     POM     Pomorskie
3           Jan                                      Kowalski                                                     1           NULL                 J/Kowalski             1           Gdañsk               POM     POM     Pomorskie
4           Oskar                                    Janicki                                                      2           NULL                 O/Janicki              2           Gdynia               POM     POM     Pomorskie
5           Remigiusz                                Orzeszkowski                                                 2           NULL                 R/Orzeszkowski         2           Gdynia               POM     POM     Pomorskie
6           Julia                                    Kominkowa                                                    4           NULL                 J/Kominkowa            4           Pruszków             MAZ     MAZ     Mazowieckie
7           Sylwia                                   Stó³                                                         4           NULL                 S/Stó³                 4           Pruszków             MAZ     MAZ     Mazowieckie
10          Paulina                                  Poczta                                                       6           NULL                 P/Poczta               6           £ódŸ                 LODZ    LODZ    £ódzkie
11          Klaudia                                  Sobota                                                       6           NULL                 K/Sobota               6           £ódŸ                 LODZ    LODZ    £ódzkie
12          Jan                                      Abacki                                                       7           NULL                 J/Abacki               7           Pabianice            LODZ    LODZ    £ódzkie
13          Anna                                     Orzeszkowa                                                   8           NULL                 A/Orzeszkowa           8           Olsztyn              WMAZ    WMAZ    Warmiñsko_mazurskie

*/

/* Uzasadnienie */
SELECT * FROM OSOBY o 
	JOIN MIASTA m ON m.id_miasta=o.id_miasta 
	JOIN WOJ w on w.kod_woj=m.kod_woj 
	WHERE EXISTS (SELECT * FROM ETATY eW 
		JOIN FIRMY fW on eW.id_firmy=fW.nazwa_skr
		JOIN MIASTA mW on mW.id_miasta=fW.id_miasta
		JOIN WOJ wW on wW.kod_woj=mW.kod_woj AND wW.kod_woj=w.kod_woj
		WHERE eW.id_osoby=o.id_osoby)

/* Suma wyników obu zapytañ daje nam wszystkie osoby, co jak najbardziej ma sens, bo w pierwszym zapytaniu, bierzemy osoby, które nie pracuj¹ / nie pracowa³y w tym samym
** województwie, w którym mieszkaj¹, a w drugim zapytaniu bierzemy osoby, które mia³y przyjemnoœæ pracowaæ w tym samym województwie co zamieszkiwa³y. */



/* ----- Z4.2 ----- */
SELECT w.kod_woj ,w.nazwa, COUNT(o.id_miasta) as [Liczba mieszkancow] 
	FROM WOJ w 
	JOIN MIASTA m on m.kod_woj=w.kod_woj 
	JOIN OSOBY o on o.id_miasta=m.id_miasta 
	GROUP BY w.kod_woj, w.nazwa HAVING COUNT(DISTINCT o.id_osoby) > 1

/* Wynik
kod_woj nazwa                Liczba mieszkancow
------- -------------------- ------------------
LODZ    £ódzkie              3
MAZ     Mazowieckie          5
POM     Pomorskie            4
WMAZ    Warmiñsko_mazurskie  2
*/

/* Uzasadnienie 
Po wyniku ponizszych zapytañ, mo¿na zauwa¿yæ, ¿e niektóre województwa nie zosta³y w ogóle wziête pod uwagê, bo nie zawieraj¹ ¿adnego mieszkañca, lub
zawieraj¹ tylko jednego mieszkañca. */
SELECT * FROM WOJ
SELECT * FROM OSOBY o JOIN MIASTA m on m.id_miasta=o.id_miasta JOIN WOJ w ON w.kod_woj=m.kod_woj ORDER BY w.kod_woj



/* ----- Z4.3 ----- */
/* Wariant "srednia z osob mieszkajacych", czyli œrednia pensji w miastach, w których mieszka wiêcej ni¿ jeden pracownik. Tutaj uzasadnienia mo¿e wymagaæ polecenie HAVING. W tym¿e poleceniu liczê id_osób, bo jeœli DLA DANEGO MIASTA, policzê wiêcej ni¿ jedn¹ osobê,
** to znaczy, ¿e mieszka w nim wiêcej ni¿ jedna osoba.*/
SELECT m.nazwa, AVG(t.pensja) as [Srednia pensja] FROM MIASTA m 
	JOIN OSOBY o on o.id_miasta=m.id_miasta 
	JOIN (SELECT mW.id_miasta, eW.pensja FROM ETATY eW 
		JOIN FIRMY fW ON eW.id_firmy=fw.nazwa_skr 
		JOIN MIASTA mW on mW.id_miasta=fW.id_miasta
		WHERE eW.do IS NULL) t on t.id_miasta=m.id_miasta 
	GROUP BY m.nazwa
	HAVING COUNT(DISTINCT o.id_osoby) > 1

/* Wynik
nazwa                Srednia pensja
-------------------- ---------------------
Gdañsk               3500,00
Pruszków             6000,00
*/

/* Uzasadnienie */
/* Dobrym uzasadnieniem wydaje siê byæ same wewnêtrzne zapytanie, gdzie mo¿emy podejrzeæ, w których miastach osoby maj¹ aktualnie etat i to za jak¹ pensje. Widzimy, ¿e dla miast o id={3, 4} jest dwóch mieszkañców o aktualnych etatach. */
SELECT mW.id_miasta, eW.pensja FROM ETATY eW 
		JOIN FIRMY fW ON eW.id_firmy=fw.nazwa_skr 
		JOIN MIASTA mW on mW.id_miasta=fW.id_miasta
		WHERE eW.do IS NULL


/* Wariant 2 */
/* Srednia z firm w miastach, czyli œrednia pensja w firmach, które siê znajduj¹ w miastach, w którym mieszka wiêcej ni¿ jedna osoba. */
SELECT CONVERT(nvarchar(6),f.nazwa) AS [Nazwa miasta], AVG(e.pensja) as [Srednia pensja] FROM ETATY e 
	JOIN FIRMY f ON f.nazwa_skr=e.id_firmy 
	JOIN (SELECT mW.id_miasta, mW.nazwa, COUNT(oW.id_osoby) as [Liczba osob] FROM OSOBY oW 
		JOIN MIASTA mW on mW.id_miasta=oW.id_miasta 
		GROUP BY mW.id_miasta, mW.nazwa 
		HAVING COUNT(ow.id_osoby) > 1) t on t.id_miasta=f.id_miasta
	WHERE e.do IS NULL
	GROUP BY f.nazwa

/* Wynik
Nazwa miasta Srednia pensja
------------ ---------------------
DELL         6000,00
X-KOM        3500,00
*/
	
/* Uzasadnienie */
IF OBJECT_ID(N'tempdb..#tt') IS NOT NULL
	DROP TABLE #tt
/* W poni¿szych miastach jest wiêcej ni¿ dwóch mieszkañców */
SELECT m.id_miasta, m.nazwa, COUNT(o.id_osoby) as [Liczba oosb] INTO #tt FROM OSOBY o JOIN MIASTA m ON m.id_miasta=o.id_miasta  GROUP BY m.nazwa, m.id_miasta HAVING COUNT(o.id_osoby) > 1
/* To s¹ firmy, w ktorych miastach mieszka wiêcej ni¿ dwóch mieszkañców (mieszkaniec miasta to osoba, która mieszka w tym mieœcie) */
SELECT #tt.nazwa, f.nazwa FROM FIRMY f JOIN #tt on #tt.id_miasta=f.id_miasta GROUP BY #tt.nazwa, f.nazwa
