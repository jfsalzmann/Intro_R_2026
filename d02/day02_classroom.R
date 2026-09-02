# ============================================================
# DAY 2 -- CLASSROOM QUICK-REFERENCE
# ============================================================

# Setup

if (!require(pacman)) install.packages("pacman")
p_load(tidyverse)

# German federal election polling trend (ZEIT ONLINE), one row per poll x party
polls <- read_csv("polls.csv")
polls |> head(100)


# ============================================================
# 1. BASE R: A QUICK LOOK ----
# ============================================================
# two of the most common plots, quickly, before we move on to ggplot2
# every plot() call starts from a blank canvas -- ggplot2 builds in layers,
# so from here on we use it exclusively

afd <- polls |>
  filter(party == "AfD") |>
  filter(Date >= as.Date("2025-01-01"))
afd

plot(afd$Date, afd$share)
lines(afd$Date, afd$share)
hist(afd$share)


# ============================================================
# 2. THE GRAMMAR OF GRAPHICS ----
# ============================================================
# every ggplot starts from a blank canvas, built up step by step with +

ggplot(polls)
ggplot(afd, aes(x = Date, y = share))

afd |>
  ggplot(aes(x = Date, y = share)) +
  geom_point()


# ============================================================
# 3. SCATTER PLOTS ----
# ============================================================
# one point per poll, colored by pollster

afd |>
  ggplot(aes(x = Date, y = share, color = Pollster)) +
  geom_point(alpha = 0.6)

# add labels, change axis breaks and set limits
afd |>
  ggplot(aes(x = Date, y = share, color = Pollster)) +
  geom_point(alpha = 0.6) +
  scale_y_continuous(
    breaks = seq(15, 30, by = 5),
    labels = c("15%", "20%", "25%", "30%"),
    limits = c(15, 30)
  )

# handy shortcut: y-axis formatted as percent
p_load(scales)

afd |>
  mutate(share = share / 100) |>
  ggplot(aes(x = Date, y = share, color = Pollster)) +
  geom_point(alpha = 0.6) +
  scale_y_continuous(breaks = breaks_width(.05), labels = label_percent())


# ============================================================
# 4. LINE PLOTS ----
# ============================================================
# connecting raw polls in order is noisy -- filter the timeframe first

afd |>
  filter(between(Date, as.Date("2026-01-01"), Sys.Date())) |>
  ggplot(aes(x = Date, y = share)) +
  geom_line()

# a line plot makes more sense per pollster
afd |>
  filter(between(Date, as.Date("2026-01-01"), Sys.Date())) |>
  ggplot(aes(x = Date, y = share, color = Pollster)) +
  geom_line()

# a smoothed trend line reads much better
afd |>
  ggplot(aes(x = Date, y = share)) +
  geom_point(alpha = 0.3) +
  geom_smooth(span = 0.2, se = FALSE)


# ============================================================
# 5. BOXPLOTS ----
# ============================================================
# spread of a party's polled share per pollster -- "house effects"

afd |>
  ggplot(aes(x = Pollster, y = share)) +
  geom_boxplot()


# ============================================================
# 6. HISTOGRAM ----
# ============================================================

afd |>
  ggplot(aes(x = share)) +
  geom_histogram(binwidth = 1)


# ============================================================
# 7. DENSITY PLOT ----
# ============================================================
# a smoothed version of the same distribution

afd |>
  ggplot(aes(x = share)) +
  geom_density()


# ============================================================
# 8. COLOR SCALES ----
# ============================================================
# real party colors instead of ggplot's defaults

party_colors <- c(
  CDUCSU = "#000000",
  SPD    = "#E3000F",
  Gruene = "#46962b",
  FDP    = "#ffed00",
  Linke  = "#be3075",
  AfD    = "#009ee0",
  BSW    = "#7d3f98"
)
party_colors

polls |>
  ggplot(aes(x = Date, y = share, color = party)) +
  geom_smooth(se = FALSE) +
  scale_color_manual(values = party_colors) +
  labs(title = "Bundestag polling trend", x = NULL, y = "Share (%)", color = "Party")


