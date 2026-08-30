# ============================================================
# Day 1 — IDE-driven opening
# Plain .R script — opened directly in Positron / RStudio
# ============================================================

# --- IDE tour ---
# - Panes: Editor / Console / Environment / Files-Plots-Packages-Help
# - Positron vs. RStudio: same R underneath, different shell around it
# - Running code: run current line, run selection, run whole script
# - .R script now -> .qmd later
# - Projects: a folder is a project, working directory is "just there"
# - GitHub 101: this course's repo, cloning it, where d01/ lives, pulling updates

# --- Package management ---
# every session starts the same way
if (!require(pacman)) install.packages("pacman")
p_load(tidyverse)

# --- R as a calculator ---
# normal math
1 + 1
5 * 2
5 / 2
5^2
(1 + 2) + 2^2 * 3
0.5
.5

# --- functions for calculations ---
sqrt(4)
?sqrt

round(3.142, digits = 1)
round(3.142, 1) # argument names optional if order is respected

# --- First objects ---
# both work — we'll use = for now, then switch to <- as our default later
x <- 5
y = 5

income = 1500
job = "Political Scientist"

# print() keeps the quotes, cat() doesn't
print(job)
cat(job)

# paste() glues pieces together, space-separated by default
paste("I am a", job, "and I earn", income, "per month.")
paste0("I am a ", job, " and I earn ", income, "€ per month.") # paste0() = paste(sep = "")
paste("Some Info", job, income, sep = " - ")

# str_glue() interpolates variables straight into {}
str_glue("I am a {job} and I earn {income}€ per month.")
str_glue("Some Info - {job} - {income}")

str_glue(
  "I am a {job_title} and I earn {monthly_income} € per month.",
  job_title = job, # custom {placeholder}, not tied to an existing variable
  monthly_income = income + 200
)

# naming: start with a letter, no spaces (use _), case-sensitive
# don't shadow function names (sum, mean, ...)

# --- Try it: voter turnout ---
# turnout = voters who showed up / eligible voters
# from here on, <- is our default assignment operator
voted <- 24000
eligible <- 32101

turnout <- voted / eligible * 100
turnout

# output only vs. storing the result
# applying a function won't change the variable's state
round(turnout, digits = 1)
turnout
rounded <- round(turnout, digits = 1)
rounded

# --- Example data: try View() & inspector ---
example_data <- mtcars
View(example_data)
