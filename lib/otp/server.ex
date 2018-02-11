defmodule DataBackup.Server do
  use GenServer

  @ets_name :data

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

  #############
  # Callbacks #
  #############

  def init(_) do
    unless DataBackup.Backup.restore do
      :ets.new(@ets_name, [:set, :protected, :named_table])
    end
    {:ok, %{ets: @ets_name}}
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

  # Does nothing on ETS transfer
  def handle_info({:"ETS-TRANSFER", _, _, _}, state) do
    {:noreply, state}
  end
end
