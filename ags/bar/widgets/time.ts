import { BarWidget } from "../bar-widget.js";
import { config } from "lib/settings.js";

const time = Variable("", {
  // TODO: Format date in program.
  poll: config.vertical ? [1000, 'date +"%-d %b %H:%M"'] : [1000, 'date +"%H\n%M"'],
});

export const Time = () =>
  BarWidget({
    child: Widget.Label({
      className: "time",
      label: time.bind(),
      justify: 2,
    }),
    onClicked: () => Utils.execAsync("swaync-client -t"),
  });
