# Pixel Connect 4 (Godot)

Un juego de Conecta 4 en estilo Pixel Art para 2 jugadores.

## Instrucciones
1. Abre este proyecto con Godot Engine 4.
2. Si las imágenes no aparecen, asegúrate de que Godot las haya importado (se reimportan automáticamente al abrir).
3. Ejecuta el juego.

## Ajustes
Si el tamaño del tablero o las fichas no encaja:
- Abre `scripts/Game.gd`.
- Ajusta `TILE_SIZE` (tamaño de la celda en píxeles).
- Ajusta `BOARD_OFFSET` (posición de la esquina superior izquierda del tablero).
- O ajusta la escala de los Sprites en `scenes/Main.tscn`.

## Controles
- **Mouse**: Haz clic en una columna para soltar una ficha.
- **Click tras ganar**: Reinicia el juego.
