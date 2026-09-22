# R-LM-Isotope-Companion: Zenodo example
#
# This file is a test/example script extracted from a Zenodo-associated analysis.
# It is not a production-ready scientific workflow and it is not a dataset.
# It is used only to evaluate the R code-review behavior of the addin.
#
# Script:
# https://doi.org/10.5281/zenodo.17868174
#
# The script is not included in this repository.

#First example

example_values <- c(1, 2, 3, NA)
mean(example_values)


#Second example
#load packages
#Range 1 
library(googlesheets4)
library(dplyr)
library(scales)
library(ggrepel)
library(cowplot)
library(ggrepel)
library(ggplot2)
library(vroom)
library(tidyr)
library(Hmisc)
library(ggpmisc)
library(ggthemes)
library(rstatix)
library(effectsize)
library(tidyverse)
library(rstatix)
library(broom)

AbT <- read.csv(file = "AbT.csv", head = TRUE, sep=";")
AbT <- AbT %>%
  mutate(
    Ba.Ca = as.numeric(Ba.Ca),
    Sr.Ca = as.numeric(Sr.Ca),
    d18O = as.numeric(d18O),
    d13C = as.numeric(d13C),
    d66Zn = as.numeric(d66Zn)
  )

AbT1<-filter(AbT, Species=="Homo sapiens")
AbTF<-filter(AbT, Species!="Homo sapiens")

#Range 2
ZnCHAbT <-ggplot()+geom_point(data = AbT1%>% filter(!is.na(d13C) & !is.na(d66Zn)), mapping = aes(x=d13C, y=d66Zn, shape=Nutrition), color= "#BEBADA",size=3.5, stroke=1, alpha=.8)+
  scale_x_continuous(limits = c(-13, -8), breaks = pretty_breaks(n = 5))+
  theme_clean()+
  theme(panel.grid.major.x = element_line(color = "grey", linetype ="dotted"),  
        panel.grid.major.y = element_line(color = "grey"), 
        panel.grid.minor = element_blank(),  
        axis.ticks.length = unit(0.2, "cm")) +
  theme(plot.title=element_text(hjust=0.5, family = "Times New Roman"))+
  theme(axis.text=element_text(size=11),
        axis.title = element_text(size=12),
        axis.text.y = element_text(margin = margin(b = 2), hjust=0.95, vjust=0.4),
        axis.title.x.bottom = element_text(margin = margin(t=2, b=5)),
        axis.text.y.left = element_text(margin = margin(l= 2)),
        axis.title.y.left = element_text(margin = margin(l=5)),
        title = element_text(size=12),
        legend.position = "right", 
        legend.box.margin = margin(t = 40),
        plot.margin = margin(t = 20, r = 1, b = 20, l = 1, unit = "mm")) +
  theme(
    legend.text = element_text(size = 8),        
    legend.title = element_text(size = 9),       
    legend.key.size = unit(0.5, "cm")            
  )+
  scale_shape_manual(values = c(17, 18, 19, 25,  9, 15), breaks = c("Mother", "Probable Exclusive Breastfeeding", "Exclusive breastfeeding", "Weaning", "Probable Post weaning", "Post weaning"))+
  labs(y=expression(delta^{66}*Zn*"(\u2030)"), x = expression(delta^{13}*C*"(\u2030)"))+ 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  guides(shape=guide_legend(title="Nutrition"))+
  theme(aspect.ratio=1)+
  coord_fixed(ratio = 1)
ZnCHAbT
