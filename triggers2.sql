CREATE OR REPLACE TRIGGER licz_wol_miejsc_insert_trigger
    AFTER INSERT ON REZERWACJE
    FOR EACH ROW
    WHEN (NEW.STATUS IN ('N','P','Z'));
    BEGIN
        UPDATE WYCIECZKI w
        SET w.LICZBA_WOLNYCH_MIEJSC = w.LICZBA_WOLNYCH_MIEJSC - 1;
        WHERE w.ID_WYCIECZKI = :NEW.ID_WYCIECZKI
    END;

CREATE OR REPLACE PROCEDURE DODAJ_REZERWACJE4
   ( id_dodawanej_wycieczki IN int, id_dodawanej_osoby in int)
IS
  sprawdz_osobe NUMBER(1); 
  sprawdz_wycieczke NUMBER(1);
BEGIN
  SELECT
    CASE
      WHEN EXISTS(SELECT * FROM WYCIECZKI_MIEJSCA wm
                  WHERE wm.ID_WYCIECZKI = id_dodawanej_wycieczki AND wm.DATA > SYSDATE)
        THEN 1
      ELSE 0
    END
  INTO sprawdz_wycieczke FROM DUAL;

  SELECT
    CASE
      WHEN EXISTS(SELECT * FROM OSOBY o
                    WHERE o.ID_OSOBY = id_dodawanej_osoby)
        THEN 1
      ELSE 0
    END
  INTO sprawdz_osobe FROM DUAL;

  IF sprawdz_wycieczke = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Wycieczka jest nieosiagalna.');
  END IF;

  IF sprawdz_osobe = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Nie mozna dodac tej osoby');
  END IF;

  INSERT INTO rezerwacje(id_wycieczki, id_osoby, status)
  VALUES (id_dodawanej_wycieczki, id_dodawanej_osoby, 'N');

END;


CREATE OR REPLACE TRIGGER licz_wol_miejsc_update_trigger
    AFTER UPDATE OF STATUS ON REZERWACJE
    FOR EACH ROW
    WHEN (NEW.STATUS IN ('A'))
    BEGIN
        UPDATE WYCIECZKI w
        SET w.LICZBA_WOLNYCH_MIEJSC = w.LICZBA_WOLNYCH_MIEJSC + 1
        WHERE w.ID_WYCIECZKI = :NEW.ID_WYCIECZKI;
    END;

CREATE OR REPLACE PROCEDURE ZMIEN_STATUS_REZERWACJI4
   ( id_zmienianej_rezerwacji IN INT, nowy_status IN CHAR)
IS
  sprawdz_rezerwacje NUMBER(1); 
  sprawdz_status NUMBER(1);
  stary_status CHAR(1);
BEGIN
  SELECT
    CASE
      WHEN EXISTS(SELECT * 
                  FROM REZERWACJE r
                  JOIN WYCIECZKI w ON r.ID_WYCIECZKI = w.ID_WYCIECZKI
                  WHERE r.NR_REZERWACJI = id_zmienianej_rezerwacji AND W.DATA > CURRENT_DATE)
        THEN 1
      ELSE 0
    END
  INTO sprawdz_rezerwacje FROM DUAL;

  IF nowy_status IN ('A', 'N', 'P', 'Z') THEN
    SELECT 1 INTO sprawdz_status FROM DUAL;  
  ELSE
    SELECT 0 INTO sprawdz_status FROM DUAL; 
  END IF;

  IF sprawdz_rezerwacje = 0 THEN
    raise_application_error(-20000, 'Podana rezerwacja jest nieosiagalna');
  END IF;
  IF sprawdz_status = 0 THEN
    raise_application_error(-20000, 'Wybrano bledny status. (A, N, P, Z)');
  END IF;

  SELECT r.STATUS
  INTO stary_status
  FROM REZERWACJE r
  WHERE r.NR_REZERWACJI = id_zmienianej_rezerwacji and ROWNUM = 1;

  IF stary_status = 'A' THEN
    raise_application_error(-20000, 'Rezerwacja jest juz anulowana!');
  END IF;
  IF (stary_status = 'Z' AND nowy_status IN ('N', 'P', 'Z')) THEN
    raise_application_error(-20000, 'Rezerwacja zaplacona, chcesz ja anulowac?');
  END IF;
  IF (stary_status = 'N' AND nowy_status = 'N') THEN
    raise_application_error(-20000, 'Nadpisujesz obecny stan!');
  END IF;
  IF (stary_status = 'P' AND nowy_status IN ('N', 'P')) THEN
    raise_application_error(-20000, 'Mozesz jedynie ustalic jako zaplacone lub anulowone!');
  END IF;
  
  UPDATE REZERWACJE r
  SET r.STATUS = nowy_status
  WHERE r.NR_REZERWACJI = id_zmienianej_rezerwacji;
  
END;

CREATE OR REPLACE TRIGGER licz_wol_miejsc_wycieczki_update_trigger
    AFTER UPDATE OF LICZBA_WOLNYCH_MIEJSC ON WYCIECZKI
    FOR EACH ROW
    WHEN (NEW.LICZBA_WOLNYCH_MIEJSC != OLD.LICZBA_WOLNYCH_MIEJSC) 
    BEGIN
        UPDATE WYCIECZKI w
        SET w.LICZBA_WOLNYCH_MIEJSC = w.LICZBA_WOLNYCH_MIEJSC + 1
        WHERE w.ID_WYCIECZKI = :NEW.ID_WYCIECZKI;
    END;

CREATE OR REPLACE PROCEDURE ZMIEN_LICZBE_MIEJSC4
    (id_szukanej_wycieczki in INT, nowa_liczba_miejsc in INT)
  AS
    sprawdz_wycieczke NUMBER(1);
    sprawdz_liczbe_miejsc NUMBER(1);
  BEGIN
    SELECT 
      CASE
        WHEN exists(SELECT *
                  FROM WYCIECZKI w
                  WHERE w.ID_WYCIECZKI = id_szukanej_wycieczki AND w.DATA > CURRENT_DATE)
        THEN 1
        ELSE 0
    END
    INTO sprawdz_wycieczke FROM dual;

    SELECT
      CASE
        WHEN EXISTS(SELECT * FROM WYCIECZKI w
                    WHERE w.ID_WYCIECZKI = id_szukanej_wycieczki
                    AND ( w.LICZBA_MIEJSC - w.LICZBA_WOLNYCH_MIEJSC < nowa_liczba_miejsc ))
        THEN 1
        ELSE 0
    END
    INTO sprawdz_liczbe_miejsc FROM DUAL;

    IF sprawdz_wycieczke = 0 THEN
      raise_application_error(-20000, 'Wycieczka nieosiagalna!');
    END IF;
    
    IF sprawdz_liczbe_miejsc = 0 THEN
      raise_application_error(-20000, 'Za mala ilosc miejsc!');
    END IF;

    UPDATE WYCIECZKI w
    SET w.LICZBA_MIEJSC = nowa_liczba_miejsc
    WHERE w.ID_WYCIECZKI = id_szukanej_wycieczki;
  END;