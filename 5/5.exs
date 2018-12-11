input = File.read!("input")
chars = String.graphemes(String.trim(input, "\n"))

reacts? = fn c1, c2 ->
  c1 != c2 and String.downcase(c1) == String.downcase(c2)
end

one_pass = fn chars ->
  with_post = Enum.zip(chars, Enum.drop(chars, 1) ++ [" "])
  reaction_index = Enum.find_index(with_post, fn {char, post} -> reacts?.(char, post) end)

  case reaction_index do
    nil -> chars
    index -> List.delete_at(chars, index) |> List.delete_at(index)
  end
end

get_triplets = fn chars ->
  with_post = Enum.zip(chars, Enum.drop(chars, 1) ++ [" "])
  with_pre = Enum.zip(with_post, [" "] ++ Enum.drop(chars, -1))
  Enum.map(with_pre, fn {{char, post}, pre} -> {char, pre, post} end)
end

to_list = fn list -> Enum.map(list, fn {char, _, _} -> char end) end

one_reaction_pass = fn triplets ->
  Enum.filter(triplets, fn {char, pre, post} ->
    (reacts?.(char, pre) and reacts?.(char, post)) or
      (not reacts?.(char, pre) and not reacts?.(char, post))
  end)
end

# pairs = Enum.chunk_every(chars, 2, 1, :discard)
IO.inspect(chars)
# IO.inspect(first_filter)
IO.inspect(reacts?.("a", "C"))
IO.inspect(reacts?.("a", "a"))
IO.inspect(reacts?.("A", "A"))
IO.inspect(reacts?.("b", "B"))

get_count = fn chars ->
  {n, chars} =
    Enum.reduce_while(1..1_000_000, chars, fn n, chars ->
      new_chars = one_pass.(chars)

      cond do
        Enum.count(new_chars) == Enum.count(chars) -> {:halt, {n, chars}}
        true -> {:cont, new_chars}
      end
    end)

  Enum.count(chars)
end

alphabet = for n <- ?a..?z, do: <<n::utf8>>
IO.inspect(is_list(alphabet))

remove_char = fn chars, remove_char ->
  Enum.filter(chars, fn char -> String.downcase(char) != remove_char end)
end

Enum.min(
  Enum.map(
    alphabet,
    fn current_char -> get_count.(remove_char.(chars, current_char)) end
  )
)
|> IO.inspect()
