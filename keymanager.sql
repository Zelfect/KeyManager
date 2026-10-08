CREATE TABLE User (
    Id           INTEGER PRIMARY KEY AUTOINCREMENT,
    FullName     TEXT NOT NULL,
    Email        TEXT NOT NULL UNIQUE,
    PasswordHash TEXT NOT NULL,
    Role         TEXT NOT NULL CHECK (Role IN ('Admin', 'Employee', 'Manager')),
    Department   TEXT
);


CREATE TABLE Room (
    Id         INTEGER PRIMARY KEY AUTOINCREMENT,
    RoomNumber TEXT NOT NULL,
    Name       TEXT NOT NULL,
    Building   TEXT,
    Floor      INTEGER
);


CREATE TABLE Key (
    Id        INTEGER PRIMARY KEY AUTOINCREMENT,
    KeyNumber TEXT NOT NULL UNIQUE,
    RoomId    INTEGER NOT NULL,
    Status    TEXT NOT NULL DEFAULT 'Available'
              CHECK (Status IN ('Available', 'Issued', 'Overdue', 'Blocked')),
    QrCode    TEXT,
    FOREIGN KEY (RoomId) REFERENCES Room(Id) 
);


CREATE TABLE KeyTransaction (
    Id               INTEGER PRIMARY KEY AUTOINCREMENT,
    KeyId            INTEGER NOT NULL,
    UserId           INTEGER NOT NULL,      
    IssuedByUserId   INTEGER NOT NULL,      
    IssuedAt         TEXT NOT NULL DEFAULT (datetime('now')),
    ExpectedReturnAt TEXT NOT NULL,
    ReturnedAt       TEXT,                  
    Reason           TEXT,
    Status           TEXT NOT NULL DEFAULT 'Active'
                     CHECK (Status IN ('Active', 'Returned', 'Overdue')),
    FOREIGN KEY (KeyId)          REFERENCES Key(Id)  ,
    FOREIGN KEY (UserId)         REFERENCES User(Id) ,
    FOREIGN KEY (IssuedByUserId) REFERENCES User(Id) 
);


CREATE TABLE KeyRequest (
    Id          INTEGER PRIMARY KEY AUTOINCREMENT,
    UserId      INTEGER NOT NULL,
    KeyId       INTEGER NOT NULL,
    Reason      TEXT,
    PlannedFrom TEXT NOT NULL,
    PlannedTo   TEXT NOT NULL,
    Status      TEXT NOT NULL DEFAULT 'Pending'
                CHECK (Status IN ('Pending', 'Approved', 'Rejected')),
    FOREIGN KEY (UserId) REFERENCES User(Id) ,
    FOREIGN KEY (KeyId)  REFERENCES Key(Id)  
);


CREATE TABLE Notification (
    Id        INTEGER PRIMARY KEY AUTOINCREMENT,
    UserId    INTEGER NOT NULL,
    Message   TEXT NOT NULL,
    CreatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    IsRead    INTEGER NOT NULL DEFAULT 0 CHECK (IsRead IN (0, 1)),
    FOREIGN KEY (UserId) REFERENCES User(Id) 
);


INSERT INTO User (FullName, Email, PasswordHash, Role, Department) VALUES
 ('Админ', 'admin@univ.kz',   'hash1', 'Admin',    'Хоз. отдел'),
 ('Ержан', 'yerzhan@univ.kz', 'hash2', 'Employee', 'Информатика');

INSERT INTO Room (RoomNumber, Name, Building, Floor) VALUES
 ('305', 'Аудитория 305', 'Главный корпус', 3);

INSERT INTO Key (KeyNumber, RoomId, QrCode) VALUES ('K-035', 1, 'QR-K035');

INSERT INTO KeyTransaction (KeyId, UserId, IssuedByUserId, ExpectedReturnAt, Reason)
VALUES (1, 2, 1, datetime('now', '+2 hours'), 'Сабақ өткізу');



INSERT INTO KeyRequest (UserId, KeyId, Reason, PlannedFrom, PlannedTo)
VALUES (2, 1, 'Сабақ өткізу', '2026-10-09 10:00:00', '2026-10-09 12:00:00');

INSERT INTO Notification (UserId, Message) VALUES (2, 'Вам выдан ключ K-035');
