; extends

; Both of these match a comment of /* sql */ preceeding any string literal

; Mainly matches function calls
; `Exec(/* sql */ "SELECT * FROM foo")`
(
 ((comment) @_c (interpreted_string_literal) @injection.content)
 (#eq? @_c "/* sql */")
 (#offset! @injection.content 0 1 0 -1)
 (#set! injection.language "sql"))

; Mainly used to match assignments
; q := /* sql */ "SELECT * FROM foo"
(
 (comment) @_c (expression_list (interpreted_string_literal) @injection.content)
 (#eq? @_c "/* sql */")
 (#offset! @injection.content 0 1 0 -1)
 (#set! injection.language "sql"))
