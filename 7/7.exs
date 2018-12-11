input = File.read!("input")
lines = String.split(input, "\n")

edges =
  Enum.map(lines, fn line ->
    [_, dep, node] =
      Regex.run(~r/Step ([A-Z]) must be finished before step ([A-Z]) can begin./, line)

    [dep, node]
  end)

steps = Enum.uniq(List.flatten(edges)) |> Enum.sort()

defmodule Tasks do
  def find_dep(edges, node) do
    Enum.filter(edges, fn [dep, node_] -> node_ == node end)
    |> Enum.sort()
  end

  def get_no_deps(edges, nodes) do
    Enum.filter(nodes, &(find_dep(edges, &1) == []))
  end

  def traverse(edges, [], order) do
    order
  end

  def traverse(edges, nodes, order) do
    ready = get_no_deps(edges, nodes)
    to_remove = Enum.at(ready, 0)

    if to_remove == nil do
      :stop
    else
      IO.inspect(ready)
      IO.inspect(to_remove)
      IO.inspect(nodes -- [to_remove])
      new_edges = Enum.filter(edges, fn [dep, node] -> dep != to_remove end)
      traverse(new_edges, nodes -- [to_remove], order ++ [to_remove])
    end
  end

  def create_worker(step) do
    [char_code] = String.to_charlist(String.downcase(step))
    time_left = char_code - 97
    IO.puts("New worker with #{step} with #{61 + time_left} steps")
    %{:step => step, :time_left => 61 + time_left}
  end

  def update_workers(workers) do
    updated_workers = Enum.map(workers, fn worker -> Map.update(worker, :time_left, 0, &(&1 - 1)) end)
    new_workers = Enum.filter(updated_workers, fn %{:time_left => time_left} -> time_left > 0 end)
    done = Enum.filter(updated_workers, fn %{:time_left => time_left} -> time_left <= 0 end)
      |> Enum.map(fn %{:step => step} -> step end)
    {new_workers, done}
  end

  def traverse_multi(edges, [], order, idle_workers, workers, time) do
    {order, time}
  end

  def traverse_multi(edges, nodes, order, idle_workers, workers, time) do
    {workers, done} = update_workers(workers)
    new_edges = Enum.filter(edges, fn [dep, node] -> dep not in done end)
    new_nodes = nodes -- done
    new_order = order ++ done

    ready = get_no_deps(new_edges, new_nodes) |> Enum.filter(fn step ->
      Enum.filter(workers, fn %{:step => worker_step} -> worker_step == step end)
      |> Enum.count() == 0
    end)
    assignments = Enum.take(ready, idle_workers)
    new_idle_workers = idle_workers - Enum.count(assignments) + Enum.count(done)
    new_workers = Enum.map(assignments, fn step -> create_worker(step) end)
    total_workers = workers ++ new_workers

    #IO.puts("Tot #{new_idle_workers + Enum.count(total_workers)}")
    #IO.puts("Idle: #{new_idle_workers}, Assignments: #{assignments}")
    #IO.getn("")
    traverse_multi(new_edges, new_nodes, new_order, new_idle_workers, total_workers, time + 1)
  end
end

Tasks.traverse(edges, steps, []) |> Enum.join() |> IO.inspect()
Tasks.traverse_multi(edges, steps, [], 5, [], -1) |> IO.inspect()
