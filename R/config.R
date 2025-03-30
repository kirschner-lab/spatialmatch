#' Directory containing the dated model run directories.
dir_data <- "~/modelruns"

#' Number of agent-based model time steps per day.  The time step interval is 6
#' minutes, or 10 steps per hour, and there are 1440 minutes in day.
ticks_per_day <- 144L

## Helpful message to ensure that the directory exists.
if (! dir.exists(dir_data)) {
  stop("Could not find dir_data = ", dir_data,
       " in R/config.R; does it point to the unzipped Zenodo directory?")
}
