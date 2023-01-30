#' abfrage_fundamentaldaten
#'
#' @param url character - URL zu Unternehmens-Daten
#'
#' @description Die Funktion ruft die Fundamentaldaten eines Unternehmens ab
#'
#' @return data.table enthält alle Fundamentaldaten der letzten 12 Jahre
#'
#' @import data.table
#' @import rvest
#'
#'


abfrage_fundamentaldaten <- function(url){

  fundamentaldaten <- data.table()
  page = 0

  for(i in 1:2){

    #Quelltext auslesen, nach Formular suchen und das auf die jeweilge Seite anpassen
    #Seitenanzahl plus 6 ist gut, um einen 12 Jahres Zeitraum hinzubekommen
    #Bei mehr als 12 Jahren stürzt die Funktion ab, da die Daten von ariva.de wohl in einem anderen Format vorliegen und nicht zusammengefügt werden können
    quelltext <- read_html(url)
    form <- html_form(quelltext)
    form <- html_form_set(form[[2]], page = page)
    form <- html_form_submit(form)
    quelltext <- read_html(form)

    #Tabellen aus Quelltext auslesen
    tabellen <- quelltext %>%
      html_elements(".table .line") %>%
      html_table(header = TRUE)
    #Das Ergebnis ist eine Liste mit 14 tibbles, daher löschen der nicht benötigten Tabellen
    tabellen <- tabellen[- c(2:9, 11:12)]
    #Die übrigen Tabellen zu einer zusammenfügen
    tabellen <- rbindlist(tabellen, use.names = TRUE, fill = TRUE)
    #Zeilen mit "Datenmüll" aussortieren / es gibt einige, in denen alle Zahlen zusammengefasst wurden
    tabellen <- subset(tabellen, nchar(as.character(V1)) < 150)
    #Es sind zu viele Spalten enthalten (durch die Untertabellen die ein- und ausgeblendet werden können), diese werden hier entfernt
    tabellen <- tabellen[, c(8:ncol(tabellen)) := NULL]
    #Zusammenführen der ausgelesenen Tabellen
    fundamentaldaten <- as.data.table(c(fundamentaldaten, tabellen))
    page <- page + 6

  }

  #Entfernen von doppelten Spalten
  fundamentaldaten <- fundamentaldaten[ , which( !duplicated( t( fundamentaldaten ) ) ), with = FALSE ]
  #Entfernen von Leerzeilen
  fundamentaldaten <- fundamentaldaten[V1 != "", ]
  #Sortieren nach Spaltenname
  setcolorder(fundamentaldaten, sort(colnames(fundamentaldaten)))
  #Spalte V1 wieder an den Anfang bringen
  setcolorder(fundamentaldaten, c("V1"))



  # Zu erst die Punkte als Tausender-Trennzeichen entfernen, dann die Dezimalkommas in einen Punkt wandeln
  fundamentaldaten[, c(2:ncol(fundamentaldaten)) := lapply(.SD, function(x) (gsub("[$.]", "", x))), .SDcols = c(2:ncol(fundamentaldaten))]
  fundamentaldaten[, c(2:ncol(fundamentaldaten)) := lapply(.SD, function(x) (gsub("[$,]", ".", x))), .SDcols = c(2:ncol(fundamentaldaten))]
  #Entfernen von - welches für nicht vorhandene Daten gesetzt wurde, Achtung, dass minus als negatives Vorzeichen nicht entfernt wird
  fundamentaldaten[, c(2:ncol(fundamentaldaten)) := lapply(.SD, function(x) (gsub("^-$", "0", x))), .SDcols = c(2:ncol(fundamentaldaten))]
  fundamentaldaten[, c(2:ncol(fundamentaldaten)) := lapply(.SD, as.numeric), .SDcols = c(2:ncol(fundamentaldaten))]

}
