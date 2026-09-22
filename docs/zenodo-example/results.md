# R code-review prompt comparison

## Test context

The tests used:

- the minimal R example `example_values <- c(1, 2, 3, NA); mean(example_values)`;
- the R script `Giaccari_et_al_Zn_Isotopes_Analysis.R`, extracted from the Zenodo record;
- the existing `Geochemistry & Isotopes` system prompt in the addin;
- the local Model 4B model in LM Studio.

The system prompt was not modified during these tests. The comparison focused on different user questions sent with the same selected R code and the same system prompt.

The Zenodo test used two code ranges. Range 1 contained package loading, data import, conversion, and filtering. Range 2 contained the plotting code. The code below is the exact selected material used for the final comparison.

## Preliminary functional test

### Submitted code

```r
example_values <- c(1, 2, 3, NA)
mean(example_values)
```

### User prompt

```text
Review this selected R code.
```

### Result

The model correctly identified that `mean(example_values)` returns `NA` when the vector contains a missing value and suggested:

```r
mean(example_values, na.rm = TRUE)
```

This was a successful minimal test: the problem was real, the suggested correction was valid, and the result could be verified directly in R.

## Zenodo script analyzed

The following code was extracted from `Giaccari_et_al_Zn_Isotopes_Analysis.R` and sent to the addin as Range 1 and Range 2:

```r
# Range 1
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

AbT <- read.csv(file = "AbT.csv", head = TRUE, sep = ";")
AbT <- AbT %>%
  mutate(
    Ba.Ca = as.numeric(Ba.Ca),
    Sr.Ca = as.numeric(Sr.Ca),
    d18O = as.numeric(d18O),
    d13C = as.numeric(d13C),
    d66Zn = as.numeric(d66Zn)
  )

AbT1 <- filter(AbT, Species == "Homo sapiens")
AbTF <- filter(AbT, Species != "Homo sapiens")

# Range 2
ZnCHAbT <- ggplot() +
  geom_point(
    data = AbT1 %>% filter(!is.na(d13C) & !is.na(d66Zn)),
    mapping = aes(x = d13C, y = d66Zn, shape = Nutrition),
    color = "#BEBADA",
    size = 3.5,
    stroke = 1,
    alpha = .8
  ) +
  scale_x_continuous(limits = c(-13, -8), breaks = pretty_breaks(n = 5)) +
  theme_clean() +
  theme(
    panel.grid.major.x = element_line(color = "grey", linetype = "dotted"),
    panel.grid.major.y = element_line(color = "grey"),
    panel.grid.minor = element_blank(),
    axis.ticks.length = unit(0.2, "cm")
  ) +
  theme(plot.title = element_text(hjust = 0.5, family = "Times New Roman")) +
  theme(
    axis.text = element_text(size = 11),
    axis.title = element_text(size = 12),
    axis.text.y = element_text(margin = margin(b = 2), hjust = 0.95, vjust = 0.4),
    axis.title.x.bottom = element_text(margin = margin(t = 2, b = 5)),
    axis.text.y.left = element_text(margin = margin(l = 2)),
    axis.title.y.left = element_text(margin = margin(l = 5)),
    title = element_text(size = 12),
    legend.position = "right",
    legend.box.margin = margin(t = 40),
    plot.margin = margin(t = 20, r = 1, b = 20, l = 1, unit = "mm")
  ) +
  theme(
    legend.text = element_text(size = 8),
    legend.title = element_text(size = 9),
    legend.key.size = unit(0.5, "cm")
  ) +
  scale_shape_manual(
    values = c(17, 18, 19, 25, 9, 15),
    breaks = c(
      "Mother",
      "Probable Exclusive Breastfeeding",
      "Exclusive breastfeeding",
      "Weaning",
      "Probable Post weaning",
      "Post weaning"
    )
  ) +
  labs(
    y = expression(delta^{66} * Zn * "(‰)"),
    x = expression(delta^{13} * C * "(‰)")
  ) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(title = "Nutrition")) +
  theme(aspect.ratio = 1) +
  coord_fixed(ratio = 1)

ZnCHAbT
```

## Prompt comparison

| Test | User prompt | Tokens reported by LM Studio | Main result |
|---|---|---:|---|
| 1 | `Review this selected R code and suggest only necessary changes.` | 2036 | Found duplicate imports, but introduced unrelated `example_values` context and unnecessary suggestions. |
| 2 | `Review this selected R code.` | 2492 | Found duplicate imports, but made questionable claims about `theme_clean()` and valid `ggplot2` syntax. |
| 3 | `Review this selected R code for real bugs and necessary corrections. Preserve the intended analysis.` | 2686 | Produced the longest response; included some potentially useful observations but also unnecessary refactoring and repeated claims. |
| 4 | `Review only the selected R code. Identify only problems that are actually visible in this code. Do not invent missing code, functions, objects, packages, or file context. Do not refer to line numbers. Quote the relevant code fragment and show the corrected code. If the code is correct, say so.` | 2225 | Best overall response, but it still referred to the unrelated `example_values` example. |

