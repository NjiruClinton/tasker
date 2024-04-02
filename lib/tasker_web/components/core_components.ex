defmodule TaskerWeb.CoreComponents do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  attr :flash, :map, required: true

  def flash_group(assigns) do
    ~H"""
    <div class="flash-group">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
    </div>
    """
  end

  attr :kind, :atom, values: [:info, :error], required: true
  attr :flash, :map, required: true

  def flash(assigns) do
    ~H"""
    <div :if={msg = Phoenix.Flash.get(@flash, @kind)} class={["flash", Atom.to_string(@kind)]}>
      <p><%= msg %></p>
    </div>
    """
  end

  attr :for, :any, required: true
  attr :as, :any, default: nil
  slot :inner_block, required: true
  attr :rest, :global, include: ~w(autocomplete name rel action enctype method novalidate target multipart)

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="stack">
        <%= render_slot(@inner_block, f) %>
      </div>
    </.form>
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, required: true
  attr :type, :string, default: "text"
  attr :rest, :global

  def input(assigns) do
    ~H"""
    <div class="field">
      <label for={@field.id}><%= @label %></label>
      <input class="input" type={@type} id={@field.id} name={@field.name} value={Phoenix.HTML.Form.normalize_value(@type, @field.value)} {@rest} />
      <p :for={msg <- Enum.map(@field.errors, &translate_error(&1))} class="text-sm text-red-700"><%= msg %></p>
    </div>
    """
  end

  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil
  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def link_button(assigns) do
    ~H"""
    <.link :if={@navigate} navigate={@navigate} class={["button", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </.link>
    <.link :if={@patch} patch={@patch} class={["button", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      transition: {"transition-all ease-in duration-200", "opacity-100", "opacity-0"}
    )
  end

  def translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
