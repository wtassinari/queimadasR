library(hexSticker)
library(ggplot2)

# Criar um polígono orgânico suave (sem auto-intersecções)
set.seed(789)

# Gerar ângulos em ordem crescente (garante que o polígono não se cruza)
t <- seq(0, 2*pi, length.out = 40)

# Criar raios com variação suave (usando ondas senoidais para evitar picos abruptos)
raios <- 0.38 + 
  0.06 * sin(3 * t) +      # onda principal
  0.03 * cos(5 * t + 0.5) + # onda secundária
  0.02 * sin(7 * t + 1)     # detalhes

# Adicionar pequeno ruído aleatório controlado (apenas para suavizar)
raios <- raios + rnorm(length(t), 0, 0.005)

# Garantir que os raios são positivos
raios <- abs(raios)

# Criar coordenadas do polígono
poligono <- data.frame(
  x = 0.5 + raios * cos(t),
  y = 0.5 + raios * sin(t)
)

# Fechar o polígono (o último ponto deve ser igual ao primeiro)
poligono <- rbind(poligono, poligono[1, ])

# Criar pontos de fogo DENTRO do polígono
set.seed(456)
n_pontos <- 50
pontos_tentativa <- data.frame(
  x = runif(n_pontos * 3, 0.25, 0.75),
  y = runif(n_pontos * 3, 0.25, 0.75)
)

# Verificar pontos dentro do polígono (método do raio)
pontos_dentro <- data.frame()
for (i in 1:nrow(pontos_tentativa)) {
  px <- pontos_tentativa$x[i]
  py <- pontos_tentativa$y[i]
  
  # Calcular ângulo e distância do centro
  ang <- atan2(py - 0.5, px - 0.5)
  if (ang < 0) ang <- ang + 2*pi
  
  # Encontrar o raio do polígono neste ângulo (aproximado)
  # Método simplificado: distância do centro
  dist_centro <- sqrt((px - 0.5)^2 + (py - 0.5)^2)
  
  # Encontrar o raio do polígono mais próximo deste ângulo
  idx <- which.min(abs(t - ang))
  raio_poligono <- raios[min(idx, length(raios))]
  
  # Se distância for menor que o raio, está dentro
  if (dist_centro < raio_poligono) {
    pontos_dentro <- rbind(pontos_dentro, data.frame(x = px, y = py))
  }
  
  if (nrow(pontos_dentro) >= 35) break
}

# Se não tiver pontos suficientes, adicionar alguns manualmente
if (nrow(pontos_dentro) < 30) {
  extras <- data.frame(
    x = 0.5 + runif(15, -0.2, 0.2),
    y = 0.5 + runif(15, -0.2, 0.2)
  )
  pontos_dentro <- rbind(pontos_dentro, extras)
}

# Limitar a 35 pontos
pontos_dentro <- pontos_dentro[1:min(35, nrow(pontos_dentro)), ]

# Adicionar intensidade para os pontos
pontos_dentro$intensidade <- runif(nrow(pontos_dentro), 0.5, 1)
pontos_dentro$tamanho <- 3 + pontos_dentro$intensidade * 3

# Criar o plot
p <- ggplot() +
  # Polígono principal (preenchimento sólido)
  geom_polygon(data = poligono,
               aes(x = x, y = y),
               fill = "#E0E0E0",  # cinza claro
               color = "#2E8B57",  # verde marinho
               size = 2.2,
               alpha = 0.9) +
  
  # Pontos de fogo com gradiente
  geom_point(data = pontos_dentro,
             aes(x = x, y = y, 
                 size = tamanho,
                 alpha = intensidade),
             color = "#FF4500",  # laranja
             show.legend = FALSE) +
  
  # Escala de tamanho
  scale_size_continuous(range = c(2, 6)) +
  scale_alpha_continuous(range = c(0.6, 1)) +
  
  # Remover elementos do gráfico
  theme_void() +
  theme(plot.background = element_rect(fill = "transparent", color = NA)) +
  
  # Ajustar limites
  xlim(0, 1) + ylim(0, 1)

# Criar o sticker
sticker(
  subplot = p,
  package = "queimadasR",
  p_color = "white",
  p_size = 18,
  p_family = "sans",
  p_y = 1.4,
  s_x = 1,
  s_y = 0.8,
  s_width = 1.2,
  s_height = 1.0,
  h_fill = "#0B3D2E",  # verde escuro
  h_color = "#FF4500",  # laranja
  filename = "queimadasR_hex_final.png"
)

print("Sticker criado com sucesso! Verifique o arquivo queimadasR_hex_final.png")