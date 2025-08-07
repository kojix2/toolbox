require "compiler/crystal/syntax"

require "compiler/crystal/syntax"

class ASTDotPrinter
  def initialize(@io : IO)
    @node_id = 0
    @parent_stack = [] of Int32
  end

  def print(node : Crystal::ASTNode)
    @io.puts "digraph AST {"
    @io.puts "  node [fontname=\"Arial\"];"
    node.accept(self)
    @io.puts "}"
  end

  def visit(node : Crystal::ASTNode)
    current_id = @node_id
    @node_id += 1

    # ノードの実際の内容を取得
    content = get_node_content(node)
    node_type = node.class.name.split("::").last

    # HTMLライクなラベルを作成
    label = create_label(content, node_type)

    @io.puts "  node#{current_id} [label=<#{label}>, shape=box, style=filled, fillcolor=lightblue];"

    if parent_id = @parent_stack.last?
      @io.puts "  node#{parent_id} -> node#{current_id};"
    end

    @parent_stack.push(current_id)
    true
  end

  def visit_any(node : Crystal::ASTNode)
    visit(node)
    true
  end

  def end_visit(node : Crystal::ASTNode)
  end

  def end_visit_any(node : Crystal::ASTNode)
    @parent_stack.pop
  end

  private def get_node_content(node : Crystal::ASTNode) : String
    case node
    when Crystal::StringLiteral
      "\"#{escape_html(node.value)}\""
    when Crystal::NumberLiteral
      node.value
    when Crystal::BoolLiteral
      node.value.to_s
    when Crystal::SymbolLiteral
      ":#{escape_html(node.value)}"
    when Crystal::Var
      node.name
    when Crystal::Call
      if node.obj
        "#{get_node_content(node.obj.not_nil!)}.#{node.name}"
      else
        node.name
      end
    when Crystal::Def
      "def #{node.name}"
    when Crystal::ClassDef
      "class #{node.name}"
    else
      # その他のノードは to_s を使用
      content = String.build do |str|
        node.to_s(str)
      end
      escape_html(content.lines.first? || "")
    end
  end

  private def create_label(content : String, node_type : String) : String
    # メインコンテンツを大きく、ノードタイプを小さく灰色で表示
    main_content = content.empty? ? node_type : content

    if content.empty?
      %(<FONT POINT-SIZE="12" COLOR="black">#{main_content}</FONT>)
    else
      %(<FONT POINT-SIZE="14" COLOR="black">#{main_content}</FONT><BR/><FONT POINT-SIZE="10" COLOR="gray">#{node_type}</FONT>)
    end
  end

  private def escape_html(str : String) : String
    str.gsub("&", "&amp;")
      .gsub("<", "&lt;")
      .gsub(">", "&gt;")
      .gsub("\"", "&quot;")
      .gsub("'", "&#39;")
  end
end

str = ARGF.gets_to_end
ast = Crystal::Parser.parse(str)

printer = ASTDotPrinter.new(STDOUT)
printer.print(ast)
