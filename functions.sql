-- a) uczestnicy_wycieczki(id_wycieczki)
DROP FUNCTION uczestnicy_wycieczki;
DROP TYPE uczestnicy_table;
DROP TYPE uczestnicy_type;

CREATE TYPE uczestnicy_type AS OBJECT (
  id VARCHAR2(10),
  nazwa VARCHAR2(100),
  kraj VARCHAR2(50),
  data_wycieczki DATE,
  imie VARCHAR2(50),
  nazwisko VARCHAR2(50),
  status_rezerwacji char(1)
);

CREATE TYPE uczestnicy_table AS TABLE OF uczestnicy_type;

CREATE FUNCTION uczestnicy_wycieczki (id_szukanej_wycieczki IN INT)
  RETURN uczestnicy_table
AS
  id_exist NUMBER(1);
  uczestnicy uczestnicy_table;
  BEGIN
    uczestnicy := uczestnicy_table();

    SELECT CASE
      WHEN EXISTS(SELECT *
                  FROM WYCIECZKI w
                  WHERE w.ID_WYCIECZKI = id_szukanej_wycieczki)
        THEN 1
        ELSE 0
    END
    INTO id_exist FROM dual;

    IF id_exist = 0 THEN
        raise_application_error(-20001, 'Wycieczka o podanym ID nie istnieje!');
    END IF;

    SELECT uczestnicy_type(r.ID_WYCIECZKI, w.NAZWA, w.KRAJ, w.data, o.IMIE, o.NAZWISKO, r.STATUS)
    BULK COLLECT INTO uczestnicy
    FROM rezerwacje r
    JOIN wycieczki w ON w.ID_WYCIECZKI = r.ID_WYCIECZKI
    JOIN osoby o ON o.ID_OSOBY = r.ID_OSOBY 
    WHERE r.ID_WYCIECZKI = id_szukanej_wycieczki;

    RETURN uczestnicy;
END;


--b) rezerwacja osoby(id_osoby)
DROP FUNCTION rezerwacje_osoby;
DROP TYPE rezerwacje_table;
DROP TYPE rezerwacje_type;

CREATE TYPE rezerwacje_type AS OBJECT (
  id VARCHAR2(10),
  imie VARCHAR2(50),
  nazwisko VARCHAR2(50),
  nazwa VARCHAR2(100),
  kraj VARCHAR2(50),
  data_wycieczki DATE,
  status_rezerwacji char(1)
);

CREATE TYPE rezerwacje_table AS TABLE OF rezerwacje_type;

CREATE FUNCTION rezerwacje_osoby (id_szukanej_osoby IN INT)
  RETURN rezerwacje_table
AS
  id_os NUMBER(1);
  rezerwacje rezerwacje_table;
  BEGIN
    rezerwacje := rezerwacje_table();

    SELECT CASE
      WHEN EXISTS(SELECT *
                  FROM OSOBY o
                  WHERE o.ID_OSOBY = id_szukanej_osoby)
        THEN 1
        ELSE 0
    END
    INTO id_os FROM dual;

    IF id_os = 0 THEN
        raise_application_error(-20001, 'Osoba o podanym ID nie istnieje!');
    END IF;

    SELECT rezerwacje_type(r.ID_OSOBY, o.IMIE, o.NAZWISKO, w.NAZWA, w.KRAJ, w.data, r.STATUS)
    BULK COLLECT INTO rezerwacje
    FROM rezerwacje r
    JOIN wycieczki w ON w.ID_WYCIECZKI = r.ID_WYCIECZKI
    JOIN osoby o ON o.ID_OSOBY = r.ID_OSOBY 
    WHERE r.ID_OSOBY = id_szukanej_osoby;

    RETURN rezerwacje;
END;

--c) przyszle_rezerwacjee_osoby(id_osoby)
DROP FUNCTION przyszle_rezerwacje_osoby;
DROP TYPE przyszle_rezerwacje_table;
DROP TYPE przyszle_rezerwacje_type;

