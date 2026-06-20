# Overview of HPC code

<!-- badges: start -->
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

- The following describes the computer cluster simulation files and directories
  in v2 of the Zenodo-archived zip file.

- The standard operating procedure of the Kirschner laboratory is to run
  simulations on computer clusters only after first creating a dedicated
  "model-run" directory that is prefixed with the creation date in ISO-8601
  format and a capital letter indicating whether the simulation was re-run (A,
  B, C, ...).  Therefore, the research work associated with this manuscript is
  organized into several model-run directories and is described in the
  "[Flowcharts of model-run directories](#flowcharts-of-model-run-directories)"
  section below.

- Flowcharts are provided to describe the intent and scope of each model-run
  directory with corresponding input files, command-line programs, and key
  output files.  However, to improve legibility, not all output files, such as
  diagnostic files, are indicated in flowcharts or provided.

- Command-line programs in the flowcharts consist of work from the Kirschner
  laboratory (with CLI executable name) as follows:

  - GranSim (`gr`, `grviz-lung`) <http://malthus.micro.med.umich.edu/GranSim/>
  - gransimg (`gransimg`) <https://github.com/kirschner-lab/gransimg>
  - SLURM job submission wrapper for GranSim (`lhssubmit-job-array`)
  - Sensitivity analysis for GranSim (`make-lhs-prcc.py`)

  ... as well as 3rd party software that we do not provide:

  - Bash (`bash`) <https://www.gnu.org/software/bash/>
  - CellProfiler (`cellprofiler`) <https://cellprofiler.org>
  - FIJI (`ImageJ2`) <https://fiji.sc>
  - MATLAB (`matlab`) <https://www.mathworks.com/products/matlab.html>
  - Ninja (`ninja`) <https://ninja-build.org>
  - Parallel (`parallel`) <https://www.gnu.org/software/parallel/>
  - Python (`python`) <https://www.python.org>
  - R (`R`, `Rscript`) <https://www.r-project.org>
  - SingularityCE (`singularity`) <https://sylabs.io/singularity/> (now
    superceded by the Linux Foundation project Apptainer <https://apptainer.org>
    that allows building containers without root permissions)
  - SLURM (`sbatch`) <https://slurm.schedmd.com/overview.html>
  - Spack (`spack`) <https://spack.io>

- A single * symbol after any files in the flowchart indicates that those files
  are not present in the model-run directories, and a ** symbol indicates that
  those files are already provided with the Zenodo data to reproduce the
  publication figures: <https://zenodo.org/records/15102621>.

- All model-run directories were executed on HPC clusters that use the SLURM
  job scheduler.  In general any job involving CellProfiler or CellProfiler
  output was memory limited, otherwise jobs were comptue limited.  Memory
  limited jobs were run on nodes with 256 GB RAM; calculations and
  optimizations to prevent high memory loads from crashing the job are
  contained and documented within the `*.sbatch` job submission scripts.
  Except for `modelruns/2026-02-03-A-gr-20k-3rep`, all model-runs use the
  Purdue Anvil cluster.  Most jobs are embarrassingly parallel serial CPU jobs
  run without MPI, or GPUs, or any requirement for special network topology or
  high-speed interconnect on large clusters.

  - `modelruns/2026-02-03-A-gr-20k-3rep` had the highest CPU need for 60,000
    simulations (20,000 samples x 3 replicates) and therefore used the U-M
    Lighthouse and U-M Great Lakes clusters.

## Flowcharts of model-run directories

### modelruns/2026-02-03-A-gr-20k-3rep

