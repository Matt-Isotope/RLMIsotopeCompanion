# R-LM-Isotope-Companion

An RStudio addin for using local language models through LM Studio while working with R code.

The package exposes the interactive interface in the RStudio Addins menu as `LM Studio R Assistant`.

The project combines three main use cases:

- general R programming assistance;
- statistical and data-analysis support;
- domain-oriented assistance for archaeology, geochemistry, and isotope research.

The addin is designed as a local companion for reviewing R code, asking questions about selected sections of a script, and discussing possible improvements to an analysis workflow.

The project is experimental and does not replace statistical validation, domain expertise, scientific literature, dataset documentation, or reproducibility checks.

## Features

The addin can:

- inspect an `.R` file;
- send a selected range of lines to a local language model;
- include a second range selected directly in the RStudio editor;
- choose between different system prompts;
- ask questions about R code;
- identify possible bugs and inefficient code;
- discuss `tidyverse`, `ggplot2`, and data-analysis workflows;
- provide general statistical code-review suggestions;
- provide domain-oriented assistance for archaeological science, geochemistry, and isotope research;
- estimate the approximate number of tokens in the selected code;
- communicate with a locally running LM Studio server through its OpenAI-compatible API.

## Example UI

The addin provides a compact RStudio gadget with a file selector, model/prompt controls, range selection, question input, and response panel.