## Results of the prompt study

### Test 1: `Review this selected R code and suggest only necessary changes.`

The response correctly identified the two duplicated imports:

```r
library(ggrepel)
...
library(ggrepel)
```

and:

```r
library(rstatix)
...
library(rstatix)
```

However, it also discussed the unrelated code:

```r
example_values <- c(1, 2, 3, NA)
mean(example_values)
```

That code was not part of the selected Zenodo ranges. The response was therefore partially correct but not fully grounded in the supplied code.

### Test 2: `Review this selected R code.`

The response began with `## Code Review Findings` and reported:

- an allegedly undefined `theme_clean()`;
- an allegedly inefficient `ggplot()` construction;
- duplicate `rstatix` and `ggrepel` imports;
- the `theme_clean()` issue twice.

The duplicate imports are real. However, this construction is valid `ggplot2` syntax:

```r
ggplot() +
  geom_point(
    data = AbT1,
    mapping = aes(x = d13C, y = d66Zn)
  )
```

Passing the data to `ggplot()` instead is an optional alternative, not a necessary correction. The availability of `theme_clean()` cannot be established confidently without knowing all package namespaces and the complete script context. The model should have marked this as uncertain rather than asserting that it was definitely undefined.

### Test 3: `Review this selected R code for real bugs and necessary corrections. Preserve the intended analysis.`

The response began with `## Code Review Findings` and reported:

- an allegedly undefined `theme_clean()`;
- an allegedly inefficient `ggplot()` construction;
- duplicate `rstatix` and `ggrepel` imports;
- the `theme_clean()` issue again.

This was the longest response at 2686 tokens. The phrase `Preserve the intended analysis` did not improve factual accuracy. The response still proposed unnecessary refactoring of valid plotting code and repeated one finding.

### Test 4: strict evidence-based prompt

The response began with `**Problems Found:**` and correctly identified:

```r
library(ggrepel)
```

appearing twice and:

```r
library(rstatix)
```

appearing twice.

It nevertheless introduced the unrelated `example_values` example. It was the best response in the comparison because it identified the clearest visible problems and was more constrained than the other responses, but it was still not completely reliable.

## Which response was best?

The strict evidence-based prompt produced the best overall response:

```text
Review only the selected R code. Identify only problems that are actually visible in this code. Do not invent missing code, functions, objects, packages, or file context. Do not refer to line numbers. Quote the relevant code fragment and show the corrected code. If the code is correct, say so.
```

It was not perfect because it still mentioned `example_values`, but it was more useful than the shorter prompts and less speculative than the response containing `Preserve the intended analysis`.

The best practical default for future use is shorter:

```text
Review this selected R code for real bugs and necessary corrections.
```

The general evidence and anti-invention rules should remain in the existing system prompt. They do not need to be repeated in every user question.

## Effect of prompt length and specificity

The results suggest that prompt wording can affect the total token usage by approximately 10% in this comparison, although this should be treated as an observation rather than a universal benchmark.

The measured totals ranged from 2036 to 2686 tokens. The strict prompt used 2225 tokens, while the prompt containing `Preserve the intended analysis` used 2686 tokens. This shows that a longer or more specific user prompt can increase the total, but the relationship is not perfectly linear: the generated answer, system prompt, selected code, model reasoning, and LM Studio context settings also affect the total.

Therefore:

- prompt length can contribute to token usage;
- prompt specificity can change the model's review behavior;
- a shorter prompt does not automatically produce a shorter total response;
- a longer prompt does not automatically produce a better answer;
- quality must be assessed together with token usage.

For this test, the explicit constraints improved grounding more than the shortest prompt, but repeating all constraints in every question is inefficient when the existing system prompt already contains them.

## Recommended question structure

Use a short task-specific question and leave the general review rules in the existing system prompt.

### Recommended default

```text
Review this selected R code for real bugs and necessary corrections.
```

### Strict correctness review

```text
Check this selected R code for errors that would affect execution or the intended result. Ignore optional style and performance suggestions.
```

### General explanation

```text
Explain what this selected R code does and mention any real problems.
```

### Minimal version

```text
Review this selected R code.
```

The minimal version is acceptable, but the comparison showed that it gave the model more freedom to make broad or speculative suggestions.

## Final assessment

The addin successfully identified clear, visible issues in the Zenodo-derived R code, especially duplicated package imports. However, the model sometimes introduced unrelated context or presented optional refactoring as a necessary correction.

The results support using the addin as an interactive code-review aid, not as an automatic validator. Every answer should be compared with the exact code sent in the selected ranges and checked independently in R.

The system prompt was already present in the addin and was not changed for this study. The study evaluated the user-question wording only.
