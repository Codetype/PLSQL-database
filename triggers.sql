--a)
CREATE OR REPLACE TRIGGER dodaj_rezrwacje_trigger
    AFTER INSERT ON REZERWACJE
    FOR EACH ROW
    DECLARE
        nowy_numer_rez INT;
    BEGIN
        nowy_numer_rez := :NEW.NR_REZERWACJI;
        INSERT INTO REZERWACJE_LOG (ID_REZERWACJI, DATA_REZERWACJI, STATUS_REZERWACJI) VALUES (nowy_numer_rez, SYSDATE, 'N');
    END;

CREATE OR REPLACE PROCEDURE DODAJ_REZERWACJE3
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

  UPDATE WYCIECZKI w
  SET w.LICZBA_WOLNYCH_MIEJSC = w.LICZBA_WOLNYCH_MIEJSC - 1
  WHERE w.ID_WYCIECZKI = id_dodawanej_wycieczki;

END;


--B)
CREATE OR REPLACE TRIGGER zmien_status_trigger
    AFTER UPDATE ON REZERWACJE
    FOR EACH ROW
    DECLARE
        nowy_numer_rez INT;
        nowy_status_rez CHAR(1);
    BEGIN
        nowy_numer_rez := :NEW.NR_REZERWACJI;
        nowy_status_rez := :NEW.STATUS;
        INSERT INTO REZERWACJE_LOG (ID_REZERWACJI, DATA_REZERWACJI, STATUS_REZERWACJI) VALUES (nowy_numer_rez, SYSDATE, nowy_status_rez);
    END;

CREATE OR REPLACE PROCEDURE ZMIEN_STATUS_REZERWACJI3
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

  IF nowy_status = 'A' THEN
    UPDATE WYCIECZKI w
    SET w.LICZBA_WOLNYCH_MIEJSC = w.LICZBA_WOLNYCH_MIEJSC + 1
    WHERE w.ID_WYCIECZKI = (SELECT r.ID_WYCIECZKI FROM REZERWACJE r WHERE r.NR_REZERWACJI = id_zmienianej_rezerwacji );
  END IF;
  
END;


CREATE OR REPLACE TRIGGER usun_rezerwacje_trigger
    BEFORE DELETE ON REZERWACJE
    FOR EACH ROW
    DECLARE
        numer_usuw_rez INT;
    BEGIN
        numer_usuw_rez := :OLD.NR_REZERWACJI;
        INSERT INTO REZERWACJE_LOG (ID_REZERWACJI, DATA_REZERWACJI, STATUS_REZERWACJI) VALUES (numer_usuw_rez, SYSDATE, 'A');
        RAISE_APPLICATION_ERROR(-20001, 'Usuwanie rezerwacji zabronione! Anulowano rezerwacje.');
    END;

-------------------------------------------------------------------------