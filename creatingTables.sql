/* Usunięcie tabel jeżeli istnieją, zapobiega to błędom, w przypadku próby stworzenia już istniejącej tabeli. */
IF OBJECT_ID('dbo.ETATY') IS NOT NULL
	DROP TABLE dbo.ETATY
IF OBJECT_ID('dbo.OSOBY') IS NOT NULL
	DROP TABLE dbo.OSOBY
IF OBJECT_ID('dbo.FIRMY') IS NOT NULL
	DROP TABLE dbo.FIRMY
IF OBJECT_ID('dbo.MIASTA') IS NOT NULL
	DROP TABLE dbo.MIASTA
IF OBJECT_ID('dbo.WOJ') IS NOT NULL
	DROP TABLE dbo.WOJ


/* Stworzenie tabeli WOJ, jej kluczem głównym jest kod_woj, będąca typu nchar(4).*/
CREATE TABLE dbo.WOJ (
kod_woj nchar(4)	NOT NULL CONSTRAINT PK_WOJ PRIMARY KEY,
nazwa nvarchar(20)	NOT NULL,
);

/* Stworzenie tabeli MIASTA, jej kluczem głównym jest id_miasta, które jest automatycznie inkrementowane wraz dodawaniem kolejnych rekordów.
Kluczem obcym jest kod_woj z tabeli WOJ */
CREATE TABLE dbo.MIASTA(
id_miasta int			NOT NULL IDENTITY CONSTRAINT PK_MIASTA PRIMARY KEY,
nazwa	nvarchar(20)	NOT NULL,
kod_woj nchar(4)		NOT NULL CONSTRAINT FK_MIASTA_WOJ FOREIGN KEY REFERENCES dbo.WOJ(kod_woj)
);

/* Stworzenie tabeli OSOBY, jej kluczem głównym jest id_osoby, które jest automatycznie inkrementowane, wraz z dodawaniem kolejnych rekordów.
Kluczem obcym jest id_miasta z tabeli MIASTA */
CREATE TABLE dbo.OSOBY  ( 
id_osoby int					NOT NULL IDENTITY CONSTRAINT PK_OSOBY PRIMARY KEY,
imie   nvarchar(40)				NOT NULL,
nazwisko nvarchar(60)			NOT NULL,
id_miasta int					NOT NULL CONSTRAINT FK_OSOBY_MIASTA FOREIGN KEY REFERENCES MIASTA(id_miasta),
);

/* Stworzenie tabeli FIRMY, jej kluczem głównym jest nazwa_skr, będąca typu nchar(5). Kluczem obcym jest id_miasta z tabeli MIASTA */
CREATE TABLE dbo.FIRMY (
nazwa_skr nchar(4)		NOT NULL CONSTRAINT PK_FIRMY PRIMARY KEY,
id_miasta int			NOT NULL CONSTRAINT FK_FIRMY_MIASTA FOREIGN KEY REFERENCES dbo.MIASTA(id_miasta),
nazwa nvarchar(50)		NOT NULL,
kod_pocztowy nchar(6)	NOT NULL,
ulica nvarchar(30)		NOT NULL
);

/* Stworzenie tabeli ETATY. Klcuczem głównym tabeli jest id_etatu, będące typu INT - klucz główny jest inkrementowany, wraz z dodawaniem kolejnych rekordów. 
Kluczami obcymi tabeli są id_osoby, id_firmy. */
CREATE TABLE dbo.ETATY (
id_osoby int			NOT NULL CONSTRAINT FK_ETATY_OSOBY FOREIGN KEY REFERENCES dbo.OSOBY(id_osoby),
id_firmy nchar(4)		NOT NULL CONSTRAINT FK_ETATY_FIRMY FOREIGN KEY REFERENCES dbo.FIRMY(nazwa_skr),
stanowisko nvarchar(20) NOT NULL,
pensja money			NOT NULL,
od datetime					NOT NULL,
do datetime					NULL,
id_etatu int			NOT NULL IDENTITY CONSTRAINT PK_ETATU PRIMARY KEY,
);


