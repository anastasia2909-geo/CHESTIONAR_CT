# Regenerează docs/dictionar_date.csv și docs/dictionar_date.xlsx din
# definiția chestionarului (R/01_intrebari.R). Rulați după orice modificare
# a întrebărilor sau a codurilor.
source("scripts/_incarca.R", encoding = "UTF-8")
d <- scrie_dictionar(Q, "docs")
message("Dicționar scris: ", nrow(d), " variabile.")
