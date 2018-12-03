# Part one
input = File.read!("input")
claims_raw = String.split(input, "\n")

get_dims = fn claim_string ->
  [_, id, x, y, w, h] = Regex.run(~r/#([0-9]+) @ ([0-9]+),([0-9]+): ([0-9]+)x([0-9]+)/, claim_string)
  %{id: String.to_integer(id), x: String.to_integer(x), y: String.to_integer(y), w: String.to_integer(w), h: String.to_integer(h)}
end

render_claim = fn claim, fabric ->
  positions =
    for x <- claim[:x]..(claim[:x] + claim[:w] - 1), y <- claim[:y]..(claim[:y] + claim[:h] - 1) do
      [x, y]
    end

  Enum.reduce(positions, fabric, fn pos, fab -> update_in(fab, pos, &(&1 ++ [claim[:id]])) end)
end

create_fabric = fn w, h ->
  for x <- 0..(w - 1), into: %{} do
    {x, for(y <- 0..(h - 1), into: %{}, do: {y, []})}
  end
end

IO.inspect(create_fabric.(5, 5))
fabric = render_claim.(%{id: 1, x: 0, y: 0, w: 2, h: 2}, render_claim.(%{id: 0, x: 1, y: 1, w: 2, h: 2}, create_fabric.(5, 5)))
IO.inspect(fabric)

claims =
  claims_raw
  |> Enum.map(get_dims)

fabric_with_claims =
  Enum.reduce(claims, create_fabric.(1000, 1000), fn claim, fabric ->
    render_claim.(claim, fabric)
  end)

just_counts = for {_, col} <- fabric_with_claims do
  for {_, ids} <- col do
    Enum.count(ids)
  end
end

List.flatten(just_counts)
|> Enum.filter(&(&1 >= 2))
|> Enum.count()
|> IO.inspect()

# Part two
is_unique? = fn claim, fabric ->
  positions =
    for x <- claim[:x]..(claim[:x] + claim[:w] - 1), y <- claim[:y]..(claim[:y] + claim[:h] - 1) do
      [x, y]
    end

  matching = Enum.map(positions, fn pos -> get_in(fabric, pos) end)
  |> Enum.filter(fn ids -> Enum.count(ids) == 1 and Enum.at(ids, 0) == claim[:id] end)
  Enum.count(matching) == Enum.count(positions)
end

IO.inspect(Enum.filter(claims, &(is_unique?.(&1, fabric_with_claims))))
