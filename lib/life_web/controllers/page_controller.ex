defmodule LifeWeb.PageController do
  use LifeWeb, :controller
  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, LifeWeb.GridView, session: %{})
#    render(conn, "index.html")
#    LiveView.Controller.live_render(conn, "index.html", session: %{})
  end
end
