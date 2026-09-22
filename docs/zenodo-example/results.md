# R code-review prompt comparison

## Test context

This document reports two related tests of the R-LM-Isotope-Companion addin using qwen3.5-4b-claude-4.6-opus-reasoning-openclaw model in LM Studio.

The system prompt was already defined in the addin and was not modified during the study. The comparison focused on the wording of the user question.

The tests were:

1. a minimal functional test using a deliberately incomplete `mean()` call;
2. a code-review test using code extracted from the Zenodo-associated script `Giaccari_et_al_Zn_Isotopes_Analysis.R`.

The minimal test and the Zenodo test are separate. The `example_values` code belongs only to the minimal functional test and was not part of the Zenodo analysis.

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

This was a successful minimal test: the problem was real, the correction was valid, and the result could be verified directly in R.

## Zenodo script analyzed

The following code was extracted from https://doi.org/10.5281/zenodo.17868174 `Giaccari_et_al_Zn_Isotopes_Analysis.R` and sent to the addin as two ranges. Range 1 contained package loading, data import, conversion, and filtering. Range 2 contained the plotting code.

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

## Prompt comparison for the Zenodo script

| Test | User prompt | Tokens reported by LM Studio | Result |
|---|---|---:|---|
| 1 | `Review this selected R code and suggest only necessary changes.` | 2036 | Correctly identified duplicated imports, but also made broader and partly unnecessary suggestions. |
| 2 | `Review this selected R code.` | 2492 | Identified duplicated imports, but also made questionable claims about `theme_clean()` and valid `ggplot2` syntax. |
| 3 | `Review this selected R code for real bugs and necessary corrections. Preserve the intended analysis.` | 2686 | Produced the longest response; it included useful observations but also unnecessary refactoring and repeated claims. |
| 4 | `Review only the selected R code. Identify only problems that are actually visible in this code. Do not invent missing code, functions, objects, packages, or file context. Do not refer to line numbers. Quote the relevant code fragment and show the corrected code. If the code is correct, say so.` | 2225 | Produced the best and most focused response in this comparison. |

## Results of the Zenodo prompt study

### Test 1

The model correctly identified the duplicated imports:

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

These are real, visible redundancies. The response also proposed additional changes that were not clearly necessary from the selected code. In particular, `as.numeric()` may be appropriate when imported columns are character data, and using `filter()` twice is not by itself a correctness problem.

### Test 2

The model again identified the duplicated imports. It also reported `theme_clean()` as undefined and described the following valid construction as inefficient:

```r
ggplot() +
  geom_point(
    data = AbT1,
    mapping = aes(x = d13C, y = d66Zn)
  )
```

The `ggplot2` construction is valid. Passing the data to `ggplot()` instead is an optional style alternative, not a necessary correction. The availability of `theme_clean()` depends on the complete package and script context, so it should have been reported as uncertain rather than definitely invalid.

### Test 3

This was the longest response at 2686 tokens. It correctly noticed the duplicate imports and raised a potentially useful question about `theme_clean()`. However, it also proposed unnecessary refactoring of valid plotting code and repeated the same issue. Adding `Preserve the intended analysis` did not improve factual accuracy in this test.

### Test 4

The strict evidence-based prompt produced the best response. It correctly focused on the two duplicated package imports and avoided most of the unnecessary refactoring found in the other responses.

The response was not perfect, but it was the most useful because it instructed the model to remain within the selected code, distinguish actual problems from optional changes, and provide evidence for each finding.

## Best response and recommended prompt

The best response was produced by the strict evidence-based prompt:

```text
Review only the selected R code. Identify only problems that are actually visible in this code. Do not invent missing code, functions, objects, packages, or file context. Do not refer to line numbers. Quote the relevant code fragment and show the corrected code. If the code is correct, say so.
```

However, because the general evidence and anti-invention rules are already included in the existing system prompt, the best practical default user question is shorter:

```text
Review this selected R code for real bugs and necessary corrections.
```

This version gives the model a clear task without repeating the entire system prompt.

## Effect of prompt length and specificity on token usage

In this comparison, the wording and specificity of the user prompt appeared to affect total token usage by approximately 10–15%. This is an observation from these tests, not a universal benchmark.

The measured totals ranged from 2036 to 2686 tokens. The total is influenced not only by the user question, but also by:

- the selected code;
- the existing system prompt;
- model reasoning;
- response length;
- LM Studio context settings.

Therefore, prompt length and specificity can influence token usage by roughly 10–15% in a comparable setup, but a longer prompt does not automatically produce a better response. The quality of the review must be assessed separately by checking whether the model:

- identifies real visible problems;
- avoids inventing code or context;
- distinguishes bugs from optional style suggestions;
- proposes technically valid corrections.

## Recommended question structure

The general rules should remain in the existing system prompt. The user question should describe the immediate task.

### Default review

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

### Minimal review

```text
Review this selected R code.
```

The minimal version is acceptable, but the default review prompt is preferable because it explicitly asks for real bugs and necessary corrections.

## Final assessment

The addin successfully identified clear, visible issues in the Zenodo-derived R code, especially duplicated package imports. The comparison also showed that the model may present optional refactoring as a necessary correction, particularly when the question is broad.

The strict evidence-based prompt produced the best response in this study. For routine use, the shorter task-specific prompt is recommended because the existing system prompt already supplies the general review constraints.

The addin should be treated as an interactive code-review aid rather than an automatic validator. Every answer should be checked against the exact selected ranges and independently verified in R.

The system prompt was already present in the addin and was not changed during this study.
