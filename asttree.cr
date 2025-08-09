require "compiler/crystal/syntax"
require "colorize"

str = ARGF.gets_to_end
a = Crystal::Parser.parse(str)

class TreePrinter < Crystal::Visitor
  def initialize
    @prefix = ""
    @is_last = true
  end

  def visit(node)
    node_info = get_node_info(node)
    puts @prefix + (@is_last ? "└── " : "├── ") + node_info

    children = collect_children(node)
    children.each_with_index do |child, i|
      old_prefix = @prefix
      old_is_last = @is_last

      @prefix += @is_last ? "    " : "│   "
      @is_last = i == children.size - 1

      child.accept(self)

      @prefix = old_prefix
      @is_last = old_is_last
    end

    false
  end

  private def get_node_info(node) : String
    class_name = node.class.to_s.colorize(:green).to_s

    case node
    when Crystal::StringLiteral
      "#{class_name}: #{node.value.inspect.colorize(:yellow).to_s}"
    when Crystal::NumberLiteral
      "#{class_name}: #{node.value.colorize(:magenta).to_s}"
    when Crystal::Var
      "#{class_name}: #{node.name.colorize(:cyan).to_s}"
    when Crystal::Call
      obj_part = node.obj ? "#{node.obj.class.to_s.downcase}." : ""
      "#{class_name}: #{obj_part}#{node.name.colorize(:blue).to_s}"
    when Crystal::Path
      "#{class_name}: #{node.names.join("::").colorize(:cyan).to_s}"
    when Crystal::SymbolLiteral
      "#{class_name}: #{node.value.colorize(:magenta).to_s}"
    when Crystal::BoolLiteral
      "#{class_name}: #{node.value.colorize(:light_red).to_s}"
    else
      class_name
    end
  end

  private def collect_children(node)
    children = [] of Crystal::ASTNode
    node.accept_children(ChildCollector.new(children))
    children
  end
end

class ChildCollector < Crystal::Visitor
  def initialize(@children : Array(Crystal::ASTNode))
  end

  def visit(node)
    @children << node
    false
  end
end

puts a.class.to_s.colorize(:green)
TreePrinter.new.visit(a)
