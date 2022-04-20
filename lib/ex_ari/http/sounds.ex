defmodule ARI.HTTP.Sounds do
  @moduledoc """
  HTTP Interface for CRUD operations on Sound objects

  REST Reference: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+Sounds+REST+API

  Sound Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk18RESTDataModels-Sound
  """

  use ARI.HTTPClient, "/sounds"
  alias ARI.HTTPClient.Response

  @doc """
  Get a list of all sounds

  ## Parameters
    payload: map of the parameters and values to pass to Asterisk
      lang: Lookup sound for a specific language
      format: Lookup sound for a specific format
  """
  @spec list(map()) :: Response.t()
  def list(payload \\ %{}) do
    GenServer.call(__MODULE__, {:list, payload})
  end

  @doc """
  Get sound's details

  ## Parameters
    id: String (UTF-8) that represents the sound's id
  """
  @spec get(String.t()) :: Response.t()
  def get(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  @impl true
  def handle_call({:list, payload}, from, state) do
    {:noreply, request("GET", "?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:get, id}, from, state) do
    {:noreply, request("GET", "/#{id}", from, state)}
  end
end
