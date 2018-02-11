defmodule DataBackup.Supervisor do
  use Supervisor

  #######
  # API #
  #######

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  #############
  # Callbacks #
  #############

  def init(_) do
    children = [
      
    ]

    opts = [
      strategy: :one_for_one,
      max_restart: 3,
      max_time: 3_600
    ]

    supervise(children, opts)
  end
end
