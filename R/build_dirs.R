#' Build sub-directories for Shiny Server
#'
#' This function builds sub-directories for apps in R packages and creates an
#' \code{app.R} file to launch each one on Shiny Server. This makes it easier to
#' install shiny apps via independent R packages and host them on Shiny Server.
#'
#' A CI tool (e.g. Jenkins, Travis, or AppVeyor) can install the R package and
#' app on a server where Shiny Server is running. Then use \code{build_dirs()}
#' to update Shiny Server based on app.yaml as part of the release step in a
#' CI/CD pipeline.
#'
#' @param yaml_loc path to app.yaml file
#'
#' @export
build_dirs <- function(yaml_loc = "/srv/shiny-server/app.yaml") {

  root_dir <- dirname(yaml_loc)
  if (root_dir != "/srv/shiny-server") warning(paste(root_dir, "is not the standard location for hosted shiny apps."))

  app_list <- yaml::read_yaml(yaml_loc)
  pkgs     <- names(app_list)

  for (pkg in pkgs) {
    sub_dir <- create_sub_dir(root_dir, pkg)

    apps <- app_list[[pkg]]
    if (class(apps) == "list") {
      sub_dir <- create_sub_dir(sub_dir, names(apps))
      apps <- app_list[[pkg]][[names(apps)]]

    }
    if (class(apps) == "list") stop("Please do not use more than 2 sub-directories in inst/")

    create_app_file(pkg, sub_dir, apps)
  }
  clean_up(root_dir, pkgs)
}

#' @keywords internal
create_sub_dir <- function(root, name) {
  sub_dir <- file.path(root, name)
  if (!dir.exists(sub_dir)) dir.create(sub_dir)
  invisible(sub_dir)
}

#' @keywords internal
create_app_file <- function(pkg, sub_dir, apps) {
  for (app in apps) {
    app_dir <- create_sub_dir(sub_dir, app)

    if (basename(sub_dir) == pkg) {
      app_loc <- app
    } else  {
      app_loc <- file.path(basename(sub_dir), app)
    }

    writeLines(
      text = sprintf('shiny::shinyAppDir(system.file(package = "%s", "%s"))', pkg, app_loc),
      con  = file.path(app_dir, "app.R")
    )
  }
}

#' @keywords internal
clean_up <- function(root_dir, pkgs) {
  dir_list <- list.dirs(root_dir, full.names = F, recursive = F)

  for (pkg in pkgs) {
    if (!pkg %in% dir_list) warning(sprintf("%s's apps did not get deployed", pkg)) #nocov
  }
  for (sub_dir in dir_list) {
    if (!sub_dir %in% pkgs) unlink(file.path(root_dir, sub_dir), recursive = TRUE, force = TRUE)
  }
}
