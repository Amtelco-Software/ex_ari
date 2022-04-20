defmodule ARI.HTTP.Events do
  @moduledoc """
  HTTP Interface for CRUD operations on Event objects

  There is only one function in this module to create a user event. All incoming events are handled by the `ARI.WebSocket` module

  REST Reference: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+Events+REST+API

  Messages: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk18RESTDataModels-Message
  """
  use ARI.HTTPClient, "/events"
  alias ARI.HTTPClient.Response

  @doc """
  WebSocket connection for events

  ## Parameters
    payload: map of the parameters and values to pass to Asterisk
      app: (required) Applications to subscribe to,
        Allows comma seperated values
      subscribeAll: Subscribe to all Asterisk events.
        If provided, the applications listed will be subscribed to all events, effectively disabling the application specific subscriptions. Default is 'false'
        Allowed values: 'false', 'true'
  """
  @spec event_websocket(map()) :: Response.t()
  def event_websocket(%{app: _} = payload) do
    GenServer.call(__MODULE__, {:event_websocket, payload})
  end

  @doc """
  Generate a user event

  ## Parameters
    name: Event name
    payload: map of the parameters and values to pass to Asterisk
      application: (required) The name of the Stasis Application that will receive this event
      source: URI for event source (channel:{channelId}, bridge:{bridgeId}, endpoint:{tech}/{resource}, deviceState:{deviceName})
        Allows comma seperated values
    variables: map - The "variables" key in the body object holds custom key/value pairs to add to the user event
      Ex. { "variables": { "key": "value" } }
  """
  @spec create(String.t(), map(), map()) :: Response.t()
  def create(name, %{application: _} = payload, variables \\ %{variables: %{}}) do
    GenServer.call(__MODULE__, {:create, name, payload, variables})
  end

  @impl true
  def handle_call({:event_websocket, payload}, from, state) do
    {:noreply,
     request("GET", "?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:create, name, payload, variables}, from, state) do
    {:noreply,
     request("POST", "/user/#{name}?#{encode_params(payload)}", from, state, variables)}
  end
end