# ============================================================
# 9. SAVING PLOTS ----
# ============================================================
# ggsave() saves the last plot drawn, or a specific one via plot = ...
# width/height set the physical size, dpi the pixel density

trend_plot <- polls |>
  ggplot(aes(x = Date, y = share, color = party)) +
  geom_smooth(se = FALSE) +
  scale_color_manual(values = party_colors) +
  labs(title = "Bundestag polling trend", x = NULL, y = "Share (%)", color = "Party")

ggsave("afd_trend.png", plot = trend_plot, width = 7, height = 5, dpi = 300)
ggsave("afd_trend.pdf", plot = trend_plot, width = 7, height = 5)


# ============================================================
# 10. BAR PLOTS ----
# ============================================================
# one bar per party, from the most recent Forsa poll

latest_forsa <- polls |>
  filter(Pollster == "Forsa", Date == max(Date))
latest_forsa

latest_forsa |>
  ggplot(aes(x = party, y = share, fill = party)) +
  scale_fill_manual(values = party_colors) +
  geom_col()


# ============================================================
# 11. PIE PLOTS ----
# ============================================================
# ggplot2 has no dedicated pie geom -- it is a bar chart bent into a circle

latest_forsa |>
  ggplot(aes(x = "", y = share, fill = party)) +
  geom_col() +
  coord_polar("y") +
  scale_fill_manual(values = party_colors)


# ============================================================
# 12. GROUPS ----
# ============================================================
# a second mapped variable (fill/color/group) clusters bars side by side

polls |>
  filter(Date == max(Date)) |>
  ggplot(aes(x = party, y = share, fill = Pollster)) +
  geom_col(position = "dodge")

# color only outlines the bars -- for geom_col() you almost always want fill
polls |>
  filter(Date == max(Date)) |>
  ggplot(aes(x = party, y = share, color = Pollster)) +
  geom_col(position = "dodge")

# group alone still dodges the bars, just without visual distinction
polls |>
  filter(Date == max(Date)) |>
  ggplot(aes(x = party, y = share, group = Pollster)) +
  geom_col(position = "dodge")

# color/fill and group don't have to match -- group decides which points
# geom_line() connects, independently of what color encodes
polls |>
  filter(between(Date, as.Date("2026-01-01"), Sys.Date())) |>
  ggplot(aes(x = Date, y = share, color = party, group = paste(Pollster, party))) +
  geom_point(alpha = 0.4) +
  geom_line(alpha = 0.4) +
  scale_color_manual(values = party_colors) +
  labs(title = "Same color, grouped by pollster x party", x = NULL, y = "Share (%)", color = "Party")


# ============================================================
# 13. FACETING ----
# ============================================================
# one small panel per pollster instead of one crowded plot

afd |>
  ggplot(aes(x = Date, y = share)) +
  geom_point(alpha = 0.4) +
  geom_smooth(span = .4, se = FALSE) +
  facet_wrap(~Pollster)

# facet by party instead -- scales = "free_y" lets each panel use its own
# y-axis range, since parties poll at very different levels
polls |>
  filter(Pollster == "Forsa") |>
  ggplot(aes(x = Date, y = share, color = party)) +
  geom_point(alpha = 0.05) +
  geom_smooth(span = .4, se = FALSE) +
  scale_color_manual(values = party_colors) +
  facet_wrap(~party, scales = "free_y")


# ============================================================
# 14. TRY IT: THE FULL PARTY LANDSCAPE ----
# ============================================================
# Your task: combine color scales, faceting, and labels into one plot --
# a trend line per party, real party colors, one panel per pollster.


# ============================================================
# 15. TRY IT: HOW EACH PARTY HAS MOVED SINCE 2017 ----
# ============================================================
# Your task: show how each party's Forsa-polled support has shifted
# between its very first poll and the most recent one. No new geom
# needed -- think about what a plot connecting just two points per party
# would look like.


# ============================================================
# 16. TRY IT: DID BSW CLEAR THE 5% THRESHOLD? ----
# ============================================================
# Your task: plot BSW's Forsa-polled trend over time and show whether --
# and when -- it crosses the 5% electoral threshold. A reference line at
# 5% helps make the answer visible at a glance.

