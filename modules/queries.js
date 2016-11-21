module.exports = {};

module.exports.CREATE_ROUTINE_TABLE_CONDITIONALLY = `
CREATE TABLE IF NOT EXISTS routine
( id INTEGER PRIMARY KEY AUTOINCREMENT
, name TEXT UNIQUE
, created TEXT
);
`;

module.exports.CREATE_TICK_TABLE_CONDITIONALLY = `
CREATE TABLE IF NOT EXISTS tick
( id INTEGER PRIMARY KEY AUTOINCREMENT
, routine INTEGER
, date TEXT
);
`;

module.exports.INSERT_ROUTINE = `
INSERT INTO routine
( name
, created
)
VALUES
( ?
, ?
);
`;

module.exports.INSERT_TICK = `
INSERT INTO tick
( routine
, date
)
VALUES
( ?
, ?
);
`;

module.exports.SELECT_ROUTINES = `
SELECT
  routine.id,
  routine.created,
  routine.name,
  tick.id as tickId,
  tick.date as tickDate
FROM routine
LEFT OUTER JOIN tick
ON routine.id = tick.routine;
`;

module.exports.SELECT_ROUTINE = `
SELECT *
FROM routine
WHERE routine.id = ?;
`;

module.exports.SELECT_ROUTINE_AND_ITS_TICKS = `
SELECT
  routine.id,
  routine.created,
  routine.name,
  tick.id as tickId,
  tick.date as tickDate
FROM routine
LEFT OUTER JOIN tick
ON routine.id = tick.routine
WHERE routine.id = ?;
`;

module.exports.SELECT_TICK_BY_ID_AND_DATE = `
SELECT *
FROM tick
WHERE tick.routine = ?
AND tick.date = ?;
`;

module.exports.SELECT_TICK_BY_ID = `
SELECT *
FROM tick
WHERE tick.id = ?;
`;

module.exports.DELETE_ROUTINE = `
DELETE FROM routine
WHERE routine.id = ?;
`;

module.exports.SELECT_TICKS = `
SELECT *
FROM tick
WHERE tick.id = ?;
`;

module.exports.DELETE_TODAYS_TICK = `
DELETE FROM tick
WHERE tick.routine = ?
AND tick.date = ?;
`;

module.exports.UPDATE_ROUTINE_NAME = `
UPDATE routine
SET name = ?
WHERE id = ?;
`;