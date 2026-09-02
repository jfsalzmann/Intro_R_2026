# ============================================================
# DAY 3 -- CLASSROOM QUICK-REFERENCE
# ============================================================

# Setup

if (!require(pacman)) install.packages("pacman")
p_load(tidyverse)


# ============================================================
# 1. AGGREGATION: GROUP_BY(), MUTATE(), AND SUMMARIZE() ----
# ============================================================
# a small toy tibble to see exactly what each verb does to every row

df <- tribble(
  ~cat1, ~cat2, ~x,
  "a",   "j",   1,
  "a",   "j",   2,
  "a",   "k",   3,
  "b",   "j",   4,
  "b",   "k",   5,
  "b",   "k",   6,
  "c",   "j",   7,
  "c",   "j",   8,
  "c",   "k",   9
)
df
# note: df() is also a base R function (F-distribution density) -- naming
# our tibble df shadows it, harmless here, but worth flagging once

# mutate(): adds a column, keeps every row ----
df |>
  mutate(y = x - min(x))

# works, but makes less sense without grouping first
df |>
  mutate(avg = mean(x))

# summarize(): collapses all rows into one ----
df |>
  summarize(avg = mean(x))

# multiple aggregations at once
df |>
  summarize(avg = mean(x), total = sum(x), n = n())

# group_by() alone changes nothing visible ----
# it tags the tibble with grouping metadata; ungroup() removes the tag
df |>
  group_by(cat2)

df |>
  group_by(cat2) |>
  ungroup()

# group_by() + mutate(): still one row per row, computed per group ----
df |>
  group_by(cat1) |>
  mutate(avg = mean(x))

df |>
  group_by(cat1) |>
  mutate(y = x - min(x))

# group_by() + summarize(): one row per group ----
df |>
  group_by(cat1) |>
  summarize(avg = mean(x), total = sum(x), n = n())

df |>
  group_by(cat2) |>
  summarize(avg = mean(x), total = sum(x), n = n())

# grouping by two variables collapses to one row per combination --
# ungroup() afterwards allows for clean further handling
df |>
  group_by(cat1, cat2) |>
  summarize(avg = mean(x), total = sum(x), n = n()) |>
  ungroup()


# ============================================================
# 2. GETTING THE DATA ----
# ============================================================
# German federal election polling trend (ZEIT ONLINE), same source as Day
# 2 -- but here we start from the raw wide file (one column per party)
# instead of the already-reshaped long version, since reshaping is this
# day's own topic

polls <- read_csv("polls.csv")
polls |> head(100)


# ============================================================
# 3. LOADING AND STORING DATA (CSV, DTA, SAV, XLSX) ----
# ============================================================
# read_csv() we already know. Other formats need their own reader --
# haven for Stata/SPSS, readxl for Excel

p_load(haven, readxl)

read_dta("polls_sample.dta")   # Stata
read_sav("polls_sample.sav")   # SPSS
read_xlsx("polls_sample.xlsx") # Excel

# storing works the same way, one write_*() per format --
# write_csv(), write_dta(), write_sav(); Excel needs the writexl package


# ============================================================
# 4. SUMS AND MEANS OF BOOLEANS ----
# ============================================================
# a logical condition inside summarize() is just a column of TRUE/FALSE --
# sum() counts the TRUEs, mean() gives the proportion that are TRUE

polls |>
  summarize(
    n_above_20 = sum(SPD > 20)
  )

# in case there might be NAs, add na.rm to aggregations
sum(1, 2, 3, NA)
sum(1, 2, 3, NA, na.rm = TRUE)
polls |>
  summarize(
    n_above_20 = sum(SPD > 20, na.rm = TRUE),
    pct_above_20 = mean(SPD > 20, na.rm = TRUE)
  )

# same idea, grouped -- how often each pollster puts AfD above 25% in 2026
polls |>
  filter(Date >= as.Date("2026-01-01")) |>
  group_by(Pollster) |>
  summarize(pct_afd_above_25 = mean(AfD > 25, na.rm = TRUE))


# ============================================================
# 5. ORDERING YOUR DATA ----
# ============================================================
# arrange() sorts rows; desc() reverses the order; multiple columns break ties

polls |> arrange(Date)
polls |> arrange(desc(Date))
polls |> arrange(Pollster, Date)


# ============================================================
# 6. TRANSFORMING VARIABLES ----
# ============================================================
# rename() just relabels a column

polls |>
  rename(Union = CDUCSU)


# ============================================================
# 7. SELECTING VARIABLES ----
# ============================================================
# select() takes a subset of columns, and can also be used to drop columns

polls |>
  select(Pollster, Date, Period)

polls |>
  select(-BSW)

# case_when() recodes a variable into categories, checked top to bottom --
# the first matching condition wins
polls_with_terms <- polls |>
  mutate(
    term = case_when(
      Date < as.Date("2021-10-26") ~ "19. Wahlperiode",
      Date < as.Date("2025-03-25") ~ "20. Wahlperiode",
      .default = "21. Wahlperiode"
    )
  )
polls_with_terms

# unique combinations of pollster and term
polls_with_terms |> distinct(Pollster, term)

# in how many unique terms has each pollster been active?
polls_with_terms |>
  distinct(term, Pollster) |>
  group_by(Pollster) |>
  summarize(terms = n())

# what share of all polls in a given term did each pollster carry out?
polls_with_terms |>
  group_by(term, Pollster) |>
  summarize(polls = n()) |>
  group_by(term) |>
  mutate(percentage = polls / sum(polls), sum_polls = sum(polls))


