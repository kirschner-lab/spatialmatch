# Overview of HPC code

<!-- badges: start -->
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

- The following describes the computer cluster simulation files and directories
  in the Zenodo-archived zip file.

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
  Except for `modelruns/2024-07-19-A-gr-50k`, all model-runs use the Purdue
  Anvil cluster.  Most jobs are embarrassingly parallel serial CPU jobs run
  without MPI, or GPUs, or any requirement for special network topology or
  high-speed interconnect on large clusters.

  - `modelruns/2024-07-19-A-gr-50k` had the highest CPU need for 50,000
    simulations and therefore additionally used the UCSD Expanse, the U-M
    Lighthouse, and the U-M Great Lakes clusters.

  - The workflow in `modelruns/2024-06-27-A-training-data-oneshot` was split
    into `modelruns/2024-08-19-A-training-data-oneshot-50k` and
    `modelruns/2024-09-03-A-varsel-50k` due to higher memory requirements when
    going from 5,000 to 50,000 granulomas.

## Flowcharts of model-run directories

### modelruns/2024-06-14-A-gs-5000

```uniline
╭─Inputs─────────────────────────────────╮
│baseline_200_host_param_ranges_grans.xml│
╰────┰───────────────────────────────────╯
     ┃
     ▼
╭─Command─────────────────────────────────────╮
│lhs \                                        │
│  -s 123 \                                   │
│  -n 5000 \                                  │
│  -i baseline_200_host_param_ranges_grans.xml│
╰────┰────────────────────────────────────────╯
     ┃
     ▼
╭─Outputs───────╮
│{1..5000}.xml *│
╰───────────────╯

╭─Inputs────────────────────╮
│gr *                       │
│lung-model-options-short.sh│
│{1..5000}.xml *            │
╰────┰──────────────────────╯
     ┃
     ▼
╭─Command───────────────────────╮
│lhssubmit-job-array \          │
│  ./gr 1 5000 1 1 048:00:00 \  │
│  lung-model-options-short.sh 1│
╰────┰──────────────────────────╯
     ┃
     ▼
╭─Outputs──────────────╮
│exp{1..5000}/*/*.csv *│
╰──────────────────────╯

╭─Inputs─────────────────────────────────╮
│baseline_200_host_param_ranges_grans.xml│
│exp{1..5000}/*/*.csv *                  │
│output_fields.csv                       │
╰────┰───────────────────────────────────╯
     ┃
     ▼
╭─Command───────────────────────────────────────╮
│TIME_STEPS_PER_DAY=144 make-lhs-prcc.py \      │
│  -i baseline_200_host_param_ranges_grans.xml \│
│  --f output_fields.csv --o output-lhs.csv \   │
│  --di 7,0,154 --es 1 --ee 5000 --rs 1 --re 1  │
╰────┰──────────────────────────────────────────╯
     ┃
     ▼
╭─Outputs─────────────────────────────────╮
│output-lhs-aggregated-stat-cols-35.csv **│
╰─────────────────────────────────────────╯
```

### modelruns/2024-06-27-A-training-data-oneshot

