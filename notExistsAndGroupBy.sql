/*
Z2, Kuba Krzychowiec, 2, 319058

Z3.1 - policzyæ liczbê osób w ka¿dym mieœcie (zapytanie z grupowaniem)
Najlepiej wynik zapamiêtaæ w tabeli tymczasowej

Z3.2 - korzystaj¹c z wyniku Z3,1 - pokazaæ, które miasto ma najwiêksz¹ liczbê mieszkañców
(zapytanie z fa - analogiczne do zadañ z Z2)

Z3.3 Pokazaæ liczbê firm w ka¿dym z województw (czyli grupowanie po kod_woj)
Z3.4 Poazaæ województwa w których nie ma ¿adnej firmy

(suma z3.3 i z3.4 powinna daæ nam pe³n¹ listê województw - woj gdzie sa firmy i gdzie ich nie ma to razem powinny byc wszystkie

*/


/* -----Z1-----*/
/* Jeœli istnieje tabela tymczasowa, to j¹ usuñ. */
IF OBJECT_ID(N'TEMPDB..#tt') IS NOT NULL
	DROP TABLE #tt

SELECT CONVERT(nvarchar(10), m.nazwa) as [nazwa miasta], COUNT(m.id_miasta) as [Liczba osób] INTO #tt FROM MIASTA m join OSOBY o on o.id_miasta = m.id_miasta GROUP BY m.nazwa 
SELECT * FROM #tt
/* Wynik 
nazwa miasta Liczba osób
------------ -----------
Elbl¹g       1
Gdañsk       2
Gdynia       2
£ódŸ         2
Olsztyn      1
Pabianice    1
Piastów      2
Pruszków     2
Warszawa     1
*/


/* -----Z2----- */
/* Z tabelki tymczasowej, zawieraj¹cej liczby osób w mieœcie, wybieram tylko te miasto, które zawiera najwiêksza liczbê osób.
** Tutaj warto zauwa¿yæ, ¿e dwa razy u¿ywam tej samej tabeli tymczasowej i mo¿na powiedzieæ, ¿e wynik jednego zapytania (wewnêtrznego) ³¹cze z zewnêtrznym. */
SELECT #tt.[Liczba osób], #tt.[nazwa miasta] FROM (SELECT MAX(#tt.[Liczba osób]) as [Najwieksza liczba osob] FROM #tt) xW JOIN #tt ON xW.[Najwieksza liczba osob] = #tt.[Liczba osób]

/* WYNIK
Liczba osób nazwa miasta
----------- ------------
2           Gdañsk
2           Gdynia
2           £ódŸ
2           Piastów
2           Pruszków
*/
/* Uzasadnieniem jest wynik pierwszego zapytania, zapytanie wypisuje piêæ rekordów, bo ka¿dy z nich zawiera najwiêksz¹ liczbê mieszkañców, czyli 2. */


/* -----Z3-----*/
/* Aby policzyæ liczbê wszystkich firm w danym województwie, pierw liczê liczbe firm w ka¿dym  mieœcie, a nastêpnie sumuje liczbê osób 
** z ka¿dego miasta nale¿¹cego do danego wojewoództwa. */
SELECT w.nazwa, SUM(x.[Iloœæ firm w mieœcie]) as [Iloœæ firm w województwie]
FROM WOJ w 
	JOIN MIASTA m on m.kod_woj = w.kod_woj 
	JOIN (SELECT COUNT(f.nazwa_skr) [Iloœæ firm w mieœcie], f.id_miasta FROM FIRMY f GROUP BY f.id_miasta) x on m.id_miasta=x.id_miasta
GROUP BY w.nazwa

/*Wynik
nazwa                Iloœæ firm w województwie
-------------------- -------------------------
Kujawsko_pomorskie   1
£ódzkie              1
Mazowieckie          2
Pomorskie            2
Warmiñsko_mazurskie  2
*/

/* Uzasadnienie 
Zapytanie SELECT * FROM FIRMY, wypisuje 8 rekordów, zawierajacych informacje o ka¿dej z firm. Suma iloœci firm daje nam 8, czyli siê zgadza z za³o¿eniem. Wynik zapytania: SELECT * FROM FIRMY
nazwa_skr id_miasta   nazwa                                              kod_pocztowy ulica
--------- ----------- -------------------------------------------------- ------------ ------------------------------
APPL      9           APPLE                                              65-675       Jerozolimska
BIED      3           BIEDRONKA                                          41-432       Kryszta³owa
DELL      3           DELL                                               05-823       Ochocka
DHL       8           DHL                                                21-626       JanaPaw³a
DPD       6           DPD                                                94-923       Kamienna
SUNS      1           SUNSUNG                                            80-123       Powiœle
XKOM      1           X-KOM                                              71-190       Mazowiecka
ZABK      10          ZABKA                                              44-135       Sprawiedliwoœci
*/



/*-----Z4-----*/
/* Wybieram wszystko z województw, tych w których nie istnieje ¿adna firma.
** To czy firma istnieje determinuje mi warunek tabeli wewnêtrznej i zewnêtrznej, w moim wypadku jest to WHERE w.kod_woj = mW.kod_woj.
** Wykorzystuje polecenie NOT EXISTS, a potem SELECT 1 gdy¿ jest najszybsze. */
SELECT * FROM WOJ w WHERE NOT EXISTS (SELECT 1 FROM FIRMY fW JOIN MIASTA mW on fW.id_miasta=mW.id_miasta WHERE w.kod_woj = mW.kod_woj)
/* Wynik
kod_woj nazwa
------- --------------------
OPOL    Opolskie
ZPOM    Zachodnio_pomorskie

*/
/* Uzasadnienie Z3 i Z4
Suma wyników obu zadañ jest równowa¿na z zapytaniem SELECT * FROM WOJ:
kod_woj nazwa
------- --------------------
KPOM    Kujawsko_pomorskie
LODZ    £ódzkie
MAZ     Mazowieckie
OPOL    Opolskie
POM     Pomorskie
WMAZ    Warmiñsko_mazurskie
ZPOM    Zachodnio_pomorskie
*/