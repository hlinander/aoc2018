input = File.read!("input")
lines = String.split(input, "\n")

coordinates =
  Enum.map(lines, fn line ->
    coord_strings = String.split(line, ", ")
    [x, y] = Enum.map(coord_strings, &String.to_integer/1)
  end)

IO.inspect(coordinates)

manhattan = fn [x1, y1], [x2, y2] ->
  abs(x2 - x1) + abs(y2 - y1)
end

sx = -100
sy = -100
ex = 400
ey = 400
width = ex - sx + 1
height = ey - sy + 1

colors =
  0..Enum.count(coordinates)
  |> Enum.map(fn _ -> [Enum.random(0..255), Enum.random(0..255), Enum.random(0..255)] end)

distance_map =
  for x <- sx..ex, y <- sy..ey, into: %{} do
    distances_with_index =
      Enum.zip(coordinates, 0..Enum.count(coordinates))
      |> Enum.map(fn {coord, index} ->
        {index, manhattan.(coord, [x, y])}
      end)

    {min_index, min_distance} =
      distances_with_index
      |> Enum.min_by(fn {_, distance} -> distance end)

    color_and_index =
      case Enum.count(
             Enum.filter(distances_with_index, fn {_, distance} -> distance == min_distance end)
           ) do
        1 -> {Enum.at(colors, min_index), min_index}
        _ -> {[255, 255, 255], :not_unique}
      end

    {[x, y], color_and_index}
  end

write_ppm = fn filename, data ->
  {:ok, file} = File.open(filename, [:write])
  IO.write(file, "P3\n")
  IO.write(file, "#{width} #{height}\n")
  IO.write(file, "255\n")

  for y <- sy..ey do
    for x <- sx..ex do
      {[r, g, b], _} = data[[x, y]]
      IO.write(file, "#{r} #{g} #{b} ")
    end

    IO.write(file, "\n")
  end

  File.close(file)
end

write_ppm.("out.ppm", distance_map)

inf_indices_top =
  for x <- sx..ex, into: MapSet.new() do
    {_, index} = distance_map[[x, sy]]
    index
  end

inf_indices_bottom =
  for x <- sx..ex, into: MapSet.new() do
    {_, index} = distance_map[[x, ey]]
    index
  end

inf_indices_left =
  for y <- sy..ey, into: MapSet.new() do
    {_, index} = distance_map[[sx, y]]
    index
  end

inf_indices_right =
  for y <- sy..ey, into: MapSet.new() do
    {_, index} = distance_map[[ex, y]]
    index
  end

inf_indices =
  inf_indices_top
  |> MapSet.union(inf_indices_bottom)
  |> MapSet.union(inf_indices_left)
  |> MapSet.union(inf_indices_right)

finite =
  0..Enum.count(coordinates)
  |> Enum.filter(&(&1 not in inf_indices))

areas =
  Enum.map(finite, fn search_index ->
    Enum.filter(distance_map, fn {_, {_, index}} = indata ->
      index == search_index
    end)
    |> Enum.count()
  end)

IO.inspect(Enum.max(areas))

# Part two
distance_map_2 =
  for x <- sx..ex, y <- sy..ey, into: %{} do
    total_distance =
      coordinates
      |> Enum.map(fn coord ->
        manhattan.(coord, [x, y])
      end)
      |> Enum.sum()

    cond do
      total_distance < 10000 -> {[x, y], {[255, 0, 0], :inside}}
      true -> {[x, y], {[0, 0, 0], :outside}}
    end
  end

write_ppm.("out2.ppm", distance_map_2)

area = Enum.filter(distance_map_2, fn {_, {_, status}} -> status == :inside end)
  |> Enum.count()

IO.inspect(area)
