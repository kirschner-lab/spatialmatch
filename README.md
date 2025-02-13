# Overview {-}

<!-- badges: start -->
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

- This repository contains RMarkdown documents to reproduce the results figures
  and supplementary figures for a research publication.  Each figure is
  self-contained with explicit inputs and library imports by using RMarkdown's
  knit and merge approach[^fn1].  Note that some of the supplementary figures
  are created alongside the results figures.

- To recreate the figures code, if necessary edit the `config.R` file in this
  directory with the path to your downloaded data directory, then run these R
  commands to install the dependencies and then build the RMarkdown book PDF:

  ```r
  ## Install the dependencies:
  install.packages(c("BiocManager", "remotes"))
  options(repos = BiocManager::repositories())
  remotes::install_deps(dependencies = TRUE)

  ## Build the RMarkdown book PDF:
  bookdown::render_book()
  ```

- Additionally, this repository contains the job submission scripts used to
  generate the results.  However, these scripts are fairly specific to the
  compute clusters[^fn2] on which they were run and require over a quarter
  million comptue hours to run and are, therefore, intended as reference rather
  than being part of a practical, fully-reproducible workflow.

[^fn1]: Knit then merge (K-M) approach
    <https://bookdown.org/yihui/bookdown/new-session.html>
[^fn2]: Purdue University's Anvil cluster (primarily), San Diego Supercomputer
    Center's Expanse cluster, and the University of Michigan's Lighthouse and
    Great Lakes clusters (these latter non-Purdue clusters were only used to
    split up running the 50,000 GranSim simulations).
