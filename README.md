# hielo-fino

Juego de puzzle en Godot 4: lleva el bloque de hielo **parado** hasta el hoyo naranja sin que el hielo se rompa bajo tus pies.

## Sonidos

Los efectos de sonido (`golpe`, `volteo`, `rotura`, `salpicadura` y `estrella`) los generó **Claude** (Anthropic) con código, sin grabaciones ni bancos de sonido. El script queda en el repo para volver a crearlos:

```bash
python3 herramientas/generar_sonidos.py
```

Este fue el pedido que se le hizo a Claude:

> Necesito los efectos de sonido para Hielo Fino, un puzzle 3D en Godot donde un bloque de hielo se voltea sobre casillas de nieve y hielo. Quiero cinco sonidos cortos, suaves y "family friendly": un golpe seco cuando el bloque aterriza, un soplido leve cuando se voltea, hielo que se quiebra en pedacitos cuando una casilla se rompe, una salpicadura con burbujitas cuando el bloque cae al agua, y un arpegio alegre cuando llega a la meta. Créalos con un script de Python que no necesite librerías extra, para poder regenerarlos cuando queramos.

Claude no es colaborador del repo ni sube commits: todo se sube desde la cuenta **iandifilippo**.
