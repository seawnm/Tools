--選擇查詢的DB Name
--USE Cognos

SELECT (select distinct TABLE_CATALOG from information_schema.tables) DBName,[ROLE] = su.name, [OBJECT] = so.name,
[OBJECT TYPE] = CASE so.type
WHEN 'C' THEN 'CHECK constraint'
WHEN 'D' THEN 'Default or DEFAULT constraint'
WHEN 'F' THEN 'FOREIGN KEY constraint'
WHEN 'FN' THEN 'Scalar function'
WHEN 'IF' THEN 'Inlined table-function'
WHEN 'K' THEN 'PRIMARY KEY or UNIQUE constraint'
WHEN 'L' THEN 'Log'
WHEN 'P' THEN 'Stored procedure'
WHEN 'R' THEN 'Rule'
WHEN 'RF' THEN 'Replication filter stored procedure'
WHEN 'S' THEN 'System table'
WHEN 'TF' THEN 'Table function'
WHEN 'TR' THEN 'Trigger'
WHEN 'U' THEN 'User table'
WHEN 'V' THEN 'View'
WHEN 'X' THEN 'Extended stored procedure'
ELSE 'OTHER'
END, 
--sc.name 'COLUMN NAME', 
[ACTION] = CASE sp.action
WHEN 26 THEN 'REFERENCES'
WHEN 178 THEN 'CREATE FUNCTION'
WHEN 193 THEN 'SELECT'
WHEN 195 THEN 'INSERT'
WHEN 196 THEN 'DELETE'
WHEN 197 THEN 'UPDATE'
WHEN 198 THEN 'CREATE TABLE'
WHEN 203 THEN 'CREATE DATABASE'
WHEN 207 THEN 'CREATE VIEW'
WHEN 222 THEN 'CREATE PROCEDURE'
WHEN 224 THEN 'EXECUTE'
WHEN 228 THEN 'BACKUP DATABASE'
WHEN 233 THEN 'CREATE DEFAULT'
WHEN 235 THEN 'BACKUP LOG'
WHEN 236 THEN 'CREATE RULE'
ELSE 'OTHER'
END,
[PROTECT TYPE] = CASE sp.protecttype
WHEN 204 THEN 'GRANT_W_GRANT'
WHEN 205 THEN 'GRANT'
WHEN 206 THEN 'REVOKE'
ELSE 'OTHER'
END,
[PROTECTION APPLIES] = CASE
WHEN sp.columns = 1 THEN 'ALL COLUMNS'
WHEN sp.columns > 1 THEN 'SPECIFIC COLUMNS'
ELSE 'N/A'
END
FROM sysprotects sp
INNER JOIN sysusers su ON sp.uid = su.uid
INNER JOIN sysobjects so ON so.id = sp.id
--INNER JOIN syscolumns sc ON so.id = sc.id
