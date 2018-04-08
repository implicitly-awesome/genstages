defmodule GS.Application do
  use Application
  import Supervisor.Spec

  def start(_type, _args), do: Supervisor.start_link(children(), opts())

  defp children do
    [
      supervisor(GS.Supervisor, [])
    ]
  end

  defp opts do
    [
      strategy: :one_for_one,
      name: __MODULE__
    ]
  end
end
