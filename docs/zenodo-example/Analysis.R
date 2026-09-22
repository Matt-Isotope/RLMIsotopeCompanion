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

# ============================================================
# MANUAL TESTS FOR THE ADDIN
# ============================================================

# These examples are intentionally simple and designed to verify that
# the addin identifies real problems without inventing missing code or
# context. They are not scientific workflows and are only meant for
# local validation of the review behavior.

# ------------------------------------------------------------
# TEST 1 - Missing values in mean()
# ------------------------------------------------------------
# Goal: confirm that the model notices that mean() returns NA when NA
# values are present unless na.rm = TRUE.

example_values <- c(1, 2, 3, NA)
mean(example_values)

# Suggested user prompt:
# "Review this selected R code for real bugs and necessary corrections."


# ------------------------------------------------------------
# TEST 2 - Obvious argument error
# ------------------------------------------------------------
# Goal: confirm that the model identifies an invalid argument name.

values <- c(10, 20, 30)

mean(values, remove_missing = TRUE)

# Suggested user prompt:
# "Identify only the visible execution errors in this code."


# ------------------------------------------------------------
# TEST 3 - Undefined variable
# ------------------------------------------------------------
# Goal: confirm that the model catches a real execution error without
# inventing the missing object.

result <- not_existing_variable * 2

# Suggested user prompt:
# "Review only the selected code. Point out only real errors."


# ------------------------------------------------------------
# TEST 4 - Incorrect dplyr filter syntax
# ------------------------------------------------------------
# Goal: confirm that the model recognises that "=" is not valid in filter().

library(dplyr)

data_test <- data.frame(
  species = c("human", "animal", "human"),
  value = c(10, 20, 30)
)

filtered_data <- data_test %>%
  filter(species = "human")

# Suggested user prompt:
# "Check this selected R code for errors that would affect execution or results."


# ------------------------------------------------------------
# TEST 5 - Missing values handling
# ------------------------------------------------------------
# Goal: confirm that the model notices an NA-related issue.

data_test <- data.frame(
  group = c("A", "A", "B"),
  value = c(10, NA, 30)
)

mean(data_test$value)

# Suggested user prompt:
# "Review this selected R code and mention any real problems."


# ------------------------------------------------------------
# TEST 6 - ggplot with missing column
# ------------------------------------------------------------
# Goal: confirm that the model notices that the column does not exist.

library(ggplot2)

ggplot(data_test, aes(x = group, y = missing_column)) +
  geom_point()

# Suggested user prompt:
# "Review this selected R code for real bugs and necessary corrections."


# ------------------------------------------------------------
# TEST 7 - Correct code should not be flagged
# ------------------------------------------------------------
# Goal: confirm that the model does not invent problems in valid code.

x <- c(1, 2, 3, 4)

mean(x)
sd(x)

# Suggested user prompt:
# "Identify only real problems. Ignore optional style suggestions."


# ------------------------------------------------------------
# TEST 8 - Two-range workflow
# ------------------------------------------------------------
# Goal: check that Range 1 and Range 2 are handled as expected in the addin.

# Range 1
numbers <- c(1, 2, 3, 4, NA)
mean(numbers)

# Range 2
numbers[numbers > 2]

# In the addin:
# 1. select this file;
# 2. use the first block as Range 1;
# 3. select the second block in the editor;
# 4. click "Grab editor selection";
# 5. send the question to LM Studio.

# Suggested user prompt:
# "Review this selected R code for real bugs and necessary corrections."


# ------------------------------------------------------------
# ADDITIONAL MANUAL CHECKS
# ------------------------------------------------------------

# Manual check A - LM Studio offline
# 1. Close LM Studio or stop the local server.
# 2. Open the addin.
# 3. Click "Refresh models".
# Expected behavior: the app should show a clear error message instead of failing silently.

# Manual check B - No model loaded
# 1. Open LM Studio.
# 2. Start the local server.
# 3. Do not load any model.
# 4. Refresh models in the addin.
# Expected behavior: the app should explain that no model is available.

# Manual check C - Missing file
# 1. Set the file path to a non-existent file.
# 2. Click "Ask LM Studio".
# Expected behavior: the app should show a clear "file not found" or equivalent
# error message without crashing.

# Manual check D - Large code selection
# 1. Select a large code range.
# 2. Ask the addin to review it.
# Expected behavior: the app should either handle the request gracefully or warn
# that the prompt may be too large.

# ------------------------------------------------------------
# EVALUATION GUIDE
# ------------------------------------------------------------
# A response is considered acceptable when:
# - it identifies real visible issues;
# - it does not invent missing objects, functions, packages or file context;
# - it distinguishes actual bugs from optional style suggestions;
# - it proposes valid R corrections;
# - it does not flag clearly correct code as broken.

#Real example
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
