#' Directory containing the dated model run directories.
dir_data <- "~/modelruns"

#' Directory containing the MIBI-TOF metadata and cell centroid spreadsheets.
dir_mibi <- "~/immunology/data"

#' Number of agent-based model time steps per day.  The time step interval is 6
#' minutes, or 10 steps per hour, and there are 1440 minutes in day.
ticks_per_day <- 144L
