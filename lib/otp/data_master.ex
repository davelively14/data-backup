defmodule DataBackup.DataMaster do
  use GenServer

  @table_name :data

  #######
  # API #
  #######

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_ets do
    GenServer.call(__MODULE__, :get_ets)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  #############
  # Callbacks #
  #############

  def init(_) do
    :ets.new(@table_name, [:set, :protected, :named_table, {:heir, self(), nil}])

    {:ok, %{ets: @table_name}}
  end

  def handle_info({:"ETS-TRANSFER", @table_name, _origin, _gift_data}, _state) do
    {:noreply, %{ets: @table_name}}
  end

  def handle_info({:"ETS-TRANSFER", table_name, _, _}, state) do
    :ets.delete(table_name)
    {:noreply, state}
  end

  def handle_call(:get_ets, _from, nil), do: {:reply, nil, nil}
  def handle_call(:get_ets, {pid, _ref}, %{ets: ets}) do
    :ets.give_away(ets, pid, nil)
    {:reply, ets, nil}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
