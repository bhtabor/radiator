defmodule RadiatorWeb.OutlineLive.Index do
  use RadiatorWeb, :live_view

  alias Radiator.Accounts
  alias Radiator.Outline
  alias RadiatorWeb.Endpoint

  @topic "outline"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(@topic)
    end

    socket
    |> assign(:page_title, "Outline")
    |> assign(:bookmarklet, get_bookmarklet(Endpoint.url() <> "/api/v1/outline", socket))
    |> push_event("list", %{nodes: Outline.list_nodes()})
    |> reply(:ok)
  end

  @impl true
  def handle_event("set_focus", _node_id, socket) do
    socket
    |> reply(:noreply)
  end

  def handle_event("remove_focus", _node_id, socket) do
    socket
    |> reply(:noreply)
  end

  def handle_event("create_node", params, socket) do
    user = socket.assigns.current_user
    Outline.create_node(params, user)

    socket
    |> reply(:noreply)
  end

  def handle_event("update_node", params, socket) do
    Outline.upsert_node(params)

    socket
    |> reply(:noreply)
  end

  def handle_event("delete_node", node_id, socket) do
    node = Outline.get_node!(node_id)
    Outline.delete_node(node)

    socket
    |> reply(:noreply)
  end

  @impl true
  def handle_info({:insert, node}, socket) do
    socket
    |> push_event("insert", %{nodes: [node]})
    |> reply(:noreply)
  end

  def handle_info({:update, _node}, socket) do
    socket
    # |> push_event("update", %{nodes: [node]})
    |> reply(:noreply)
  end

  def handle_info({:delete, node}, socket) do
    socket
    |> push_event("delete", %{nodes: [node]})
    |> reply(:noreply)
  end

  defp get_bookmarklet(api_uri, socket) do
    token =
      socket.assigns.current_user
      |> Accounts.generate_user_api_token()
      |> Base.url_encode64(padding: false)

    """
    javascript:(function(){
      s=window.getSelection().toString();
      c=s!=""?s:window.location.href;
      xhr=new XMLHttpRequest();
      xhr.open('POST','#{api_uri}',true);
      xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
      xhr.send('content='+encodeURIComponent(c)+'&token=#{token}');
    })()
    """
    |> String.replace(["\n", "  "], "")
  end
end
