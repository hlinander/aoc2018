# Part one
input = File.read!("input")
codes = String.split(input)

list_of_counts =
  Enum.map(codes, fn string ->
    chars = String.codepoints(string)

    Enum.group_by(
      chars,
      fn char -> Enum.count(Enum.filter(chars, &(&1 == char))) end
    )
  end)

number_of_2 = Enum.filter(list_of_counts, &Map.has_key?(&1, 2)) |> Enum.count(& &1)
number_of_3 = Enum.filter(list_of_counts, &Map.has_key?(&1, 3)) |> Enum.count(& &1)
IO.inspect(number_of_2 * number_of_3)

# Part two
distance = fn string1, string2 ->
  chars1 = String.codepoints(string1)
  chars2 = String.codepoints(string2)

  Enum.zip(chars1, chars2)
  |> Enum.map(fn {c1, c2} ->
    if c1 == c2, do: 0, else: 1
  end)
  |> Enum.sum()
end

distances = for code1 <- codes, code2 <- codes do
  {distance.(code1, code2), code1, code2}
end

distance_1_codes = distances |> Enum.filter(fn {distance, c1, c2} -> distance == 1 end)
# There are two distance 1 items in the cartesian product
{distance, code1, code2} = Enum.at(distance_1_codes, 1)
common_chars = [code1, code2]
|> Enum.map(&(String.codepoints(&1)))
|> Enum.zip()
|> Enum.filter(fn {c1, c2} -> c1 == c2 end)
|> Enum.map(fn {c1, c2} -> c1 end)
|> Enum.reduce(fn val, acc -> acc <> val end)
IO.inspect(common_chars)


