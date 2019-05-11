defmodule Life.Grid do
  def calc_next_grid(grid) do
    Enum.reduce(alive_plus_neighbors(grid), MapSet.new, fn({x, y}, next_gen_grid) ->
      is_alive = MapSet.member?(grid, {x, y})
      num_neighbors = count_neighbors(grid, {x, y})
      if should_live?(is_alive, num_neighbors), do: MapSet.put(next_gen_grid, {x, y}), else: next_gen_grid
    end)
  end

  defp alive_plus_neighbors(grid) do
    offsets = [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 0}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]
    Enum.reduce(grid, MapSet.new, fn({x, y}, grid2) ->
      Enum.reduce(offsets, grid2, fn({x_off, y_off}, grid3) ->
        MapSet.put(grid3, {x + x_off, y + y_off})
      end)
    end)
  end

  defp should_live?(is_alive, num_neighbors) do
    (num_neighbors == 2 && is_alive) || (num_neighbors == 3)
  end

  defp count_neighbors(grid, {x, y}) do
    offsets = [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]
    Enum.reduce(offsets, 0, fn({x_off, y_off}, acc) ->
      acc + if MapSet.member?(grid, {x + x_off, y + y_off}), do: 1, else: 0
    end)
  end
end