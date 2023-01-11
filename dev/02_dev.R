#
#
#

devtools::load_all()

usethis::use_package("bs4Dash", type = "Imports", min_version = TRUE )
attachment::att_amend_desc()

devtools::document() #Dokumentation erstellen

usethis::use_pkgdown() #Webseite initial erstellen
pkgdown::build_site() #Webseite aktualisieren

golem::add_module(name = "name_of_module1", with_test = TRUE)
golem::add_module(name = "name_of_module2", with_test = TRUE)
golem::add_fct("helpers", with_test = TRUE)
golem::add_utils("helpers", with_test = TRUE)
golem::add_js_file("script")
golem::add_js_handler("handlers")
golem::add_css_file("custom")
golem::add_sass_file("custom")
usethis::use_data_raw(name = "my_dataset", open = FALSE)
usethis::use_test("app")
usethis::use_vignette("aktienanalyse")
devtools::build_vignettes()
usethis::use_coverage()
covrpage::covrpage()
usethis::use_github()
usethis::use_github_action()
usethis::use_github_action_check_release()
usethis::use_github_action_check_standard()
usethis::use_github_action_check_full()
usethis::use_github_action_pr_commands()
usethis::use_travis()
usethis::use_travis_badge()
usethis::use_appveyor()
usethis::use_appveyor_badge()
usethis::use_circleci()
usethis::use_circleci_badge()
usethis::use_jenkins()
usethis::use_gitlab_ci()
rstudioapi::navigateToFile("dev/03_deploy.R")
