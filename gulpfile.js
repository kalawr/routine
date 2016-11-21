var gulp = require('gulp');
var elm  = require('gulp-elm');

var paths = {
	elm: {
		src: './src/Main.elm',
		watch: './src/**/*.elm',
		dest: './src/compiled',
		filename: 'app.js'
	}
};

var elmOptions = {
	debug: true
};

gulp.task('elm-init', elm.init);

gulp.task('elm',
	['elm-init'],
	function ()
	{
		return gulp.src(paths.elm.src)
			.pipe(
				elm.bundle(
					paths.elm.filename,
					elmOptions
				)
			)
			.pipe(gulp.dest(paths.elm.dest));
	}
);

gulp.task('watch',
	['elm'],
	function ()
	{
		return gulp.watch(
			paths.elm.watch,
			['elm']
		);
	}
);