import { BarWidget } from "../bar-widget.js"; // Import BarWidget
import { config } from "lib/settings.js";
const systemtray = await Service.import("systemtray");

/**
 * Creates a button for a system tray item.
 * @param {import('types/service/systemtray').TrayItem} item - The system tray item.
 * @returns {Widget.Button} - A button widget for the tray item.
 */
const SysTrayItem = (item) =>
  BarWidget({
    child: Widget.Icon({
      icon: item.bind("icon"),
      className: "systrayitem",
    }),
    tooltipMarkup: item.bind("tooltip_markup"),
    onPrimaryClick: (_, event) => item.activate(event),
    onSecondaryClick: (_, event) => item.openMenu(event),
  });

/**
 * The system tray widget.
 */
export const SystemTrayWidget = () =>
  Widget.Box({
    vertical: config.vertical ?? false,
    children: systemtray.bind("items").as((items) => items.map(SysTrayItem)),
  });

