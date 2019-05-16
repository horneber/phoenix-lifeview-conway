defmodule LifeWeb.GridView do
  use Phoenix.LiveView
  require Logger
  alias Life.Grid


  def render(assigns) do
    LifeWeb.PageView.render("grid_view.html", assigns)
  end

  @default_timer_interval 250
  @default_grid_size 120
  def mount(_session, socket) do
    Logger.debug "Mounting!"
    grid = Life.Grids.interesting_starter()
    if connected?(socket), do: Logger.debug "Connected."
    {:ok, assign(socket,
      generation: 0,
      grid: grid,
      tref: nil,
      grid_size: @default_grid_size,
      timer_interval: @default_timer_interval,
      edit?: false,
      largest_population_ever: MapSet.size(grid)
    )}
  end

  def handle_event("toggle", value,  %{assigns: %{ grid: grid}} = socket) do
    {x, "," <> rest} = Integer.parse(value)
    {y, _} = Integer.parse(rest)
    grid = Life.Grids.toggle_cell(grid, {x, y})
    {:noreply, assign(socket, grid: grid)}
  end

  def handle_event("stop_editing", _value,   socket)  do
    {:noreply, assign(socket, edit?: false)}
  end

  def handle_event("start_editing", _value,   socket)  do
    {:noreply, assign(socket, edit?: true)}
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

  def handle_event("log", %{"controls" => controls}, socket) do
    Logger.debug inspect(controls)
    {:noreply, socket}
  end

  @minimum_interval 100
  def handle_event("save", %{"controls" => controls}, socket) do
    Logger.debug "save #{inspect(controls)}"
    grid_size = case Integer.parse(controls["grid_size"]) do
      {grid_size, _} -> grid_size
      :error -> @default_grid_size
    end
    timer_interval = case Integer.parse(controls["timer_interval"]) do
      {timer_interval, _} -> max(timer_interval, @minimum_interval)
      :error -> @default_timer_interval
    end
    Logger.debug("new timer #{inspect(timer_interval)}}")
    tref = socket.assigns.tref
    socket = if tref do
      Logger.debug("On the fly new timer.")
      :timer.cancel(tref)
      tref = new_timer(timer_interval)
      assign(socket, timer_interval: timer_interval, grid_size: grid_size, tref: tref)
    else
      assign(socket, timer_interval: timer_interval, grid_size: grid_size)
    end
    {:noreply, socket}
  end

  def handle_event("window_key_event", " ", %{assigns: %{ tref: nil }} = socket) do
    start_auto(socket)
  end

  def handle_event("window_key_event", " ", %{assigns: %{ tref: tref }} = socket) do
    stop_auto(socket, tref)
  end

  def handle_event("window_key_event", "ArrowUp", %{assigns: %{ grid: grid }} = socket) do
    {:noreply, assign(socket, :grid, Life.Grids.transpose(grid, {0, -1}))}
  end

  def handle_event("window_key_event", "ArrowDown", %{assigns: %{ grid: grid }} = socket) do
    {:noreply, assign(socket, :grid, Life.Grids.transpose(grid, {0, 1}))}
  end

  def handle_event("window_key_event", "ArrowLeft", %{assigns: %{ grid: grid }} = socket) do
    {:noreply, assign(socket, :grid, Life.Grids.transpose(grid, {-1, 0}))}
  end

  def handle_event("window_key_event", "ArrowRight", %{assigns: %{ grid: grid }} = socket) do
    {:noreply, assign(socket, :grid, Life.Grids.transpose(grid, {1, 0}))}
  end

  def handle_event("window_key_event", "w", %{assigns: %{ grid: grid }} = socket) do
    {:noreply, assign(socket, :grid, Life.Grids.transpose(grid, {0, -4}))}
  end

  def handle_event("window_key_event", "s", %{assigns: %{ grid: grid }} = socket) do
    {:noreply, assign(socket, :grid, Life.Grids.transpose(grid, {0, 4}))}
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

  def handle_info(:next_gen,
        %{assigns:
           %{ grid: grid, generation: generation, largest_population_ever: largest_population_ever }
        } = socket) do
    # Logger.debug "next_gen for #{inspect(grid)}}"
    next_grid = Grid.calc_next_grid(grid)
    largest_population_ever = max(largest_population_ever, MapSet.size(next_grid))
    # Logger.debug "next_gen is #{inspect(next_grid)}}"
    {:noreply,
      assign(socket,
        generation: generation + 1,
        grid: next_grid,
        largest_population_ever: largest_population_ever
    )}
  end

  def start_auto(socket) do
    %{assigns: %{timer_interval: timer_interval}} = socket
    tref = new_timer(timer_interval)
    {:noreply, assign(socket, tref: tref)}
  end

  def new_timer(timer_interval) do
    Logger.debug "new timer"
    {:ok, tref} = :timer.send_interval(timer_interval,  self(), :next_gen)
    tref
  end

  def stop_auto(socket, tref) do
    Logger.debug "stop_auto"
    :timer.cancel(tref)
    {:noreply, assign(socket, tref: nil)}
  end
end