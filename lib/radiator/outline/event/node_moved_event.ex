defmodule Radiator.Outline.Event.NodeMovedEvent do
  @moduledoc false
  defstruct [
    :event_id,
    :node,
    :user_id,
    :old_prev,
    :old_next,
    :next,
    :episode_id,
    :children
  ]
end
