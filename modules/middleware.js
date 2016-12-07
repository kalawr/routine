let _ = require('lodash');
let bodyParser = require('body-parser');
let database = require('./database');

let db = database.initialize();

module.exports = {};

module.exports.cors = cors;

module.exports.json = bodyParser.json();

module.exports.all = all;

module.exports.one = one;

module.exports.create = create;

module.exports.tick = tick;

module.exports.untick = untick;

module.exports.delete = del;

module.exports.rename = rename;

function cors(req, res, next)
{
	res.set(
		'Access-Control-Allow-Origin', '*'
	);

	next();
}

function notImplemented(req, res, next)
{
	res.sendStatus(501);
}

function tick(req, res, next)
{
	if (req.body.action === "tick")
	{
		database.ticks.today(
			db,
			req.params.id,
			req.body.date,
			function (err, row)
			{
				if (err)
				{
					res
						.status(500)
						.send(err);

					console.log(err);
				}
				else if (row)
				{
					res
						.status(302) // 302 Found
						.send(row);
				}
				else
				{
					database.ticks.insert(
						db,
						req.params.id,
						req.body.date,
						function (err)
						{
							if (err)
							{
								res
									.status(500)
									.send(err);
								
								console.log(err, 2);
							}
							else
							{
								var id = this.lastID;


								database.ticks.one(
									db,
									id,
									function (err, row)
									{
										if (err)
										{
											res
												.status(500)
												.send(err);

											console.log(err);
										}
										else
										{
											res
												.status(200)
												.send(row);
										}
									}
								);
							} 
						}
					);
				}
			}

		);
	}
	else
	{
		next();
	}
}

function untick(req, res, next)
{
	if (req.body.action === "untick")
	{
		database.ticks.deleteTodays(
			db,
			req.params.id,
			req.body.date,
			function (err)
			{
				if (err)
				{
					res
						.status(500)
						.send(err);

					console.log(err);
				}
				else
				{
					res
						.status(200)
						.send(
							{
								routine: parseInt(req.params.id),
								date: req.body.date
							}
						);
				}
			}
		);
	}
	else
	{
		next();
	}
}

function create(req, res, next)
{
	database.routines.insert(
		db,
		req.body,
		function (err)
		{
			if (err)
			{
				res.sendStatus(500);
				console.log(err);
			}
			else
			{
				database.routines.one(
					db,
					this.lastID,
					function (err, body)
					{
						if (err)
						{
							res.sendStatus(500);
						}
						else
						{
							res.status(200).send(
								nest([body])[0]
							);
						}
					}
				);
			}
		}
	);
}

function all(req, res, next)
{
	database.routines.all(
		db,
		function (err, body)
		{
			if (err)
			{
				res.sendStatus(500);
				console.log(err);
			}
			else
			{
				res
					.status(200)
					.send(
						nest(body)
					);
			}
		}
	);
}

function one(req, res, next)
{
	database.routines.one(
		db,
		req.params.id,
		function (err, body)
		{
			if (err)
			{
				res.sendStatus(500);
				console.log(err);
			}
			else
			{
				res.status(200).send(body);
				console.log(body);
			}
		}
	);
}

function del(req, res, next)
{
	database.routines.delete(
		db,
		req.params.id,
		function (err)
		{
			if (err)
			{
				res.sendStatus(500);
				console.log(err);
			}
			else
			{
				res
					.status(200)
					.send(
						{
							id: parseInt(req.params.id)
						}
					);
			}
		}
	);
}

function nest(rows)
{
	var output = _.uniqBy(
		_.map(rows,
			function (row)
			{
				return _.extend(
					_.pick(row, ['id', 'created', 'name']),
					{
						progress: []
					}
				);
			}
		),
		'id'
	);

	for (var i = 0; i < rows.length; i++)
	{
		if (rows[i].tickId)
		{
			_.map(output,
				function (row)
				{
					if (row.id == rows[i].id)
					{
						var clone = _.clone(row);

						clone.progress.push(
							{
								id: rows[i].tickId,
								date: rows[i].tickDate
							}
						);
					}

					return clone || row;
				}
			)
		}
	}

	return _.values(output);
}

function rename(req, res, next)
{
	if (req.body.action === "rename" )
	{
		database.routines.update(
			db,
			req.params.id,
			req.body.name,
			function (err)
			{
				if (err)
				{
					res
						.status(500)
						.send(err);

					console.log(err);
				}
				else
				{
					res
						.status(200)
						.send(
							{
								id: parseInt(req.params.id),
								name: req.body.name
							}
						);
				}
			}
		);
	}
	else
	{
		next();
	}
}