```uniline
╭─Inputs────╮ ╭─Inputs───────╮ ╭─Inputs────────────────╮
│build.ninja│ │gransim.cpproj│ │caret.def              │
│gransimg.c │ ╰────┰─────────╯ │caret-install-methods.R│
╰────┰──────╯      ┃           ╰────┰──────────────────╯
     ┃             ┃                ┃
     ▼             ▼                ▼
╭─Command╮    ╭─Command──────╮ ╭─Command──────────────────────╮
│ninja * │    │cellprofiler *│ │SINGULARITY_TMPDIR=/var/tmp \ │
╰────┰───╯    ╰────┰─────────╯ │  sudo singularity build \    │
     ┃             ┃           │  /var/tmp/caret.sif caret.def│
     ▼             ▼           ╰────┰─────────────────────────╯
╭─Outputs──╮  ╭─Outputs──────╮      ┃
│gransimg *│  │gransim.cppipe│      ▼
╰──────────╯  ╰──────────────╯ ╭─Outputs───╮
                               │caret.sif *│
╭─Inputs───────╮               ╰───────────╯
│gramsimg *    │
│gransim.cppipe│
│caret.sif *   │
│summarize.R   │
│parallel *    │
╰────┰─────────╯
     ┃
     ▼
╭─Command─────────────╮
│run-cp-oneshot.sbatch│
╰────┰────────────────╯
     ┃
     ▼
╭─Outputs──────╮
│joblog        │
│output/*.csv *│
╰──────────────╯

╭─Inputs─────────╮
│output/*/*.csv *│
│combine-csvs.R  │
╰────┰───────────╯
     ┃
     ▼
╭─Command──────────────╮
│Rscript combine-csvs.R│
╰────┰─────────────────╯
     ┃
     ▼
╭─Outputs─────╮
│output.csv **│
╰─────────────╯
```

Notes for
"[modelruns/2024-06-27-A-training-data-oneshot](#modelruns2024-06-27-a-training-data-oneshot)":

- `cellprofiler` is the CellProfiler graphical program; to export
  `gransim.cpproj` to the `gransim.cppipe` file that can run on a cluster, in
  the graphical interface, click on File > Export > Pipeline... >
  gransim.cppipe.

### modelruns/2024-07-19-A-gr-50k

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
│{1..50000}.xml *                        │
╰────┰───────────────────────────────────╯
     ┃
     ▼
╭─Command───────────────────────╮
│lhssubmit-job-array \          │
│  ./gr 1 50000 1 1 096:00:00 \ │
│  lung-model-options-short.sh 1│
╰────┰──────────────────────────╯
     ┃
     ▼
╭─Outputs───────────────╮
│exp{1..50000}/*/*.csv *│
╰───────────────────────╯

╭─Inputs─────────────────────────────────╮
│baseline_200_host_param_ranges_grans.xml│
│exp{1..50000}/*/*.csv *                 │
│output_fields.csv                       │
╰────┰───────────────────────────────────╯
     ┃
     ▼
╭─Command───────────────────────────────────────╮
│TIME_STEPS_PER_DAY=144 make-lhs-prcc.py \      │
│  -i baseline_200_host_param_ranges_grans.xml \│
│  --f output_fields.csv --o output-lhs.csv \   │
│  --di 7,0,154 --es 1 --ee 50000 --rs 1 --re 1 │
│gzip output-lhs-aggregated-stat-cols-35.csv    │
╰────┰──────────────────────────────────────────╯
     ┃
     ▼
╭─Outputs────────────────────────────────────╮
│output-lhs-aggregated-stat-cols-35.csv.gz **│
╰────────────────────────────────────────────╯
 
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

Notes for "[modelruns/2024-07-19-A-gr-50k](#modelruns2024-07-19-a-gr-50k)":

- Run the graphical program FIJI / `ImageJ2` to combine the TIFF files into
  colorized TIFF stacks for visualization.

### modelruns/2024-08-13-A-training-data-oneshot-50k

