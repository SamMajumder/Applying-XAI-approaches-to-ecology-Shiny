
library(shiny)
library(tidyverse)
library(here)
library(sf)
library(ggplot2)
library(plotly)
library(RColorBrewer)
library(leaflet)

### Load the datasets ### 


ALE <- readRDS("ALE_train.RDS")

Boruta <- read.csv("Boruta_results.csv") %>% 
                                 select(meanImp,Feature) %>%
                                 rename(Overall = meanImp) %>% 
                                 rename(Features = Feature) %>% 
                                 mutate(Groups = "Strongly_Divergent")
                              

C_V_I_predicted_GBM <- readRDS("C_V_I_predicted_GBM.RDS")

Ecoregions <- readRDS("Ecoregions_shape_our_ecotype.RDS") 

#Ecoregions_shape <- readRDS("Ecoregions_shape.RDS")

RFE <- read.csv("Rfe_best_subset_imp.csv") %>% 
                           mutate(Groups = "Divergent")

Study_ecoregions_sf <- readRDS("Study_ecoregions_sf.RDS")


# Transform CRS outside the render function
Ecoregions <- st_transform(Ecoregions, crs = 4326)
Study_ecoregions_sf <- st_transform(Study_ecoregions_sf, crs = 4326)



### Binding the RFE and Boruta 

Importance <- rbind(RFE,Boruta)

### Editing the names so that they look aesthetically pleasing on the plot

Importance <- Importance %>% 
  mutate(Features = str_replace_all(Features,"\\."," ")) %>% 
  mutate(Features = str_replace_all(Features, "_"," ")) %>% 
  mutate(Features = recode(Features, "Days to flowering" = "DTF")) %>% 
  mutate(Features = recode(Features, "Darker axillae1" = "Darker axillae")) %>% 
  mutate(Features = recode(Features, "Total Leaf Number" = "TLN")) %>% 
  mutate(Features = recode(Features, "Specific Leaf Area" = "SLA")) %>% 
  mutate(Trait_type = case_when(str_detect(Features,"Leaf") ~ "Leaf",
                                str_detect(Features, "Seed") ~ "Seed",
                                str_detect(Features, "RGB") ~ "Leaf",
                                str_detect(Features, "SLA") ~ "Leaf",
                                str_detect(Features, "Primary branches") ~ "Plant architecture",
                                str_detect(Features, "Distance of first branching from ground") ~ "Plant architecture",
                                str_detect(Features, "TLN") ~ "Plant architecture",
                                str_detect(Features, "Stem") ~ "Stem",
                                str_detect(Features, "Flower") ~ "Floral",
                                str_detect(Features, "Ligule") ~ "Floral",
                                str_detect(Features, "axillae") ~ "Floral",
                                str_detect(Features, "phyllaries") ~ "Floral",
                                str_detect(Features, "Phyllaries") ~ "Floral",
                                str_detect(Features, "Disk") ~ "Floral",
                                str_detect(Features, "DTF") ~ "Phenology",
                                str_detect(Features, "Plant height at flowering") ~ "Phenology",
                                str_detect(Features, "Days to budding") ~ "Phenology"))


Importance$Trait_type <- factor(Importance$Trait_type, 
                                       levels = c("Leaf","Plant architecture",
                                                  "Floral","Seed","Phenology",
                                                  "Stem"))





##############