CREATE TYPE przyszle_rezerwacje_type AS OBJECT (
  id VARCHAR2(10),
  imie VARCHAR2(50),
  nazwisko VARCHAR2(50),
  nazwa VARCHAR2(100),
  kraj VARCHAR2(50),
  data_wycieczki DATE,
  status_rezerwacji char(1)
);

CREATE TYPE przyszle_rezerwacje_table AS TABLE OF przyszle_rezerwacje_type;

CREATE FUNCTION przyszle_rezerwacje_osoby (id_szukanej_osoby IN INT)
  RETURN rezerwacje_table
AS
  id_os NUMBER(1);
  rezerwacje rezerwacje_table;
  BEGIN
    rezerwacje := rezerwacje_table();

    SELECT CASE
      WHEN EXISTS(SELECT *
                  FROM OSOBY o
                  WHERE o.ID_OSOBY = id_szukanej_osoby)
        THEN 1
        ELSE 0
    END
    INTO id_os FROM dual;

    IF id_os = 0 THEN
        raise_application_error(-20001, 'Osoba o podanym ID nie istnieje!');
    END IF;

    SELECT rezerwacje_type(r.ID_OSOBY, o.IMIE, o.NAZWISKO, w.NAZWA, w.KRAJ, w.data, r.STATUS)
    BULK COLLECT INTO rezerwacje
    FROM rezerwacje r
    JOIN wycieczki w ON w.ID_WYCIECZKI = r.ID_WYCIECZKI
    JOIN osoby o ON o.ID_OSOBY = r.ID_OSOBY 
    WHERE r.ID_OSOBY = id_szukanej_osoby AND w.DATA > sysdate;

    RETURN rezerwacje;
END;

--d) dostepne_wycieczki(kraj, data_od, data_do)
DROP FUNCTION dostepne_wycieczki2;
DROP TYPE dostepne_wycieczki2_table;
DROP TYPE dostepne_wycieczki2_type;

CREATE TYPE dostepne_wycieczki2_type AS OBJECT (
  id_wyczieczki NUMBER,
  kraj VARCHAR2(50),
  data_ DATE,
  nazwa_wycieczki VARCHAR2(100),
  liczba_wolnych_miejsc NUMBER
);

CREATE TYPE dostepne_wycieczki2_table AS TABLE OF dostepne_wycieczki2_type;

CREATE FUNCTION dostepne_wycieczki2 (szukany_kraj in VARCHAR2, data_od in DATE, data_do in DATE)
  RETURN dostepne_wycieczki2_table
AS
  naz_kraju NUMBER(1);
  wycieczki2 dostepne_wycieczki2_table;
  BEGIN
    wycieczki2 := dostepne_wycieczki2_table();

    SELECT CASE
      WHEN EXISTS(SELECT *
                  FROM wycieczki w
                  WHERE w.KRAJ = szukany_kraj)
        THEN 1
        ELSE 0
    END
    INTO naz_kraju FROM dual;

    IF naz_kraju = 0 THEN
        raise_application_error(-20001, 'Kraj o podanej nazwie nie występuję w bazie danych!');
    END IF;

    SELECT dostepne_wycieczki2_type(wm.id_wycieczki, wm.kraj, wm.data, wm.nazwa, wm.liczba_wolnych_miejsc)
    BULK COLLECT INTO wycieczki2
    FROM wycieczki_miejsca wm
    WHERE (wm.DATA >= data_od AND wm.DATA <= data_do) AND wm.KRAJ = szukany_kraj AND wm.liczba_wolnych_miejsc > 0;

    RETURN wycieczki2;
END;

SELECT * FROM uczestnicy_wycieczki(1);
SELECT * FROM rezerwacje_osoby(2);
SELECT * FROM przyszle_rezerwacje_osoby(10);
SELECT * FROM dostepne_wycieczki2('Włochy', '2018-12-01', '2018-12-14');