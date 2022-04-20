defmodule ARI.HTTP.Playbacks do
  @moduledoc """
  HTTP Interface for CRUD operations on Playback objects

  REST Reference: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+Playbacks+REST+API

  Playback Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk18RESTDataModels-Playback
  """

  use ARI.HTTPClient, "/playbacks"
  alias ARI.HTTPClient.Response

  @doc """
  Get a playback's details

  ## Parameters
    id: String (UTF-8) that represents the playback's id
  """
  @spec get(String.t()) :: Response.t()
  def get(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  @doc """
  Stop a playback

  ## Parameters
    id: String (UTF-8) that represents the playback id to stop
  """
  @spec stop(String.t()) :: Response.t()
  def stop(id) do
    GenServer.call(__MODULE__, {:stop, id})
  end

  @doc """
  Control a playback

  ## Parameters
    id: String (UTF-8) that represents the playback id to stop
    payload: map of the parameters and values to pass to Asterisk
      operation: (required) Operation to perform on the playback.
        Allowed values: restart, pause, unpause, reverse, forward
  """
  @spec control(String.t(), map()) :: Response.t()
  def control(id, %{operation: _} = payload) do
    GenServer.call(__MODULE__, {:control, id, payload})
  end

  @impl true
  def handle_call({:get, id}, from, state) do
    {:noreply, request("GET", "/#{id}", from, state)}
  end

  @impl true
  def handle_call({:stop, id}, from, state) do
    {:noreply, request("DELETE", "/#{id}", from, state)}
  end

  @impl true
  def handle_call({:control, id, payload}, from, state) do
    {:noreply,
     request("POST", "/#{id}/control?#{encode_params(payload)}", from, state)}
  end
end