/* Dodanie to tabeli WOJ, konkrentych województw. */
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'POM', N'Pomorskie')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'LODZ', N'Łódzkie')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'WMAZ', N'Warmińsko_mazurskie')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'MAZ', N'Mazowieckie')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'KPOM', N'Kujawsko_pomorskie')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'OPOL', N'Opolskie')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'ZPOM', N'Zachodnio_pomorskie')

DECLARE @id_war int, @id_gda int, @id_gdy int, @id_pru int, @id_pia int, @id_lod int, @id_pab int, @id_ols int, @id_elb int,
@id_byd int, @id_tor int

/* Dodawanie rekordów do tabeli MIASTA. Przy okazji dodania do tabeli, przypisuje do zmiennych @id_<miasto> nadane im id. */
INSERT INTO MIASTA(nazwa, kod_woj) VALUES (N'Gdańsk', N'POM')
SET @id_gda = SCOPE_IDENTITY()

INSERT INTO MIASTA(nazwa, kod_woj) VALUES (N'Gdynia', N'POM')
SET @id_gdy = SCOPE_IDENTITY()

INSERT INTO MIASTA(nazwa, kod_woj) VALUES (N'Warszawa', N'MAZ')
SET @id_war = SCOPE_IDENTITY()
INSERT INTO OSOBY(imie, nazwisko, id_miasta) VALUES (N'Marcin', N'Przybylski', @id_war)

INSERT INTO MIASTA(nazwa, kod_woj) VALUES (N'Pruszków', N'MAZ')
SET @id_pru = SCOPE_IDENTITY()

INSERT INTO MIASTA(nazwa, kod_woj) VALUES (N'Piastów', N'MAZ')
SET @id_pia = SCOPE_IDENTITY()

INSERT INTO MIASTA(nazwa, kod_woj) VALUES (N'Łódź', N'LODZ')
SET @id_lod = SCOPE_IDENTITY()

INSERT INTO MIASTA(nazwa, kod_woj) VALUES (N'Pabianice', N'LODZ')
SET @id_pab = SCOPE_IDENTITY()

INSERT INTO MIASTA(nazwa, kod_woj) VALUES (N'Olsztyn', N'WMAZ')
SET @id_ols = SCOPE_IDENTITY()

INSERT INTO MIASTA(nazwa, kod_woj) VALUES (N'Elbląg', N'WMAZ')
SET @id_elb = SCOPE_IDENTITY()

INSERT INTO MIASTA(nazwa, kod_woj) VALUES (N'Bydgoszcz', N'KPOM')
SET @id_byd = SCOPE_IDENTITY()

INSERT INTO MIASTA(nazwa, kod_woj) VALUES (N'Toruń', N'KPOM')
SET @id_tor = SCOPE_IDENTITY()


