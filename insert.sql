--osoby
INSERT INTO osoby (imie, nazwisko, pesel, kontakt)
VALUES('Adam', 'Kowalski', '87654321', 'tel: 6623');

INSERT INTO osoby (imie, nazwisko, pesel, kontakt)
VALUES('Jan', 'Nowak', '12345678', 'tel: 2312, dzwonić po 18.00');

INSERT INTO osoby (imie, nazwisko, pesel, kontakt)
VALUES('Paweł', 'Wiśniewski', '23456781', 'tel: 1298');

INSERT INTO osoby (imie, nazwisko, pesel, kontakt)
VALUES('Natalia', 'Wójcik', '34567812', 'tel: 2387');

INSERT INTO osoby (imie, nazwisko, pesel, kontakt)
VALUES('Michał', 'Kowalczyk', '45678123', 'tel: 3476');

INSERT INTO osoby (imie, nazwisko, pesel, kontakt)
VALUES('Justyna', 'Kamińska', '56781234', 'tel: 4565');

INSERT INTO osoby (imie, nazwisko, pesel, kontakt)
VALUES('Filip', 'Lewandowski', '67812345', 'tel: 5654');

INSERT INTO osoby (imie, nazwisko, pesel, kontakt)
VALUES('Magdalena', 'Zieliński', '78123456', 'tel: 6743');

INSERT INTO osoby (imie, nazwisko, pesel, kontakt)
VALUES('Tomasz', 'Szymański', '67891234', 'tel: 8921');

INSERT INTO osoby (imie, nazwisko, pesel, kontakt)
VALUES('Ewa', 'Woźniak', '67891234', 'tel: 8822');

--wycieczki
INSERT INTO wycieczki (nazwa, kraj, data, opis, liczba_miejsc)
VALUES ('Wycieczka do Paryza','Francja','2016-01-01','Ciekawa wycieczka ...',3);

INSERT INTO wycieczki (nazwa, kraj, data, opis, liczba_miejsc)
VALUES ('Piękny Kraków','Polska','2017-02-03','Najciekawa wycieczka ...',2);

INSERT INTO wycieczki (nazwa, kraj, data, opis, liczba_miejsc)
VALUES ('Wieliczka','Polska','2017-03-03','Zadziwiająca kopalnia ...',2);

INSERT INTO wycieczki (nazwa, kraj, data, opis, liczba_miejsc)
VALUES ('Rzym','Włochy','2018-12-01','Piękne miasto ...',6);

--rezerwacje
INSERT INTO rezerwacje(id_wycieczki, id_osoby, status)
VALUES (1,1,'N');

INSERT INTO rezerwacje(id_wycieczki, id_osoby, status)
VALUES (2,2,'P');

INSERT INTO rezerwacje(id_wycieczki, id_osoby, status)
VALUES (4,7,'A');

INSERT INTO rezerwacje(id_wycieczki, id_osoby, status)
VALUES (4,8,'P');

INSERT INTO rezerwacje(id_wycieczki, id_osoby, status)
VALUES (4,9,'Z');

INSERT INTO rezerwacje(id_wycieczki, id_osoby, status)
VALUES (4,10,'P');

INSERT INTO rezerwacje(id_wycieczki, id_osoby, status)
VALUES (1,3,'N');

INSERT INTO rezerwacje(id_wycieczki, id_osoby, status)
VALUES (1,4,'A');

INSERT INTO rezerwacje(id_wycieczki, id_osoby, status)
VALUES (3,5,'P');

INSERT INTO rezerwacje(id_wycieczki, id_osoby, status)
VALUES (3,6,'Z');