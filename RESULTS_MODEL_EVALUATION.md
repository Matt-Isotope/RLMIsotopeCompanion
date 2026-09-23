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

## Comparison with a larger model

The same prompt suite was also tested with Claude Sonnet 5 using the senior R developer system prompt. Compared with the tested 4B local models, Claude followed the prompt constraints more consistently and produced fewer false positives.

It correctly identified the main issues in the short R tests, including missing-value handling, invalid arguments, undefined objects, the distinction between `=` and `==`, and `NA` propagation in logical indexing. On the longer Zenodo example, it did not incorrectly classify valid `ggplot2` constructions, filters inside a layer's `data` argument, multiple `theme()` calls, or `theme_clean()` with `ggthemes` loaded as syntax errors.

Some suggestions, such as adding `na.rm = TRUE` or merging multiple `theme()` calls, remain dependent on the intended analysis or represent maintainability suggestions rather than confirmed bugs. The Claude response therefore was not treated as universally correct: it was treated as a stronger, more cautious comparison result.

This comparison suggests that model capacity and instruction-following ability affect code-review quality, particularly for long R scripts and incomplete context. It is an observation from this test setup, not a formal benchmark or a general claim that larger models are always correct.

## Performance observations

For Qwen3-4B Q4_K_M on the tested local setup, short prompts were substantially more manageable than long reviews. Long responses could reach more than 1,000 generated tokens and fall to approximately 5–7 tokens per second, causing several minutes of waiting and occasional client disconnections before the response was complete.

A shorter prompt, a lower maximum output length, and reviewing smaller code selections are recommended. A context length of 8,192 tokens was more practical than 16,384 for the available hardware.

## Conclusion

The addin integration with LM Studio worked as intended during testing. The main limitation observed was the reliability and verbosity of small local models, especially on long or incomplete R scripts. The larger-model comparison suggests that the prompts can work substantially better when the model has enough capacity to follow the instructions and maintain context.

The results are model-dependent and should not be interpreted as proof that the addin can detect all R errors or that a particular model is universally superior.
