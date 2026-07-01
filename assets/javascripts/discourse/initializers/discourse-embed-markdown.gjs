import { withPluginApi } from "discourse/lib/plugin-api";

const PLUGIN_ID = "discourse-embed-markdown";

export default {
  name: "discourse-embed-markdown",

  initialize() {
    withPluginApi((api) => {
      api.setAdminPluginIcon(PLUGIN_ID, "fab-markdown");
    });
  },
};
