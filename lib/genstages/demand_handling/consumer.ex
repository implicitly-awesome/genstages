defmodule GS.DemandHandling.Consumer do
  defmodule State do
    @type t :: %__MODULE__{producer: pid() | atom(), subscription: pid() | atom()}

    defstruct ~w(producer subscription)a
  end

  use GenStage

  require Logger

  @min_demand 1 # default is 500
  @max_demand 4 # default is 1000

  def start_link, do: start_link([])
  def start_link(_), do: GenStage.start_link(__MODULE__, :ok)

  def init(:ok) do
    state = %State{producer: GS.DemandHandling.Producer}

    GenStage.async_subscribe(
      self(),
      to: state.producer,
      min_demand: @min_demand,
      max_demand: @max_demand
    )

    {:consumer, state}
  end

  def handle_subscribe(:producer, _opts, from, state) do
    # send(self(), :init_ask)

    # {:manual, Map.put(state, :subscription, from)}
    {:automatic, Map.put(state, :subscription, from)}
  end

  def handle_info(:init_ask, %State{subscription: subscription} = state) do
    GenStage.ask(subscription, @max_demand)

    {:noreply, [], state}
  end
  def handle_info(_, state), do: {:noreply, [], state}

  def handle_events(events, _from, %State{subscription: subscription} = state)
      when is_list(events)
  do
    Enum.each(events, fn(_event) ->
      :timer.sleep(500)

      Logger.info("#{inspect(self())} handled an event")
    end)

    # GenStage.ask(subscription, @max_demand)

    {:noreply, [], state}
  end
  def handle_events(_events, _from, state), do: {:noreply, [], state}
end