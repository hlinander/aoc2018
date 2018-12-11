input = File.read!("input") |> String.trim_trailing("\n")
entries = String.split(input, " ") |> Enum.map(&String.to_integer/1)

defmodule Parser do
  def parse(entries, cursor) do
    num_children = Enum.at(entries, cursor)
    num_meta = Enum.at(entries, cursor + 1)
    # IO.puts("Children: #{num_children}, Meta: #{num_meta}")
    # IO.getn("")
    slots =
      case num_children do
        0 -> []
        _ -> 1..num_children
      end

    {children, end_cursor} =
      Enum.reduce(slots, {[], cursor + 2}, fn _, {children, curr_cursor} ->
        {child, new_cursor} = parse(entries, curr_cursor)
        {children ++ [child], new_cursor}
      end)

    meta = Enum.slice(entries, end_cursor, num_meta)
    object = {%{:children => children, :meta => meta}, end_cursor + num_meta}
    object
  end

  def sum_meta(tree) do
    children_sum = Enum.reduce(tree.children, 0, fn child, sum -> sum + sum_meta(child) end)
    children_sum + Enum.sum(tree.meta)
  end

  def sum_extended_meta(tree) do
    num_children = Enum.count(tree.children)
    case tree.children do
      [] ->
        Enum.sum(tree.meta)

      children ->
        Enum.reduce(tree.meta, 0, fn child_index, sum ->
          case child_index do
            n when n >= 1 and n <= num_children ->
              sum + sum_extended_meta(Enum.at(tree.children, n - 1))

            _ ->
              sum
          end
        end)
    end
  end
end

IO.inspect(entries)
{tree, _} = Parser.parse(entries, 0)
IO.inspect(Parser.sum_meta(tree))
IO.inspect(Parser.sum_extended_meta(tree))
