const gulp = require('gulp')
const watch = require('gulp-watch')
const sourcemaps = require('gulp-sourcemaps')
const autoprefixer = require('gulp-autoprefixer')
const less = require('gulp-less')
const cssnano = require('gulp-cssnano')
const path = require('path')

function compileLess (input) {
  return input
    .pipe(sourcemaps.init())
    .pipe(less({
      paths: [path.join(__dirname, 'css')]
    }))
    .pipe(autoprefixer({ browsers: ['last 2 versions'] }))
    .pipe(cssnano())
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest('styles'))
}

gulp.task('compile-styles', function () {
  return compileLess(gulp.src('css/index.less'))
})

gulp.task('watch-styles', function () {
  return watch('css/**/*.less', function () {
    compileLess(gulp.src('css/index.less'))
  })
})

gulp.task('default', ['compile-styles', 'watch-styles'])
