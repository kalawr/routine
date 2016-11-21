let express = require('express');
let middleware = require('./modules/middleware');
let compression = require('compression');

let app = express();

app.use(compression());
app.use(express.static('./src'));
app.use(middleware.cors);
app.use(middleware.json);

app.get('/api/routines',
	middleware.all
);

app.get('/api/routines/:id',
	middleware.one
);

app.put('/api/routines',
	middleware.create
);

app.post('/api/routines/:id',
	middleware.tick,
	middleware.untick,
	middleware.rename
);

app.delete('/api/routines/:id',
	middleware.delete
);

app.listen(3000, onListening);

function onListening()
{
	console.log('App live on localhost:3000');
}