![LM Studio R Assistant UI](https://raw.githubusercontent.com/Matt-Isotope/RLMIsotopeCompanion/main/docs/images/ui-overview.png)

## Documentation map

- `docs/system-prompts.md` explains the rationale and structure of the built-in prompt modes.
- `docs/zenodo-example/Analysis.R` provides a sample analysis workflow used for manual testing.
- `docs/zenodo-example/results.md` summarises the model-evaluation observations.
- `SECURITY.md` contains the project security and sensitive-data guidance.
- `CONTRIBUTING.md` contains local setup and contribution steps.

## Important notice

R-LM-Isotope-Companion is an assistance tool, not an automated validation system.

Language models can produce plausible but incorrect:

- R code;
- statistical interpretations;
- explanations;
- function names or arguments;
- recommendations;
- citations;
- archaeological, biological, or geochemical interpretations.

All suggestions must be reviewed, tested, and evaluated by the user.

The tool should not be used as a substitute for:

- statistical expertise;
- archaeological or biological expertise;
- isotope geochemistry expertise;
- dataset documentation;
- research design;
- peer review;
- reproducibility checks;
- independent validation of scientific results.

## Requirements

You need:

- R;
- RStudio;
- LM Studio;
- a locally installed compatible language model;
- an active LM Studio local server;
- the required R packages.

The addin currently imports:

- `shiny`;
- `miniUI`;
- `ellmer`;
- `rstudioapi`;
- `shinyjs`;
- `httr`.

The default LM Studio API endpoint is:

```text
http://localhost:1234/v1
```

## Installation

### Install from a local folder

Download or clone this repository, then install the package from R.

First install `devtools` if necessary:

```r
install.packages("devtools")
```

Install the package by specifying its local path:

```r
devtools::install(
  "path/to/RLMIsotopeCompanion",
  upgrade = FALSE
)
```

On Windows, use forward slashes in the path:

```r
devtools::install(
  "C:/Users/your-name/Downloads/RLMIsotopeCompanion",
  upgrade = FALSE
)
```

After installation, restart RStudio.

The addin should then be available in the Addins menu as:

```text
LM Studio R Assistant
```

It can also be launched from R:

```r
RLMIsotopeCompanion::R_LM_Isotope_Companion()
```

## Package structure

The project follows the standard R package layout:

```text
RLMIsotopeCompanion/
├── DESCRIPTION
├── NAMESPACE
├── README.md
├── NEWS.md
├── SECURITY.md
├── CONTRIBUTING.md
├── R/
│   └── addin.R
├── inst/
│   └── rstudio/
│       └── addins.dcf
├── docs/
│   ├── system-prompts.md
│   └── zenodo-example/
│       ├── Analysis.R
│       └── results.md
├── LICENSE
└── .github/
```

The RStudio addin registration file must be located at:

```text
inst/rstudio/addins.dcf
```

## LM Studio setup

1. Open LM Studio.
2. Download or import a compatible model.
3. Load the model.
4. Start the local server.
5. Confirm that the OpenAI-compatible API is available at:

   ```text
   http://localhost:1234/v1
   ```

The addin obtains the available model names from:

```text
http://localhost:1234/v1/models
```

You can test the endpoint from R:

```r
httr::GET("http://localhost:1234/v1/models")
```

A successful response should have HTTP status `200`.

```r
httr::status_code(
  httr::GET("http://localhost:1234/v1/models")
)
```

## How to use the addin

1. Open an R script in RStudio.
2. Launch the addin from the Addins menu:

   ```text
   Addins → LM Studio R Assistant
   ```

3. Confirm or select the path to the R file.
4. Select an available LM Studio model.
5. Choose a system prompt.
6. Set the first line range.
7. Optionally select code in the RStudio editor.
8. Click:

   ```text
   Grab editor selection
   ```

9. Enter a question.
10. Click:

   ```text
   Ask LM Studio
   ```

The addin sends the selected code and question to the local language model.

## System prompts

For the design rationale behind the built-in prompts, see `docs/system-prompts.md`.

The addin currently provides three prompt modes:

### Geochemistry & Isotopes

This prompt is designed for R code used in:

- archaeology;
- archaeological human and faunal remains;
- geochemistry;
- isotope research;
- data analysis and statistics.

It asks the model to focus on:

- bugs;
- inefficient loops;
- possible vectorisation;
- incorrect tidyverse usage;
- incorrect function arguments;
- possible statistical errors.

### General R Expert

This prompt is designed for general R development and code review.

It asks the model to focus on:

- bugs;
- inefficient code;
- vectorisation;
- tidyverse usage;
- memory problems;
- bad practices;
- incorrect function arguments.

### Statistics & Data Analysis

This prompt is designed for statistical R workflows.

It asks the model to focus on:

- statistical test selection;
- assumptions;
- transformations;
- missing-data handling;
- `ggplot2`;
- tidyverse usage;
- possible statistical errors;
- interpretation of analytical workflows.

The output of this prompt should be treated as a suggestion for further checking, not as statistical validation.

## Tested environment and model notes

The project is currently being tested on:

- Windows;
- RStudio Desktop;
- R 4.6.0;
- LM Studio 0.4.16;
- a local model served through the LM Studio OpenAI-compatible API.

Hardware used during testing:

- CPU: 11th Gen Intel Core i7-11800H @ 2.30 GHz;
- RAM: 32 GB;
- GPU: NVIDIA GeForce RTX 3050 Laptop GPU with 4 GB VRAM.

The currently tested local model family is approximately 4B-class and includes:

- `qwen/qwen3-4b-2507`;
- `qwen3.5-4b-claude-4.6-opus-reasoning-openclaw`;
- `rhea-4b-coding-max-i1`.

Model availability, naming, quantisation, performance, and API behaviour may vary depending on the model files installed in LM Studio.

The token estimate displayed by the addin is approximate and based on character length, not on a model-specific tokenizer count.

## Example script source

Initial testing may use script and documentation associated with the following Zenodo record:

https://doi.org/10.5281/zenodo.17868174

The script is distributed under the Creative Commons Attribution 4.0 International licence:

```text
CC BY 4.0
```

Users should consult the original Zenodo record for the complete script description, citation requirements, authorship information, and licence conditions.

The addin may assist with discussing analysis scripts and workflows associated with the dataset. It does not independently validate the dataset, the original research, or any scientific conclusions.

## Suggested Zenodo testing workflow

A possible testing workflow is:

1. Download the script from Zenodo.
2. Read the data in R.
3. Create or open an R script that analyses the data.
4. Open the script in RStudio.
5. Launch the addin.
6. Select a small range of relevant code.
7. Ask the model to explain or review the code.
8. Compare the response with the Zenodo metadata, the original documentation, the data structure, the published research context, the expected statistical assumptions, and independent R checks.

Example questions include:

```text
What does this section of code do?
```

```text
Are there obvious errors in this data transformation?
```

```text
Are the statistical assumptions of this test appropriate?
```

```text
Could this code be made more efficient?
```

```text
Are missing values handled consistently?
```

```text
Does this visualisation accurately represent the variables?
```

## Privacy and data handling

The addin is designed to communicate with a local LM Studio server.

In the default configuration:

- R code is sent to `localhost`;
- the request is handled by the locally running LM Studio server;
- no external API key is required;
- the addin does not automatically upload code to Zenodo, GitHub, or another website.

However, users should still check:

- the LM Studio server configuration;
- the selected model;
- whether a proxy or external service is being used;
- the contents of the code before sending it;
- whether the selected model or application has any external connectivity.

Do not send:

- passwords;
- API keys;
- authentication tokens;
- patient or participant information;
- personal data;
- confidential research material;
- unpublished sensitive data;
- proprietary code;
- data covered by restrictions that do not allow local-model processing.

## Known limitations

- The addin currently expects LM Studio at `localhost:1234`.
- The model list depends on the LM Studio `/v1/models` endpoint.
- The token estimate is approximate.
- Large files and large line ranges may be slow.
- Overlapping ranges may send the same code more than once.
- The response is generated synchronously.
- The RStudio interface may appear busy while the model is responding.
- The model may generate incorrect or incomplete code.
- Statistical suggestions require independent validation.
- Domain-specific answers may be affected by incomplete context.
- The model does not automatically know the complete metadata or provenance of a dataset.
- Results may differ between model versions, quantisations, and prompt settings.

## Troubleshooting

### No models are found

Check that:

1. LM Studio is open.
2. A model is loaded.
3. The local server is running.
4. The server is using port `1234`.
5. The following request returns HTTP status `200`:

```r
httr::status_code(
  httr::GET("http://localhost:1234/v1/models")
)
```

### Chat not initialized

This usually means that the addin could not create a client for the selected model.

Check:

- whether LM Studio is running;
- whether the local server is active;
- whether the selected model is loaded;
- whether the selected model name appears in `/v1/models`;
- whether the API endpoint is correct;
- whether the model has finished loading.

### The addin is very slow

Try:

- using a 4B model rather than a larger model;
- reducing the context length;
- selecting fewer lines of code;
- avoiding large scripts in the prompt;
- reducing the expected response length;
- adjusting GPU offloading;
- reducing batch sizes if memory is limited;
- checking whether the computer is using disk-based virtual memory.

### The addin does not appear in the Addins menu

Check that the file exists at:

```text
inst/rstudio/addins.dcf
```

and contains:

```text
Name: LM Studio R Assistant
Description: Ask LM Studio about selected R code
Binding: R_LM_Isotope_Companion
Interactive: true
```

Then reinstall the package and restart RStudio.

### Package installation problems on Windows

If R reports that Rtools is required, install the version compatible with the installed R version:

```text
https://cran.r-project.org/bin/windows/Rtools/
```

The need for Rtools depends on how the package and its dependencies are installed. The package may install successfully without Rtools if no compilation is required, but Rtools may be needed when dependencies require compilation.

## Development status

This project is currently experimental.

The interface, package name, prompts, model support, and implementation may change.

Testing is ongoing, especially with:

- different local language models;
- R code-review tasks;
- statistical workflows;
- archaeological data;
- geochemical and isotope-related analyses;
- datasets available through Zenodo.

Feedback, testing reports, and suggestions are welcome.

## Development with AI assistance

This project was developed with assistance from artificial intelligence tools.

AI assistance was used for activities including:

- discussing the design of the RStudio addin;
- exploring R package structure and RStudio addin conventions;
- identifying possible R and Shiny issues;
- identifying syntax and namespace problems;
- suggesting input validation;
- suggesting error-handling improvements;
- discussing interaction with the LM Studio OpenAI-compatible API;
- drafting and improving documentation;
- reviewing error messages;
- discussing possible model and hardware configurations.

The project author remains responsible for:

- the final code;
- design decisions;
- testing;
- documentation;
- scientific claims;
- data handling;
- licensing decisions;
- published results.

AI-generated suggestions were reviewed and adapted, but they may still contain errors. The use of AI assistance does not imply that the code, analysis, or scientific interpretation has been independently verified.

The code is still being reviewed, adapted, and tested. The current release should therefore be considered experimental.

## Reproducibility

For reproducible use, record:

- the R version;
- the RStudio version;
- the LM Studio version;
- the model name;
- the model version or file identifier;
- the model quantisation;
- the context length;
- the GPU offloading settings;
- the CPU thread settings;
- the batch-size settings;
- the system prompt;
- the version of this addin;
- the input code;
- the script version;
- the relevant Zenodo record.

## Repository

```text
https://github.com/Matt-Isotope/RLMIsotopeCompanion
```

## Citation

If you use this addin in a project, publication, teaching material, or analysis workflow, please cite the repository once it has been published.

When using the example Zenodo script, cite the original Zenodo record:

```text
https://doi.org/10.5281/zenodo.17868174
```

Please also cite LM Studio and the selected language model where appropriate.

## Package checks

The package is automatically checked with `R CMD check` using GitHub Actions.

The latest check completed successfully with:

- 0 errors;
- 0 warnings.

See the latest [R-CMD-check workflow run](https://github.com/Matt-Isotope/RLMIsotopeCompanion/actions/workflows/R-CMD-check.yaml).

## Licence

This project is released under the MIT License.

The licences of external components must be checked separately, including:

- LM Studio;
- the selected language model;
- scripts used with the addin;
- external code;
- examples;
- documentation;
- third-party dependencies.

The Zenodo script used for initial testing is associated with the Creative Commons Attribution 4.0 International licence, subject to the terms of the original Zenodo record.
