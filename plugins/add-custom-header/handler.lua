local AddHeader = {}

AddHeader.VERSION = "1.0.0"
AddHeader.PRIORITY = 1000

function AddHeader:new()
  return setmetatable({}, { __index = self })
end

function AddHeader:access(conf)
  kong.service.request.add_header(conf.header_name, conf.header_value)
end

return AddHeader
