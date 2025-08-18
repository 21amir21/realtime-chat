defmodule RealtimeChatWeb.PageController do
  use RealtimeChatWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
