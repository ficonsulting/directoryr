# directoryr
[![Travis build status](https://travis-ci.org/ficonsulting/directoryr.svg?branch=master)](https://travis-ci.org/ficonsulting/directoryr)
[![Coverage status](https://codecov.io/gh/ficonsulting/directoryr/branch/master/graph/badge.svg)](https://codecov.io/github/ficonsulting/directoryr?branch=master)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

Simple package to manage Shiny Server with app.yml and simplify continuous integration pipelines.

## Create /srv/shiny-server/app.yml
```
testpkg:
 - App1
 - App2
sabbatical:
 - app
extrapkg:
  shiny-apps:
   - App1
   - App2
```

## Run `build_dirs()`
In R:
```
directoryr::build_dirs()
```
In Travis CI:
```
- Rscript -e 'directoryr::build_dirs()'
```


`build_dirs()` creates directories based on app.yml and creates an app.R file for each app:

## app.R
```
shiny::shinyAppDir(system.file(package = "sabbatical", "app"))
```

If you install the `sabbatical` package on the server, this will launch the app from the `sabbatical` package on Shiny Server.

`build_dirs()` also cleans up after itself. So if you edit app.yml, it will remove unused directories as well.

### Contributor Code of Conduct
Please note that the `directoryr` project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

