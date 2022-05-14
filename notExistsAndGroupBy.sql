/*
Z2, Kuba Krzychowiec, 2, 319058

Z3.1 - policzy� liczb� os�b w ka�dym mie�cie (zapytanie z grupowaniem)
Najlepiej wynik zapami�ta� w tabeli tymczasowej

Z3.2 - korzystaj�c z wyniku Z3,1 - pokaza�, kt�re miasto ma najwi�ksz� liczb� mieszka�c�w
(zapytanie z fa - analogiczne do zada� z Z2)

Z3.3 Pokaza� liczb� firm w ka�dym z wojew�dztw (czyli grupowanie po kod_woj)
Z3.4 Poaza� wojew�dztwa w kt�rych nie ma �adnej firmy

(suma z3.3 i z3.4 powinna da� nam pe�n� list� wojew�dztw - woj gdzie sa firmy i gdzie ich nie ma to razem powinny byc wszystkie

*/


/* -----Z1-----*/
/* Je�li istnieje tabela tymczasowa, to j� usu�. */
IF OBJECT_ID(N'TEMPDB..#tt') IS NOT NULL
	DROP TABLE #tt

SELECT CONVERT(nvarchar(10), m.nazwa) as [nazwa miasta], COUNT(m.id_miasta) as [Liczba os�b] INTO #tt FROM MIASTA m join OSOBY o on o.id_miasta = m.id_miasta GROUP BY m.nazwa 
SELECT * FROM #tt
/* Wynik 
nazwa miasta Liczba os�b
------------ -----------
Elbl�g       1
Gda�sk       2
Gdynia       2
��d�         2
Olsztyn      1
Pabianice    1
Piast�w      2
Pruszk�w     2
Warszawa     1
*/


/* -----Z2----- */
/* Z tabelki tymczasowej, zawieraj�cej liczby os�b w mie�cie, wybieram tylko te miasto, kt�re zawiera najwi�ksza liczb� os�b.
** Tutaj warto zauwa�y�, �e dwa razy u�ywam tej samej tabeli tymczasowej i mo�na powiedzie�, �e wynik jednego zapytania (wewn�trznego) ��cze z zewn�trznym. */
SELECT #tt.[Liczba os�b], #tt.[nazwa miasta] FROM (SELECT MAX(#tt.[Liczba os�b]) as [Najwieksza liczba osob] FROM #tt) xW JOIN #tt ON xW.[Najwieksza liczba osob] = #tt.[Liczba os�b]

/* WYNIK
Liczba os�b nazwa miasta
----------- ------------
2           Gda�sk
2           Gdynia
2           ��d�
2           Piast�w
2           Pruszk�w
*/
/* Uzasadnieniem jest wynik pierwszego zapytania, zapytanie wypisuje pi�� rekord�w, bo ka�dy z nich zawiera najwi�ksz� liczb� mieszka�c�w, czyli 2. */


/* -----Z3-----*/
/* Aby policzy� liczb� wszystkich firm w danym wojew�dztwie, pierw licz� liczbe firm w ka�dym  mie�cie, a nast�pnie sumuje liczb� os�b 
** z ka�dego miasta nale��cego do danego wojewo�dztwa. */
SELECT w.nazwa, SUM(x.[Ilo�� firm w mie�cie]) as [Ilo�� firm w wojew�dztwie]
FROM WOJ w 
	JOIN MIASTA m on m.kod_woj = w.kod_woj 
	JOIN (SELECT COUNT(f.nazwa_skr) [Ilo�� firm w mie�cie], f.id_miasta FROM FIRMY f GROUP BY f.id_miasta) x on m.id_miasta=x.id_miasta
GROUP BY w.nazwa

/*Wynik
nazwa                Ilo�� firm w wojew�dztwie
-------------------- -------------------------
Kujawsko_pomorskie   1
��dzkie              1
Mazowieckie          2
Pomorskie            2
Warmi�sko_mazurskie  2
*/

/* Uzasadnienie 
Zapytanie SELECT * FROM FIRMY, wypisuje 8 rekord�w, zawierajacych informacje o ka�dej z firm. Suma ilo�ci firm daje nam 8, czyli si� zgadza z za�o�eniem. Wynik zapytania: SELECT * FROM FIRMY
nazwa_skr id_miasta   nazwa                                              kod_pocztowy ulica
--------- ----------- -------------------------------------------------- ------------ ------------------------------
APPL      9           APPLE                                              65-675       Jerozolimska
BIED      3           BIEDRONKA                                          41-432       Kryszta�owa
DELL      3           DELL                                               05-823       Ochocka
DHL       8           DHL                                                21-626       JanaPaw�a
DPD       6           DPD                                                94-923       Kamienna
SUNS      1           SUNSUNG                                            80-123       Powi�le
XKOM      1           X-KOM                                              71-190       Mazowiecka
ZABK      10          ZABKA                                              44-135       Sprawiedliwo�ci
*/



/*-----Z4-----*/
/* Wybieram wszystko z wojew�dztw, tych w kt�rych nie istnieje �adna firma.
** To czy firma istnieje determinuje mi warunek tabeli wewn�trznej i zewn�trznej, w moim wypadku jest to WHERE w.kod_woj = mW.kod_woj.
** Wykorzystuje polecenie NOT EXISTS, a potem SELECT 1 gdy� jest najszybsze. */
SELECT * FROM WOJ w WHERE NOT EXISTS (SELECT 1 FROM FIRMY fW JOIN MIASTA mW on fW.id_miasta=mW.id_miasta WHERE w.kod_woj = mW.kod_woj)
/* Wynik
kod_woj nazwa
------- --------------------
OPOL    Opolskie
ZPOM    Zachodnio_pomorskie

*/
/* Uzasadnienie Z3 i Z4
Suma wynik�w obu zada� jest r�wnowa�na z zapytaniem SELECT * FROM WOJ:
kod_woj nazwa
------- --------------------
KPOM    Kujawsko_pomorskie
LODZ    ��dzkie
MAZ     Mazowieckie
OPOL    Opolskie
POM     Pomorskie
WMAZ    Warmi�sko_mazurskie
ZPOM    Zachodnio_pomorskie
*/