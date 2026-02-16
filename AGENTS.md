# Coin - Proyecto Godot

Juego de monedas con servidor HTTP para spawnear monedas con nombres y sistema de puntuación.

## Estructura

```
Scripts/
  HTTPServer.gd      - Servidor HTTP en puerto 8200 + lógica de puntuación
  CoinSpawner.gd     - Spawner de monedas automático
  CoinSpawnerMove.gd - Movimiento del spawner
  Pusher.gd          - Obstáculo push

Prefabs/
  scene1.tscn        - Escena principal
  coin.tscn          - Prefab de moneda
  Hud.tscn           - HUD con puntuación
  coin_destroy.gd    - Script de destrucción de monedas

Materials/
  *.tres             - Materiales del juego

Phys/
  *.tres             - Materiales físicos
```

## Servidor HTTP

**Puerto:** 8200

**Parámetros:**
- `key` - API key (configurable, por defecto: `secret123`)
- `name` - Nombre del jugador
- `color` - Color del nombre (hex 6 caracteres o `rainbow`)

**Ejemplos:**
```
/?key=secret123&name=jugador1&color=ff0000
/?key=secret123&name=jugador2&color=rainbow
/?key=secret123&name=test&color=00ff00
```

## Sistema de Puntuación

1. **Barras de tiempo:** Cada moneda con nombre tiene una barra verde que dura 30 segundos (120 segundos para rainbow)
2. **Puntuación:** Cuando cualquier moneda cae del mapa, TODOS los nombres con barras activas reciben +1 punto por cada barra que tengan
3. **Multiplicador por nombre:** Si un nombre tiene 3 barras activas y cae 1 moneda, ese nombre recibe +3 puntos

### Reglas:
- Solo las monedas que CAEN del mapa dan puntos (no las que spawnean)
- Las barras se destruyen cuando expira el tiempo o la moneda se destruye
- El nombre se queda después de que la barra desaparece, hasta que la moneda se destruye

## Controles de Debug

- **M** - Velocidad del juego x4
- **N** - Velocidad del juego x10

## Constantes (en HTTPServer.gd)

```gdscript
var BAR_DURATION: float = 30.0      # Duración barra normal
var RAINBOW_DURATION: float = 120.0  # Duración barra rainbow
var AUTO_SPAWN_INTERVAL: float = 10.0 # Intervalo auto-spawn
var api_key: String = "secret123"     # API key
var port: int = 8200                  # Puerto HTTP
```

## HUD

- **Panel derecho:** Puntuaciones ordenadas de mayor a menor
- **Panel izquierdo:** Jugadores activos con tiempo restante y multiplicador (X#)

## Monedas Auto-spawn

Cada 10 segundos spawnea una moneda sin nombre que contribuye a la puntuación cuando cae (si hay barras activas).

## Problemas Comunes Conocidos

1. **URL Encoding:** Los nombres con espacios deben usar `%20` o `+`
2. **Señales:** Asegurarse que `delete_coin` signal está correctamente conectado
3. **Límites de destrucción:** Las monedas se destruyen en y < -2.0 (ajustable en coin_destroy.gd)

## Dependencias

- Godot 4.x
- Proyecto usa Forward Plus renderer
