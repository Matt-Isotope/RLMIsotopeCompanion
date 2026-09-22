# R code-review prompt comparison

## Test context

The tests used:

- the minimal R example `example_values <- c(1, 2, 3, NA); mean(example_values)`;
- the Zenodo-associated R script `Giaccari_et_al_Zn_Isotopes_Analysis.R`;
- the `Geochemistry & Isotopes` system prompt;
- the local Model 4B model in LM Studio.

The Zenodo test focused on a selected plotting section containing package imports, data conversion, filtering, and a `ggplot2` workflow. The source script was analyzed locally; the script itself was not modified by the addin.

LM Studio reported the token totals below. These are useful for comparing the runs. They should not be confused with the addin's approximate token estimate, which is based on character length.

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

### Assessment

This was a successful minimal test. The problem was real, the suggested correction was valid, and the correction could be verified directly in R.

## Zenodo script prompt comparison

| Test | User prompt | Tokens reported by LM Studio | Assessment |
|---|---|---:|---|
| 1 | `Review this selected R code and suggest only necessary changes.` | 2036 | Correctly found duplicate imports, but also discussed unrelated `example_values` context and made unnecessary recommendations. |
| 2 | `Review this selected R code.` | 2492 | Correctly found duplicate imports, but proposed questionable changes and repeated an uncertain `theme_clean()` claim. |
| 3 | `Review this selected R code for real bugs and necessary corrections. Preserve the intended analysis.` | 2686 | Longer response; identified a potentially relevant `theme_clean()` issue, but also treated valid `ggplot2` syntax as a problem and repeated findings. |
| 4 | `Review only the selected R code. Identify only problems that are actually visible in this code. Do not invent missing code, functions, objects, packages, or file context. Do not refer to line numbers. Quote the relevant code fragment and show the corrected code. If the code is correct, say so.` | 2225 | Best overall result, although it still referred to unrelated `example_values` context. |

## Test 1: necessary changes

### User prompt

```text
Review this selected R code and suggest only necessary changes.
```

### Response summary

The model correctly identified duplicated calls to:

```r
library(ggrepel)
```

and:

```r
library(rstatix)
```

It also discussed `example_values`, although that code was not part of the selected Zenodo fragment.

### Assessment

The duplicate imports were real. The `example_values` discussion was not grounded in the selected code. The response also treated a possible educational expression as if it required a correction. This result was partially useful but not fully reliable.

## Test 2: short review prompt

### User prompt

```text
Review this selected R code.
```

### Response summary

The model reported:

- an allegedly undefined `theme_clean()`;
- an allegedly inefficient `ggplot()` construction;
- duplicated `rstatix` and `ggrepel` imports;
- the `theme_clean()` issue a second time.

### Assessment

The duplicate imports were real. The `ggplot2` construction below is valid syntax and does not require the proposed refactoring:

```r
ggplot() +
  geom_point(data = AbT1, mapping = aes(x = d13C, y = d66Zn))
```

Whether `theme_clean()` is available depends on the complete package context. The model should have reported `[insufficient context]` or stated the dependency uncertainty instead of asserting that it was definitely undefined.

## Test 3: preserve the intended analysis

### User prompt

```text
Review this selected R code for real bugs and necessary corrections. Preserve the intended analysis.
```

### Assessment

This produced the longest response. It correctly noticed duplicated imports and raised a potentially useful question about `theme_clean()`, but it proposed unnecessary refactoring of valid `ggplot2` code and repeated the same issue. The phrase `Preserve the intended analysis` did not improve factual accuracy.

## Test 4: strict evidence-based prompt

### User prompt

```text
Review only the selected R code. Identify only problems that are actually visible in this code. Do not invent missing code, functions, objects, packages, or file context. Do not refer to line numbers. Quote the relevant code fragment and show the corrected code. If the code is correct, say so.
```

### Assessment

This was the most useful response overall. It correctly identified the duplicate `ggrepel` and `rstatix` imports and was more explicit about evidence. However, it still referred to the unrelated `example_values` fragment. The result was mostly useful but not fully reliable.

## Interpretation of the token results

The user question alone does not determine the total token count. The selected code, system prompt, model reasoning, generated response, and LM Studio context settings also affect the total.

The shortest reported total was 2036 tokens. The strict prompt used 2225 tokens, the shortest question alone used 2492 tokens in another run, and the prompt containing `Preserve the intended analysis` used 2686 tokens. Therefore, a shorter question does not necessarily produce a shorter total response.

Token count must be evaluated together with response quality. A shorter response is not automatically better if it misses a real bug, invents context, or proposes an unnecessary change.

## Recommended system prompt structure

The general rules should remain in the system prompt because they should apply to every request:

```text
# R code review assistant

You are an expert R programmer specializing in geochemistry, isotope analysis, archaeology, and statistical analysis.

Review only the R code explicitly provided in the current message.
Do not invent missing code, functions, objects, packages, files, datasets, or previous context.
Do not refer to line numbers unless they are explicitly provided.
Only report real correctness problems that are visible in the supplied code.
Distinguish between genuine bugs, necessary corrections, and optional style or performance improvements.

If the supplied code is incomplete or insufficient for a confident assessment, write:
[insufficient context]

Quote the relevant code fragment before explaining the issue.
When a fix is needed, show the corrected code snippet.
If the code is correct, say so briefly and clearly.
Do not suggest aesthetic changes unless they affect correctness or reproducibility.
```

## Recommended user prompts

### Default review

```text
Review this selected R code for real bugs and necessary corrections.
```

Use this as the normal default. It is short but tells the model to focus on correctness rather than broad stylistic commentary.

### Strict correctness review

```text
Check this selected R code for errors that would affect execution or the intended result. Ignore optional style and performance suggestions.
```

Use this when false positives are a bigger concern than finding optional improvements.

### General explanation

```text
Explain what this selected R code does and mention any real problems.
```

Use this when the goal is understanding rather than code review.

### Minimal prompt

```text
Review this selected R code.
```

This is technically sufficient when the system prompt is strong, but it leaves the model more freedom and produced less consistent results in this comparison.

## Recommendation

Use this combination:

**System prompt:** the structured evidence-based prompt above.

**Default user prompt:**

```text
Review this selected R code for real bugs and necessary corrections.
```

Do not repeat all anti-hallucination rules in every user question. Keep those rules in the system prompt. Add task-specific instructions to the user prompt only when needed.

The phrase `Preserve the intended analysis` should not be used by default. It can be useful when a user specifically wants to avoid analytical changes, but in this test it produced a longer response without improving factual accuracy.

## Limitations

The model can still generate unsupported claims even when the system prompt is explicit. Every response should therefore be checked against the exact code sent to the model. The addin's token estimate is approximate, while LM Studio reports its own token totals. Results may also vary with model version, context settings, and the exact selected ranges.