```uniline
╭─Inputs────╮ ╭─Inputs───────╮
│build.ninja│ │gransim.cpproj│
│gransimg.c │ ╰────┰─────────╯
╰────┰──────╯      ┃
     ┃             ┃
     ▼             ▼
╭─Command╮    ╭─Command──────╮
│ninja * │    │cellprofiler *│
╰────┰───╯    ╰────┰─────────╯
     ┃             ┃
     ▼             ▼
╭─Outputs──╮  ╭─Outputs──────╮
│gransimg *│  │gransim.cppipe│
╰──────────╯  ╰──────────────╯

╭─Inputs───────────────────────────────────────╮
│gransimg *                                    │
│cellprofiler *                                │
│parallel *                                    │
│../2024-07-19-A-gr-50k/exp{1..50000}/*/seed * │
│../2024-07-19-A-gr-50k/exp{1..50000}/*/*.csv *│
│../2024-07-19-A-gr-50k/*.xml *                │
│gransim.cppipe                                │
╰────┰─────────────────────────────────────────╯
     ┃
     ▼
╭─Command─────────────╮
│run-cp-oneshot.sbatch│
╰────┰────────────────╯
     ┃
     ▼
╭─Outputs──────────────────────╮
│joblogs/*.joblog              │
│output/week{1.22}/*/cp/*.csv *│
╰──────────────────────────────╯

╭─Inputs───────────────────────╮
│tar *                         │
│zstd *                        │
│output/week{1.22}/*/cp/*.csv *│
╰────┰─────────────────────────╯
     ┃
     ▼
╭─Command───────────╮
│run-compress.sbatch│
╰────┰──────────────╯
     ┃
     ▼
╭─Outputs─────────╮
│output.tar.zstd *│
╰─────────────────╯
```

Notes for "[modelruns/2024-08-13-A-training-data-oneshot-50k](#modelruns2024-08-19-A-training-data-oneshot-50k)":

- `cellprofiler` is the CellProfiler graphical program; to export
  `gransim.cpproj` to the `gransim.cppipe` file that can run on a cluster, in
  the graphical interface, click on File > Export > Pipeline... >
  gransim.cppipe.
- cp / cellprofiler is installed into the spack environment.

### modelruns/2024-08-19-A-training-data-reduce-50k

```uniline
╭─Inputs────────────────╮
│caret.def              │
│caret-install-methods.R│
╰────┰──────────────────╯
     ┃
     ▼
╭─Command─────╮
│singularity *│
╰────┰────────╯
     ┃
     ▼
╭─Outputs───╮
│caret.sif *│
╰───────────╯

╭─Inputs──────────────────────────────────────────────────────────────────╮
│caret.sif *                                                              │
│summarize.R                                                              │
│../2024-08-13-A-training-data-oneshot-50k/output/week{1..22}/*/cp/*.csv *│
╰────┰────────────────────────────────────────────────────────────────────╯
     ┃
     ▼
╭─Command──────────────╮
│run-cp-reduce-2.sbatch│
╰────┰─────────────────╯
     ┃
     ▼
╭─Outputs──────────────────────╮
│joblogs/week{1..22}.joblog *  │
│output/week{1..22}/*/im.csv * │
│output/week{1..22}/*/obj.csv *│
╰──────────────────────────────╯

╭─Inputs───────────────────────╮
│caret.sif *                   │
│combine.R                     │
│output/week{1..22}/*/im.csv * │
│output/week{1..22}/*/obj.csv *│
╰────┰─────────────────────────╯
     ┃
     ▼
╭─Command─────────────╮
│run-cp-combine.sbatch│
╰────┰────────────────╯
     ┃
     ▼
╭─Outputs──────────────────────────╮
│output-combined/week{1..22}.csv **│
╰──────────────────────────────────╯
```

Notes for "[modelruns/2024-08-19-A-training-data-reduce-50k](#modelruns2024-08-19-A-training-data-reduce-50k)":

- Building the `caret.sif` Singularity image requires root access for older
  versions of Singularity; therefore, this typically means running the root
  command on a machine other than a shared HPC cluster.  Root access is no
  longer required for the current version, Apptainer (renamed from Singularity
  by the Linux Foundation), so you could use Apptainer instead of Singularity
  to simplify building the `caret.sif` Singularity image.

### modelruns/2024-09-03-A-varsel-50k

