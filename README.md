# hielo-fino

Juego de puzzle en Godot 4: lleva el bloque de hielo **parado** hasta el hoyo naranja sin que el hielo se rompa bajo tus pies.

## Cómo se juega

- El bloque mide 1 × 1 × 2 y avanza **volteándose**: parado ocupa una casilla, acostado ocupa dos.
- Ganas cuando el bloque entra **parado** al hoyo naranja.
- Si alguna parte del bloque queda sobre el agua, te caes.
- **Nieve:** nunca se rompe. **Hielo:** aguanta dos aterrizajes. **Grieta:** aguanta uno. Las casillas se rompen cuando el bloque se va de ellas.
- **Paredes:** no se pueden atravesar (solo en Extensión).
- Terminar en el par o menos da ★★★.

## Controles

| Tecla | Acción |
|---|---|
| W A S D | Voltear el bloque (según hacia dónde mira la cámara) |
| Flechas | Girar la cámara y acercar o alejar |
| Z | Deshacer |
| R | Reiniciar el nivel |
| Espacio / Enter | Siguiente nivel |
| Esc | Volver al menú |

## Modos

- **Fácil:** 5 niveles de pura nieve.
- **Difícil:** 5 niveles con hielo y grietas.
- **Reto:** 5 niveles contra el reloj.
- **Extensión:** niveles con paredes que tapan la vista; gira la cámara para ver el camino.

## Equipo

El proyecto se trabaja con tres cuentas, cada una en su rama: `rama-ian`, `rama-matheus` y `rama-coba`. Todo se fusiona en `main`.

## Sonidos

Los efectos de sonido (`golpe`, `volteo`, `rotura`, `salpicadura` y `estrella`) los generó **Claude** (Anthropic) con código, sin grabaciones ni bancos de sonido. El script queda en el repo para volver a crearlos:

```bash
python3 herramientas/generar_sonidos.py
```

Este fue el pedido que se le hizo a Claude:

> Necesito los efectos de sonido para Hielo Fino, un puzzle 3D en Godot donde un bloque de hielo se voltea sobre casillas de nieve y hielo. Quiero cinco sonidos cortos, suaves y "family friendly": un golpe seco cuando el bloque aterriza, un soplido leve cuando se voltea, hielo que se quiebra en pedacitos cuando una casilla se rompe, una salpicadura con burbujitas cuando el bloque cae al agua, y un arpegio alegre cuando llega a la meta. Créalos con un script de Python que no necesite librerías extra, para poder regenerarlos cuando queramos.

Claude no es colaborador del repo ni sube commits: todo se sube desde la cuenta **iandifilippo**.
