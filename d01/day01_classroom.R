# ============================================================
# DAY 1 -- CLASSROOM QUICK-REFERENCE
# ============================================================

# Setup

if (!require(pacman)) install.packages("pacman")
p_load(tidyverse)


# ============================================================
# 1. VARIABLE TYPES ----
# ============================================================
# every value has a type -- R guesses it, but you should know it

vote_share <- 42.3
class(vote_share)

party <- "Greens"
class(party)

won_election <- TRUE
class(won_election)

region <- factor("East")
class(region)

# convert between types where it makes sense
vote_share_string <- as.character(vote_share)
class(vote_share_string)

as.numeric("42.3")
as.numeric("Greens") # not every conversion works

# numeric (double) vs. integer
16L
as.integer(16)
class(16L)
class(16)


# ============================================================
# 2. VECTORS ----
# ============================================================
# one object, many values of the same type

parties <- c("SPD", "CDU", "Greens", "FDP", "AfD")
vote_share <- c(25.7, 24.1, 14.7, 11.5, 10.3)

length(parties)
length(vote_share)
mean(vote_share)
min(vote_share)
max(vote_share)
sum(vote_share)

# vectorised math -- applies element by element
vote_share / 100 # convert into actual shares (%)

# named vectors attach a label to each value
vote_share_named <- c(
  SPD = 25.7,
  CDU = 24.1,
  Greens = 14.7,
  FDP = 11.5,
  AfD = 10.3
)
vote_share_named

vote_share_named <- setNames(vote_share, parties)
vote_share_named

# mixing types coerces everything to the most flexible type
c(1, 2, "three")

# boolean shortcuts
c(TRUE, T, FALSE, F)


# ============================================================
# 3. PIPING ----
# ============================================================
# same calls, written left to right instead of inside out

mean(vote_share)
vote_share |> mean()

mean(vote_share, na.rm = TRUE)
vote_share |> mean(na.rm = TRUE)

round(mean(vote_share), digits = 1)
vote_share |> mean() |> round(digits = 1)

# magrittr pipe -- same idea, older syntax you'll still see around
p_load(magrittr)
vote_share %>% mean() %>% round(1)

# %<>% pipes into and reassigns the same object
vote_share
vote_share %<>% round(0)
vote_share


# ============================================================
# 4. SEQUENCES ----
# ============================================================
# quick ways to build a run of numbers

1:10
seq(from = 0, to = 100, by = 10)
weeks <- 1:12


# ============================================================
# 5. INDEXING & SUBSETTING ----
# ============================================================
# pulling specific elements out of a vector

# BASE R ----
parties[1] # first element
parties[length(parties)] # last element
parties[-1] # everything except the first
parties[1:3] # first three elements
vote_share_named[["AfD"]] # named element

# TIDYVERSE ----
first(parties) # first element
last(parties) # last element
tail(parties, -1) # everything except the first
head(parties, 3) # first three elements
vote_share_named |> pluck("AfD") # named element

# comparisons return logical vectors
vote_share > 15
which(vote_share > 15)

# BASE R ----
parties[vote_share > 15] # subsetting with a condition

# TIDYVERSE ----
parties |> keep(vote_share > 15) # subsetting with a condition


# ============================================================
# 6. A FIRST LOOK AT IF/ELSE ----
# ============================================================
# more on this later this week

threshold <- 5

x <- 3

if (x > threshold) {
  cat("Is greater than the threshold")
} else {
  cat("Is not greater than the threshold")
}

if (first(vote_share) > threshold) {
  # If condition is true, execute:
  str_glue(
    "{first_party} enters parliament",
    first_party = first(parties)
  ) |> cat()
} else {
  # If condition is false, execute:
  cat(str_glue("{first_party} misses the threshold", first_party = first(parties)))
}


# ============================================================
# 7. MATRICES ----
# ============================================================
# bundling equal-length vectors together, by row or by column
# rarely required nowadays unless doing matrix algebra

party_id <- c(1, 2, 3)
seats_2021 <- c(206, 152, 118)
seats_2025 <- c(120, 164, 85)

seats_matrix <- cbind(party_id, seats_2021, seats_2025)
seats_matrix

dim(seats_matrix)
nrow(seats_matrix)
ncol(seats_matrix)
rowSums(seats_matrix)
colSums(seats_matrix)


# ============================================================
# 8. LISTS ----
# ============================================================
# unlike vectors, list elements can be different types and lengths

