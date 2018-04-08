defmodule GS.EventsPushing.Producer do
  use GenStage

  require Logger

  alias GS.ConsumersSupervisor

  @buffer_size 8 # default is 10_000
  @consumers_count 2

  def start_link do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    send(self(), :init)

    {:producer, [], buffer_size: @buffer_size}
  end

  def handle_info(:init, state) do
    Enum.each(1..@consumers_count, fn(_) ->
      ConsumersSupervisor.start_consumer(GS.EventsPushing.Consumer)
    end)

    {:noreply, [], state}
  end
  def handle_info(_, state), do: {:noreply, [], state}

  def add(events), do: GenServer.cast(__MODULE__, {:add, events})

  def handle_cast({:add, events}, state) when is_list(events) do
    {:noreply, events, state}
  end
  def handle_cast({:add, events}, state), do: {:noreply, [events], state}

  def handle_demand(_, state), do: {:noreply, [], state}
end