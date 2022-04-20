defmodule ARI.HTTP.Applications do
  @moduledoc """
  HTTP Interface for CRUD operations on Application objects

  REST Reference: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+Applications+REST+API

  Application Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk18RESTDataModels-Application
  """
  use ARI.HTTPClient, "/applications"
  alias ARI.HTTPClient.Response

  @doc """
  Retrieve list of Stasis applications in Asterisk
  """
  @spec list :: Response.t()
  def list do
    GenServer.call(__MODULE__, :list)
  end

  @doc """
  Get details of a Stasis application.

  ## Parameters
    name: String (UTF-8) that represents the application's name to retrieve details for
  """
  @spec get(String.t()) :: Response.t()
  def get(name) do
    GenServer.call(__MODULE__, {:get, name})
  end

  @doc """
  Subscribe an application to a event source. Returns the state of the application after the subscriptions have changed.

  ## Parameters
    name: String (UTF-8) that represents the application's name to retrieve details for
    payload:
      eventSource: (required) URI for event source (channel:{channelId}, bridge:{bridgeId}, endpoint:{tech}[/{resource}], deviceState:{deviceName}
        Allows comma separated values.
  """
  @spec subscribe(String.t(), map()) :: Response.t()
  def subscribe(name, %{eventSource: _} = payload) do
    GenServer.call(__MODULE__, {:subscribe, name, payload})
  end

  @doc """
  Unsubscribe an application from an event source. Returns the state of the application after the subscriptions have changed.

  ## Parameters
    name: String (UTF-8) that represents the application's name to retrieve details for
    payload:
      eventSource: (required) URI for event source (channel:{channelId}, bridge:{bridgeId}, endpoint:{tech}[/{resource}], deviceState:{deviceName}
        Allows comma separated values.
  """
  @spec unsubscribe(String.t(), map()) :: Response.t()
  def unsubscribe(name, %{eventSource: _} = payload) do
    GenServer.call(__MODULE__, {:unsubscribe, name, payload})
  end

  @impl true
  def handle_call(:list, from, state) do
    {:noreply, request("GET", "", from, state)}
  end

  @impl true
  def handle_call({:get, name}, from, state) do
    {:noreply, request("GET", "/#{name}", from, state)}
  end

  @impl true
  def handle_call({:subscribe, name, payload}, from, state) do
    {:noreply, request("POST", "/#{name}/subscription?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:unsubscribe, name, payload}, from, state) do
    {:noreply, request("DELETE", "/#{name}/subscription?#{encode_params(payload)}", from, state)}
  end
end
