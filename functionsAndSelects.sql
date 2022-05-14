/*
Z2, Kuba Krzychowiec, 2, 319058

1) Pokaza� dane podstawowe osoby, w jakim mie�cie mieszka i w jakim to jest wojew�dztwie

2) Pokaza� wszystkie osoby o nazwisku na liter� M i ostatniej literze nazwiska i lub a
(je�eli nie macie takowych to wybierzcie takie warunki - inn� liter� pocz�tkow� i inne 2 ko�cowe)
kt�re maj� pensje pomi�dzy 3000 a 5000 (te� mo�ecie zmieni� je�eli macie g�ownie inne zakresy)
mieszkajace w innym mie�cie ni� znajduje si� firma, w kt�rej maj� etat
(wystarcz� dane z tabel etaty, firmy, osoby , miasta)

3) Pokaza� kto ma najd�u�sze nazwisko w bazie
(najpierw szukamy MAX z LEN(nazwisko) a potem pokazujemy te osoby z tak� d�ugo�ci� nazwiska)

4) Policzy� liczb� os�b w mie�cie o nazwie (tu daj� Wam wyb�r - w kt�rym mie�cie macie najwi�cej)

*/


/* ----- ZADANIE  1 ----- */

/* Wybieram wszystkie osoby, wraz z nazwa miasta, w ktorym mieszkaja, oraz nazwa wojewodztwa. \
** U�ywam polecenia CONVERT, aby zmniejszy� ilo�� zajmowanego miejsca w tabeli wynikowej. */
SELECT CONVERT(nvarchar(12),o.imie) as imie, CONVERT(nvarchar(13), o.nazwisko) as nazwisko, m.nazwa, w.nazwa
FROM OSOBY o 
join MIASTA m on (m.id_miasta = o.id_miasta) 
join WOJ w on (w.kod_woj = m.kod_woj)

/* Wynik zapytania */
/*
imie         nazwisko      nazwa                nazwa
------------ ------------- -------------------- --------------------
Marcin       Przybylski    Piast�w              Mazowieckie
Kuba         Krzychowiec   Gda�sk               Pomorskie
Jan          Kowalski      Piast�w              Mazowieckie
Oskar        Janicki       Gdynia               Pomorskie
Remigiusz    Orzeszkowski  Gdynia               Pomorskie
Julia        Kominkowa     Pruszk�w             Mazowieckie
Sylwia       St�          Pruszk�w             Mazowieckie
Kacper       Tarka         Piast�w              Mazowieckie
Mateusz      Suwinica      Piast�w              Mazowieckie
Paulina      Poczta        ��d�                 ��dzkie
Klaudia      Sobota        ��d�                 ��dzkie
Jan          Mabacki       Pabianice            ��dzkie
Anna         Orzeszkowa    Olsztyn              Warmi�sko_mazurskie
El�bieta     Kraus         Elbl�g               Warmi�sko_mazurskie
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
7           Sylwia                                   St�                                                         4
8           Kacper                                   Tarka                                                        5
9           Mateusz                                  Suwinica                                                     5
10          Paulina                                  Poczta                                                       6
11          Klaudia                                  Sobota                                                       6
12          Jan                                      Mabacki                                                      7
13          Anna                                     Orzeszkowa                                                   8
14          El�bieta                                 Kraus                                                        9
*/

/* ----- ZADANIE 2 ----- */

/* To co nale�y zauwa�y�, to �e par� razy do��czam tabel� miasta, dlatego �e, miasta firm i miasta os�b to mog� by� r�ne warto�ci.
** Nast�pnie uwzgl�dniam wszystkie kryteria, kt�re s� wymagane w poleceniu - po WHERE.
** Jednocze�nie, chcia�bym nadmieni�, �e na potrzeby zadania u�y�em zapytania UPDATE, aby zmieni� miasto, w kt�rym mieszka osoba o id_osoby=12, oraz jej nazwisko,
** w ten spos�b, aby zaczyna�o si� na M.*/

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
Sylwia       St�            4
Kacper       Tarka           5
Mateusz      Suwinica        8
Paulina      Poczta          6
Klaudia      Sobota          6
Jan          Mabacki         7
Anna         Orzeszkowa      10
El�bieta     Kraus           5
*/


/* ----- ZADANIE 4 ----- */
/* Najwa�niejsze w tym zadaniu jest policzenie RӯNYCH os�b, mimo �e w tabeli OSOBY, nie ma powt�rzonych os�b, to aby zagwarantowa� sp�jno�� w przysz�o�ci, pos�u�y�em
** si� funkcja agreguj�c� COUNT i DISTINCT. */
SELECT COUNT(DISTINCT o.id_osoby) as [Liczba mieszka�c�w Pruszkowa]
FROM MIASTA m join OSOBY o on o.id_miasta = m.id_miasta
WHERE m.nazwa LIKE N'Pruszk�w'

/* Wynik zapytania */
/*
Liczba mieszka�c�w Pruszkowa
----------------------------
2
 */
 /* Uzasadanie*/
 SELECT CONVERT(nvarchar(12), m.nazwa) as [Zamieszkiwane Miasta] FROM OSOBY o join MIASTA m on m.id_miasta = o.id_miasta ORDER BY m.nazwa DESC
 /* 
 Zamieszkiwane Miasta
--------------------
Pruszk�w
Pruszk�w
Piast�w
Piast�w
Piast�w
Piast�w
Pabianice
Olsztyn
��d�
��d�
Gdynia
Gdynia
Gda�sk
Elbl�g 
*/