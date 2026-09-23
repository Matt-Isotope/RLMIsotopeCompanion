# System prompt design

R-LM-Isotope-Companion targets local models served by LM Studio, including models in the 4B parameter class. The addin provides three system-prompt modes:

- **General R Expert** — general R programming and code review;
- **Statistics & Data Analysis** — statistical workflows, assumptions, transformations, missing-data handling, `ggplot2`, and tidyverse usage;
- **Geochemistry & Isotopes** — archaeology, human and animal remains, geochemistry, isotope analysis, and the usefulness of the analysis workflow.

## Prompt design

The prompts use a deliberately flat structure:

- the model is told to read all supplied code before answering;
- domain prompts separate bug detection from analytical purpose or usefulness;
- instructions use imperative wording;
- the three prompts repeat the same core rules in the same order;
- nested conditional instructions are avoided;
- answers should report real problems only and avoid invented context;
- missing context is reported explicitly as `[insufficient context]`;
- uncertainty is reported as `[uncertain]`;
- fixes should be minimal and use base R or already-loaded packages where possible;
- existing validation and error handling must not be removed;
- the model should start directly with findings and avoid essays.

This repeated pattern is intentional. Small local models may follow repeated, structurally similar instructions more reliably than prompts with substantially different wording or deeply nested conditions.

The prompts are guidance, not a correctness guarantee. A model may still produce false positives, incomplete answers, or technically incorrect R, statistical, archaeological, or geochemical interpretations. Generated suggestions must be checked directly in R and against the relevant scientific context.

## Why the addin reads all supplied code first

The addin can send two code ranges: a first range that commonly contains imports, data preparation, or object definitions, and a second range selected in the editor. The prompt therefore asks the model to read the complete supplied context before answering instead of analysing fragments line by line. This is intended to reduce incorrect claims that an object, column, package, or function is missing.

The model still receives only the selected ranges. It does not automatically receive the complete script, dataset, metadata, or project context.

## Local execution

The prompts are sent to the locally running model through LM Studio's OpenAI-compatible API. Response quality and speed depend on the selected model, quantisation, context length, sampling settings, GPU/CPU offloading, available memory, and the amount of code supplied. The design is intended to make small local models more usable; it does not make their output equivalent to formal static analysis or expert review.
