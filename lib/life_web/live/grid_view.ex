defmodule LifeWeb.GridView do
  use Phoenix.LiveView
  require Logger
  alias Life.Grid


  def render(assigns) do
    LifeWeb.PageView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    Logger.debug "Mounting!"
    {:ok, assign(socket, generation: 0, grid: Life.Grids.interesting_starter(), tref: nil)}
  end

  def handle_event("toggle", value,  %{assigns: %{ grid: grid}} = socket) do
    {x, "," <> rest} = Integer.parse(value)
    {y, _} = Integer.parse(rest)
    grid = Life.Grids.toggle_cell(grid, {x, y})
    {:noreply, assign(socket, grid: grid)}
  end


  def handle_event("start_auto", _value,  %{assigns: %{ tref: nil}} = socket)  do
    start_auto(socket)
  end

  def handle_event("start_auto", _value,  %{assigns: %{ tref: _tref,}} = socket) do
    {:noreply, socket}
  end

  def handle_event("stop_auto", _value,  %{assigns: %{ tref: nil}} = socket) do
    {:noreply, socket}
  end

  def handle_event("stop_auto", _value,  %{assigns: %{ tref: tref}} = socket) do
    stop_auto(socket, tref)
  end

  def handle_event("next_gen", _value, socket) do
    handle_info(:next_gen, socket)
  end

  def handle_event("window_key_event", " ", %{assigns: %{ tref: nil }} = socket) do
    start_auto(socket)
  end

  def handle_event("window_key_event", " ", %{assigns: %{ tref: tref }} = socket) do
    stop_auto(socket, tref)
  end

  def handle_event("window_key_event", "ArrowUp", %{assigns: %{ grid: grid }} = socket) do
    {:noreply, assign(socket, :grid, Life.Grids.transpose(grid, {0, 1}))}
  end

  def handle_event("window_key_event", "ArrowDown", %{assigns: %{ grid: grid }} = socket) do
    {:noreply, assign(socket, :grid, Life.Grids.transpose(grid, {0, -1}))}
  end

  def handle_event("window_key_event", "ArrowLeft", %{assigns: %{ grid: grid }} = socket) do
    {:noreply, assign(socket, :grid, Life.Grids.transpose(grid, {-1, 0}))}
  end

  def handle_event("window_key_event", "ArrowRight", %{assigns: %{ grid: grid }} = socket) do
    {:noreply, assign(socket, :grid, Life.Grids.transpose(grid, {1, 0}))}
  end

  def handle_event("window_key_event", "w", %{assigns: %{ grid: grid }} = socket) do
    {:noreply, assign(socket, :grid, Life.Grids.transpose(grid, {0, 4}))}
  end

  def handle_event("window_key_event", "s", %{assigns: %{ grid: grid }} = socket) do
    {:noreply, assign(socket, :grid, Life.Grids.transpose(grid, {0, -4}))}
  end

  def handle_event("window_key_event", "a", %{assigns: %{ grid: grid }} = socket) do
    {:noreply, assign(socket, :grid, Life.Grids.transpose(grid, {-4, 0}))}
  end

  def handle_event("window_key_event", "d", %{assigns: %{ grid: grid }} = socket) do
    {:noreply, assign(socket, :grid, Life.Grids.transpose(grid, {4, 0}))}
  end

  def handle_event("window_key_event", any_other_key, socket) do
    Logger.debug "unhandled key: #{inspect(any_other_key)}"
    {:noreply, socket}
  end

  def handle_info(:next_gen, %{assigns: %{ grid: grid, generation: generation }} = socket) do
    # Logger.debug "next_gen for #{inspect(grid)}}"
    next_grid = Grid.calc_next_grid(grid)
    # Logger.debug "next_gen is #{inspect(next_grid)}}"
    {:noreply, assign(socket, generation: generation + 1, grid: next_grid)}
  end

  def start_auto(socket) do
    {:ok, tref} = :timer.send_interval(500, self(), :next_gen)
    {:noreply, assign(socket, tref: tref)}
  end

  def stop_auto(socket, tref) do
    :timer.cancel(tref)
    {:noreply, assign(socket, tref: nil)}
  end
end