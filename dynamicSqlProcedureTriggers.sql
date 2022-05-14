/* Kuba, Nazwisko, nr grupy, nrIndeksu
**
** 3 regu³y tworzenia TRIGGERA
** R1 - Trigger nie mo¿e aktualizowaæ CALEJ tabeli a co najwy¿ej elementy zmienione
** R2 - Trigger mo¿e wywo³aæ sam siebie - uzysamy niesoñczon¹ rekurencjê == stack overflow
** R3 - Zawsze zakladamy, ¿e wstawiono / zmodyfikowano / skasowano wiecej jak 1 rekord
**
** Z1: Napisaæ trigger, który bêdzie usuwa³ spacje z pola nazwisko
** Trigger na INSERT, UPDATE
** UWAGA !! Trigger bêdzie robi³ UPDATE na polu NAZWISKO
** To grozi REKURENCJ¥ i przepelnieniem stosu
** Dlatego trzeba bêdzie sprawdzaæ UPDATE(nazwisko) i sprawdzaæ czy we
** wstawionych rekordach by³y spacje i tylko takowe poprawiaæ (ze spacjami w nazwisku)
**
** Z2: Napisaæ procedurê szukaj¹c¹ osób z paramertrami
** @imie_wzor nvarchar(20) = NULL
** @nazwisko_wzor nvarchar(20) = NULL
** @pokaz_zarobki bit = 0
** Procedura ma mieæ zmienn¹ @sql nvarchar(1000), któr¹ buduje dynamicznie
** @pokaz_zarobki = 0 => (imie, nazwisko, id_osoby, nazwa_miasta)
** @pokaz_zarobki = 1 => (imie, nazwisko, id_osoby, suma_z_akt_etatow)
** Mozliwe wywo³ania: EXEC sz_o @nazwisko_wzor = N'Stodolsk%'
** powinno zbudowaæ zmienn¹ tekstow¹
** @sql = N'SELECT o.*, m.nazwa AS nazwa_miasta FROM osoby o join miasta m "
** + N' ON (m.id_miasta=o.id_miasta) WHERE o.nazwisko LIKE N''Stodolsk%'' '
** uruchomienie zapytania to EXEC sp_sqlExec @sql
** rekomendujê aby najpierw procedura zwraca³a zapytanie SELECT @sql
** a dopiero jak bêd¹ poprawne uruachamia³a je
*/
/* ----- Z1 ----- */
CREATE TRIGGER dbo.TR_nazwisko_usun_spacja ON OSOBY FOR INSERT, UPDATE AS
	IF UPDATE(nazwisko) AND EXISTS ( SELECT 1 FROM OSOBY o WHERE o.nazwisko LIKE N'% %')
		BEGIN
		UPDATE OSOBY SET nazwisko = t.nazw FROM OSOBY JOIN
			(SELECT iW.id_osoby, REPLACE(iW.nazwisko, N' ', N'') as nazw FROM inserted iW) t ON t.id_osoby=OSOBY.id_osoby
		END
GO
/* Uzasadnienie */
SELECT id_osoby, convert(nvarchar(12),imie) as imie, convert(nvarchar(20), nazwisko) as nazwisko FROM OSOBY where id_osoby>12
INSERT INTO OSOBY (imie, nazwisko, id_miasta) VALUES (N'Milosz', N'Krzyszt ofowicz', 5)
SELECT id_osoby, convert(nvarchar(12),imie) as imie, convert(nvarchar(20), nazwisko) as nazwisko FROM OSOBY where id_osoby>12
/* Dziêki powy¿szemu triggerowi, podczas dodawania nowej osoby z jej nazwiska zostanie usuniêty znak odstêpu. Nale¿y przede wszystkim zwróciæ uwagê na linijkê zawieraj¹c¹ polecenie 
** Update(nazwisko), dziêki niej w du¿ej mierze Trigger spe³nia swoje zasady i nie wykonuje siê w nieskoñczonoœæ.
** Wynik
id_osoby    imie         nazwisko
----------- ------------ --------------------
13          Anna         Orzeszkowa
14          El¿bieta     Kraus

id_osoby    imie         nazwisko
----------- ------------ --------------------
13          Anna         Orzeszkowa
14          El¿bieta     Kraus
1014        Milosz       Krzysztofowicz
*/

DROP TRIGGER dbo.TR_nazwisko_usun_spacja





/* ----- Z2 -----  */
IF EXISTS ( SELECT 1 FROM sysobjects o WHERE (o.[name]=N'znajdz_osoby') AND (OBJECTPROPERTY(o.[id], N'IsProcedure')=1))
	DROP PROCEDURE znajdz_osoby
GO

CREATE PROCEDURE znajdz_osoby (@imie_wzor nvarchar(20)=NULL, @nazwisko_wzor nvarchar(20)=NULL, @pokaz_zarobki bit=0) AS
	SET @imie_wzor = LTRIM(RTRIM(@imie_wzor))
	SET @nazwisko_wzor = LTRIM(RTRIM(@nazwisko_wzor))
	SET @imie_wzor = LTRIM(RTRIM(@imie_wzor))

	DECLARE @sql nvarchar(1000)

	IF (@pokaz_zarobki=0)
	BEGIN
		SET @sql = N'SELECT o.imie, o.nazwisko, o.id_osoby, m.nazwa as nazwa_miasta FROM OSOBY o JOIN MIASTA m ON m.id_miasta = o.id_miasta'
	END
	ELSE
	BEGIN
		SET @sql = N'SELECT o.imie, o.nazwisko, o.id_osoby,  t.pensja FROM OSOBY o JOIN 
		(SELECT oW.id_osoby as id, SUM(eW.pensja) as pensja FROM OSOBY oW JOIN ETATY eW ON eW.id_osoby=oW.id_osoby WHERE (eW.do IS NULL) GROUP BY oW.id_osoby) t ON t.id = o.id_osoby'
		
	END
	IF (@imie_wzor IS NOT NULL) OR (@nazwisko_wzor IS NOT NULL)
		SET @sql = @sql + N' WHERE '
	IF (@imie_wzor IS NOT NULL)
		SET @sql = @sql + N'(o.imie LIKE ''' + @imie_wzor + N''')'
	IF (@imie_wzor IS NOT NULL) AND (@nazwisko_wzor IS NOT NULL)
		SET @sql = @sql + N' AND '
	IF (@nazwisko_wzor IS NOT NULL)
		SET @sql = @sql + N'(o.nazwisko LIKE '''+ @nazwisko_wzor + N''')'

	EXEC sp_sqlexec @sql

GO

/* Uzasadnienie 
** Ta procedura wykorzystuje dynamiczne budowanie zapytania i je uruchamia w zale¿noœci od podanych argumentów.
** Pierwsze trzy linijki procedury s¹ dobrym nawykiem, gdy¿ dziêki nim pozbywamy siê poprzedzaj¹cych, lub nastêpuj¹cych znaków odstêpu.
** W du¿ej mierze nale¿y zwróciæ uwagê na cztery warunki IF, które steruj¹ budowaniem procedury ze wzglêdu na argumenty.
*/
EXEC znajdz_osoby N'Kacper', @pokaz_zarobki=1
EXEC znajdz_osoby N'Kacper'
/* Wynik 
imie                                     nazwisko                                                     id_osoby    pensja
---------------------------------------- ------------------------------------------------------------ ----------- ---------------------
Kacper                                   Tarka                                                        8           6050,00


imie                                     nazwisko                                                     id_osoby    nazwa_miasta
---------------------------------------- ------------------------------------------------------------ ----------- --------------------
Kacper                                   Tarka                                                        8           Piastów

*/

