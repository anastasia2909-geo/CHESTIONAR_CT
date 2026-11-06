# Rulează testele automate. În RStudio: deschideți proiectul și rulați
#   source("scripts/ruleaza_teste.R")
# Testele folosesc baze de date temporare; datele din data/ nu sunt atinse.
if (!requireNamespace("testthat", quietly = TRUE)) install.packages("testthat")
rezultat <- testthat::test_dir("tests/testthat", reporter = "summary", stop_on_failure = FALSE)
df <- as.data.frame(rezultat)
cat("\nTeste trecute:", sum(df$passed), " Eșuate:", sum(df$failed), " Erori:", sum(df$error), "\n")

