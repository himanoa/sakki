const gulp = require("gulp");
const sass = require('gulp-sass');
const postcss      = require('gulp-postcss');
const sourcemaps   = require('gulp-sourcemaps');
const autoprefixer = require('autoprefixer');
const process = require('gulp-process');
const browserify = require('browserify');
const babelify = require('babelify');
const source = require('vinyl-source-stream');

gulp.task('sass', function () {
  return gulp.src('./sass/**/*.scss')
    .pipe(sourcemaps.init())
    .pipe(sass().on('error', sass.logError))
    .pipe(postcss([ autoprefixer() ]))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest('./public/css'));
});

gulp.task('sass:watch', function () {
  gulp.watch('./sass/**/*.scss', ['sass']);
});

gulp.task('babelify', function(){
  browserify({
    entries: './js/app.js',
    extensions: ['.js']
  })
  .transform(babelify)
  .bundle()
  .on("error", function(err){
    console.error(err);
    this.emit("end");
  })
  .pipe(source("app.js"))
  .pipe(gulp.dest("./public/js"))
})

gulp.task('build', ['sass']);

gulp.task('default', ['build'], function() {
  gulp.watch('./sass/**/*.scss', ['sass']);
  process.start('guard', 'bundle', ['exec', 'guard', '--no-interactions']);
});
