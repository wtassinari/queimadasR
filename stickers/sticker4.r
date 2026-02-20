library(hexSticker)
library(ggplot2)

# Coordenadas aproximadas do Brasil
brasil_coords <- data.frame(
  x = c(0.25, 0.45, 0.75, 0.85, 0.75, 0.55, 0.35, 0.20, 0.15, 0.25),
  y = c(0.20, 0.25, 0.30, 0.50, 0.75, 0.85, 0.80, 0.70, 0.45, 0.20)
)

# Pontos de fogo concentrados em algumas regiões (Amazônia, Cerrado)
set.seed(789)
focos_amazonia <- data.frame(
  x = runif(12, 0.25, 0.50),
  y = runif(12, 0.60, 0.80),
  size = runif(12, 3, 6)
)

focos_cerrado <- data.frame(
  x = runif(10, 0.45, 0.75),
  y = runif(10, 0.40, 0.60),
  size = runif(10, 2, 5)
)

focos_mata <- data.frame(
  x = runif(8, 0.60, 0.80),
  y = runif(8, 0.20, 0.40),
  size = runif(8, 2, 4)
)

focos <- rbind(focos_amazonia, focos_cerrado, focos_mata)

p <- ggplot() +
  # Contorno do Brasil
  geom_polygon(data = brasil_coords,
               aes(x = x, y = y),
               fill = "#E0E0E0",
               color = "#2E8B57",  # verde marinho
               size = 1.8,
               alpha = 0.3) +
  # Pontos de fogo
  geom_point(data = focos,
             aes(x = x, y = y, size = size),
             color = "#FF4500",
             alpha = 0.8,
             show.legend = FALSE) +
  scale_size_continuous(range = c(2, 6)) +
  theme_void() +
  theme(plot.background = element_rect(fill = "transparent", color = NA)) +
  xlim(0, 1) + ylim(0, 1)

sticker(
  subplot = p,
  package = "queimadasR",
  p_color = "white",
  p_size = 16,
  s_x = 1,
  s_y = 0.8,
  s_width = 1.2,
  s_height = 1.0,
  h_fill = "#0B3D2E",
  h_color = "#2E8B57",
  filename = "queimadasR_hex.png"
)