```uniline
╭─Inputs─────────────────────────────────╮
│baseline_200_host_param_ranges_grans.xml│
╰────┰───────────────────────────────────╯
     ┃
     ▼
╭─Command─────────────────────────────────────╮
│lhs \                                        │
│  -s 123 \                                   │
│  -n 50000 \                                 │
│  -i baseline_200_host_param_ranges_grans.xml│
╰────┰────────────────────────────────────────╯
     ┃
     ▼
╭─Outputs────────╮
│{1..50000}.xml *│
╰────────────────╯

╭─Inputs─────────────────────────────────╮
│gr *                                    │
│lung-model-options-short.sh             │
│{1..20000}.xml *                        │
╰────┰───────────────────────────────────╯
     ┃
     ▼
╭─Command───────────────────────╮
│lhssubmit-job-array \          │
│  ./gr 1 20000 1 3 096:00:00 \ │
│  lung-model-options-short.sh 1│
╰────┰──────────────────────────╯
     ┃
     ▼
╭─Outputs───────────────╮
│exp{1..20000}/*/*.csv *│
╰───────────────────────╯

╭─Inputs─────────────────────────────────╮
│baseline_200_host_param_ranges_grans.xml│
│{1..20000}.xml *                        │
│exp{1..20000}/*/*.csv *                 │
│output_fields.csv                       │
╰────┰───────────────────────────────────╯
     ┃
     ▼
╭─Command───────────────────────────────╮
│sbatch make-lhs-prcc-7d-interval.sbatch│
╰────┰──────────────────────────────────╯
     ┃
     ▼
╭─Outputs──────────────────────────────────────╮
│output-lhs-7d-interval-stat-cols-10.csv.zst **│
╰──────────────────────────────────────────────╯

 TODO:
╭─Inputs─────────╮
│merge.ijm **    │
╰────┰───────────╯
     ┃
     ▼
╭─Command───────────────────────────────╮
│ImageJ2 *                              │
│../2024-07-19-A-gr-50k/img/*.tif *     │
│../2024-07-19-A-gr-50k/img_mibi/*.tif *│
╰────┰──────────────────────────────────╯
     ┃
     ▼
╭─Outputs────────────────╮
│img_stacks/*.tif **     │
│img_stacks_mibi/*.tif **│
╰────────────────────────╯
```

Notes for "[modelruns/2026-02-03-A-gr-20k-3rep](#modelruns2026-02-03-A-gr-20k-3rep)":

- Run the graphical program FIJI / `ImageJ2` to combine the TIFF files into
  colorized TIFF stacks for visualization.

### modelruns/2026-02-17-A-cellprofiler-stats

