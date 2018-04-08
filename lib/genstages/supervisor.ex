defmodule GS.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok), do: supervise(children(), opts())

  defp children do
    [
      supervisor(
        GS.ConsumersSupervisor,
        [],
        restart: :permanent
      ),
      worker(
        GS.EventsPushing.Producer,
        [],
        restart: :permanent,
        name: GS.EventsPushing.Producer
      ),
      # worker(
      #   GS.DemandHandling.Producer,
      #   [],
      #   restart: :permanent,
      #   name: GS.DemandHandling.Producer
      # )
    ]
  end

  defp opts do
    [
      strategy: :one_for_one,
      name: __MODULE__
    ]
  end
end