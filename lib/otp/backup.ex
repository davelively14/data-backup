defmodule DataBackup.Backup do
  use GenServer

  #######
  # API #
  #######

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def restore do
    GenServer.call(__MODULE__, :restore)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  #############
  # Callbacks #
  #############

  def init(_) do
    {:ok, nil}
  end

  def handle_info({:"ETS-TRANSFER", table_name, origin, _gift_data}, _state) do
    {:noreply, %{origin: origin, table_name: table_name}}
  end

  def handle_call(:restore, _from, nil), do: {:reply, nil, nil}
  def handle_call(:restore, _from, %{origin: origin, table_name: table_name}) do
    :ets.give_away(table_name, origin, nil)
    {:reply, table_name, nil}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
