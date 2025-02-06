import { BarWidget } from "./bar-widget.js";
import { StatusIndicators } from "./widgets/status-indicators.js";
import { Time } from "./widgets/time.js";
import { Workspaces } from "./widgets/workspaces.js";
import { config } from "lib/settings.js";

export const Bar = (monitor: number) =>
  Widget.Window({
    monitor,
    name: `bar${monitor}`,
    className: "bar",
    anchor: config.vertical ? ["left", "top", "bottom"] : ["top", "left", "right"],
    exclusivity: "exclusive",
    layer: "top",
    child: Widget.CenterBox({
      vertical: config.vertical ?? false,
      start_widget: Widget.Box({
        hpack: config.vertical ? "center" : "start",
        vpack: config.vertical ? "start" : "center",
        children: [Workspaces(monitor)],
      }),
      center_widget: Widget.Box({
        hpack: "center",
        vpack: "center",
        children: [Time()],
      }),
      end_widget: Widget.Box({
        hpack: config.vertical ? "center" : "end",
        vpack: config.vertical ? "end" : "center",
        children: [StatusIndicators()],
      }),
    }),
  });
