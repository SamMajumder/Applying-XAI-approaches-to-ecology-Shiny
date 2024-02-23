# 🌱 Applying-XAI-approaches-to-ecology-Shiny

## Overview 📜
This Shiny app accompanies the study titled "Applying an interpretable machine learning approach to assess intraspecific trait variation under landscape-scale population differentiation," authored by Sambadi Majumder and Dr. Chase Mason. The study, accessible through [this DOI link](https://doi.org/10.1101/2023.04.07.536012), investigates the functional trait data of Helianthus annuus genotypes from the HeliantHome database.

## Data Source 🌐
The functional trait data is from the [HeliantHome database](http://www.helianthome.org/), publicized in Bercovich et al., 2022 ([DOI link](https://doi.org/10.1038/s41597-022-01842-0)). Genotypes were selected based on their occurrence within the Level I ecoregions of the Great Plains and North American Deserts, correlated with ecoregion shapefiles from the [U.S. Environmental Protection Agency](https://www.epa.gov/eco-research/ecoregions-north-america).

## Built With 🛠️
- **Programming Language**: R
- **Key Packages**:
  - `shiny` for app functionality.
  - `leaflet` for interactive mapping 🗺️.
  - `ggplot2` and `plotly` for creating visualizations 📊.
  - `dplyr` for data manipulation 🔨.
  - `sf` for handling spatial data 🌍.

## App Structure 📚
### Study Region 📍
Displays a map of Helianthus annuus populations' distribution within the Great Plains and North American Deserts ecoregions.

![Study Region Screenshot](https://github.com/SamMajumder/Applying-XAI-approaches-to-ecology-Shiny/blob/main/Screenshot%20(32).png)

### Divergent Traits 🔍
Reveals traits exhibiting divergence between the Desert and Plains populations, highlighting those most predictive of ecoregion.

![Divergent Traits Screenshot](https://github.com/SamMajumder/Applying-XAI-approaches-to-ecology-Shiny/blob/main/Screenshot%20(33).png)

### Impacts on Divergence 🔬
Shows accumulated local effects plots articulating the impact of each divergent trait on ecoregion classification.

![Impacts on Divergence Screenshot](https://github.com/SamMajumder/Applying-XAI-approaches-to-ecology-Shiny/blob/main/Screenshot%20(35).png)

## Research and Application 🧬
Demonstrates an interpretable machine learning approach for identifying ecoregion-predictive traits, essential for ecological strategy research in Helianthus annuus.

## How to Use 🤔
Navigate between study components through an intuitive interface, engaging with visualizations for a deeper understanding of the findings.

Explore the interactive visualizations on the Shiny app [here](https://sammajumder.shinyapps.io/TraitDivergenceIntraSpecific/).
