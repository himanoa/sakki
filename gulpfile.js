const gulp = require("gulp");
const sass = require('gulp-sass');
const postcss      = require('gulp-postcss');
const sourcemaps   = require('gulp-sourcemaps');
const autoprefixer = require('autoprefixer');
const process = require('gulp-process');

gulp.task('sass', function () {
  return gulp.src('./sass/**/*.scss')
    .pipe(sass().on('error', sass.logError))
    .pipe(gulp.dest('./tmp/css'));
});

gulp.task('sass:watch', function () {
  gulp.watch('./sass/**/*.scss', ['sass']);
});

gulp.task('autoprefixer', ['sass'], function () {
    return gulp.src('./tmp/css/*.css')
        .pipe(sourcemaps.init())
        .pipe(postcss([ autoprefixer() ]))
        .pipe(sourcemaps.write('.'))
        .pipe(gulp.dest('./public/css'));
});

gulp.task('autoprefixer:watch', function () {
  gulp.watch('./tmp/css/*.css', ['autoprefixer']);
});

gulp.task('build', ['sass', 'autoprefixer']);

gulp.task('default', ['build'], function() {
  gulp.watch('./sass/**/*.scss', ['sass']);
  gulp.watch('./tmp/css/*.css', ['autoprefixer']);
  process.start('guard', 'bundle', ['exec' ,'guard', '--no-interactions']);
});
