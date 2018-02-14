defmodule ReWeb do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use ReWeb, :controller
      use ReWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def controller do
    quote do
      use Phoenix.Controller, log: false, namespace: ReWeb

      alias Re.Repo
      import Ecto
      import Ecto.Query

      import ReWeb.{
        Gettext,
        Router.Helpers
      }
      import Bodyguard
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/re_web/templates",
        namespace: ReWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      import ReWeb.{
        ErrorHelpers,
        Gettext,
        Router.Helpers
      }
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel, log_join: false, log_handle_in: false

      alias Re.Repo
      import Ecto
      import Ecto.Query
      import ReWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