```uniline
╭─Inputs───╮
│spack *   │
│spack.yaml│
╰────┰─────╯
     ┃
     ▼
╭─Command──────────────────────╮
│sbatch 00-spack-install.sbatch│
╰────┰─────────────────────────╯
     ┃
     ▼
╭─Outputs───────────────────────────╮
│cellprofiler *                     │
│clustershell *                     │
│parallel *                         │
│meson *                            │
│ninja *                            │
│../2026-02-17-B-spack-buildcache/ *│
╰───────────────────────────────────╯

╭─Inputs╮
│spack *│
│meson *│
│ninja *│
╰────┰──╯
     ┃
     ▼
╭─Command──────────────────╮
│./01-gransimg-install.bash│
╰────┰─────────────────────╯
     ┃
     ▼
╭─Outputs─────────────────╮
│gransimg-build/gransimg *│
╰─────────────────────────╯

╭─Inputs───────╮
│gransim.cpproj│
╰────┰─────────╯
     ┃
     ▼
╭─Command────────────╮
│cellprofiler (gui) *│
╰────┰───────────────╯
     ┃
     ▼
╭─Outputs──────╮
│gransim.cppipe│
╰──────────────╯

╭─Inputs────────────────────────────────────────────╮
│gransimg *                                         │
│clustershell *                                     │
│cellprofiler *                                     │
│parallel *                                         │
│../2026-02-03-A-gr-20k-3rep/exp{1..20000}/*/seed * │
│../2026-02-03-A-gr-20k-3rep/exp{1..20000}/*/*.csv *│
│../2026-02-03-A-gr-20k-3rep/*.xml *                │
│gransim.cppipe                                     │
│tar *                                              │
│zstd *                                             │
╰────┰──────────────────────────────────────────────╯
     ┃
     ▼
╭─Command─────────────────────╮
│sbatch 02-cellprofiler.sbatch│
╰────┰────────────────────────╯
     ┃
     ▼
╭─Outputs────────────────────────────────────────────────────────────╮
│02-cellprofiler-joblogs/week{1..22}-rep{1..3}.joblog *              │
│02-cellprofiler-output/week{1..22}-rep{1..3}/*/cp/*.csv *           │
│02-cellprofiler-output/week{1..22}-rep{1..3}-unsummarized.tar.zstd *│
╰────────────────────────────────────────────────────────────────────╯

╭─Inputs────────────────╮
│Makefile.caret         │
│caret.def              │
│caret-install-methods.R│
╰────┰──────────────────╯
     ┃
     ▼
╭─Command────────────────╮
│make -f Makefile.caret *│
╰────┰───────────────────╯
     ┃
     ▼
╭─Outputs───╮
│caret.sif *│
╰───────────╯

╭─Inputs──────────────────────────────────────────────────╮
│clustershell *                                           │
│parallel *                                               │
│caret.sif *                                              │
│apptainer *                                              │
│02-cellprofiler-output/week{1..22}-rep{1..3}/*/cp/*.csv *│
│tar *                                                    │
│zstd *                                                   │
╰────┰────────────────────────────────────────────────────╯
     ┃
     ▼
╭─Command────────────────────╮
│sbatch 03-r-summarize.sbatch│
╰────┰───────────────────────╯
     ┃
     ▼
╭─Outputs──────────────────────────────────────────────────────────╮
│03-r-summarize-joblogs/week{1..22}-rep{1..3}.joblog *             │
│02-cellprofiler-output/week{1..22}-rep{1..3}/*/{im,obj}.csv *     │
│02-cellprofiler-output/week{1..22}-rep{1..3}-uncombined.tar.zstd *│
╰──────────────────────────────────────────────────────────────────╯

╭─Inputs──────────────────────────────────────────────────────╮
│caret.sif *                                                  │
│apptainer *                                                  │
│02-cellprofiler-output/week{1..22}-rep{1..3}/*/{im,obj}.csv *│
╰────┰────────────────────────────────────────────────────────╯
     ┃
     ▼
╭─Command──────────────────╮
│sbatch 04-r-combine.sbatch│
╰────┰─────────────────────╯
     ┃
     ▼
╭─Outputs─────────────────────────────────────────╮
│02-cellprofiler-output-combined/week{1..22}.csv *│
╰─────────────────────────────────────────────────╯

╭─Inputs────────╮
│Makefile.varsel│
│varsel.def     │
╰────┰──────────╯
     ┃
     ▼
╭─Command─────────────────╮
│make -f Makefile.varsel *│
╰────┰────────────────────╯
     ┃
     ▼
╭─Outputs────╮
│varsel.sif *│
╰────────────╯

╭─Inputs──────────────────────────────────────────╮
│varsel.sif *                                     │
│varsel.R                                         │
│output-lhs-7d-interval-stat-cols-10.csv **       │
│02-cellprofiler-output-combined/week{1..22}.csv *│
╰────┰────────────────────────────────────────────╯
     ┃
     ▼
╭─Command──────────╮
│05-r-varsel.sbatch│
╰────┰─────────────╯
     ┃
     ▼
╭─Outputs──────────────────────────────────╮
│05-r-varsel-output/size_week{1..22}.txt **│
│05-r-varsel-output/rank_week{1..22}.csv **│
╰──────────────────────────────────────────╯

╭─Inputs───────────────────────────────────────────────────────────────────╮
│../2024-09-17-A-mibi-data-oneshot/output-combined/week11.csv **           │
│../2026-02-03-A-gr-20k-3rep/output-lhs-7d-interval-stat-cols-10.csv.zst **│
│02-cellprofiler-output-combined/week11.csv.zst **                         │
│05-r-varsel-output/size_week22.txt **                                     │
│05-r-varsel-output/rank_week{11,22}.csv **                                │
╰────┰─────────────────────────────────────────────────────────────────────╯
     ┃
     ▼
╭─Command──────────────────────────────────────╮
│figure-07-08-ot-trajectories-and-images.Rmd **│
╰────┰─────────────────────────────────────────╯
     ┃
     ▼
╭─Outputs───────╮
│ot.runlist **  │
│ot-3.runlist **│
│ot-3.csv **    │
╰───────────────╯

╭─Inputs─────────────────────────────────────────────────────────────╮
│../2026-02-03-A-gr-20k-3rep/output_fields.csv *                     │
│../2026-02-03-A-gr-20k-3rep/output-lhs-7d-interval-stat-cols-*.csv *│
│ot.runlist **                                                       │
│varsel.sif *                                                        │
│matlab *                                                            │
│lhsPrccFromCsv.m *                                                  │
╰────┰───────────────────────────────────────────────────────────────╯
     ┃
     ▼
╭─Command─────────╮
│06-ot-prcc.sbatch│
╰────┰────────────╯
     ┃
     ▼
╭─Outputs───────────╮
│06-prcc_ot_9.mat **│
╰───────────────────╯

╭─Inputs────────────────────────────────────────────╮
│gransimg *                                         │
│parallel *                                         │
│tar *                                              │
│zstd *                                             │
│zip *                                              │
│../2026-02-03-A-gr-20k-3rep/1-20000.xml.tar.zst *  │
│../2026-02-03-A-gr-20k-3rep/exp{1..20000}/*/seed * │
│../2026-02-03-A-gr-20k-3rep/exp{1..20000}/*/*.csv *│
│../2026-02-03-A-gr-20k-3rep/*.xml *                │
│ot-3.runlist **                                    │
│ot-3.csv **                                        │
╰────┰──────────────────────────────────────────────╯
     ┃
     ▼
╭─Command────────────────╮
│06-ot-3-gransimg-gr.bash│
╰────┰───────────────────╯
     ┃
     ▼
╭─Outputs──────────────────╮
│06-ot-3-gransimg-gr.zip **│
╰──────────────────────────╯

╭─Inputs───────────────────╮
│merge.ijm **              │
│06-ot-3-gransimg-gr.zip **│
╰────┰─────────────────────╯
     ┃
     ▼
╭─Command─╮
│ImageJ2 *│
╰────┰────╯
     ┃
     ▼
╭─Outputs───────────╮
│img_stacks/*.tif **│
╰───────────────────╯
```

