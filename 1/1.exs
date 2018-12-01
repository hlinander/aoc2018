# Part one
input = File.read!("input")
lines = String.split(input)
steps = Enum.map(lines, fn string -> String.to_integer(string) end)
frequency = Enum.reduce(steps, fn step, freq -> freq + step end)
IO.inspect(frequency)

# Part two
infisteps = Stream.cycle(steps)

find_first_double =
  Enum.reduce_while(infisteps, {0, [0]}, fn step, {freq, list} ->
    if (freq + step) in list do
      {:halt, {freq + step, list}}
    else
      {:cont, {freq + step, list ++ [freq + step]}}
    end
  end)
IO.inspect(find_first_double)
