--
-- enhance fnutils
--
fnutils = require("hs.fnutils")
fnutils.foldLeft = function (tbl, func, val)
  for _, v in pairs(tbl) do
    val = func(val, v)
  end
  return val
end

fnutils.keys = function (tbl)
  local keys = {}
  for k, _ in pairs(tbl) do
    table.insert(keys, k)
  end
  return keys
end

--
-- require
--
keymaps = require("keymaps")

monitor = require("monitor")
monitor.start()

