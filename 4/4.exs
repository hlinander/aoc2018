# Part one
input = File.read!("input")
events_raw = String.split(input, "\n")

parse_event = fn event_string ->
  [_, syear, smonth, sday, shour, sminute, event] =
    Regex.run(~r/\[([0-9]+)-([0-9]+)-([0-9]+) ([0-9]+):([0-9]+)] ([#\w ]+)/, event_string)

  [year, month, day, hour, minute] =
    Enum.map([syear, smonth, sday, shour, sminute], &String.to_integer/1)

  {_, datetime} = NaiveDateTime.new(year, month, day, hour, minute, 0)
  %{time: datetime, event: event}
end

events =
  events_raw
  |> Enum.map(&parse_event.(&1))
  |> Enum.sort(fn %{:time => time1}, %{:time => time2} ->
    NaiveDateTime.compare(time1, time2) == :lt
  end)
  |> Enum.reduce(
    %{current_guard: -1, new_list: []},
    fn %{:time => time, :event => event}, %{:current_guard => current_guard, :new_list => list} ->
      guard =
        case Regex.run(~r/#([0-9]+)/, event) do
          nil -> current_guard
          [_, new_guard] -> String.to_integer(new_guard)
        end

      event_type =
        cond do
          String.match?(event, ~r/asleep/) -> :sleep
          String.match?(event, ~r/wakes/) -> :wakes
          true -> :new_guard
        end

      %{current_guard: guard, new_list: list ++ [%{time: time, guard: guard, event: event_type}]}
    end
  )
  |> (fn %{:new_list => new_events} -> new_events end).()

guards = Enum.map(events, fn %{:guard => guard} -> guard end) |> Enum.sort() |> Enum.uniq()

guard_maps =
  Enum.map(guards, fn current_guard ->
    guard_events =
      Enum.filter(events, fn %{:guard => guard} -> guard == current_guard end)
      |> Enum.filter(fn %{:event => event} -> event != :new_guard end)

    {current_guard, guard_events}
  end)

guard_sleep = Enum.map(guard_maps, fn {guard, maybe_events} ->
  case maybe_events do
    [] ->
      {guard, (for n <- 0..59, do: 0), 0}

    [_ | _] = events ->
      agg_minutes = Enum.chunk_every(events, 2)
      |> Enum.map(fn [%{:event => :sleep, :time => sleep}, %{:event => :wakes, :time => wake}] ->
        minutes = for n <- 0..59, do: n

        Enum.map(minutes, fn minute ->
          cond do
            minute >= sleep.minute and minute < wake.minute -> 1
            true -> 0
          end
        end)
      end)
      |> Enum.reduce(fn curr_minutes, total_minutes ->
        Enum.zip(curr_minutes, total_minutes)
        |> Enum.map(fn {m1, m2} -> m1 + m2 end)
      end)
      {guard, agg_minutes, Enum.sum(agg_minutes)}
  end
end)

# Part 1
guard_sleep
|> Enum.max_by(fn {_, _, total_slept} -> total_slept end)
|> (fn {guard, minutes, _} ->
  Enum.zip(minutes, 0..Enum.count(minutes))
  |> Enum.max_by(fn {time, minute} -> time end)
  |> (fn {time, minute} -> {guard, minute, guard * minute} end).()
end).()
|> IO.inspect

# Part 2
guard_sleep
|> Enum.map(fn {guard, minutes, _} ->
  Enum.zip(minutes, 0..Enum.count(minutes))
  |> Enum.max_by(fn {time, minute} -> time end)
  |> (fn out -> {guard, out} end).()
end)
|> Enum.max_by(fn {guard, {time, _}} -> time end)
|> (fn {guard, {_, minute}} -> guard * minute end).()
|> IO.inspect
