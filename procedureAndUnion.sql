/*
Z5 Kuba, Krzychowiec, 319058, Gr 2

Z5.1 - Pokaza� firmy wraz ze �redni� aktualna pensj� w nich
U�ywaj�c UNION, rozwa�y� opcj� ALL

Z5.2 - to samo co w Z5.1
Ale z wykorzystaniem LEFT OUTER

Z5.3 Napisa� procedur� pokazuj�c� �redni� pensj� w firmach z miasta - parametr procedure @id_miasta
*/

	

/* -----Z5.1.----- */
SELECT CONVERT(nvarchar(12) , f.nazwa) as [Nazwa firmy], AVG(e.pensja) as [Srednia pensja] FROM FIRMY f JOIN ETATY e ON e.id_firmy=f.nazwa_skr WHERE (e.do IS NULL) GROUP BY f.nazwa
UNION ALL
SELECT CONVERT(nvarchar(12) , f.nazwa) as [Nazwa firmy], CONVERT(money, null) as [Pensja] FROM FIRMY f WHERE NOT EXISTS (SELECT 1 FROM ETATY eW WHERE (eW.do IS NULL) AND (f.nazwa_skr=eW.id_firmy)) 
/* Wyniki 
Nazwa firmy  Srednia pensja
------------ ---------------------
BIEDRONKA    3500,00
DELL         6000,00
DHL          5500,00
X-KOM        3500,00
APPLE        NULL
DPD          NULL
SUNSUNG      NULL
ZABKA        NULL
*/

/* Uzasadnienie 
** U�ywam s��wka kluczowego ALL, bo oba zapytania s� roz��czne, a ALL zapewnia najwi�ksz� efektywno��.
** Oba zapytania generuj� przeciwne wyniki, co mo�na podejrze� przy poni�szym zapytaniu.*/
SELECT * FROM FIRMY

/* -----Z5.2.---- */
SELECT CONVERT(nvarchar(12), f.nazwa) AS [Nazwa firmy], AVG(t.pensja) as [Srednia pensja] FROM FIRMY f LEFT OUTER JOIN (SELECT eW.id_firmy ,AVG(eW.pensja) as pensja FROM ETATY eW WHERE eW.do IS NULL GROUP BY eW.id_firmy) t ON t.id_firmy=f.nazwa_skr GROUP BY f.nazwa
/* Wyniki
Nazwa firmy  Srednia pensja
------------ ---------------------
APPLE        NULL
BIEDRONKA    3500,00
DELL         6000,00
DHL          5500,00
DPD          NULL
SUNSUNG      NULL
X-KOM        3500,00
ZABKA        NULL*/
/* Uzasadnienie
** To zapytanie generuje teoretycznie ten sam wynik co w pierwszym zadaniu, jednak jest bardziej niebezpieczne, ze wzgl�du
** na u�ycie LEFT OUTER JOIN, podczas kt�rego trzeba by� �wiadom jak go u�ywamy.*/
SELECT * FROM FIRMY

/* -----Z5.3.---- */
DROP PROCEDURE SREDNIA_W_FIRMACH_W_MIESCIE
GO
CREATE PROCEDURE SREDNIA_W_FIRMACH_W_MIESCIE (@id_miasta integer) AS
	SELECT CONVERT(nvarchar(12), f.nazwa) as [Nazwa miasta], t.[srednia pensja] FROM FIRMY f 
	LEFT OUTER JOIN MIASTA m ON m.id_miasta=f.id_miasta
	LEFT OUTER JOIN (SELECT eW.id_firmy, AVG(eW.pensja) as [srednia pensja] FROM ETATY eW WHERE eW.do IS NULL GROUP BY eW.id_firmy) t on t.id_firmy=f.nazwa_skr
	WHERE f.id_miasta=@id_miasta
GO

EXEC SREDNIA_W_FIRMACH_W_MIESCIE @id_miasta=4
EXEC SREDNIA_W_FIRMACH_W_MIESCIE @id_miasta=8

/* Wyniki 
nazwa                                              srednia pensja
-------------------------------------------------- ---------------------
DELL                                               6000,00

nazwa                                              srednia pensja
-------------------------------------------------- ---------------------
DHL                                                5500,00
*/
SELECT * FROM FIRMY
/* 
Uzasadnienie
SELECT f.nazwa_skr, t.srd FROM FIRMY f JOIN (SELECT eW.id_firmy, AVG(eW.pensja) as srd FROM ETATY eW  WHERE eW.do IS NULL GROUP BY eW.id_firmy) t ON t.id_firmy=f.nazwa_skr 
WHERE f.id_miasta=4 OR f.id_miasta=8

Jak mo�na zauwa�y�, procedura daje taki sam wynik co powy�sze zapytanie.
*/
