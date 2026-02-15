# KODAQS-Assignment-Tillman-Claus
This is my contribution to the Course Assignment for Course 4.1 of the KODAQS Academy
It is my first time using Git, so the commits are a bit messy.
In this research project I wanted to try out cox proportional hazard models to estimate the effect of working conditions on the probability to retire early from the labour market.
For this I used data from SHARE.
Since this was also my first time working with hazard models, creating a feasible data structure for it took longer than expected, which reduced the analysis I was able to do afterwards.
But as the goal here was not to create a great analysis I wanted to use to opportunity to try something new.


## Data

This project uses data from the Survey of Health, Ageing and Retirement in Europe (SHARE).

The data are not publicly available due to licensing and privacy restrictions.

To reproduce the analysis:

1. Register at https://share-eric.eu/
2. Download the relevant waves.
3. Place the raw data files into:
   data/raw/

The scripts in `analysis/` will process the data automatically.

## Renv

This project uses renv to ensure full reproducibility of the R environment.

To reproduce the analysis:

1. Clone the repository
2. Open the project in RStudio
3. Run:

renv::restore()
