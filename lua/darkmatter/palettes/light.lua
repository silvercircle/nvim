local M = {}
function M.basepalette(desaturate, dlevel)
  if desaturate == true then
    return {
      orange = (dlevel == 1) and { "#3b2a1c", 215 } or { "#3b2a25", 215 },
      blue = { "#2020cc", 239 },
      purple = (dlevel == 1) and { "#b070b0", 241 } or { "#a070a0", 241 },
      teal = (dlevel == 1) and { "#105050", 238 } or { "#206060", 238 },
      brightteal = (dlevel == 1) and { "#70a0c0", 238 } or { "#7090b0", 238 },
      darkpurple = (dlevel == 1) and { "#705070", 240 } or { "#806a80", 240 },
      red = (dlevel == 1) and { "#bb4d5c", 203 } or { "#ab5d6c", 203 },
      yellow = (dlevel == 1) and { "#404000", 231 } or { "#404010", 231 },
      green = (dlevel == 1) and { "#105010", 231 } or { "#205020", 231 },
      darkyellow = (dlevel == 1) and { "#978634", 180 } or { "#877634" },
      special = {
        red = { "#aa2020", 203 },
        yellow = { "#aaaa20", 231 },
        green = { "#309020", 232 },
        blue = { "#2020cc", 239 },
        purple = { "#aa20aa", 241 },
        storage = { "#607560", 242 },
        class = { "#700050", 243 },
      }
    }
  else
    return {
      orange = { "#c36630", 215 },
      blue = { "#2020cc", 239 },
      purple = { "#c030c0", 241 },
      teal = { "#005050", 238 },
      brightteal = { "#006060", 238 },
      darkpurple = { "#803090", 240 },
      red = { "#aa2020", 203 },
      yellow = { "#cccc60", 231 },
      green = { "#107000", 232 },
      darkyellow = { "#a78624", 180 },
      special = {
        red = { "#aa2020", 203 },
        yellow = { "#cccc60", 231 },
        green = { "#107000", 232 },
        blue = { "#2020cc", 239 },
        purple = { "#c030c0", 241 },
        storage = { "#507050", 242 },
        class = { "#700050", 243 },
      }
    }
  end
end

function M.variants(variant)
    if variant == "cold" or variant == "deepblack" then
      return {
        black = { "#121215", 232 },
        bg_dim = { "#222327", 232 },
        bg0 = { "#b0b0b0", 235 },
        bg1 = { "#a0a0a0", 236 },
        bg2 = { "#363944", 236 },
        bg4 = { "#b0b0b0", 237 }
      }
    else
      return {
        black = { "#151212", 232 },
        bg_dim = { "#242020", 232 },
        bg0 = { "#b0b0b0", 235 },
        bg1 = { "#a0a0a0", 236 },
        bg2 = { "#403936", 236 },
        bg4 = { "#b0b0b0", 237 }
      }
    end
end
return M
