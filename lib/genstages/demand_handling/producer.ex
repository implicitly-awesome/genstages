defmodule GS.DemandHandling.Producer do
  defmodule State do
    @type t :: %__MODULE__{events: list()}

    defstruct [events: []]
  end

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

    {:producer, %State{events: []}, buffer_size: @buffer_size}
    # {:producer, %State{events: fetch_events(@buffer_size)}, buffer_size: @buffer_size}
  end

  def handle_info(:init, state) do
    Enum.each(1..@consumers_count, fn(_) ->
      ConsumersSupervisor.start_consumer(GS.DemandHandling.Consumer)
    end)

    {:noreply, [:sadf], state}
  end
  def handle_info(_, state), do: {:noreply, [], state}

  def handle_demand(demand, %State{events: events} = state)
      when demand <= length(events)
  do
    dispatch_events(events, demand, state)
  end
  def handle_demand(demand, %State{events: events} = state) do
    events = fetch_events(demand) ++ events

    dispatch_events(events, demand, state)
  end

  defp fetch_events(count), do: List.duplicate(:event, count)

  defp dispatch_events(events, demand, state) do
    Logger.info("demand of #{demand} received")

    {to_dispatch, remaining} = Enum.split(events, demand)

    Logger.info("#{length(to_dispatch)} events were prepared")

    {:noreply, to_dispatch, Map.put(state, :events, remaining)}
  end
end