# ============================================================
# 8. MISSING VALUES ----
# ============================================================
# BSW only became a party in 2024 -- every poll before that has share = NA

polls |> filter(is.na(BSW)) |> nrow() # how many rows have NAs?

polls |> filter(!is.na(BSW)) # only polls that actually asked about BSW
polls |> drop_na(BSW)        # same idea, tidyr's dedicated verb

# treating "not asked yet" as "0%" can be the better modeling choice --
# make it explicit instead of letting NAs silently vanish
polls |> mutate(BSW = replace_na(BSW, 0))

# coalesce() picks the first non-missing value across several columns,
# left to right
survey_waves <- tribble(
  ~Respondent_ID, ~Response_May, ~Response_June, ~Response_July,
  1,              "CDUCSU",         NA,             "Gruene",
  2,              NA,            "FDP",           NA,
  3,              NA,            NA,             "AfD",
  4,              NA,            NA,             NA
)
survey_waves |>
  mutate(Latest_Response = coalesce(Response_July, Response_June, Response_May))

# same shape and entries, but non-responses coded with a sentinel number:
# 97 = "still undecided" (an actual answer), 98/99 = "don't know"/
# "refused" (true missingness). across() + starts_with() recodes all
# three Response_* columns in one mutate()
survey_sentinels <- tribble(
  ~Respondent_ID, ~Response_May, ~Response_June, ~Response_July,
  1,              "CDUCSU",      "99",           "Gruene",
  2,              "98",          "FDP",          "97",
  3,              "97",          "98",           "AfD",
  4,              "99",          "97",           "98"
)

# ~ .x used here with across() to do multiple mutates at once
survey_sentinels |>
  mutate(
    across(
      starts_with("Response"), ~ replace_values(
        .x,
        c("98", "99") ~ NA,
        "97"          ~ "Undecided"
      )
    )
  )

# needing across() to mutate several look-alike columns the same way is
# often a hint that the data would rather be long -- one column, one mutate()
survey_sentinels |>
  pivot_longer(starts_with("Response"), names_to = "wave", values_to = "response") |>
  mutate(response = replace_values(response, c("98", "99") ~ NA, "97" ~ "Undecided"))


# ============================================================
# 9. RESTRUCTURING DATA: PIVOT_LONGER() AND PIVOT_WIDER() ----
# ============================================================
# one row per poll x party (long) instead of one row per poll (wide)

polls_long <- polls |>
  pivot_longer(CDUCSU:BSW, names_to = "party", values_to = "share")
polls_long

# pivot_wider() is the mirror image -- back to one row per poll
polls_long |>
  pivot_wider(names_from = party, values_from = share)


# ============================================================
# 10. MERGING DATA: BIND_ROWS() AND JOINS ----
# ============================================================
# bind_rows() stacks tibbles with the same columns on top of each other

afd_polls <- polls_long |> filter(party == "AfD") |> head(n = 3)
afd_polls
cdu_polls <- polls_long |> filter(party == "CDUCSU") |> slice_head(n = 3)
cdu_polls
bind_rows(afd_polls, cdu_polls)

# joins add columns from a second table by matching a key -- here, each
# party's group in the European Parliament (2024-2029 term)
party_ep_groups <- tribble(
  ~party,   ~ep_group,
  "CDUCSU", "EPP",
  "SPD",    "S&D",
  "Gruene", "Greens/EFA",
  "FDP",    "Renew Europe",
  "Linke",  "The Left",
  "AfD",    "ESN",
  "DIE PARTEI", "Non-attached"
  # no BSW
)

# just the most recent polling day (2 polls x 7 parties = 14 rows)
recent_polls_long <- polls_long |> filter(Date == max(Date))
recent_polls_long

# left_join() keeps every row of the left table, filling in NA for any
# party without a match
recent_polls_long |> left_join(party_ep_groups, by = "party")

# inner_join() keeps only rows that match on both sides
recent_polls_long |> inner_join(party_ep_groups, by = "party")

# right_join() keeps every row of party_ep_groups (the right table)
recent_polls_long |> right_join(party_ep_groups, by = "party")

# full_join() keeps everything from both sides
recent_polls_long |> full_join(party_ep_groups, by = "party")


# ============================================================
# 11. TRY IT: GREEN VOTE SHARE BY BUNDESTAG TERM ----
# ============================================================
# Your task: compute the Greens' average polled vote share within each
# Bundestag term (Wahlperiode), ranked from highest to lowest -- starting
# fresh from polls, not the term/long objects already built above.


# ============================================================
# 12. TRY IT: WHICH POLLSTER SHOWS AfD ABOVE 20% MOST OFTEN? ----
# ============================================================
# Your task: starting fresh from polls again, work out what share of
# each pollster's polls put AfD above 20%, ranked from most to least
# often.


# ============================================================
# 13. TRY IT: REBUILD DAY 2'S POLLING TREND PLOT ----
# ============================================================
# Your task: rebuild Day 2's "color scales" plot, but starting straight
# from the wide polls tibble instead of an already-long one -- there's
# no one column called party to hand to color =, only 7 separate share
# columns.


# ============================================================
# 14. TRY IT: AfD VS. SPD -- A NEGATIVE CORRELATION ----
# ============================================================
# Your task: check whether AfD and SPD support move in opposite
# directions -- a Day 2 question, worth revisiting now that
# pivot_wider() is fresh. Pair each poll's AfD and SPD share into one
# row per poll, then plot one against the other, overall and split out
# by year.
