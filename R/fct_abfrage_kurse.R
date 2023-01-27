#' abfrage_kurse
#'
#' @param url character
#'
#' @return data.table
#'
#' @import data.table
#' @import rvest
#'
#' @export


abfrage_kurse <- function(url){

  #url <- "https://www.ariva.de/s_p_500-index/kursliste"
  #url <- "https://www.ariva.de/prime_all_share_performance-index/kursliste"

  #Den HTML Quelltext der Seite auslesen
  quelltext <- read_html(url)

  #Finden der Input-Forms (auch der hidden forms) für den paging Befehl
  #Ich nehme das Listenelement 4 hier schon mit rein, da ich weiß, dass es dieses Input Form ist
  #Ansonsten wird eine Liste mit allen ermittelten Forms zurück gegeben
  hidden_form <- html_form(quelltext)[[4]]

  #Anpassen der Form, so dass 1.000 Ergebnisse pro Seite angezeigt werden
  #Das Input field heißt "page_size". Zu Erkennen, in der Abfrage html_form
  hidden_form <- html_form_set(hidden_form, page_size = 1000)

  #Nun eine neue Anfrage stellen mit dem angepassten hidden form
  hidden_form <- html_form_submit(hidden_form)

  #Jetzt wieder den HTML Quelltext auslesen und dann die Tabelle mit den Daten extrahieren
  quelltext <- read_html(hidden_form)

  tabelle <- quelltext %>%
    html_nodes("table") %>%
    .[4] %>%
    html_table() %>%
    as.data.table()



  #Bereinigen der Tabelle
  tabelle <- tabelle[X == "", ] #löschen von nicht benötigten Zeilen
  tabelle <- tabelle[, c("X", "X.1", "X.2", "X.3", "X.4", "X.5", "\u00c4nderung.1", "Weitere.Links", "Zeit") := NULL] #löschen von nicht benötigten Spalten
  tabelle <- setorder(tabelle, Name) #Tabelle nach Unternehmensnamen sortieren
  tabelle <- tabelle[!duplicated(tabelle$Name), ] #Duplikate, falls vorhanden, entfernen

}
