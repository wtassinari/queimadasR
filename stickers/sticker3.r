library(hexSticker)
library(ggplot2)

# Criar coordenadas para um polígono que lembra o mapa do Brasil
brasil_polygon <- data.frame(
  x = c(0.2, 0.8, 0.9, 0.7, 0.3, 0.1, 0.2),
  y = c(0.2, 0.2, 0.5, 0.8, 0.8, 0.5, 0.2)
)

# Criar pontos de fogo DENTRO do polígono
set.seed(123)  # para reprodutibilidade
focos <- data.frame(
  x = runif(30, min = 0.2, max = 0.8),
  y = runif(30, min = 0.2, max = 0.8)
)

# Filtrar apenas pontos dentro do polígono (aproximadamente)
focos <- focos[focos$x > 0.2 & focos$x < 0.8 & 
                 focos$y > 0.2 & focos$y < 0.8, ]

p <- ggplot() +
  # Polígono (área) com contorno
  geom_polygon(data = brasil_polygon, 
               aes(x = x, y = y),
               fill = "#FFE4B5",  # bege claro (terreno)
               color = "#8B4513",  # marrom (contorno)
               size = 1.5,
               alpha = 0.3) +
  # Pontos de fogo dentro do polígono
  geom_point(data = focos,
             aes(x = x, y = y),
             color = "#FF4500",  # laranja/vermelho
             size = 3,
             alpha = 0.8) +
  # Alguns pontos maiores para dar ênfase
  geom_point(data = focos[sample(1:nrow(focos), 5), ],
             aes(x = x, y = y),
             color = "#FF0000",  # vermelho
             size = 4,
             alpha = 0.6) +
  coord_equal() +
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
  s_width = 1.3,
  s_height = 0.9,
  h_fill = "#0B3D2E",  # verde escuro
  h_color = "#1E6F4C",  # verde médio
  filename = "queimadasR_hex.png"
)