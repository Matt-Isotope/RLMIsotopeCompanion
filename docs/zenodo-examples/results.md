## Test: missing-value handling

### Submitted code

```r
example_values <- c(1, 2, 3, NA)
mean(example_values)
```

### Question

```text
Review only the shown R code. Identify only real problems. Show the relevant code fragment and the corrected code. Do not invent missing context.
```

### Model response

The model correctly identified that:

```r
mean(example_values)
```

returns `NA` because `example_values` contains a missing value and `mean()` does not remove missing values by default.

It suggested the following correction:

```r
mean(example_values, na.rm = TRUE)
```

### Manual verification

The original code returns:

```r
[1] NA
```

The corrected code:

```r
mean(example_values, na.rm = TRUE)
```

returns:

```r
[1] 2
```

### Assessment

The model correctly identified the problem and proposed a valid correction. This test was successful.

The response was relevant to the supplied code and did not require additional context.
