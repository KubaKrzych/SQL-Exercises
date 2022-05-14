/*
Z2, Kuba Krzychowiec, 2, 319058

1) Pokazaæ dane podstawowe osoby, w jakim mieœcie mieszka i w jakim to jest województwie

2) Pokazaæ wszystkie osoby o nazwisku na literê M i ostatniej literze nazwiska i lub a
(je¿eli nie macie takowych to wybierzcie takie warunki - inn¹ literê pocz¹tkow¹ i inne 2 koñcowe)
które maj¹ pensje pomiêdzy 3000 a 5000 (te¿ mo¿ecie zmieniæ je¿eli macie g³ownie inne zakresy)
mieszkajace w innym mieœcie ni¿ znajduje siê firma, w której maj¹ etat
(wystarcz¹ dane z tabel etaty, firmy, osoby , miasta)

3) Pokazaæ kto ma najd³u¿sze nazwisko w bazie
(najpierw szukamy MAX z LEN(nazwisko) a potem pokazujemy te osoby z tak¹ d³ugoœci¹ nazwiska)

4) Policzyæ liczbê osób w mieœcie o nazwie (tu dajê Wam wybór - w którym mieœcie macie najwiêcej)

*/


/* ----- ZADANIE  1 ----- */

/* Wybieram wszystkie osoby, wraz z nazwa miasta, w ktorym mieszkaja, oraz nazwa wojewodztwa. \
** U¿ywam polecenia CONVERT, aby zmniejszyæ iloœæ zajmowanego miejsca w tabeli wynikowej. */
SELECT CONVERT(nvarchar(12),o.imie) as imie, CONVERT(nvarchar(13), o.nazwisko) as nazwisko, m.nazwa, w.nazwa
FROM OSOBY o 
join MIASTA m on (m.id_miasta = o.id_miasta) 
join WOJ w on (w.kod_woj = m.kod_woj)

/* Wynik zapytania */
/*
imie         nazwisko      nazwa                nazwa
------------ ------------- -------------------- --------------------
Marcin       Przybylski    Piastów              Mazowieckie
Kuba         Krzychowiec   Gdañsk               Pomorskie
Jan          Kowalski      Piastów              Mazowieckie
Oskar        Janicki       Gdynia               Pomorskie
Remigiusz    Orzeszkowski  Gdynia               Pomorskie
Julia        Kominkowa     Pruszków             Mazowieckie
Sylwia       Stó³          Pruszków             Mazowieckie
Kacper       Tarka         Piastów              Mazowieckie
Mateusz      Suwinica      Piastów              Mazowieckie
Paulina      Poczta        £ódŸ                 £ódzkie
Klaudia      Sobota        £ódŸ                 £ódzkie
Jan          Mabacki       Pabianice            £ódzkie
Anna         Orzeszkowa    Olsztyn              Warmiñsko_mazurskie
El¿bieta     Kraus         Elbl¹g               Warmiñsko_mazurskie
*/

/* Uzasadnienie*/
SELECT CONVERT(nvarchar(12), imie) as imie, CONVERT(nvarchar(15), nazwisko) as nazwisko FROM OSOBY
/*
id_osoby    imie                                     nazwisko                                                     id_miasta
----------- ---------------------------------------- ------------------------------------------------------------ -----------
1           Marcin                                   Przybylski                                                   5
2           Kuba                                     Krzychowiec                                                  1
3           Jan                                      Kowalski                                                     5
4           Oskar                                    Janicki                                                      2
5           Remigiusz                                Orzeszkowski                                                 2
6           Julia                                    Kominkowa                                                    4
7           Sylwia                                   Stó³                                                         4
8           Kacper                                   Tarka                                                        5
9           Mateusz                                  Suwinica                                                     5
10          Paulina                                  Poczta                                                       6
11          Klaudia                                  Sobota                                                       6
12          Jan                                      Mabacki                                                      7
13          Anna                                     Orzeszkowa                                                   8
14          El¿bieta                                 Kraus                                                        9
*/

/* ----- ZADANIE 2 ----- */

/* To co nale¿y zauwa¿yæ, to ¿e parê razy do³¹czam tabelê miasta, dlatego ¿e, miasta firm i miasta osób to mog¹ byæ ró¿ne wartoœci.
** Nastêpnie uwzglêdniam wszystkie kryteria, które s¹ wymagane w poleceniu - po WHERE.
** Jednoczeœnie, chcia³bym nadmieniæ, ¿e na potrzeby zadania u¿y³em zapytania UPDATE, aby zmieniæ miasto, w którym mieszka osoba o id_osoby=12, oraz jej nazwisko,
** w ten sposób, aby zaczyna³o siê na M.*/

