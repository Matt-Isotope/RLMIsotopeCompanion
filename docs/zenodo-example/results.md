# Model Evaluation Results

## Scope

The addin was tested as a local R-code-review interface connected to LM Studio through its OpenAI-compatible API. The addin successfully sends selected R code and displays the generated response.

These tests evaluate the behaviour of the selected local language models; they are not a formal benchmark of the addin or of R itself.

## Model-dependent behaviour

The correctness and completeness of the review depend on:

- the selected model and prompt;
- model size and training data;
- GGUF quantisation;
- context length and context-overflow policy;
- sampling parameters;
- GPU/CPU offloading and available memory;
- the amount and completeness of the selected code.

Small models generally performed better on short, focused snippets than on long scripts. With larger `ggplot2` examples, some models incorrectly reported valid R constructions as bugs, rewrote correct code, or produced incomplete responses.

## Tests

| Test | Expected behaviour | Observed evaluation |
|---|---|---|
| 1 | Detect that `mean()` returns `NA` when the input contains `NA` and `na.rm = TRUE` is not used | Model-dependent; Qwen3-4B generally recognised this correctly |
| 2 | Detect an invalid argument such as `remove_missing` passed to `mean()` | Qwen3-4B recognised this correctly |
| 3 | Avoid inventing a value or definition for an object that is not shown | Mixed; some responses correctly identified insufficient context, while others invented a possible replacement |
| 4 | Distinguish `=` from `==` in `dplyr::filter()` | Qwen3-4B recognised the error; Rhea-4B was inconsistent and sometimes called the code correct |
| 5 | Understand `mean()` with `NA` values | Qwen3-4B recognised the default `NA` result; Rhea-4B incorrectly claimed that `mean()` removes `NA` values automatically |
| 6 | Treat an unseen column as a context-dependent issue rather than a confirmed error | Mixed; models sometimes incorrectly claimed that the column definitely existed or definitely did not exist |
| 7 | Recognise valid R code without inventing a problem | Generally correct for the short example |
| 8 | Understand `NA` in logical indexing | Mixed; models often recognised that `mean()` returns `NA` but failed to include the `NA` retained by logical indexing |

## Long-script observations

On a longer `ggplot2` script, models incorrectly reported some valid constructions as bugs, including:

```r
ggplot() +
  geom_point(data = filtered_data, mapping = aes(...))
```

```r
data = dplyr::filter(...)
```

and multiple chained `theme()` calls. They also sometimes treated `theme_clean()` as invalid without considering that `ggthemes` had been loaded, and treated redundant package loading as a runtime error.

These are model-review errors, not confirmed defects in the addin.

## Performance observations

For Qwen3-4B Q4_K_M on the tested local setup, short prompts were substantially more manageable than long reviews. Long responses could reach more than 1,000 generated tokens and fall to approximately 5–7 tokens per second, causing several minutes of waiting and occasional client disconnections before the response was complete.

A shorter prompt, a lower maximum output length, and reviewing smaller code selections are recommended. A context length of 8,192 tokens was more practical than 16,384 for the available hardware.

# Model evaluation and limitations

This repository provides a local interface for sending selected R code to a local language model through LM Studio. The addin itself works as an interface, but the
quality of the generated review depends on the selected model, prompt, context length, quantisation, and hardware.

## Observations

- Short code snippets were handled more reliably than long scripts.
- Small local models sometimes reported valid R code as bugs, especially in `ggplot2` examples and when the selected context was incomplete.
- Long responses could become slow and verbose, especially on 4B models.
- Model performance is therefore highly dependent on prompt design and local configuration.

## Conclusion

The results should be interpreted as model-dependent observations rather than a formal benchmark. The addin is functional, but the quality of the code review depends on the model and local configuration.

## Conclusion

The addin integration with LM Studio worked as intended during testing. The main limitation observed was the reliability and verbosity of small local models, especially on long or incomplete R scripts. Generated reviews should therefore be treated as suggestions and checked directly in R.

The results are model-dependent and should not be interpreted as proof that the addin can detect all R errors or that a particular model is universally superior.
