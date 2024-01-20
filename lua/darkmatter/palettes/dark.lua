local vivid_colors = {
  orange = { "#c36630", 215 },
  blue = { "#4a4adf", 239 },
  purple = { "#c030c0", 241 },
  teal = { "#108080", 238 },
  brightteal = { "#30a0c0", 238 },
  darkpurple = { "#803090", 240 },
  red = { "#cc2d4c", 203 },
  yellow = { "#aaaa20", 231 },
  green = { "#10801f", 232 },
  darkyellow = { "#a78624", 180 },
  grey = { "#707069", 2 },
  grey_dim = { "#595f6f", 240 },
  diff_red = { "#45292d", 52 },
  diff_green = { "#10320a", 22 },
  diff_blue = { "#253147", 17 },
  deepred = { "#8b2d3c", 203 },
  olive = { "#708422", 181 },
  lpurple = { "#b39df3", 176 },
  brown = { "#905010", 233 },
  special = {
    red = { "#cc2d4c", 203 },
    yellow = { "#cccc60", 231 },
    green = { "#10801f", 232 },
    blue = { "#6060cf", 239 },
    purple = { "#c030c0", 241 },
    storage = { "#507050", 242 },
    class = { "#804060", 243 },
  }
}

local desaturated_colors = {
  low = {
    orange = { "#ab6a6c", 215 },
    blue = { "#5a6acf", 239 },
    purple = { "#b070b0", 241 },
    teal = { "#609090", 238 },
    brightteal = { "#70a0c0", 238 },
    darkpurple = { "#705070", 240 },
    red = { "#bb4d5c", 203 },
    yellow = { "#aaaa60", 231 },
    green = { "#60906f", 231 },
    darkyellow = { "#958434", 180 },
    grey = { "#707069", 2 },
    grey_dim = { "#595f6f", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#8b2d3c", 203 },
    olive = { "#708422", 181 },
    lpurple = { "#b39df3", 176 },
    brown = { "#905010", 233 },
    special = {
      red = { "#bb4d5c", 203 },
      yellow = { "#aaaa20", 231 },
      green = { "#309020", 232 },
      blue = { "#6060cf", 239 },
      purple = { "#904090", 241 },
      storage = { "#607560", 242 },
      class = { "#905070", 243 },
    }
  },
  high = {
    orange = { "#9b7a7c", 215 },
    blue = { "#5a6acf", 239 },
    purple = { "#a070a0", 241 },
    teal = { "#709090", 238 },
    brightteal = { "#7090b0", 238 },
    darkpurple = { "#806a80", 240 },
    red = { "#ab5d6c", 203 },
    yellow = { "#909870", 231 },
    green = { "#658075", 231 },
    darkyellow = { "#877634", 180 },
    grey = { "#707069", 2 },
    grey_dim = { "#595f6f", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#8b2d3c", 203 },
    olive = { "#708422", 181 },
    lpurple = { "#b39df3", 176 },
    brown = { "#905010", 233 },
    special = {
      red = { "#bb4d5c", 203 },
      yellow = { "#aaaa20", 231 },
      green = { "#309020", 232 },
      blue = { "#6060cf", 239 },
      purple = { "#904090", 241 },
      storage = { "#607560", 242 },
      class = { "#905070", 243 },
    }
  }
}

local M = {}
function M.basepalette(desaturate, dlevel)
  if desaturate == true then
    return (dlevel == 1) and desaturated_colors.low or desaturated_colors.high
  else
    return vivid_colors
  end
end

function M.variants(variant)
    if variant == "cold" or variant == "deepblack" then
      return {
        darkred = { "#601010", 249 },
        pmenubg = { "#241a20", 156 },
        black = { "#121215", 232 },
        bg_dim = { "#222327", 232 },
        bg0 = { "#2c2e34", 235 },
        bg1 = { "#33353f", 236 },
        bg2 = { "#363944", 236 },
        bg4 = { "#414550", 237 }
      }
    else
      return {
        darkred = { "#601010", 249 },
        pmenubg = { "#241a20", 156 },
        black = { "#151212", 232 },
        bg_dim = { "#242020", 232 },
        bg0 = { "#302c2e", 235 },
        bg1 = { "#322a2a", 236 },
        bg2 = { "#403936", 236 },
        bg4 = { "#504531", 237 }
      }
    end
end
return M
