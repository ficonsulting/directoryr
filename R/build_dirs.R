#' Build sub-directories of Shiny Server
#'
#' @export
build_dirs <- function(yaml_loc = "/srv/shiny-server/app.yml") {

  root_dir <- dirname(yaml_loc)
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
    writeLines(
      text = sprintf('shiny::shinyAppDir(system.file(package = "%s", "%s"))', pkg, app),
      con  = file.path(app_dir, "app.R")
    )
  }
}

#' @keywords internal
clean_up <- function(root_dir, pkgs) {
  dir_list <- list.dirs(root_dir, full.names = F, recursive = F)

  for (pkg in pkgs) {
    if (!pkg %in% dir_list) warning(sprintf("%s's apps did not get deployed", pkg))
  }
  for (sub_dir in dir_list) {
    if (!sub_dir %in% pkgs) unlink(file.path(root_dir, sub_dir), recursive = TRUE, force = TRUE)
  }
}
