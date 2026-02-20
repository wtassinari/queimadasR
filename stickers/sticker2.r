library(hexSticker)
library(ggplot2)

# Criar ícone de árvore estilizada
arvore_plot <- ggplot() +
  # Tronco
  geom_rect(aes(xmin = 0.45, xmax = 0.55, ymin = 0.2, ymax = 0.5), 
            fill = "#8B4513", color = NA) +
  # Copa da árvore (triângulo verde)
  geom_polygon(aes(x = c(0.2, 0.5, 0.8), y = c(0.5, 0.9, 0.5)), 
               fill = "#228B22", alpha = 0.7) +
  # Chamas (pontos laranja/vermelho)
  geom_point(aes(x = 0.5, y = 0.7), color = "#FF4500", size = 8, alpha = 0.8) +
  geom_point(aes(x = 0.4, y = 0.6), color = "#FF8C00", size = 6, alpha = 0.8) +
  geom_point(aes(x = 0.6, y = 0.6), color = "#FF8C00", size = 6, alpha = 0.8) +
  theme_void() +
  theme(plot.background = element_rect(fill = "transparent", color = NA)) +
  xlim(0, 1) + ylim(0, 1)

sticker(
  subplot = arvore_plot,
  package = "queimadasR",
  p_color = "white",
  p_size = 16,
  s_x = 1,
  s_y = 0.8,
  s_width = 1.2,
  s_height = 1.0,
  h_fill = "#0B3D2E",
  h_color = "#1E6F4C",
  filename = "queimadasR_hex.png"
)