```uniline
╭─Inputs───╮
│Makefile  │
│varsel.def│
╰────┰─────╯
     ┃
     ▼
╭─Command─────╮
│singularity *│
╰────┰────────╯
     ┃
     ▼
╭─Outputs────╮
│varsel.sif *│
╰────────────╯

╭─Inputs─────────────────────────────────────────────────────────────────╮
│varsel.sif *                                                            │
│varsel.R                                                                │
│../2024-07-19-A-gr-50k/output-lhs-stat-cols-35.csv.gz                   │
│../2024-08-19-A-training-data-reduce-50k/output-combined/week{1..22}.csv│
╰────┰───────────────────────────────────────────────────────────────────╯
     ┃
     ▼
╭─Command─────────╮
│run-varsel.sbatch│
╰────┰────────────╯
     ┃
     ▼
╭─Outputs───────────────────────────╮
│output/refm_obj_week{1..22}.RData *│
│output/cvvs_week{1..22}.RData *    │
╰───────────────────────────────────╯

╭─Inputs────────────────────────────╮
│varsel.sif *                       │
│fix_cvvs_exports.R                 │
│output/refm_obj_week{1..22}.RData *│
│output/cvvs_week{1..22}.RData *    │
╰────┰──────────────────────────────╯
     ┃
     ▼
╭─Command──────────╮
│run-exports.sbatch│
╰────┰─────────────╯
     ┃
     ▼
╭─Outputs──────────────────────╮
│output/rank_week{1..22}.txt **│
│output/size_week{1..22}.txt **│
╰──────────────────────────────╯
```

Notes for "[modelruns/2024-09-03-A-varsel-50k](#modelruns2024-09-03-A-varsel-50k)":

- Building the `varsel.sif` Singularity image requires root access for older
  versions of Singularity; therefore, this typically means running the root
  command on a machine other than a shared HPC cluster.  Root access is no
  longer required for the current version, Apptainer (renamed from Singularity
  by the Linux Foundation), so you could use Apptainer instead of Singularity
  to simplify building the `varsel.sif` Singularity image.

### modelruns/2024-09-17-A-mibi-data-oneshot

```uniline
╭─Inputs────╮
│mibi.cpproj│
╰────┰──────╯
     ┃
     ▼
╭─Command──────╮
│cellprofiler *│
╰────┰─────────╯
     ┃
     ▼
╭─Outputs──╮
│cp/*.csv *│
╰──────────╯

╭─Inputs────╮
│summarize.R│
│cp/*.csv * │
╰────┰──────╯
     ┃
     ▼
╭─Command───────────────────────╮
│Rscript summarize.R cp/ output/│
╰────┰──────────────────────────╯
     ┃
     ▼
╭─Outputs─────────────────╮
│output/week11/0/im.csv * │
│output/week11/0/obj.csv *│
╰─────────────────────────╯

╭─Inputs──────────────────╮
│combine.R                │
│output/week11/0/im.csv * │
│output/week11/0/obj.csv *│
╰────┰────────────────────╯
     ┃
     ▼
╭─Command─────────╮
│Rscript combine.R│
╰────┰────────────╯
     ┃
     ▼
╭─Outputs─────────────────────╮
│output-combined/week11.csv **│
╰─────────────────────────────╯
```

### modelruns/2024-12-25-A-ot-prcc-50k

```uniline
╭─Inputs────────────────────────────────────────────────────────╮
│make-lhs-prcc.py *                                             │
│../2024-07-19-A-gr-50k/baseline_200_host_param_ranges_grans.xml│
│../2024-07-19-A-gr-50k/exp*/*/*.csv *                          │
│output_fields.csv                                              │
│runlist                                                        │
│R *                                                            │
│matlab *                                                       │
│lhsPrccFromCsv.m *                                             │
╰────┰──────────────────────────────────────────────────────────╯
     ┃
     ▼
╭─Command────────────────╮
│make-csv-and-prcc.sbatch│
╰────┰───────────────────╯
     ┃
     ▼
╭─Outputs─────────╮
│prcc-0.1-9.mat **│
╰─────────────────╯
```

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
