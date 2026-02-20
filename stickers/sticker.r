library(hexSticker)
library(ggplot2)

# Criar um plot simples para usar como subplot
p <- ggplot() +
  geom_point(aes(x = 1:10, y = runif(10)), color = "orange", size = 3) +
  theme_void() +
  theme(plot.background = element_rect(fill = "transparent", color = NA))

# Criar o sticker
sticker(
  subplot = p,
  package = "queimadasR",
  p_color = "white",
  p_size = 18,
  s_x = 1,
  s_y = 0.8,
  s_width = 1.2,
  s_height = 0.8,
  h_fill = "#0B3D2E",  # verde escuro
  h_color = "#1E6F4C",  # verde médio
  filename = "queimadasR_hex.png"
)