/* Deklaracja zmiennych przetrzymuwujących id osob. */
DECLARE @id_o01 int,@id_o02 int,@id_o03 int,@id_o04 int,@id_o05 int,@id_o06 int,@id_o07 int, @id_o08 int, @id_o09 int,@id_o10 int, @id_o11 int, @id_o12 int, @id_o13 int 
 
 
/* Dodawanie do tabeli OSOBY, konkretnych rekordów, które przedstawiają informacje o konkretnej osobie. Id osób jest nadawane automatycznie, poprzez autoinkrementacje klucza głównego
będącego typu INT. Przyporządkowanie osoby od konkretnego miasta, zapewniają mi wcześniej zadeklarowane zmienne przetrzymuwujące id konkretneych miast. */
INSERT INTO OSOBY(imie, nazwisko, id_miasta) VALUES (N'Kuba', N'Krzychowiec', @id_gda)
SET @id_o01 = SCOPE_IDENTITY()
INSERT INTO OSOBY(imie, nazwisko, id_miasta) VALUES (N'Jan', N'Kowalski', @id_gda)
SET @id_o02 = SCOPE_IDENTITY()
INSERT INTO OSOBY(imie, nazwisko, id_miasta) VALUES (N'Oskar', N'Janicki', @id_gdy)
SET @id_o03 = SCOPE_IDENTITY()
INSERT INTO OSOBY(imie, nazwisko, id_miasta) VALUES (N'Remigiusz', N'Orzeszkowski', @id_gdy)
SET @id_o04 = SCOPE_IDENTITY()
INSERT INTO OSOBY(imie, nazwisko, id_miasta) VALUES (N'Julia', N'Kominkowa', @id_pru)
SET @id_o05 = SCOPE_IDENTITY()
INSERT INTO OSOBY(imie, nazwisko, id_miasta) VALUES (N'Sylwia', N'Stół', @id_pru)
SET @id_o06 = SCOPE_IDENTITY()
INSERT INTO OSOBY(imie, nazwisko, id_miasta) VALUES (N'Kacper', N'Tarka', @id_pia)
SET @id_o07 = SCOPE_IDENTITY()
INSERT INTO OSOBY(imie, nazwisko, id_miasta) VALUES (N'Mateusz', N'Suwinica', @id_pia)
SET @id_o08 = SCOPE_IDENTITY()
INSERT INTO OSOBY(imie, nazwisko, id_miasta) VALUES (N'Paulina', N'Poczta', @id_lod)
SET @id_o09 = SCOPE_IDENTITY()
INSERT INTO OSOBY(imie, nazwisko, id_miasta) VALUES (N'Klaudia', N'Sobota', @id_lod)
SET @id_o10 = SCOPE_IDENTITY()
INSERT INTO OSOBY(imie, nazwisko, id_miasta) VALUES (N'Jan', N'Abacki', @id_pab)
SET @id_o11 = SCOPE_IDENTITY()
INSERT INTO OSOBY(imie, nazwisko, id_miasta) VALUES (N'Anna', N'Orzeszkowa', @id_ols)
SET @id_o12 = SCOPE_IDENTITY()
INSERT INTO OSOBY(imie, nazwisko, id_miasta) VALUES (N'Elżbieta', N'Kraus', @id_elb)
SET @id_o13 = SCOPE_IDENTITY()


/* Dodanie rekordów konkretnych firm, warto zauważyć, że posługuje się id konkretnych miast, co zapewnia spójność bazy danych */
INSERT INTO FIRMY(id_miasta, kod_pocztowy, nazwa, nazwa_skr, ulica) VALUES(@id_gda, N'80-123', N'SUNSUNG', N'SUNS', N'Powiśle')
INSERT INTO FIRMY(id_miasta, kod_pocztowy, nazwa, nazwa_skr, ulica) VALUES(@id_war, N'05-823', N'DELL', N'DELL', N'Ochocka')
INSERT INTO FIRMY(id_miasta, kod_pocztowy, nazwa, nazwa_skr, ulica) VALUES(@id_byd, N'44-135', N'ZABKA', N'ZABK', N'Sprawiedliwości')
INSERT INTO FIRMY(id_miasta, kod_pocztowy, nazwa, nazwa_skr, ulica) VALUES(@id_elb, N'65-675', N'APPLE', N'APPL', N'Jerozolimska')
INSERT INTO FIRMY(id_miasta, kod_pocztowy, nazwa, nazwa_skr, ulica) VALUES(@id_lod, N'94-923', N'DPD', N'DPD', N'Kamienna')
INSERT INTO FIRMY(id_miasta, kod_pocztowy, nazwa, nazwa_skr, ulica) VALUES(@id_ols, N'21-626', N'DHL', N'DHL', N'JanaPawła')
INSERT INTO FIRMY(id_miasta, kod_pocztowy, nazwa, nazwa_skr, ulica) VALUES(@id_gda, N'71-190', N'X-KOM', N'XKOM', N'Mazowiecka')
INSERT INTO FIRMY(id_miasta, kod_pocztowy, nazwa, nazwa_skr, ulica) VALUES(@id_war, N'41-432', N'BIEDRONKA', N'BIED', N'Kryształowa')

	
/* Dodanie etatów do tabeli ETATY, posługuje się wcześniej zadeklarowanymi zmiennymi przetrzymującymi dane o id osób */
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES(@id_o01, N'DELL',N'Programista', 4500, '2000-12-01', '2005-04-14')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES(@id_o02,N'BIED',N'Sprzedawca', 3500, '2020-06-13')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES(@id_o03,N'APPL',N'Konsultant', 3000, '2018-08-14', '2022-01-14')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES(@id_o04,N'DHL',N'Dostawca', 2500, '2014-02-22', '2016-05-11')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES(@id_o01,N'DPD',N'Product owner', 8500, '2005-08-13', '2009-05-13')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES(@id_o05,N'XKOM',N'Konsltant', 3500, '2011-09-20', '2014-11-14')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES(@id_o06,N'XKOM',N'Sprzedawca', 3500, '2020-01-13')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES(@id_o07,N'DHL',N'Kierowca', 3000, '2018-04-12', '2018-10-16')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES(@id_o07,N'DELL',N'Księgowy', 5500, '2018-10-24')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES(@id_o08,N'DELL',N'HR', 4000, '2014-10-15', '2016-02-25')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES(@id_o08,N'DPD',N'Kurier', 2500, '2016-03-02', '2020-09-26')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES(@id_o09,N'DHL',N'Kierownik magazynu', 5500, '2018-12-05')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES(@id_o10,N'DELL',N'Specjalista bd', 9500, '2012-04-13', '2018-07-10')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES(@id_o10,N'DELL',N'Programista', 13300, '2018-09-10', '2022-02-05')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES(@id_o11,N'BIED',N'Menadżer', 6000, '2005-06-01', '2008-09-14')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES(@id_o11,N'BIED',N'Sprzedawca', 3500, '2020-03-14')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES(@id_o12,N'XKOM',N'Konsultant', 4000, '2013-07-20', '2015-09-25')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES(@id_o12,N'XKOM',N'Sprzedawca', 3700, '2016-02-02', '2020-01-15')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES(@id_o13,N'APPL',N'Sprzedawca', 4000, '2014-06-30', '2016-09-15')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES(@id_o13,N'DELL',N'Helpdesk', 6500, '2015-10-14')

