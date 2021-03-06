# PSIchomics [![Build Status](https://travis-ci.org/nuno-agostinho/psichomics.svg?branch=master)](https://travis-ci.org/nuno-agostinho/psichomics) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/nuno-agostinho/psichomics?branch=master&svg=true)](https://ci.appveyor.com/project/nuno-agostinho/psichomics) [![codecov](https://codecov.io/gh/nuno-agostinho/psichomics/branch/master/graph/badge.svg)](https://codecov.io/gh/nuno-agostinho/psichomics)
Interactive R package to quantify, analyse and visualise alternative splicing 
data from [The Cancer Genome Atlas (TCGA)][1].

## Table of Contents

* [Install and Start Running](#install-and-start-running)
* [Tutorials](#tutorials)
* [Data Input](#data-input)
    * [Download TCGA data](#download-tcga-data)
    * [Load User Files](#load-user-files)
* [Splicing Quantification](#splicing-quantification)
* [Data Analyses](#data-analyses)
    * [Differential Splicing Analysis](#differential-splicing-analysis)
    * [Principal Component Analysis (PCA)](#principal-component-analysis-pca)
    * [Survival Analysis](#survival-analysis)
    * [Gene, Transcript and Protein Information](#gene-transcript-and-protein-information)
* [Data Groups](#data-groups)
* [Feedback](#feedback)
* [Contributions](#contributions)
* [References](#references)

## Install and Start Running
This package is not yet available in [Bioconductor][2]. To install and start 
using this program, follow these steps:

1. [Install R][3]
2. Open [RStudio][4] (or open a console, type `R` and press enter)
3. Type the following to install, load and start the visual interface:
```r
install.packages("devtools")
devtools::install_github("nuno-agostinho/psichomics")
library(psichomics)
psichomics()
```

## Tutorials

The following tutorials are available:

* [Visual interface](http://rpubs.com/nuno-agostinho/psichomics-tutorial-visual)
* [Command-line interface](http://rpubs.com/nuno-agostinho/psichomics-cli-tutorial)

Other tutorials coming soon:
* Developers and other contributors

## Data Input
### Download TCGA Data
You can download data from [The Cancer Genome Atlas (TCGA)][1] using this
package. Simply choose the cohort of interest, date of the sample, type of 
interest and so on.

### Load User Files
To load your own files, simply choose the folder where the data is located. 
PSIchomics will try to process all the data contained in the given folder and
sub-folders to search for files that can be loaded.

## Splicing Quantification
The quantification of each alternative splicing event is based on the proportion
of junction reads that support the inclusion isoform, known as percent 
spliced-in or PSI [(Wang *et al.*, 2008)](#references).

An estimate of this value is obtained based on the the proportion of reads 
supporting the inclusion of an exon over the reads supporting both the inclusion
and exclusion of that exon. To measure this estimate, both alternative splicing 
annotation and the quantification of RNA-Seq reads aligning to splice junctions
(junction quantification) are required. While alternative splicing Human (hg19
assembly) annotation is provided by the package, junction quantification may be
retrieved from [TCGA][1].

## Data Analyses
The program performs survival and principal component analyses, as well as
differential splicing analysis using non-parametric statistical tests.

### Differential Splicing Analysis
Analyse alternative splicing quantification based on variance and median 
statistical tests. The groups available for differential analysis comprise 
sample types (e.g. normal versus tumour) and clinical attributes of patients 
(e.g. tumour stage).

### Principal Component Analysis (PCA)
Explore alternative splicing quantification groups using associated clinical 
attributes.

### Survival Analysis
Analyse survival based on clinical attributes (e.g. tumour stage, gender and
race). Additionally, study the impact of the quantification of a single 
alternative splicing event on patient survivability.

### Gene, Transcript and Protein Information
For a given splicing event, examine its gene's annotation and corresponding 
transcripts and proteins. Related research articles are also available.

## Data Groups

- **By column:** automatically create groups by selecting a specific column of 
the dataset; for instance, to create a group for each tumour stage, start typing
`tumor_stage`, select the appropriate field from the suggestions, click 
`Create group` and confirm that there is now one group for each stage.
- **By row:** input specific rows to create a group
- **By subset expression:** type a subset expression
- **By GREP expression:** apply a GREP expression over a specific column of the 
dataset

You can also select groups by clicking on them in order to merge, intersect or 
remove the groups.

## Feedback
All feedback on the program, documentation and associated material is welcome. 
Please, send any suggestions and comments to the following contact:

> Nuno Saraiva-Agostinho (nunodanielagostinho@gmail.com)

> [Nuno Morais Lab, IMM][5]

## Contributions
Please note that this project is released with a [Contributor Code of Conduct]
[6]. By participating in this project you agree to abide by its terms.

## References
Wang, E. T., R. Sandberg, S. Luo, I. Khrebtukova, L. Zhang, C. Mayr, S. F. 
Kingsmore, G. P. Schroth, and C. B. Burge. 2008. [*Alternative isoform 
regulation in human tissue transcriptomes.*][7] Nature 456 (7221): 470–76.

[1]: https://tcga-data.nci.nih.gov
[2]: https://www.bioconductor.org
[3]: https://www.r-project.org
[4]: https://www.rstudio.com/products/rstudio
[5]: http://imm.medicina.ulisboa.pt/group/compbio
[6]: CONDUCT.md
[7]: http://www.nature.com/nature/journal/v456/n7221/full/nature07509.html