defmodule NovenWeb.ModalComponent do
  use NovenWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="phx-modal"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target="#<%= @id %>"
      phx-page-loading>

      <div class="phx-modal-content rounded px-4 border shadow-xl bg-white">
        <div class="flex items-center justify-between">
        <div> <%=@opts[:title] || "Modal" %></div>
        <%= live_patch raw("&times;"), to: @return_to, class: "phx-modal-close" %>
        </div>
        <%= live_component @socket, @component, @opts %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
