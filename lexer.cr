require "compiler/crystal/syntax"
require "csv"

code = ARGF.gets_to_end

CSV.build(STDOUT, separator: '\t') do |csv|
  csv.row %w[
    type value
    line col file
    numkind
    keyword space newline
    doc
    bslash escape
    delim dnest dend dcount
    dindent dallow
  ]

  lexer = Crystal::Lexer.new(code)
  lexer.comments_enabled = true
  lexer.wants_raw = true
  lexer.doc_enabled = true
  lexer.count_whitespace = true

  loop do
    token = lexer.next_token
    break if token.type == Crystal::Token::Kind::EOF

    csv.row [
      # Core token identity
      token.type.to_s,
      Process.quote(token.value.to_s),
      # Process.quote(token.raw.to_s),

      # Location information
      token.line_number.to_s,
      token.column_number.to_s,
      token.filename.to_s,

      # Type-specific information
      token.number_kind.to_s,

      # Token classification flags
      token.keyword?.to_s,
      token.type.space?.to_s,
      token.type.newline?.to_s,

      # Documentation
      Process.quote(token.doc.to_s),

      # Processing flags
      token.passed_backslash_newline.to_s,
      token.invalid_escape.to_s,

      # Delimiter state
      token.delimiter_state.kind.to_s,
      Process.quote(token.delimiter_state.nest.to_s),
      Process.quote(token.delimiter_state.end.to_s),
      token.delimiter_state.open_count.to_s,
      token.delimiter_state.heredoc_indent.to_s,
      token.delimiter_state.allow_escapes.to_s,
    ]
  end
end