ui <- fluidPage(
  
  titlePanel("Intraspecific trait variation under landscape-scale population 
             differentiation"),
  
  tabsetPanel(
    tabPanel("About",
             h1("Description"),
             p("This accompanying shiny app showcases some of the key results 
             from the study titled - 'Applying an interpretable machine learning 
             approach to assess intraspecific trait variation under landscape-scale 
             population differentiation', authored by Sambadi Majumder and 
             Dr. Chase Mason (doi: https://doi.org/10.1101/2023.04.07.536012)."),
             
             p("This study used data from the HeliantHome database (Link: http://www.helianthome.org/), 
             which is a public database of functional trait data for Helianthus annuus genotypes 
             (Bercovich et al., 2022) (doi: https://doi.org/10.1038/s41597-022-01842-0) 
             The genotypes used in this study were extracted from the database 
             based on their occurrence within the Level I ecoregions of the 
             Great Plains and North American Deserts. The geographic coordinates 
             of each source population were cross-referenced with a shapefile of 
             Level I ecoregions sourced from the United States Environmental Protection 
             Agency (U.S. Environmental Protection Agency, 2010)
             (https://www.epa.gov/eco-research/ecoregions-north-america)"),
             
             p("The 'Study Region' tab of the app shows the populations of Helianthus 
             annuus used in this study and in which ecoregion they are distributed. 
             The 'Divergent Traits' tab shows the traits that exhibit intraspecific 
             divergence between the Desert and Plains populations. These are the 
             functional traits most predictive of ecoregion, spanning categories of 
             leaf economics, plant architecture, reproductive phenology, and floral 
             and seed morphology. The 'Impact of Divergence' tab shows accumulated 
             local effects plots that articulate how each divergent trait specifically 
             impacts classification of an individual to Plains versus Desert."),
              
             p("This approach readily identifies traits predictive of ecoregion origin and the functional 
             traits most likely to be responsible for contrasting ecological strategies across the landscape. 
             This type of approach can be used to parse large plant trait datasets in a wide range of contexts, 
             including explicitly testing the applicability of interspecific paradigms at intraspecific scales. 
             The HeliantHome database provides a valuable resource for researchers studying functional trait 
             divergence in Helianthus annuus."),
             
             h2("References"),
             
             p("Bercovich N, N Genze, M Todesco, GL Owens, J-S Légaré, K Huang, LH Rieseberg, DG 
             Grimm 2022 HeliantHOME, a public and centralized database of phenotypic sunflower 
             data. Sci Data 9: 735.")
             
             ),
    
    tabPanel("Study Region",
             leafletOutput("Study_Region_Map", height = "600px")), 
    
    tabPanel("Divergent Traits",
             ## Hierarchical dropdowns #####
             
             fluidRow(
               column(width = 6,
                      selectInput("Groups",
                                  "Groups",
                                  choices = unique(Importance$Groups)))
              ),
    plotlyOutput("Importance_plot",
                 height = "800px")
    
    ),
    
    tabPanel("Impacts on divergence",
            ### Hierarchical dropdowns 
             fluidRow(
               column(width = 6,
                      selectInput("Trait",
                                  "Trait",
                                  choices = unique(ALE$Trait)))
             ),
             plotlyOutput("ALE")
    )
  )
)
  
    
  
  
server <- function(input,output,session){ 
  
  # Check unique values in Ecoregion column
  observe({
    print(unique(Ecoregions$Ecoregion))
  })
  
  # Define color palette
  ecoregion_colors <- colorFactor(c("red", "blue"), domain = unique(Ecoregions$Ecoregion))
  
  
  output$Study_Region_Map <- renderLeaflet({ 
    
    # Create a leaflet map
    m <- leaflet() %>%
      addTiles() %>% # Add default OpenStreetMap tiles
      addPolygons(data = Ecoregions, 
                  fillColor = ~ecoregion_colors(Ecoregion), 
                  fillOpacity = 0.2, 
                  weight = 1, color = "black",
                  label = ~as.character(Ecoregion)) %>% # Add labels for interactivity 
      addCircleMarkers(data = Study_ecoregions_sf, radius = 5, 
                       color = ~ecoregion_colors(Ecoregions), 
                       fillColor = ~ecoregion_colors(Ecoregions), 
                       fillOpacity = 1, 
                       stroke = FALSE,
                       popup = ~as.character(population_id)) %>% # Make points interactive with popups
      addLegend("bottomright", pal = ecoregion_colors, 
                values = unique(Ecoregions$Ecoregion), 
                title = "Ecoregion") # Add legend
    
    # Return the map
    m
  
    
  })
  
  
  
  output$Importance_plot <- renderPlotly({
    
    p2 <- Importance %>% 
                  filter(Groups == input$Groups) %>% 
      ggplot(aes(x=reorder(Features,
                           Overall), 
                 y = Overall, 
                 fill = Trait_type)) +
      geom_bar(stat = "identity",
               color ="black") + 
      scale_fill_manual(values = c("#A6D854",
                                   "#8DA0CB",
                                   "#FFD92F" ,
                                   "#E5C494",
                                   "#E78AC3",
                                   "#FC8D62"),
                        name= 'Trait type') +
      labs(x= "HeliantHOME Traits",
           y= "Variable Importance") +
      coord_flip() + 
      theme_bw() + theme(legend.position = "right") +
      theme(text = element_text(size = 10))
    
    ggplotly(p2)
    
  })
  
  output$ALE <- renderPlotly({
    
    p3 <- ALE %>% 
               filter(Trait == input$Trait) %>% 
           ggplot(aes(x = Trait_Value, 
                      y = ALE)) + 
      geom_line(aes(color = Ecoregions)) +
      facet_wrap(~Ecoregions) +
      scale_color_manual(values=c('#619CFF',
                                  '#F8766D')) + 
      labs(x = "Trait Value", 
           y = "Accumulated Local Effects") +
      theme(text = element_text(size = 9)) +
      theme(legend.position="bottom") 
    
    ggplotly(p3)
    
  }) 

}


shinyApp(ui,server)








