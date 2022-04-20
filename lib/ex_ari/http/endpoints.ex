defmodule ARI.HTTP.Endpoints do
  @moduledoc """
  HTTP Interface for CRUD operations on Endpoint objects

  REST Reference: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+Endpoints+REST+API

  Endpoint Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk18RESTDataModels-Endpoint
  """
  use ARI.HTTPClient, "/endpoints"
  alias ARI.HTTPClient.Response

  @doc """
  Retrieve list of all endpoints
  """
  @spec list :: Response.t()
  def list do
    GenServer.call(__MODULE__, :list)
  end

  @doc """
  List available endpoints for a given endpoint technology

  ## Parameters
    tech: String (UTF-8) that represents the technology of the endpoints (sip, iax2, pjsip, ...)
  """
  @spec list_by_tech(String.t()) :: Response.t()
  def list_by_tech(tech) do
    GenServer.call(__MODULE__, {:list, tech})
  end

  @doc """
  Details for an endpoint

  ## Parameters
    tech: String (UTF-8) that represents the technology of the endpoint (sip, iax2, pjsip, ...)
    id: String (UTF-8) that represents the ID of the endpoint
  """
  @spec get(String.t(), String.t()) :: Response.t()
  def get(tech, id) do
    GenServer.call(__MODULE__, {:get, tech, id})
  end

  @doc """
  Send a message to some technology URI or endpoint

  ## Parameters
    payload:
      to: (required) The endpoint resource or technology specific URI to send the message to. Valid resources are sip, pjsip, and xmpp.
      from: (required) The endpoint resource or technology specific identity to send this message from. Valid resources are sip, pjsip, and xmpp.
      body: The body of the message
    variables:
      containers
  """
  @spec send_message(map(), %{variables: %{}}) ::
          Response.t()
  def send_message(%{to: _, from: _} = payload, variables \\ %{variables: %{}}) do
    GenServer.call(__MODULE__, {:send_message, payload, variables})
  end

  @doc """
  Send a message to some endpoint in a technology.

  ## Parameters
    tech: String (UTF-8) that represents the technology of the endpoint (sip, iax2, pjsip, ...)
    id: String (UTF-8) that represents the ID of the endpoint
    payload:
      from: (required) The endpoint resource or technology specific identity to send this message from. Valid resources are sip, pjsip, and xmpp.
      body: The body of the message
    variables:
      containers
  """
  @spec send_message_to_endpoint(String.t(), String.t(), map(), %{variables: %{}}) ::
          Response.t()
  def send_message_to_endpoint(tech, id, %{from: _} = payload, variables \\ %{variables: %{}}) do
    GenServer.call(__MODULE__, {:send_message_to_endpoint, tech, id, payload, variables})
  end

  @impl true
  def handle_call(:list, from, state) do
    {:noreply, request("GET", "", from, state)}
  end

  @impl true
  def handle_call({:list, tech}, from, state) do
    {:noreply, request("GET", "/#{tech}", from, state)}
  end

  @impl true
  def handle_call({:get, tech, id}, from, state) do
    {:noreply, request("GET", "/#{tech}/#{id}", from, state)}
  end

  @impl true
  def handle_call({:send_message, payload, variables}, from, state) do
    {:noreply,
     request(
       "PUT",
       "/sendMessage?#{encode_params(payload)}",
       from,
       state,
       variables
     )}
  end

  @impl true
  def handle_call({:send_message_to_endpoint, tech, id, payload, variables}, from, state) do
    {:noreply,
     request(
       "PUT",
       "/#{tech}/#{id}/sendMessage?#{encode_params(payload)}",
       from,
       state,
       variables
     )}
  end
end
