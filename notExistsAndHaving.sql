/*
Z4 Kuba, Krzychowiec, 319058, Gr 2

Z4.1 - poaza� osoby z wojew�dztwa o odzie X, kt�re nigdy
nie pracowa�y / nie pracuja tez obecnie w firmie z woj o tym samym kodzie (lub innym - jakie dane lepsze)

czyli jezeli jaikolwiek etat spe�niaj�cy warunek powy�ej to osoby nie pokazujemy

Czyli jak Osoba MS mieszka w woj o kodzie X a pracuje w firmie z woj X
a drugi etat w firmie z woj Y
to takiej osoby NIE POKOZUJEMY !!!
A nie, �e poka�emy jeden etat a drugi nie

Z4.2 - pkoaza� liczb� mieszka�c�w w wojew�dztwach ale tylko w tych maj�cych wiecej jak jednego mieszka�ca

Z4,3 - pokaza� sredni� pensj� w miastach ale tylko tych posiadaj�cych wi�cej ja jednego mieszka�ca

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
2           Kuba                                     Krzychowiec                                                  1           NULL                 K/Krzychowiec          1           Gda�sk               POM     POM     Pomorskie
3           Jan                                      Kowalski                                                     1           NULL                 J/Kowalski             1           Gda�sk               POM     POM     Pomorskie
4           Oskar                                    Janicki                                                      2           NULL                 O/Janicki              2           Gdynia               POM     POM     Pomorskie
5           Remigiusz                                Orzeszkowski                                                 2           NULL                 R/Orzeszkowski         2           Gdynia               POM     POM     Pomorskie
6           Julia                                    Kominkowa                                                    4           NULL                 J/Kominkowa            4           Pruszk�w             MAZ     MAZ     Mazowieckie
7           Sylwia                                   St�                                                         4           NULL                 S/St�                 4           Pruszk�w             MAZ     MAZ     Mazowieckie
10          Paulina                                  Poczta                                                       6           NULL                 P/Poczta               6           ��d�                 LODZ    LODZ    ��dzkie
11          Klaudia                                  Sobota                                                       6           NULL                 K/Sobota               6           ��d�                 LODZ    LODZ    ��dzkie
12          Jan                                      Abacki                                                       7           NULL                 J/Abacki               7           Pabianice            LODZ    LODZ    ��dzkie
13          Anna                                     Orzeszkowa                                                   8           NULL                 A/Orzeszkowa           8           Olsztyn              WMAZ    WMAZ    Warmi�sko_mazurskie

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

/* Suma wynik�w obu zapyta� daje nam wszystkie osoby, co jak najbardziej ma sens, bo w pierwszym zapytaniu, bierzemy osoby, kt�re nie pracuj� / nie pracowa�y w tym samym
** wojew�dztwie, w kt�rym mieszkaj�, a w drugim zapytaniu bierzemy osoby, kt�re mia�y przyjemno�� pracowa� w tym samym wojew�dztwie co zamieszkiwa�y. */



/* ----- Z4.2 ----- */
SELECT w.kod_woj ,w.nazwa, COUNT(o.id_miasta) as [Liczba mieszkancow] 
	FROM WOJ w 
	JOIN MIASTA m on m.kod_woj=w.kod_woj 
	JOIN OSOBY o on o.id_miasta=m.id_miasta 
	GROUP BY w.kod_woj, w.nazwa HAVING COUNT(DISTINCT o.id_osoby) > 1

/* Wynik
kod_woj nazwa                Liczba mieszkancow
------- -------------------- ------------------
LODZ    ��dzkie              3
MAZ     Mazowieckie          5
POM     Pomorskie            4
WMAZ    Warmi�sko_mazurskie  2
*/

/* Uzasadnienie 
Po wyniku ponizszych zapyta�, mo�na zauwa�y�, �e niekt�re wojew�dztwa nie zosta�y w og�le wzi�te pod uwag�, bo nie zawieraj� �adnego mieszka�ca, lub
zawieraj� tylko jednego mieszka�ca. */
SELECT * FROM WOJ
SELECT * FROM OSOBY o JOIN MIASTA m on m.id_miasta=o.id_miasta JOIN WOJ w ON w.kod_woj=m.kod_woj ORDER BY w.kod_woj



/* ----- Z4.3 ----- */
/* Wariant "srednia z osob mieszkajacych", czyli �rednia pensji w miastach, w kt�rych mieszka wi�cej ni� jeden pracownik. Tutaj uzasadnienia mo�e wymaga� polecenie HAVING. W tym�e poleceniu licz� id_os�b, bo je�li DLA DANEGO MIASTA, policz� wi�cej ni� jedn� osob�,
** to znaczy, �e mieszka w nim wi�cej ni� jedna osoba.*/
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
Gda�sk               3500,00
Pruszk�w             6000,00
*/

/* Uzasadnienie */
/* Dobrym uzasadnieniem wydaje si� by� same wewn�trzne zapytanie, gdzie mo�emy podejrze�, w kt�rych miastach osoby maj� aktualnie etat i to za jak� pensje. Widzimy, �e dla miast o id={3, 4} jest dw�ch mieszka�c�w o aktualnych etatach. */
SELECT mW.id_miasta, eW.pensja FROM ETATY eW 
		JOIN FIRMY fW ON eW.id_firmy=fw.nazwa_skr 
		JOIN MIASTA mW on mW.id_miasta=fW.id_miasta
		WHERE eW.do IS NULL


/* Wariant 2 */
/* Srednia z firm w miastach, czyli �rednia pensja w firmach, kt�re si� znajduj� w miastach, w kt�rym mieszka wi�cej ni� jedna osoba. */
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
/* W poni�szych miastach jest wi�cej ni� dw�ch mieszka�c�w */
SELECT m.id_miasta, m.nazwa, COUNT(o.id_osoby) as [Liczba oosb] INTO #tt FROM OSOBY o JOIN MIASTA m ON m.id_miasta=o.id_miasta  GROUP BY m.nazwa, m.id_miasta HAVING COUNT(o.id_osoby) > 1
/* To s� firmy, w ktorych miastach mieszka wi�cej ni� dw�ch mieszka�c�w (mieszkaniec miasta to osoba, kt�ra mieszka w tym mie�cie) */
SELECT #tt.nazwa, f.nazwa FROM FIRMY f JOIN #tt on #tt.id_miasta=f.id_miasta GROUP BY #tt.nazwa, f.nazwa
