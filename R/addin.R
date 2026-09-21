#' Launch the R_LM_Isotope_Companion
#'
#' Opens an RStudio addin for querying a local LM Studio model about R code.
#'
#' @export

R_LM_Isotope_Companion <- function() {
  
  SYSTEM_PROMPTS <- list(
    "Geochemistry & Isotopes" = "You are an expert R programmer specializing in data analysis and statistics applied to geochemistry and isotopes on archaeological human and faunal remains. Review the given R code strictly. Report only real problems: bugs, loops that should be vectorized, misused tidyverse verbs, wrong function arguments, statistical errors, needless complexity. List each problem as: the affected line, what is wrong, the fix. Every fix MUST be the laziest one that works: the shortest correct code, base R or already-loaded packages before any new dependency, no new abstractions, delete rather than add. Never remove checks that prevent wrong results (input validation, error handling). Start directly with the findings, no introduction. If uncertain, write [uncertain]; do not invent problems. If the code is correct, reply with one line saying so.",
    "General R Expert" = "You are a senior R developer. Review the given R code strictly. Report only real problems: bugs, bad practices, inefficient vectorization, wrong tidyverse usage, memory issues, needless complexity. Every fix MUST be the laziest one that works: the shortest correct code, base R or already-loaded packages before any new dependency, no new abstractions, delete rather than add. Never remove checks that prevent wrong results (input validation, error handling). Be terse: corrected code first, explanation only when necessary. Start directly with the findings, no introduction. If uncertain, write [uncertain]; do not invent problems. If the code is correct, reply with one line saying so.",
    "Statistics & Data Analysis" = "You are an expert in R statistical analysis. Review the given R code strictly. Report only real problems in: use of statistical tests, assumption violations, data transformation errors, ggplot2/tidyverse misuse, missing data handling, needless complexity. List each problem as: the affected line, what is wrong, the fix. Every fix MUST be the laziest one that works: the shortest correct code, base R or already-loaded packages before any new dependency, no new abstractions, delete rather than add. Never remove checks that prevent wrong results (input validation, error handling). Start directly with the findings, no introduction. If uncertain, write [uncertain]; do not invent problems. If the code is correct, reply with one line saying so."
  )
  
  ui <- miniUI::miniPage(
    shinyjs::useShinyjs(),
    htmltools::tags$head(
      htmltools::tags$style(
        htmltools::HTML("
      * { box-sizing: border-box; }
      body, .mini-layout { background: #1e1e2e !important; color: #cdd6f4; font-family: 'Segoe UI', sans-serif; font-size: 13px; }
      .gadget-title { background: #181825 !important; color: #cba6f7 !important; border-bottom: 1px solid #313244 !important; font-weight: 600; }
      .mini-layout-panes { padding: 8px !important; }
      .card { background: #181825; border: 1px solid #313244; border-radius: 6px; padding: 10px; margin-bottom: 8px; }
      .card-label { color: #cba6f7; font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; margin-bottom: 6px; }
      label { color: #a6adc8 !important; font-size: 11px !important; margin-bottom: 2px !important; }
      .form-control { background: #313244 !important; color: #cdd6f4 !important; border: 1px solid #45475a !important; border-radius: 4px !important; font-size: 12px !important; height: 28px !important; padding: 3px 8px !important; }
      .form-control:focus { border-color: #cba6f7 !important; box-shadow: none !important; }
      select.form-control { height: 28px !important; }
      .row-flex { display: flex; gap: 6px; align-items: flex-end; }
      .row-flex .form-group { margin-bottom: 0 !important; }
      .btn { border-radius: 4px !important; font-size: 12px !important; padding: 4px 12px !important; height: 28px !important; line-height: 1 !important; cursor: pointer !important; }
      .btn-primary { background: #cba6f7 !important; border: none !important; color: #1e1e2e !important; font-weight: 700 !important; }
      .btn-primary:hover { background: #b4befe !important; }
      .btn-sm-sec { background: #313244 !important; border: 1px solid #45475a !important; color: #cdd6f4 !important; }
      .btn-ask { width: 100%; margin-top: 8px; font-size: 13px !important; height: 34px !important; }
      #response_box { background: #11111b; border: 1px solid #313244; border-radius: 6px; padding: 10px; font-family: 'Cascadia Code', 'Consolas', monospace; font-size: 11px; color: #a6e3a1; white-space: pre-wrap; overflow-y: auto; height: 220px; }
      #status_bar { font-size: 10px; color: #f38ba8; min-height: 14px; margin-top: 3px; }
      #token_info { font-size: 10px; color: #6c7086; margin-top: 2px; }
      #sel_info { font-size: 10px; color: #89b4fa; margin-top: 2px; }
      .form-group { margin-bottom: 6px !important; }
      #model_refresh { height: 28px; padding: 0 8px; }
            ")
      )
    ),
    miniUI::gadgetTitleBar(
      "LM Studio — R Assistant",
      right = miniUI::miniTitleBarButton(
        "done",
        "✕",
        primary = FALSE
      )
    ),
    miniUI::miniContentPanel(
      # File
      htmltools::div(class = "card",
          htmltools::div(class = "card-label", "File"),
          htmltools::div(class = "row-flex",
              htmltools::div(style = "flex:1",
                  shiny::textInput("file_path", NULL,
                            value = tryCatch(rstudioapi::getSourceEditorContext()$path, error = function(e) ""),
                            placeholder = "Path to .R file...")
              ),
              shiny::actionButton("browse", "Browse", class = "btn btn-sm-sec")
          ),
          htmltools::div(id = "file_info", style = "font-size:10px; color:#6c7086; margin-top:3px;", "")
      ),
      
      # Model + system prompt
      htmltools::div(class = "card",
          htmltools::div(class = "card-label", "Model & Prompt"),
          htmltools::div(class = "row-flex",
              htmltools::div(style = "flex:1",
                  shiny::selectInput("model_sel", "Model", choices = c("Loading..." = ""), width = "100%")
              ),
              shiny::actionButton("model_refresh", "↺", class = "btn btn-sm-sec", title = "Refresh models")
          ),
          shiny::selectInput("prompt_sel", "System prompt", choices = names(SYSTEM_PROMPTS), width = "100%")
      ),
      
      # Range 1 (always included)
      htmltools::div(class = "card",
          htmltools::div(class = "card-label", "Range 1 — always included (filters / datasets)"),
          htmltools::div(class = "row-flex",
              htmltools::div(style = "flex:1", shiny::numericInput("r1_from", "From", value = 1,  min = 1, step = 1, width = "100%")),
              htmltools::div(style = "flex:1", shiny::numericInput("r1_to",   "To",   value = 30, min = 1, step = 1, width = "100%"))
          ),
          htmltools::div(id = "range1_info", style = "font-size:10px; color:#6c7086; margin-top:3px;", "")
      ),
      
      # Range 2 (selection or manual)
      htmltools::div(class = "card",
          htmltools::div(class = "card-label", "Range 2 — selected in editor or manual"),
          shiny::actionButton("grab_sel", "⬇ Grab editor selection", class = "btn btn-sm-sec"),
          htmltools::div(id = "sel_info", style = "font-size:10px; color:#89b4fa; margin-top:3px;", "No selection grabbed yet"),
          htmltools::div(id = "token_info", style = "font-size:10px; color:#a6e3a1; margin-top:2px;", ""),
          htmltools::div(class = "row-flex", style = "margin-top:6px",
              htmltools::div(style = "flex:1", shiny::numericInput("r2_from", "From", value = NA, min = 1, step = 1, width = "100%")),
              htmltools::div(style = "flex:1", shiny::numericInput("r2_to",   "To",   value = NA, min = 1, step = 1, width = "100%"))
          )
      ),
      
      # Question + Ask
      htmltools::div(class = "card",
          htmltools::div(class = "card-label", "Question"),
          shiny::textInput("question", NULL, placeholder = "What does this code do? Any errors?", width = "100%"),
          shiny::actionButton("ask", "Ask LM Studio", class = "btn btn-primary btn-ask")
      ),
      
      # Response
      htmltools::div(class = "card",
          htmltools::div(class = "card-label", "Response"),
          htmltools::div(id = "response_box", "Response will appear here..."),
          htmltools::div(id = "status_bar", "")
      )
    )
  )
  
  server <- function(input, output, session) {
    
    chat_instance <- shiny::reactiveVal(NULL)
    
    get_valid_range <- function(from, to, n_total, label = "Range") {
      if (length(from) == 0L || length(to) == 0L ||
          is.null(from) || is.null(to) ||
          is.na(from) || is.na(to)) {
        stop(label, ": inserisci sia From sia To.")
      }
      
      from <- as.integer(from)
      to <- as.integer(to)
      
      if (from < 1L || to < 1L) {
        stop(label, ": i valori devono essere almeno 1.")
      }
      
      if (from > n_total || to > n_total) {
        stop(
          label,
          ": il file contiene ",
          n_total,
          " righe. Intervallo massimo: 1–",
          n_total,
          "."
        )
      }
      
      if (from > to) {
        stop(label, ": From non può essere maggiore di To.")
      }
      
      list(from = from, to = to)
    }
    # Fetch models from LM Studio
    fetch_models <- function() {
      tryCatch({
        res <- httr::GET("http://localhost:1234/v1/models",
                         httr::add_headers("Authorization" = "Bearer placeholder"))
        if (httr::status_code(res) == 200) {
          data <- httr::content(res, as = "parsed")
          ids <- sapply(data$data, function(m) m$id)
          return(ids)
        }
      }, error = function(e) NULL)
      return(NULL)
    }
    
    # Load models on start
    shiny::updateSelectInput(
      session,
      "model_sel",
      choices = character(0),
      selected = character(0)
    )
    
    shinyjs::html(
      "status_bar",
      htmltools::htmlEscape(
      "No model found."
    )
    )
    
    shiny::observeEvent(input$model_refresh, {
      models <- fetch_models()
      if (!is.null(models) && length(models) > 0) {
        shiny::updateSelectInput(session, "model_sel", choices = models, selected = input$model_sel)
        shinyjs::html("status_bar", "Models refreshed")
      }
    })
    
    # Init chat when model or prompt changes
    create_chat <- function() {
      if (is.null(input$model_sel) ||
          !nzchar(input$model_sel) ||
          identical(input$model_sel, "Loading...")) {
        stop("No model selected.")
      }
      
      if (is.null(input$prompt_sel) ||
          !nzchar(input$prompt_sel)) {
        stop("No system prompt selected.")
      }
      
      ch <- ellmer::chat_openai_compatible(
        api_key = "placeholder",
        base_url = "http://localhost:1234/v1",
        model = input$model_sel,
        system_prompt = SYSTEM_PROMPTS[[input$prompt_sel]]
      )
      
      chat_instance(ch)
      ch
    }
    
    shiny::observe({
      shiny::req(
        input$model_sel,
        nzchar(input$model_sel),
        input$prompt_sel
      )
      
      tryCatch(
        {
          create_chat()
          
          shinyjs::html(
            "status_bar",
            "Model connected."
          )
        },
        error = function(e) {
          chat_instance(NULL)
          
          shinyjs::html(
            "status_bar",
            htmltools::htmlEscape(
              paste("Error initialisation chat:", e$message)
            )
          )
        }
      )
    })
    
    # Browse
    shiny::observeEvent(input$browse, {
      path <- tryCatch(
        rstudioapi::selectFile(caption = "Select R file", filter = "R files (*.R)"),
        error = function(e) NULL)
      if (!is.null(path)) shiny::updateTextInput(session, "file_path", value = path)
    })
    
    # Grab selection from editor
    shiny::observeEvent(input$grab_sel, {
      tryCatch({
        ctx <- rstudioapi::getSourceEditorContext()
        sel <- ctx$selection[[1]]
        rng <- sel$range
        from_row <- as.integer(rng$start["row"])
        to_row   <- as.integer(rng$end["row"])
        if (from_row == to_row && nchar(trimws(sel$text)) == 0) {
          shinyjs::html("sel_info", "No text selected in editor")
        } else {
          session$sendInputMessage("r2_from", list(value = from_row))
          session$sendInputMessage("r2_to",   list(value = to_row))
          shinyjs::html("sel_info",
                        paste0("Grabbed rows ", from_row, "–", to_row,
                               " (", to_row - from_row + 1, " rows)"))
          res <- calc_token_estimate(input$r1_from, input$r1_to, from_row, to_row)
          if (!is.null(res)) {
            shinyjs::html("token_info",
                          paste0("Range 1: ", res$n1, " rows + Range 2: ", res$n2,
                                 " rows | ~", res$total, " tokens total"))
          }
        }
      }, error = function(e) {
        shinyjs::html("sel_info", paste("Could not grab selection:", e$message))
      })
    })
    
    # Token estimate — reactive function reused by observe and grab
    calc_token_estimate <- function(f1, t1, f2 = NA, t2 = NA) {
      if (is.null(input$file_path) ||
          !nzchar(input$file_path) ||
          !file.exists(input$file_path)) {
        return(NULL)
      }
      
      righe <- tryCatch(
        readLines(
          input$file_path,
          warn = FALSE,
          encoding = "UTF-8"
        ),
        error = function(e) NULL
      )
      
      if (is.null(righe)) {
        return(NULL)
      }
      
      n_tot <- length(righe)
      
      range1 <- tryCatch(
        get_valid_range(f1, t1, n_tot, "Range 1"),
        error = function(e) NULL
      )
      
      if (is.null(range1)) {
        return(NULL)
      }
      
      s1 <- paste(
        righe[range1$from:range1$to],
        collapse = "\n"
      )
      
      s2 <- ""
      n2 <- 0L
      
      if (!is.na(f2) && !is.na(t2)) {
        range2 <- tryCatch(
          get_valid_range(f2, t2, n_tot, "Range 2"),
          error = function(e) NULL
        )
        
        if (!is.null(range2)) {
          s2 <- paste(
            righe[range2$from:range2$to],
            collapse = "\n"
          )
          n2 <- range2$to - range2$from + 1L
        }
      }
      
      combined <- paste(s1, s2)
      estimated_tokens <- round(
        nchar(enc2utf8(combined), type = "bytes") / 4
      )
      
      list(
        total = estimated_tokens,
        n_tot = n_tot,
        n1 = range1$to - range1$from + 1L,
        n2 = n2
      )
    }
    
    # Token estimate observer
    shiny::observe({
      shiny::req(input$file_path)
      if (file.exists(input$file_path)) {
        righe <- tryCatch(readLines(input$file_path, warn = FALSE, encoding = "UTF-8"), error = function(e) NULL)
        if (!is.null(righe)) {
          n_tot <- length(righe)
          all_chars <- nchar(enc2utf8(paste(righe, collapse = "\n")), type = "bytes")
          est_full <- round(all_chars / 4)
          shinyjs::html("file_info",
                        paste0("File: ", n_tot, " rows | ~", est_full, " tokens if sent in full"))
        }
      }
    })
    
    shiny::observe({
      shiny::req(input$file_path, input$r1_from, input$r1_to)
      if (file.exists(input$file_path)) {
        righe <- tryCatch(readLines(input$file_path, warn = FALSE, encoding = "UTF-8"), error = function(e) NULL)
        if (!is.null(righe)) {
          n_tot <- length(righe)
          f1 <- max(1, input$r1_from); t1 <- min(n_tot, input$r1_to)
          n1 <- max(0, t1 - f1 + 1)
          s1 <- if (f1 <= t1) paste(righe[f1:t1], collapse = "\n") else ""
          est1 <- round(nchar(enc2utf8(s1), type = "bytes") / 4)
          shinyjs::html("range1_info", paste0(n1, " rows selected | ~", est1, " tokens"))
        }
      }
    })
    
    shiny::observe({
      shiny::req(input$r2_from, input$r2_to)
      if (!is.na(input$r2_from) && !is.na(input$r2_to) && file.exists(input$file_path)) {
        righe <- tryCatch(readLines(input$file_path, warn = FALSE, encoding = "UTF-8"), error = function(e) NULL)
        if (!is.null(righe)) {
          n_tot <- length(righe)
          f1 <- max(1, input$r1_from); t1 <- min(n_tot, input$r1_to)
          f2 <- max(1, input$r2_from); t2 <- min(n_tot, input$r2_to)
          s1 <- if (f1 <= t1) paste(righe[f1:t1], collapse = "\n") else ""
          s2 <- if (f2 <= t2) paste(righe[f2:t2], collapse = "\n") else ""
          n2 <- max(0, t2 - f2 + 1)
          est_tot <- round(nchar(enc2utf8(paste(s1, s2)), type = "bytes") / 4)
          shinyjs::html("token_info",
                        paste0(n2, " rows selected | ~", est_tot, " tokens total (R1+R2)"))
        }
      }
    })
    
    
    # Ask
    shiny::observeEvent(input$ask, {
      shinyjs::html("response_box", "⏳ Processing...")
      shinyjs::html("status_bar", "")
      
      tryCatch({
        if (!file.exists(input$file_path)) {
          stop("File not found")
        }
        
        righe <- readLines(
          input$file_path,
          warn = FALSE,
          encoding = "UTF-8"
        )
        
        n_tot <- length(righe)
        
        range1 <- get_valid_range(
          input$r1_from,
          input$r1_to,
          n_tot,
          "Range 1"
        )
        
        s1 <- paste(
          righe[range1$from:range1$to],
          collapse = "\n"
        )
        
        s2 <- ""
        
        if (!is.na(input$r2_from) && !is.na(input$r2_to)) {
          range2 <- get_valid_range(
            input$r2_from,
            input$r2_to,
            n_tot,
            "Range 2"
          )
          
          s2 <- paste(
            righe[range2$from:range2$to],
            collapse = "\n"
          )
        }
        
        code <- if (nchar(s2) > 0) {
          paste0(s1, "\n\n# --- Range 2 ---\n", s2)
        } else {
          s1
        }
        
        question <- if (nchar(trimws(input$question)) > 0) {
          input$question
        } else {
          "What does this code do? Any errors or improvements?"
        }
        
        prompt <- paste0(
          question,
          "\n\n```r\n",
          code,
          "\n```"
        )
        
        ch <- chat_instance()
        
        if (is.null(ch)) {
          ch <- create_chat()
        }
        
        reply <- ch$chat(prompt)
        
        shinyjs::html(
          "response_box",
          htmltools::htmlEscape(as.character(reply))
        )
        
      }, error = function(e) {
        shinyjs::html(
          "response_box",
          htmltools::htmlEscape(
            paste("❌ Error:", e$message)
          )
        )
      })
    })    
    shiny::observeEvent(input$done, shiny::stopApp())
  }
  
  viewer <- shiny::dialogViewer(
    "LM Studio Addin",
    width = 760,
    height = 820
  )
  
  shiny::runGadget(
    ui,
    server,
    viewer = viewer
  )
}