Notes for "[2026-02-17-A-cellprofiler-stats](#modelruns2026-02-17-A-cellprofiler-stats)":

- `cellprofiler` is the CellProfiler graphical program; to export
  `gransim.cpproj` to the `gransim.cppipe` file that can run on a cluster, in
  the graphical interface, click on File > Export > Pipeline... >
  gransim.cppipe.
- For GranSim CellProfiler is also installed into the spack environment, but
  for MIBI-TOF, cellprofiler is only run from the graphical program.
- The `gransim.cpproj` and equivalent `mibi.cpproj` files are archived in the
  subversion server directory
  /gr2d/GR-ABM-ODE/simulation/scripts/calibration/mibi/data-raw/
- The `../2026-02-17-B-spack-buildcache/` directory is an archival cache to
  redeploy subsequent spack package installations on the same operating system
  and CPU architecture without rebuilding them.
- Apptainer and Singularity-CE are the same program; Apptainer was renamed from
  Singularity by the Linux Foundation.
- Building the `caret.sif` and `varsel.sif` Singularity images requires root
  access for older versions of Singularity; therefore, this typically means
  running the root command on a machine other than a shared HPC cluster.  Root
  access is no longer required for the current version of Singularity, now
  called Apptainer, so you could use Apptainer instead of Singularity to
  simplify building these images but this build variant has not been tested for
  this research project.

### modelruns/2025-03-02-A-matches-spatial-x25-each-fig-2024-07-19-A-gr-50k

```uniline
╭─Inputs─────────────────────────────────╮
│gr *                                    │
│lung-model-options-short.sh             │
│*.xml *                                 │
│runlist                                 │
╰────┰───────────────────────────────────╯
     ┃
     ▼
╭─Command──────────────────╮
│submission-command-history│
╰────┰─────────────────────╯
     ┃
     ▼
╭─Outputs───────────╮
│exp*/*/*.state.gz *│
╰───────────────────╯

╭─Inputs────────────╮
│exp*/*/*.state.gz *│
│.config            │
╰────┰──────────────╯
     ┃
     ▼
╭─Commands───╮
│grviz-lung *│
╰────┰───────╯
     ┃
     ▼
╭─Outputs───────────────────────────────╮
│exp*/*/*png **                         │
│pngs-no-nucleus-no-sources-no-smoke.tar│
╰───────────────────────────────────────╯

╭─Inputs────────────────────────────────╮
│plot-x25.R                             │
│pngs-no-nucleus-no-sources-no-smoke.tar│
│runlist-metadata.csv **                │
╰────┰──────────────────────────────────╯
     ┃
     ▼
╭─Commands─────────╮
│Rscript plot-x25.R│
╰────┰─────────────╯
     ┃
     ▼
╭─Outputs───────────────╮
│Uncontrolled_x25.png **│
│Controlling_x25.png ** │
│Sterile_x25.png **     │
╰───────────────────────╯
```
