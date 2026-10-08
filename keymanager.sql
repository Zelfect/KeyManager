-- KeyManager — база данных SQLite по Class-диаграмме
-- Запуск:  sqlite3 keymanager.db < keymanager.sql

PRAGMA foreign_keys = ON;   -- без этого каскад в SQLite не работает

DROP TABLE IF EXISTS Notification;
DROP TABLE IF EXISTS KeyRequest;
DROP TABLE IF EXISTS KeyTransaction;
DROP TABLE IF EXISTS Key;
DROP TABLE IF EXISTS Room;
DROP TABLE IF EXISTS User;

-- User  (enum UserRole: Admin, Employee, Manager)
CREATE TABLE User (
    Id           INTEGER PRIMARY KEY AUTOINCREMENT,
    FullName     TEXT NOT NULL,
    Email        TEXT NOT NULL UNIQUE,
    PasswordHash TEXT NOT NULL,
    Role         TEXT NOT NULL CHECK (Role IN ('Admin', 'Employee', 'Manager')),
    Department   TEXT
);

-- Room
CREATE TABLE Room (
    Id         INTEGER PRIMARY KEY AUTOINCREMENT,
    RoomNumber TEXT NOT NULL,
    Name       TEXT NOT NULL,
    Building   TEXT,
    Floor      INTEGER
);

-- Key  (enum KeyStatus: Available, Issued, Overdue, Blocked)
-- Room 1 --- 1..* Key
CREATE TABLE Key (
    Id        INTEGER PRIMARY KEY AUTOINCREMENT,
    KeyNumber TEXT NOT NULL UNIQUE,
    RoomId    INTEGER NOT NULL,
    Status    TEXT NOT NULL DEFAULT 'Available'
              CHECK (Status IN ('Available', 'Issued', 'Overdue', 'Blocked')),
    QrCode    TEXT,
    FOREIGN KEY (RoomId) REFERENCES Room(Id) ON DELETE CASCADE
);

-- KeyTransaction  (enum TransactionStatus: Active, Returned, Overdue)
-- Key 1 --- 0..* KeyTransaction,  User 1 --- 0..* KeyTransaction
CREATE TABLE KeyTransaction (
    Id               INTEGER PRIMARY KEY AUTOINCREMENT,
    KeyId            INTEGER NOT NULL,
    UserId           INTEGER NOT NULL,      -- кто взял ключ
    IssuedByUserId   INTEGER NOT NULL,      -- кто выдал (админ)
    IssuedAt         TEXT NOT NULL DEFAULT (datetime('now')),
    ExpectedReturnAt TEXT NOT NULL,
    ReturnedAt       TEXT,                  -- DateTime? = может быть NULL
    Reason           TEXT,
    Status           TEXT NOT NULL DEFAULT 'Active'
                     CHECK (Status IN ('Active', 'Returned', 'Overdue')),
    FOREIGN KEY (KeyId)          REFERENCES Key(Id)  ON DELETE CASCADE,
    FOREIGN KEY (UserId)         REFERENCES User(Id) ON DELETE CASCADE,
    FOREIGN KEY (IssuedByUserId) REFERENCES User(Id) ON DELETE CASCADE
);

-- KeyRequest  (enum RequestStatus: Pending, Approved, Rejected)
-- User 1 --- 0..* KeyRequest,  Key 1 --- 0..* KeyRequest
CREATE TABLE KeyRequest (
    Id          INTEGER PRIMARY KEY AUTOINCREMENT,
    UserId      INTEGER NOT NULL,
    KeyId       INTEGER NOT NULL,
    Reason      TEXT,
    PlannedFrom TEXT NOT NULL,
    PlannedTo   TEXT NOT NULL,
    Status      TEXT NOT NULL DEFAULT 'Pending'
                CHECK (Status IN ('Pending', 'Approved', 'Rejected')),
    FOREIGN KEY (UserId) REFERENCES User(Id) ON DELETE CASCADE,
    FOREIGN KEY (KeyId)  REFERENCES Key(Id)  ON DELETE CASCADE
);

-- Notification
-- User 1 --- 0..* Notification
CREATE TABLE Notification (
    Id        INTEGER PRIMARY KEY AUTOINCREMENT,
    UserId    INTEGER NOT NULL,
    Message   TEXT NOT NULL,
    CreatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    IsRead    INTEGER NOT NULL DEFAULT 0 CHECK (IsRead IN (0, 1)),
    FOREIGN KEY (UserId) REFERENCES User(Id) ON DELETE CASCADE
);

-- Тестовые данные
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