merkel <- list(
  name = "Angela Merkel",
  party = "CDU",
  years_in_office = 16,
  chancellor = TRUE
)

# BASE R ----
merkel$party
merkel[["years_in_office"]]

# TIDYVERSE ----
merkel |> pluck("name")
merkel %$% chancellor

# lists can nest -- a list of lists, check your IDE's variable inspector
government <- list(
  chancellor = merkel,
  coalition_parties = c("CDU", "SPD")
)

# BASE R ----
government$chancellor$party
government$coalition_parties

# TIDYVERSE ----
government |> pluck("chancellor", "party")
government |> pluck("coalition_parties")


# ============================================================
# 9. A FIRST DATA FRAME ----
# ============================================================
# a table: columns are vectors, rows are observations
# full tidyverse treatment (tibbles, dplyr) comes Day 3 -- for now, a first tibble

parties_df <- tibble(
  party = parties,
  vote_share = vote_share,
  in_government = c(TRUE, FALSE, TRUE, FALSE, FALSE)
)
parties_df

# BASE R ----
parties_df$vote_share
parties_df[parties_df$in_government, ]
parties_df[parties_df$in_government == TRUE, ]
parties_df[1, ]
parties_df[nrow(parties_df), ]
parties_df[1:2, ]
parties_df[(nrow(parties_df) - 1):nrow(parties_df), ]
parties_df[c(2, 3), ]

# TIDYVERSE ----
parties_df |> pull(vote_share)
parties_df |> filter(in_government)
parties_df |> filter(in_government == TRUE)
parties_df |> first()
parties_df |> last()
parties_df |> slice_head(n = 2)
parties_df |> slice_tail(n = 2)
parties_df |> slice(c(2, 3))


# ============================================================
# 10. TRY IT: POPULIST SUPPORT ACROSS FEDERAL STATES ----
# ============================================================
# same shape as parties_df, plus a state column -- fictional AfD/BSW results
# per Bundesland (federal state); both count as "populist" here

polls_by_state <- tribble(
  ~state,                 ~party, ~vote_share,
  "Sachsen",              "AfD",  32.4,
  "Sachsen",              "BSW",  11.8,
  "Sachsen",              "CDU",  31.9,
  "Sachsen",              "SPD",   7.5,
  "Thüringen",            "AfD",  34.6,
  "Thüringen",            "BSW",  13.1,
  "Thüringen",            "CDU",  23.6,
  "Thüringen",            "SPD",   6.1,
  "Brandenburg",          "AfD",  29.2,
  "Brandenburg",          "BSW",  12.4,
  "Brandenburg",          "CDU",  15.8,
  "Brandenburg",          "SPD",  30.9,
  "Bayern",               "AfD",  18.0,
  "Bayern",               "BSW",   6.5,
  "Bayern",               "CDU",  37.0,
  "Bayern",               "SPD",   8.4,
  "Baden-Württemberg",    "AfD",  15.4,
  "Baden-Württemberg",    "BSW",   4.2,
  "Baden-Württemberg",    "CDU",  24.1,
  "Baden-Württemberg",    "SPD",   9.7,
  "Nordrhein-Westfalen",  "AfD",  14.2,
  "Nordrhein-Westfalen",  "BSW",   5.1,
  "Nordrhein-Westfalen",  "CDU",  34.6,
  "Nordrhein-Westfalen",  "SPD",  22.1,
  "Bremen",               "AfD",   9.8,
  "Bremen",               "BSW",   3.2,
  "Bremen",               "CDU",  22.5,
  "Bremen",               "SPD",  26.0,
  "Hamburg",              "AfD",   8.9,
  "Hamburg",              "BSW",   2.8,
  "Hamburg",              "CDU",  22.9,
  "Hamburg",              "SPD",  30.2
)
polls_by_state

populist_results <- polls_by_state |> filter(party %in% c("AfD", "BSW"))
populist_results

# an absolute majority -- none reach it here
majority <- populist_results |> filter(vote_share >= 50)
majority
nrow(majority)

# over the blocking minority (Sperrminorität): can block a 2/3-majority vote
blocking_minority <- populist_results |> filter(vote_share >= 33.3)
blocking_minority
blocking_minority |> pull(state)

# over the 5% entry threshold
cleared_threshold <- populist_results |> filter(vote_share >= 5)
cleared_threshold |> pull(state) |> unique()
cleared_threshold |> pull(vote_share) |> mean()
