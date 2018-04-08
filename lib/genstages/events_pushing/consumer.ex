defmodule GS.EventsPushing.Consumer do
  defmodule State do
    @type t :: %__MODULE__{producer: pid() | atom()}

    defstruct ~w(producer)a
  end

  use GenStage

  require Logger

  @max_demand 4 # default is 1000

  def start_link, do: start_link([])
  def start_link(_), do: GenStage.start_link(__MODULE__, :ok)

  def init(:ok) do
    state = %State{producer: GS.EventsPushing.Producer}
    # {:global, GS.EventsPushing.Producer}
    # {:via, Registry, {MyRegistry, GS.EventsPushing.Producer}}

    opts = [max_demand: @max_demand]

    {:consumer, state, subscribe_to: [{state.producer, opts}]}
  end

  def handle_info(_, state), do: {:noreply, [], state}

  def handle_events(events, _from, state) when is_list(events) do
    Enum.each(events, fn(_event) ->
      :timer.sleep(500)

      Logger.info("#{inspect(self())} handled an event")
    end)

    {:noreply, [], state}
  end
  def handle_events(_events, _from, state), do: {:noreply, [], state}
end