defmodule GS.DemandHandling.Producer do
  use GenStage

  require Logger

  alias GS.ConsumersSupervisor

  @buffer_size 8 # default is 10_000
  @consumers_count 1

  def start_link do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    state = %{events: [], demand: 0}

    send(self(), :init)

    {:producer, state, buffer_size: @buffer_size}
  end

  def handle_info(:init, state) do
    Enum.each(1..@consumers_count, fn(_) ->
      ConsumersSupervisor.start_consumer(GS.DemandHandling.Consumer)
    end)

    {:noreply, [], state}
  end
  def handle_info(_, state), do: {:noreply, [], state}

  def handle_demand(incoming_demand, %{demand: demand} = state) do
    new_state = Map.put(state, :demand, demand + incoming_demand)

    dispatch_events(new_state)
  end

  defp dispatch_events(%{events: events, demand: demand} = state)
       when length(events) >= demand
  do
    Logger.info("#{length(events)} events in the buffer")
    Logger.info("demand of #{demand} received")

    {events_to_dispatch, remaining_events} = Enum.split(events, demand)

    Logger.info("#{length(events_to_dispatch)} events were prepared")

    new_state =
      state
      |> Map.put(:demand, 0)
      |> Map.put(:events, remaining_events)

    {:noreply, events_to_dispatch, new_state}
  end
  defp dispatch_events(%{events: events, demand: demand} = state)
       when length(events) < demand
  do
    events = events ++ fetch_events(demand)

    state
    |> Map.put(:demand, demand)
    |> Map.put(:events, events)
    |> dispatch_events()
  end

  defp fetch_events(demand) do
    events = List.duplicate("this is my event", demand)

    Logger.info("#{length(events)} events were fetched")

    events
  end
end