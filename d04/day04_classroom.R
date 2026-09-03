# ============================================================
# DAY 4 -- CLASSROOM QUICK-REFERENCE
# ============================================================

# Setup

if (!require(pacman)) install.packages("pacman")
p_load(tidyverse)


# ============================================================
# 1. GETTING THE DATA ----
# ============================================================
# same wide polling data as Day 3, still one column per party

polls <- read_csv("polls.csv")
party_cols <- c("CDUCSU", "SPD", "Gruene", "FDP", "Linke", "AfD", "BSW")
polls |> head(100)


# ============================================================
# 2. OPERATORS ----
# ============================================================
# same combined filter as Day 3 (bsw_forsa), adapted to this year's wide
# table -- no party column here, so "was BSW even polled yet" takes its place

bsw_forsa <- polls |> filter(Pollster == "Forsa", !is.na(BSW))
bsw_forsa

# filter()'s comma is just a logical AND -- spelled out with & gives the
# identical result
bsw_forsa_and <- polls |> filter(Pollster == "Forsa" & !is.na(BSW))
identical(bsw_forsa, bsw_forsa_and)

# | is OR: true if either side is
polls |> filter(AfD > 25 | CDUCSU > 35)
polls |> filter(AfD > 25 & CDUCSU > 35)

# conditions chain as far as needed -- still just &/|
polls |> filter(Pollster == "Forsa" & Date >= as.Date("2026-01-01") | AfD > 20)
polls |> filter(Pollster == "Forsa" & (Date >= as.Date("2026-01-01") | AfD > 20))

# ifelse()
polls |> mutate(threshold = ifelse(FDP >= 5, "cleared threshold", "missed threshold"))


# ============================================================
# 3. WRITING YOUR OWN FUNCTIONS ----
# ============================================================
# name, arguments in (), curly-brace body, last line is what's returned

custom_year <- function(date_var) {
  year_num <- date_var |> year()
  year_chr <- year_num |> as.character()
  year_chr # return this
}
custom_year <- function(date_var) {
  date_var |> year() |> as.character()
}

as.Date("2026-09-03")
Sys.Date()
Sys.Date() |> year()
Sys.Date() |> custom_year()
custom_year(Sys.Date())

# use it in a data set via mutate()
polls |> mutate(year = year(Date))
polls |> mutate(year = custom_year(Date))

# default arguments: used unless the caller overrides them
custom_year_correction <- function(date_var, lag = 1) {
  actual_year <- date_var |> year()
  actual_year + lag
}

Sys.Date() |> custom_year_correction()
Sys.Date() |> custom_year_correction(2)
polls |> mutate(year = custom_year_correction(Date, 3))


# ============================================================
# 4. ANONYMOUS FUNCTIONS ----
# ============================================================
# a one-off function with no name -- three spellings of the same idea

(function(x) x / 100)(37) # spelled out
(\(x) x / 100)(37) # base R shorthand (R >= 4.1)
37 |> (\(x) x / 100)() # piped in -- extra parentheses around the function required
map_dbl(37, ~ .x / 100) # purrr formula shorthand -- only inside purrr calls


# ============================================================
# 5. FOR LOOPS ----
# ============================================================
# for (iterator in sequence) { body }

party_cols

for (party in party_cols) {
  print(str_glue("{party}: Lovely Party!"))
}

x <- 0
for (i in 1:10) {
  x <- x + i
  print(str_glue("{x}"))
}
x

# nested for loops: a loop inside a loop -- every pollster x party pair
polls_long <- polls |>
  pivot_longer(CDUCSU:BSW, names_to = "Party", values_to = "share")

pollsters <- polls_long |> pluck("Pollster") |> unique()
parties <- polls_long |> pluck("Party") |> unique()

for (party in parties) {
  for (pollster in pollsters) {
    print(str_glue("Really shocked about today's polling results for {party} by {pollster} :o"))
  }
}

# expand_grid(): the tidyverse alternative to nested loops -- same
# combinations, no nesting
grid <- expand_grid(party = parties, pollster = pollsters)

grid |> mutate(output = str_glue("Really shocked about today's polling results for {party} by {pollster} :o"))

grid |>
  mutate(output = str_glue("Really shocked about today's polling results for {party} by {pollster} :o")) |>
  pluck("output")

grid |>
  mutate(output = str_glue("Really shocked about today's polling results for {party} by {pollster} :o")) |>
  pluck("output") |> str_c(collapse = "; ")


# ============================================================
# 6. TRY IT: WHO CLEARED THE THRESHOLD? ----
# ============================================================
# Your task: write a function that reports whether a party's poll share
# cleared a threshold (default: the 5% electoral threshold). Use it to
# flag every party's status in the full polls table, then check CDU/CSU's
# latest share against the 33.3% blocking-minority mark instead.


# ============================================================
# 7. TRY IT: COUNTING WHO CLEARED ----
# ============================================================
# Your task: using the latest poll, report every party's threshold status
# one at a time, and count how many parties cleared it.


# ============================================================
# 8. TRY IT: AVERAGE SHARE BY POLLSTER ----
# ============================================================
# Your task: compute each pollster's average share for every party, one
# pollster-party combination at a time.
