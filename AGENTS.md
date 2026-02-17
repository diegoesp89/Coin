# Coin - Proyecto Godot

Juego de monedas con servidor HTTP para spawnear monedas con nombres y sistema de puntuación.

## Estructura

```
Scripts/
  HTTPServer.gd      - Servidor HTTP en puerto 8200 + lógica de puntuación
  CoinSpawner.gd     - Spawner de monedas automático (click/botón)
  CoinSpawnerMove.gd - Movimiento del spawner
  Pusher.gd          - Obstáculo push
  Scenary.gd         - Aplica texturas a los muros

Prefabs/
  scene1.tscn        - Escena principal
  coin.tscn          - Prefab de moneda
  Hud.tscn           - HUD con puntuación
  HudPoints.gd       - Script del HUD (guardado de scores)
  coin_destroy.gd    - Script de destrucción de monedas + texturas

Materials/
  *.tres             - Materiales del juego
  coin_albedo.png   - Textura de moneda (albedo)
  coin_normal.png   - Textura de moneda (normal)
  coin_roughness.png - Textura de moneda (roughness)
  coin_height.png   - Textura de moneda (height)
  wall_albedo.png   - Textura de muro (albedo)
  wall_normal.png   - Textura de muro (normal)
  wall_roughness.png - Textura de muro (roughness)
  wall_height.png   - Textura de muro (height)

Phys/
  *.tres             - Materiales físicos
```

## Servidor HTTP

**Puerto:** 8200

**Parámetros:**
- `key` - API key (configurable, por defecto: `secret123`)
- `name` - Nombre del jugador
- `color` - Color del nombre (hex 6 caracteres o `rainbow`)
- `type` - Tipo de moneda: `free` (30s), `paid` (2min), `rainbow` (5min)

**Ejemplos:**
```
/?key=secret123&name=jugador1&color=ff0000
/?key=secret123&name=jugador2&type=rainbow
/?key=secret123&name=test&type=paid&color=00ff00
```

## Sistema de Puntuación

1. **Barras de tiempo:** Cada moneda con nombre tiene una barra que dura según el tipo:
   - `free`: 30 segundos
   - `paid`: 2 minutos
   - `rainbow`: 5 minutos (barra rainbow)
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
var BAR_DURATION: float = 30.0       # free
var PAID_DURATION: float = 120.0     # paid (2 minutos)
var RAINBOW_DURATION: float = 300.0  # rainbow (5 minutos)
var AUTO_SPAWN_INTERVAL: float = 10.0 # Intervalo auto-spawn
var api_key: String = "secret123"    # API key
var port: int = 8200                 # Puerto HTTP
```

## HUD

- **Panel derecho:** Puntuaciones ordenadas de mayor a menor
- **Panel izquierdo:** Jugadores activos con tiempo restante y multiplicador (X#)
- **Persistência:** Los scores se guardan en `user://highscores.txt` y se cargan al iniciar

## Monedas Auto-spawn

Cada 10 segundos spawnea una moneda sin nombre que contribuye a la puntuación cuando cae (si hay barras activas).

## Efectos Visuales

- **Spawn:** Partículas doradas al crear moneda
- **Destrucción:** Partículas grises al caer moneda
- **Puntos:** Flash amarillo en el nombre al sumar puntos

## Problemas Comunes Conocidos

1. **URL Encoding:** Los nombres con espacios deben usar `%20` o `+`
2. **Señales:** Asegurarse que `delete_coin` signal está correctamente conectado
3. **Límites de destrucción:** Las monedas se destruyen en y < -2.0 (ajustable en coin_destroy.gd)
4. **Texturas:** Las texturas se aplican por código en `_ready()` para evitar problemas de UIDs

## Dependencias

- Godot 4.x
- Proyecto usa Forward Plus renderer
