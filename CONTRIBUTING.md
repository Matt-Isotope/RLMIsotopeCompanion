# Contributing

## Requirements

- R
- RStudio
- LM Studio for manual integration tests
- The packages listed in `DESCRIPTION`

## Install the package locally

```r
install.packages("devtools")
devtools::install(".", upgrade = "never")
```

## Run package checks

```r
devtools::test()
devtools::check()
```

## Manual LM Studio tests

1. Start LM Studio.
2. Load a compatible local model.
3. Start the local server.
4. Confirm that `http://localhost:1234/v1/models` is available.
5. Open the addin from RStudio.
6. Run the manual examples in `docs/zenodo-example/Analysis.R`.

## Bug reports

Please include:

- R version;
- RStudio version;
- operating system;
- LM Studio version;
- model name;
- selected code;
- exact error message.
