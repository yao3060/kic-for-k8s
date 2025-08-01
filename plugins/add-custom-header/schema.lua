local typedefs = require "kong.db.schema.typedefs"
local PLUGIN_NAME = "add-custom-header"

return {
  name = PLUGIN_NAME,
  fields = {
    { config = {
        type = "record",
        fields = {
          { header_name = typedefs.header_name{ default = "X-Custom-Header" } },
          { header_value = { type = "string", default = "HelloWorld" } },
        },
    }},
  },
}
