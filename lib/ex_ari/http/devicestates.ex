defmodule ARI.HTTP.Devicestates do
  @moduledoc """
  HTTP Interface for CRUD operations on Devicestate objects

  REST Reference: https://wiki.asterisk.org/wiki/display/AST/Asterisk+16+Devicestates+REST+API

  Devicestate Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+16+REST+Data+Models#Asterisk16RESTDataModels-DeviceState
  """

  alias ARI.HTTPClient.Response
  use ARI.HTTPClient, "/deviceStates"

  @doc """
  Retrieve list of ARI controlled device states
  """
  @spec list :: Response.t()
  def list do
    GenServer.call(__MODULE__, :list)
  end

  @doc """
  Retrieve the current state of a device

  ## Parameters
    name: String (UTF-8) that represents the name of the device
  """
  @spec get(String.t()) :: Response.t()
  def get(name) do
    GenServer.call(__MODULE__, {:get, name})
  end

  @doc """
  Change the current state of a device controlled by ARI

  ## Parameters
    name: String (UTF-8) that represents the name of the device
    payload: map of the parameters and values to pass to Asterisk
      deviceState: (required) Device state value
        Allowed values: NOT_INUSE, INUSE, BUSY, INVALID, UNAVAILABLE, RINGING, RINGINUSE, ONHOLD
  """
  @spec update(String.t(), map()) :: Response.t()
  def update(name, %{deviceState: _} = payload) do
    GenServer.call(__MODULE__, {:update, name, payload})
  end

  @doc """
  Destroy a device-state controlled by ARI

  ## Parameters
    name: String (UTF-8) that represents the name of the device
  """
  @spec delete(String.t()) :: Response.t()
  def delete(name) do
    GenServer.call(__MODULE__, {:delete, name})
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
  def handle_call({:update, name, payload}, from, state) do
    {:noreply,
     request("PUT", "/#{name}?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:delete, name}, from, state) do
    {:noreply, request("DELETE", "/#{name}", from, state)}
  end
end