SELECT * FROM OSOBY
/*
id_osoby    imie                                     nazwisko                                                     id_miasta
----------- ---------------------------------------- ------------------------------------------------------------ -----------
1           Marcin                                   Przybylski                                                   3
2           Kuba                                     Krzychowiec                                                  1
3           Jan                                      Kowalski                                                     1
4           Oskar                                    Janicki                                                      2
5           Remigiusz                                Orzeszkowski                                                 2
6           Julia                                    Kominkowa                                                    4
7           Sylwia                                   Stół                                                         4
8           Kacper                                   Tarka                                                        5
9           Mateusz                                  Suwinica                                                     5
10          Paulina                                  Poczta                                                       6
11          Klaudia                                  Sobota                                                       6
12          Jan                                      Abacki                                                       7
13          Anna                                     Orzeszkowa                                                   8
14          Elżbieta                                 Kraus                                                        9
*/
SELECT * FROM FIRMY
/*
nazwa_skr id_miasta   nazwa                                              kod_pocztowy ulica
--------- ----------- -------------------------------------------------- ------------ ------------------------------
APPL      9           APPLE                                              65-675       Jerozolimska
BIED      3           BIEDRONKA                                          41-432       Kryształowa
DELL      3           DELL                                               05-823       Ochocka
DHL       8           DHL                                                21-626       JanaPawła
DPD       6           DPD                                                94-923       Kamienna
SUNS      1           SUNSUNG                                            80-123       Powiśle
XKOM      1           X-KOM                                              71-190       Mazowiecka
ZABK      10          ZABKA                                              44-135       Sprawiedliwości
*/
SELECT * FROM WOJ
/*
kod_woj nazwa
------- --------------------
KPOM    Kujawsko_pomorskie
LODZ    Łódzkie
MAZ     Mazowieckie
OPOL    Opolskie
POM     Pomorskie
WMAZ    Warmińsko_mazurskie
ZPOM    Zachodnio_pomorskie
*/
SELECT * FROM MIASTA
/*
id_miasta   nazwa                kod_woj
----------- -------------------- -------
1           Gdańsk               POM 
2           Gdynia               POM 
3           Warszawa             MAZ 
4           Pruszków             MAZ 
5           Piastów              MAZ 
6           Łódź                 LODZ
7           Pabianice            LODZ
8           Olsztyn              WMAZ
9           Elbląg               WMAZ
10          Bydgoszcz            KPOM
11          Toruń                KPOM
*/
SELECT * FROM ETATY
/*
id_osoby    id_firmy stanowisko           pensja                od                      do                      id_etatu
----------- -------- -------------------- --------------------- ----------------------- ----------------------- -----------
2           DELL     Programista          4500,00               2000-12-01 00:00:00.000 2005-04-14 00:00:00.000 1
3           BIED     Sprzedawca           3500,00               2020-06-13 00:00:00.000 NULL                    2
4           APPL     Konsultant           3000,00               2018-08-14 00:00:00.000 2022-01-14 00:00:00.000 3
5           DHL      Dostawca             2500,00               2014-02-22 00:00:00.000 2016-05-11 00:00:00.000 4
2           DPD      Product owner        8500,00               2005-08-13 00:00:00.000 2009-05-13 00:00:00.000 5
6           XKOM     Konsltant            3500,00               2011-09-20 00:00:00.000 2014-11-14 00:00:00.000 6
7           XKOM     Sprzedawca           3500,00               2020-01-13 00:00:00.000 NULL                    7
8           DHL      Kierowca             3000,00               2018-04-12 00:00:00.000 2018-10-16 00:00:00.000 8
8           DELL     Księgowy             5500,00               2018-10-24 00:00:00.000 NULL                    9
9           DELL     HR                   4000,00               2014-10-15 00:00:00.000 2016-02-25 00:00:00.000 10
9           DPD      Kurier               2500,00               2016-03-02 00:00:00.000 2020-09-26 00:00:00.000 11
10          DHL      Kierownik magazynu   5500,00               2018-12-05 00:00:00.000 NULL                    12
11          DELL     Specjalista bd       9500,00               2012-04-13 00:00:00.000 2018-07-10 00:00:00.000 13
11          DELL     Programista          13300,00              2018-09-10 00:00:00.000 2022-02-05 00:00:00.000 14
12          BIED     Menadżer             6000,00               2005-06-01 00:00:00.000 2008-09-14 00:00:00.000 15
12          BIED     Sprzedawca           3500,00               2020-03-14 00:00:00.000 NULL                    16
13          XKOM     Konsultant           4000,00               2013-07-20 00:00:00.000 2015-09-25 00:00:00.000 17
13          XKOM     Sprzedawca           3700,00               2016-02-02 00:00:00.000 2020-01-15 00:00:00.000 18
14          APPL     Sprzedawca           4000,00               2014-06-30 00:00:00.000 2016-09-15 00:00:00.000 19
14          DELL     Helpdesk             6500,00               2015-10-14 00:00:00.000 NULL                    20
*/



/*
Poniższe zapytanie wywołuje błąd, dlatego że próbujemy dodać etat dla osoby nieistniejącej.
Msg 547, Level 16, State 0, Line 2
The INSERT statement conflicted with the FOREIGN KEY constraint "FK_ETATY_OSOBY". The conflict occurred in database "b_319058", table "dbo.OSOBY", column 'id_osoby'.
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (15, N'DELL', N'Sprzedawca', 3500, '2013-06-13')
*/
/*
Poniższe zapytanie wywołuje błąd, dlatego że próbujemy usunąć rekord, który jest powiązany z innymi rekordami w innych tabelach.
Msg 547, Level 16, State 0, Line 2
The DELETE statement conflicted with the REFERENCE constraint "FK_OSOBY_MIASTA". The conflict occurred in database "b_319058", table "dbo.OSOBY", column 'id_miasta'.
DELETE FROM MIASTA WHERE MIASTA.nazwa='Pruszków'
*/
/*
Poniższe zpytanie wywołuje błąd, bo istnieje  referencja do klucza obcego, powiązana z tą tabelą.
Msg 3726, Level 16, State 1, Line 2
Could not drop object 'OSOBY' because it is referenced by a FOREIGN KEY constraint.
DROP TABLE OSOBY
*/