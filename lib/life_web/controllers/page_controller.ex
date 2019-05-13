defmodule LifeWeb.PageController do
  use LifeWeb, :controller
  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, LifeWeb.GridView, session: %{})
  end
end
