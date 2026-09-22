# R code-review prompt comparison

## Test context

The test used the R script `Giaccari_et_al_Zn_Isotopes_Analysis.R` and the `Geochemistry & Isotopes` system prompt in the R-LM-Isotope-Companion addin.

The selected code contained duplicated package imports and a `ggplot2` plotting workflow. The results below compare different user prompts while keeping the selected code and system prompt as constant as possible.

LM Studio reported the token totals shown below. These totals are useful for comparing the tests, although the addin's own token estimate is approximate and LM Studio may include prompt context and generated output in its displayed total.

## Prompt comparison

| Test | User prompt | Tokens reported by LM Studio | Result |
|---|---|---:|---|
| 1 | `Review this selected R code and suggest only necessary changes.` | 2036 | Response was overconfident and included several unsupported recommendations. |
| 2 | `Review this selected R code.` | 2492 | Response correctly found duplicate imports, but also discussed an unrelated `example_values` fragment. |
| 3 | `Review this selected R code for real bugs and necessary corrections. Preserve the intended analysis.` | 2686 | Response identified a potentially real `theme_clean()` issue, but also made unsupported or incorrect claims about `ggplot()` and package imports. |
| 4 | `Review only the selected R code. Identify only problems that are actually visible in this code. Do not invent missing code, functions, objects, packages, or file context. Do not refer to line numbers. Quote the relevant code fragment and show the corrected code. If the code is correct, say so.` | 2225 | Best overall response. It correctly identified the duplicate `ggrepel` and `rstatix` imports and was more cautious than the other responses, although it still included an unrelated `example_values` discussion. |

## Test 1

### User prompt

```text
Review this selected R code and suggest only necessary changes.
```

### Model response

```text
Problems Found:

Problem 1: Duplicate library(ggrepel) calls

library(ggrepel)
library(cowplot)
library(ggrepel)
library(ggplot2)

Loading the same package twice is unnecessary and redundant.

Problem 2: Duplicate library(rstatix) calls

library(rstatix)
...
library(rstatix)

Loading rstatix twice is unnecessary.

Problem 3: Incomplete first example with no proper handling of mean() result

example_values <- c(1, 2, 3, NA)
mean(example_values)

Problem 4: The model stated that mean(example_values) returns NaN and suggested adding na.rm = TRUE.
```

### Assessment

The duplicate `ggrepel` and `rstatix` imports are real and visible in the selected code. However, the `example_values` fragment was not part of the selected Zenodo script section and should not have been mentioned. The response was therefore partially correct but not fully grounded in the supplied code.

The model also treated the final expression as a problem even though evaluating `mean(example_values)` is valid R code when the purpose is to demonstrate the effect of missing values. It should have separated a possible educational example from a real bug.

## Test 2

### User prompt

```text
Review this selected R code.
```

### Model response

```text
## Code Review Findings

### Problem 1: Undefined function theme_clean()

The model claimed that theme_clean() was not defined by the loaded packages and suggested replacing it with a base ggplot2 theme.

### Problem 2: Inefficient pipe usage with ggplot()

The model suggested passing data and aesthetics directly to ggplot() instead of using ggplot() followed by geom_point(data = ..., mapping = ...).

### Problem 3: Duplicate library loads (rstatix and ggrepel)

The model identified duplicate package imports.

### Problem 4: Potential undefined function issue (theme_clean())

The model repeated the theme_clean() claim.
```

### Assessment

The duplicate package imports are real. The `theme_clean()` warning may be valid if the selected code is executed without a package that provides that function, but the model should have stated the dependency uncertainty more carefully instead of asserting that the function was definitely undefined from the visible package list.

The `ggplot()` construction is valid. This is not a bug:

```r
ggplot() +
  geom_point(data = AbT1, mapping = aes(x = d13C, y = d66Zn))
```

Passing the data to `ggplot()` is an optional style alternative, not a necessary correction. The response also repeated the `theme_clean()` issue, which reduced its usefulness.

## Test 3

### User prompt

```text
Review this selected R code for real bugs and necessary corrections. Preserve the intended analysis.
```

### Token total

```text
2686 tokens
```

### Model response

The response began with:

```text
## Code Review Findings

### Problem 1: Undefined function theme_clean()

### Problem 2: Inefficient pipe usage with ggplot()

### Problem 3: Duplicate library loads (rstatix and ggrepel)

### Problem 4: Potential undefined function issue (theme_clean())
```

### Assessment

This prompt produced the longest response. It correctly noticed the duplicate imports and raised a potentially useful question about `theme_clean()`. However, it incorrectly described the valid `ggplot() + geom_point(data = ..., mapping = ...)` pattern as inefficient or non-intuitive and repeated the same `theme_clean()` claim twice.

The phrase `Preserve the intended analysis` did not prevent the model from proposing unnecessary refactoring. It may have encouraged a broader code review rather than a narrow list of necessary corrections.

## Test 4

### User prompt

```text
Review only the selected R code. Identify only problems that are actually visible in this code. Do not invent missing code, functions, objects, packages, or file context. Do not refer to line numbers. Quote the relevant code fragment and show the corrected code. If the code is correct, say so.
```

### Token total

```text
2225 tokens
```

### Model response

The response began with:

```text
Problems Found:

Problem 1: Duplicate library(ggrepel) calls

Problem 2: Duplicate library(rstatix) calls

Problem 3: Incomplete first example with no proper handling of mean() result
```

It correctly identified these duplicate imports:

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

However, it also referred to:

```r
example_values <- c(1, 2, 3, NA)
mean(example_values)
```

which was not part of the selected Zenodo script fragment.

### Assessment

This was the best of the tested prompts because it was the shortest response among the more constrained tests and correctly emphasized visible problems. Nevertheless, it still failed the requirement not to invent or import unrelated context. The model should have ignored the `example_values` fragment entirely.

The result is therefore **mostly useful but not fully reliable**.

## Interpretation of the token results

The lowest reported total was 2036 tokens for:

```text
Review this selected R code and suggest only necessary changes.
```

The explicit constrained prompt used 2225 tokens. The shortest question alone used 2492 tokens, and the prompt containing `Preserve the intended analysis` used 2686 tokens.

This shows that a shorter user question does not necessarily produce a shorter total response. The system prompt, selected-code size, model reasoning, generated answer, and conversation/context settings can have a larger effect than the user question itself.

The token count should therefore be interpreted together with response quality, not as a quality measure by itself.

## Recommended prompt design

The general anti-hallucination rules belong in the system prompt, because they should apply to every request. The user question should describe the task for the current request.

Recommended system-prompt principles:

- review only the code supplied in the current message;
- do not invent missing objects, packages, functions, or context;
- distinguish real correctness problems from optional style or performance suggestions;
- state `[insufficient context]` when a conclusion depends on unseen code or data;
- do not refer to line numbers unless line numbers are explicitly supplied;
- quote the relevant code before proposing a correction.

Recommended default user prompt:

```text
Review this selected R code for real bugs and necessary corrections.
```

For a narrower review focused on correctness:

```text
Check this selected R code for errors that would affect execution or the intended result. Ignore optional style and performance suggestions.
```

For a general explanation rather than a strict review:

```text
Explain what this selected R code does and mention any real problems.
```

## Recommendation

Use this as the normal user prompt:

```text
Review this selected R code for real bugs and necessary corrections.
```

It is short but gives the model a clear objective. Keep the anti-invention and evidence requirements in the selected system prompt rather than repeating them in every question.

For this particular test, the constrained prompt from Test 4 produced the most useful behavior, but it was still not perfect. If maximum faithfulness is more important than brevity, use the full constrained prompt from Test 4. If reducing repeated input is the priority, use the recommended short prompt and strengthen the `Geochemistry & Isotopes` system prompt.

Do not use `Preserve the intended analysis` as a default requirement unless the user specifically wants the model to avoid changing the analysis. In this test it did not improve factual accuracy and produced a longer response.

## Important implementation note

The addin sends the selected code and the user question together in the user message. The system prompt is created separately and passed to LM Studio. Therefore, repeating the general review rules in the question is not technically necessary when those rules are already present in the system prompt.

The addin's displayed token estimate is approximate. The code estimates selected-code tokens using byte length divided by four, while LM Studio reports its own total. These values should not be treated as identical measurements.
