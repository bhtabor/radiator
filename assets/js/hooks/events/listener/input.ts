import { getNodeByEvent } from "../../node";
import { getItemByNode, setItemDirty } from "../../item";

export function input(event: Event) {
  const node = getNodeByEvent(event);
  const item = getItemByNode(node);
  item && setItemDirty(item, true);

  this.pushEventTo(this.el, "update_node_content", node);
}