SELECT CONVERT(nvarchar(6), o.imie) as imie, CONVERT(nvarchar(10),o.nazwisko) as nazwisko, e.pensja, f.id_miasta as ID_miasta_firmy, m.id_miasta as ID_miasta_osoby, e.do
FROM OSOBY o join ETATY e ON e.id_osoby = o.id_osoby join miasta m on o.id_miasta = m.id_miasta join firmy f on f.nazwa_skr = e.id_firmy join miasta mf on mf.id_miasta = f.id_miasta
WHERE o.nazwisko LIKE N'M%a' OR o.nazwisko LIKE N'M%i' AND e.pensja BETWEEN 3000 AND 5000 AND o.id_miasta != f.id_miasta AND e.do IS NULL

/* Wynik zapytania */
/*
imie   nazwisko   pensja                ID_miasta_firmy ID_miasta_osoby do
------ ---------- --------------------- --------------- --------------- -----------------------
Jan    Mabacki    3500,00               3               7               NULL
*/


/* ----- ZADANIE 3 ----- */

IF OBJECT_ID('TEMPDB..#tt') IS NOT NULL
	DROP TABLE #tt

SELECT o.imie, o.nazwisko, X.DlugoscNazwiska, o.id_osoby INTO #tt
FROM OSOBY o 
join (SELECT LEN(os.nazwisko) as DlugoscNazwiska, os.id_osoby as IDosoby FROM OSOBY os) X on (X.IDosoby = o.id_osoby)

SELECT CONVERT(nvarchar(12), os.imie) as imie, CONVERT(nvarchar(15), os.nazwisko) as nazwisko, os.DlugoscNazwiska 
FROM #tt os join (SELECT MAX(#tt.DlugoscNazwiska) AS [Maks. dl.nazwiska] FROM #tt) X on (X.[Maks. dl.nazwiska] = os.DlugoscNazwiska)

/* Wynik zapytania */
/* 
imie         nazwisko        DlugoscNazwiska
------------ --------------- ---------------
Remigiusz    Orzeszkowski    12
*/

/* Uzasadnienie */
SELECT CONVERT(nvarchar(12), o.imie) as imie, CONVERT(nvarchar(15), o.nazwisko) as nazwisko, X.DlugoscNazwiska
FROM OSOBY o 
join (SELECT LEN(os.nazwisko) as DlugoscNazwiska, os.id_osoby as IDosoby FROM OSOBY os) X on (X.IDosoby = o.id_osoby)
/*
imie         nazwisko        DlugoscNazwiska
------------ --------------- ---------------
Marcin       Przybylski      10
Kuba         Krzychowiec     11
Jan          Kowalski        8
Oskar        Janicki         7
Remigiusz    Orzeszkowski    12
Julia        Kominkowa       9
Sylwia       Stó³            4
Kacper       Tarka           5
Mateusz      Suwinica        8
Paulina      Poczta          6
Klaudia      Sobota          6
Jan          Mabacki         7
Anna         Orzeszkowa      10
El¿bieta     Kraus           5
*/


/* ----- ZADANIE 4 ----- */
/* Najwa¿niejsze w tym zadaniu jest policzenie RÓ¯NYCH osób, mimo ¿e w tabeli OSOBY, nie ma powtórzonych osób, to aby zagwarantowaæ spójnoœæ w przysz³oœci, pos³u¿y³em
** siê funkcja agreguj¹c¹ COUNT i DISTINCT. */
SELECT COUNT(DISTINCT o.id_osoby) as [Liczba mieszkañców Pruszkowa]
FROM MIASTA m join OSOBY o on o.id_miasta = m.id_miasta
WHERE m.nazwa LIKE N'Pruszków'

/* Wynik zapytania */
/*
Liczba mieszkañców Pruszkowa
----------------------------
2
 */
 /* Uzasadanie*/
 SELECT CONVERT(nvarchar(12), m.nazwa) as [Zamieszkiwane Miasta] FROM OSOBY o join MIASTA m on m.id_miasta = o.id_miasta ORDER BY m.nazwa DESC
 /* 
 Zamieszkiwane Miasta
--------------------
Pruszków
Pruszków
Piastów
Piastów
Piastów
Piastów
Pabianice
Olsztyn
£ódŸ
£ódŸ
Gdynia
Gdynia
Gdañsk
Elbl¹g 
*/