## Read MIBI metadata and cell positions.

library(dplyr)
library(readxl)
library(readr)
library(snakecase) # to_snake_case
library(stringr)
library(forcats)

## Path to the spreadsheets.
dir_dropbox <-
  file.path("~",
            "University of Michigan Dropbox",
            "MED-KIRSCHNERLAB-SHARED-DATA",
            "Kirschner Lab M-Box",
            "Data",
            "erin_mccaffrey-data_for_gransim")

## Read in the medata data and subset to the samples we can compare with
## GranSim.
meta_new <-
  read_excel(file.path(dir_dropbox, "gran_metadata_all.xlsx"), na = "NA") %>%
  rename_with(to_snake_case)
meta_old <-
  read_csv(file.path(dir_dropbox, "LEAP_granulomas_metadata.csv"),
           show_col_types = FALSE) %>%
  rename_with(to_snake_case)
meta_all <-
  full_join(meta_new,
            select(meta_old,
                   -ct_size,
                   -fdg_suv,
                   -gran_cfu,
                   -necrotic,
                   -non_necrotic),
            by = c("sample",
                   "animal",
                   "block",
                   "cohort_code",
                   "fibrinoid_debri",
                   "fibrosis",
                   "collagenization",
                   "early_evolving"))
## Convert weeks_necropsy to days_necropsy to be comparable with
## GranSim.
lookup <- setNames(0:7, c(0, round(1:7 / 7, digits = 1)))
meta_all <-
  meta_all %>%
  mutate(decimal = as.character(round(weeks_necropsy %% 1, 1)),
         days_necropsy = setNames(7 * floor(weeks_necropsy) + lookup[decimal],
                                  NULL),
         .before = weeks_necropsy) %>%
  select(-decimal)
## Extract days necropsy for subsetting data.
days <-
  meta_all %>%
  distinct(days_necropsy) %>%
  pull()
## Single-focus, necrotic granulomas.
meta <-
  meta_all %>%
  filter(multifocal == "0") %>%
  ## Sample 1 and Sample 2 are missing necropsy week / day.
  ## Sample 47 has no gold mask, so cannot be aligned to H&E.
  ## Sample 52 appears to have 2 necrotic cores.
  filter(! sample %in% str_c("sample", c("1", "2", "47", "52")))
usethis::use_data(meta, overwrite = TRUE)

## Cell positions.
mibi_cells_all <-
  read_csv(file.path(dir_dropbox,
                     str_c("LEAP_granulomas_all_cells_phenotype_and_position",
                           "-UPDATED 3.csv")),
           col_types = c("cdicccdd")) %>%
  mutate(across(where(is.double), as.integer)) %>%
  rename_with(to_snake_case)
## Subset to single-focus, necrotic granulomas.
file_mibi_cal <-
  fs::path(rprojroot::find_root(rprojroot::is_r_package), "data",
           "mibi_cal.rda")
stopifnot("Run the mibi_cal.R script first to generate mibi_cal.rda" =
            fs::file_exists(file_mibi_cal))
load(file_mibi_cal) # mibi_cal
mibi_cells <-
  mibi_cells_all %>%
  semi_join(distinct(meta, sample), by = "sample") %>%
  arrange(str_rank(sample, numeric = TRUE)) %>%
  mutate(sample = fct_inorder(sample),
         x = mibi_cal * centroid_x,
         y = mibi_cal * centroid_y) %>%
  select(-centroid_x, -centroid_y)
usethis::use_data(mibi_cells, overwrite = TRUE)
