# Încarcă codul aplicației în sesiunea curentă (folosit de celelalte scripturi).
# Directorul de lucru trebuie să fie folderul proiectului (deschideți
# chestionar_constanta.Rproj în RStudio și acesta se setează automat).
if (!file.exists("app.R") || !dir.exists("R")) {
  stop("Rulați scriptul din folderul proiectului (deschideți chestionar_constanta.Rproj).", call. = FALSE)
}
for (f in sort(list.files("R", pattern = "^[0-9].*\\.R$", full.names = TRUE))) source(f, encoding = "UTF-8")
Q <- construieste_intrebari()
