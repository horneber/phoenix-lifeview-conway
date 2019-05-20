defmodule Life.Grids do

  def empty_grid, do: MapSet.new

  def blinker, do: MapSet.new([{-1, 0}, {0, 0}, {1, 0}])

  def gosper_glider do
    MapSet.new(
      [
        {24, 8},
        {22, 7},
        {24, 7},
        {12, 6},
        {13, 6},
        {20, 6},
        {21, 6},
        {34, 6},
        {35, 6},
        {11, 5},
        {15, 5},
        {20, 5},
        {21, 5},
        {34, 5},
        {35, 5},
        {0, 4},
        {1, 4},
        {10, 4},
        {16, 4},
        {20, 4},
        {21, 4},
        {0, 3},
        {1, 3},
        {10, 3},
        {14, 3},
        {16, 3},
        {17, 3},
        {22, 3},
        {24, 3},
        {10, 2},
        {16, 2},
        {24, 2},
        {11, 1},
        {15, 1},
        {12, 0},
        {13, 0},
      ]
    )
  end

  def gun do
    gosper_glider()
    |> transpose({0, 90})
    |> mirror()
  end

  def transpose(grid, {x_offset, y_offset}) do
    Enum.into(grid, MapSet.new, fn {x, y} -> {x + x_offset, y + y_offset}  end)
  end

  def mirror(grid) do
    Enum.into(grid, MapSet.new, fn {x, y} -> {y, x}  end)
  end

  def add_cell(grid, {_x, _y} = cell), do: MapSet.put(grid, cell)
  def add_cells(grid, cells, at \\ {0, 0}) do
    MapSet.union(grid, transpose(cells, at))
  end

  def remove_cells(grid, cells), do: MapSet.difference(grid, cells)
  def remove_cell(grid, {_x, _y} = cell), do: MapSet.delete(grid, cell)

  def toggle_cell(grid, {_x, _y} = cell) do
    if MapSet.member?(grid, cell) do
      remove_cell(grid, cell)
    else
      add_cell(grid, cell)
    end
  end

  def interesting_starter(around) do
    gosper_glider()
    |> transpose({10, 130})
    |> mirror()
    |> add_cells(blinker(), {10, 120})
    |> add_cells(blinker(), {90, 90})
    |> add_cells(blinker(), {50, 50})
    |> add_cells(blinker(), {50, 60})
    |> add_cells(blinker(), {50, 70})
    |> add_cells(blinker(), {50, 80})
    |> add_cells(Life.Patterns.Oscillators.pentadecathlon(), {40, 100})
    |> add_cells(Life.Patterns.Oscillators.toad(), {10, 10})
    |> add_cells(Life.Patterns.Oscillators.pulsar(), {25, 0})
    |> add_cells(Life.Patterns.Oscillators.pulsar(), {123, 135})
    |> add_cells(Life.Patterns.Spaceships.lightweight_spaceship(), {-40, 85})
    |> add_cells(Life.Patterns.Spaceships.lightweight_spaceship(), {-10, 85})
    |> add_cells(Life.Patterns.StillLife.beehive(), {70, 10})
    |> transpose({-around, -around})

  end
end