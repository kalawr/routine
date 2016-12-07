let fs = require('fs');
let path = require('path');
let mkdirp = require('mkdirp');
let sqlite = require('sqlite3').verbose();
let queries = require('./queries');

let filename = path.resolve(
	__dirname,
	'../db/main.db'
);

module.exports = {};

module.exports.initialize = function ()
{
	// Ensure the database file exists. Create one if it doesn't.
	mkdirp(path.dirname(filename),
		function (err)
		{
			if (err) console.log(err);

			fs.writeFile(filename, '', { flag: 'wx' }, function () {});
		}
	);

	var db = new sqlite.Database(filename);

	db.run(queries.CREATE_ROUTINE_TABLE_CONDITIONALLY);
	db.run(queries.CREATE_TICK_TABLE_CONDITIONALLY);

	return db;
};

module.exports.routines = {};

module.exports.routines.insert = function (db, values, callback)
{
	db.run(
		queries.INSERT_ROUTINE,
		values.name,
		timestamp(),
		callback
	);
};

module.exports.routines.all = function (db, callback)
{
	db.all(
		queries.SELECT_ROUTINES,
		callback
	);
};

module.exports.routines.one = function (db, id, callback)
{
	db.get(
		queries.SELECT_ROUTINE_AND_ITS_TICKS,
		id,
		callback
	);
};

module.exports.routines.delete = function (db, id, callback)
{
	db.run(
		queries.DELETE_ROUTINE,
		id,
		callback
	);
};

module.exports.routines.update = function (db, id, name, callback)
{
	db.run(
		queries.UPDATE_ROUTINE_NAME,
		name,
		id,
		callback
	);
};

module.exports.ticks = {};

module.exports.ticks.insert = function (db, id, date, callback)
{
	db.run(
		queries.INSERT_TICK,
		id,
		date,
		callback
	);
};

module.exports.ticks.select = function (db, id, callback)
{
	db.all(
		queries.SELECT_TICKS,
		id,
		callback
	);
};

module.exports.ticks.today = function (db, id, date, callback)
{
	db.get(
		queries.SELECT_TICK_BY_ID_AND_DATE,
		id,
		date,
		callback
	);
};

module.exports.ticks.deleteTodays = function (db, id, date, callback)
{
	db.run(
		queries.DELETE_TODAYS_TICK,
		id,
		date,
		callback
	);
};

module.exports.ticks.one = function (db, id, callback)
{
	db.get(
		queries.SELECT_TICK_BY_ID,
		id,
		callback
	);
};

function timestamp()
{
	return (new Date()).toJSON();
}

function today()
{
	return (new Date()).toDateString();
}