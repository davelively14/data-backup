defmodule DataBackup.Server do
  use GenServer

  #######
  # API #
  #######

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def insert_data(id, data) do
    GenServer.call(__MODULE__, {:insert_data, id, data})
  end

  def get_data(id) do
    GenServer.call(__MODULE__, {:get_data, id})
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  #############
  # Callbacks #
  #############

  def init(_) do
    {:ok, %{ets: DataBackup.DataMaster.get_ets}}
  end

  def handle_call({:insert_data, id, data}, _from, state) do
    :ets.insert(state.ets, {id, data})
    {:reply, :ok, state}
  end

  def handle_call({:get_data, id}, _from, state) do
    record =
      state.ets
      |> :ets.lookup(id)
      |> List.first
    {:reply, record, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  # Does nothing on ETS transfer
  def handle_info({:"ETS-TRANSFER", _, _, _}, state) do
    {:noreply, state}
  end
end
