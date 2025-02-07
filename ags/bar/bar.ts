import { BarWidget } from "./bar-widget.js";
import { StatusIndicators } from "./widgets/status-indicators.js";
import { Time } from "./widgets/time.js";
import { Workspaces } from "./widgets/workspaces.js";
import { SystemTrayWidget } from "./widgets/tray.js";
import { config } from "lib/settings.js";

export const Bar = (monitor: number) =>
  Widget.Window({
    monitor,
    name: `bar${monitor}`,
    className: `bar${config.vertical ? " vertical" : ""}`,
    anchor: config.vertical ? ["left", "top", "bottom"] : ["top", "left", "right"],
    exclusivity: "exclusive",
    layer: "top",
    child: Widget.CenterBox({
      vertical: config.vertical ?? false,
      start_widget: Widget.Box({
        vertical: config.vertical ?? false,
        hpack: config.vertical ? "center" : "start",
        vpack: config.vertical ? "start" : "center",
        children: [Workspaces(monitor)],
      }),
      center_widget: Widget.Box({
        vertical: config.vertical ?? false,
        hpack: "center",
        vpack: "center",
        children: [Time()],
      }),
      end_widget: Widget.Box({
        vertical: config.vertical ?? false,
        hpack: config.vertical ? "center" : "end",
        vpack: config.vertical ? "end" : "center",
        children: [SystemTrayWidget(), StatusIndicators()],
      }),
    }),
  });
