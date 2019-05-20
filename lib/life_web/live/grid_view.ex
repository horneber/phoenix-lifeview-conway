defmodule LifeWeb.GridView do
  use Phoenix.LiveView
  require Logger
  alias Life.Grid


  def render(assigns) do
    LifeWeb.PageView.render("grid_view.html", assigns)
  end

  @default_timer_interval 250
  @default_quadrant_size 60
  def mount(_session, socket) do
    Logger.debug "Mounting!"
    grid = Life.Grids.interesting_starter(@default_quadrant_size)
    if connected?(socket), do: Logger.debug "Connected."
    {
      :ok,
      assign(
        socket,
        generation: 0,
        grid: grid,
        tref: nil,
        quadrant_size: @default_quadrant_size,
        timer_interval: @default_timer_interval,
        edit?: false,
        largest_population_ever: MapSet.size(grid),
        x_origin: 0,
        y_origin: 0,
      )
    }
  end

  def handle_event("toggle", value, socket) do
    {x, "," <> rest} = Integer.parse(value)
    {y, _} = Integer.parse(rest)
    grid = Life.Grids.toggle_cell(socket.assigns.grid, {x, y})
    {:noreply, assign(socket, grid: grid)}
  end

  def handle_event("stop_editing", _value, socket)  do
    {:noreply, assign(socket, edit?: false)}
  end

  def handle_event("start_editing", _value, socket)  do
    {:noreply, assign(socket, edit?: true)}
  end

  def handle_event("start_auto", _value, socket)  do
    if socket.assigns.tref do
      {:noreply, socket}
    else
      start_auto(socket)
    end
  end

  def handle_event("zoom", %{"controls" => controls}, socket) do
    Logger.debug "zoom #{inspect(controls)}"
    quadrant_size = parse_quadrant_size(controls)
    {:noreply, assign(socket, quadrant_size: quadrant_size)}
  end

  def handle_event("speed", %{"controls" => controls}, socket) do
    Logger.debug "speed #{inspect(controls)}"
    timer_interval = parse_timer_interval(controls)
    Logger.debug("new timer #{inspect(timer_interval)}}")
    tref = socket.assigns.tref
    if tref do
      Logger.debug("On the fly new timer.")
      :timer.cancel(tref)
      tref = new_timer(timer_interval)
      {:noreply, assign(socket, timer_interval: timer_interval, tref: tref)}
    else
      {:noreply, assign(socket, timer_interval: timer_interval)}
    end
  end


  def handle_event("stop_auto", _value, socket) do
    if socket.assigns.tref do
      stop_auto(socket, socket.assigns.tref)
    else
      {:noreply, socket}
    end
  end

  def handle_event("next_gen", _value, socket) do
    handle_info(:next_gen, socket)
  end

  def handle_event("log", %{"controls" => controls}, socket) do
    Logger.debug inspect(controls)
    {:noreply, socket}
  end

  def handle_event("←", _value, socket) do
    delta = quadrant_size_normalized_movement_speed(socket.assigns.quadrant_size)
    {:noreply, assign(socket, :x_origin, socket.assigns.x_origin + delta)}
  end
  def handle_event("→", _value, socket) do
    delta = quadrant_size_normalized_movement_speed(socket.assigns.quadrant_size)
    {:noreply, assign(socket, :x_origin, socket.assigns.x_origin - delta)}
  end
  def handle_event("↑", _value, socket) do
    delta = quadrant_size_normalized_movement_speed(socket.assigns.quadrant_size)
    {:noreply, assign(socket, :y_origin, socket.assigns.y_origin + delta)}
  end
  def handle_event("↓", _value, socket) do
    delta = quadrant_size_normalized_movement_speed(socket.assigns.quadrant_size)
    {:noreply, assign(socket, :y_origin, socket.assigns.y_origin - delta)}
  end


  def handle_event("window_key_event", " ", socket) do
    if socket.assigns.tref do
      stop_auto(socket, socket.assigns.tref)
    else
      start_auto(socket)
    end
  end

  def handle_event("window_key_event", "ArrowUp", socket) do
    {:noreply, assign(socket, :y_origin, socket.assigns.y_origin + 1)}
  end

  def handle_event("window_key_event", "ArrowDown", socket) do
    {:noreply, assign(socket, :y_origin, socket.assigns.y_origin - 1)}
  end

  def handle_event("window_key_event", "ArrowLeft", socket) do
    {:noreply, assign(socket, :x_origin, socket.assigns.x_origin + 1)}
  end

  def handle_event("window_key_event", "ArrowRight", socket) do
    {:noreply, assign(socket, :x_origin, socket.assigns.x_origin - 1)}
  end

  def handle_event("window_key_event", "w", socket) do
    {:noreply, assign(socket, :y_origin, socket.assigns.y_origin + 4)}
  end

  def handle_event("window_key_event", "s", socket) do
    {:noreply, assign(socket, :y_origin, socket.assigns.y_origin - 4)}
  end

  def handle_event("window_key_event", "a", socket) do
    {:noreply, assign(socket, :x_origin, socket.assigns.x_origin + 4)}
  end

  def handle_event("window_key_event", "d", socket) do
    {:noreply, assign(socket, :x_origin, socket.assigns.x_origin - 4)}
  end

  def handle_event("window_key_event", any_other_key, socket) do
    Logger.debug "unhandled key: #{inspect(any_other_key)}"
    {:noreply, socket}
  end

  def handle_info(:next_gen, socket) do
    # Logger.debug "next_gen for #{inspect(grid)}}"
    next_grid = Grid.calc_next_grid(socket.assigns.grid)
    largest_population_ever = max(socket.assigns.largest_population_ever, MapSet.size(next_grid))
    # Logger.debug "next_gen is #{inspect(next_grid)}}"
    {
      :noreply,
      assign(socket, generation: socket.assigns.generation + 1, grid: next_grid, largest_population_ever: largest_population_ever)
    }
  end

  def start_auto(socket) do
    tref = new_timer(socket.assigns.timer_interval)
    {:noreply, assign(socket, tref: tref)}
  end

  def new_timer(timer_interval) do
    Logger.debug "new timer"
    {:ok, tref} = :timer.send_interval(timer_interval, self(), :next_gen)
    tref
  end

  def stop_auto(socket, tref) do
    Logger.debug "stop_auto"
    :timer.cancel(tref)
    {:noreply, assign(socket, tref: nil)}
  end



  def parse_quadrant_size(controls) do
    case Integer.parse(controls["quadrant_size"]) do
      {quadrant_size, _} -> quadrant_size
      :error -> @default_quadrant_size
    end
  end



  @minimum_interval 100
  def parse_timer_interval(controls) do
    case Integer.parse(controls["timer_interval"]) do
      {timer_interval, _} -> max(timer_interval, @minimum_interval)
      :error -> @default_timer_interval
    end
  end

  def assign_speed_change(socket, timer_interval) do
    tref = socket.assigns.tref
    if tref do
      Logger.debug("On the fly new timer.")
      :timer.cancel(tref)
      tref = new_timer(timer_interval)
      assign(socket, timer_interval: timer_interval, tref: tref)
    else
      assign(socket, timer_interval: timer_interval)
    end
  end

  def quadrant_size_normalized_movement_speed(quadrant_size) do
    trunc :math.log2(quadrant_size) + 1
  end
end