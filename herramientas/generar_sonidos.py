# GENERADOR DE SONIDOS DE HIELO FINO
# HECHO POR CLAUDE (ANTHROPIC). SOLO USA PYTHON, SIN LIBRERÍAS EXTRA.
# USO: python3 herramientas/generar_sonidos.py

import math
import os
import random
import struct
import wave

SR = 22050
CARPETA = os.path.join(os.path.dirname(__file__), "..", "sonidos")
random.seed(15)


def guardar(nombre, muestras):
    pico = max(abs(m) for m in muestras) or 1.0
    datos = b"".join(struct.pack("<h", int(m / pico * 0.9 * 32767)) for m in muestras)
    ruta = os.path.join(CARPETA, nombre + ".wav")
    with wave.open(ruta, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(datos)
    print("listo:", ruta)


def env(t, ataque, caida):
    if t < ataque:
        return t / ataque
    return math.exp(-(t - ataque) / caida)


def ruido():
    return random.uniform(-1.0, 1.0)


# GOLPE SECO AL ATERRIZAR
def golpe():
    out, fase, lp = [], 0.0, 0.0
    n = int(SR * 0.22)
    for i in range(n):
        t = i / SR
        f = 55 + 60 * math.exp(-t / 0.04)
        fase += 2 * math.pi * f / SR
        lp += 0.08 * (ruido() - lp)
        out.append(math.sin(fase) * env(t, 0.004, 0.05) + lp * env(t, 0.002, 0.02) * 2.0)
    return out


# SOPLIDO SUAVE AL VOLTEAR
def volteo():
    out, lento, rapido = [], 0.0, 0.0
    n = int(SR * 0.2)
    for i in range(n):
        t = i / SR
        x = ruido()
        rapido += 0.25 * (x - rapido)
        lento += 0.03 * (x - lento)
        forma = math.sin(math.pi * t / 0.2) ** 2
        out.append((rapido - lento) * forma)
    return out


# HIELO QUE SE ROMPE EN PEDAZOS
def rotura():
    n = int(SR * 0.5)
    out, prev = [0.0] * n, 0.0
    for i in range(n):
        x = ruido()
        alto = x - prev
        prev = x
        out[i] = alto * env(i / SR, 0.001, 0.07) * 0.6
    for _ in range(14):
        ini = random.randint(0, int(SR * 0.3))
        f = random.uniform(2000, 6000)
        caida = random.uniform(0.01, 0.04)
        fuerza = random.uniform(0.3, 1.0)
        for j in range(int(SR * 0.12)):
            if ini + j >= n:
                break
            t = j / SR
            out[ini + j] += math.sin(2 * math.pi * f * t) * math.exp(-t / caida) * fuerza
    return out


# SALPICADURA AL CAER AL AGUA
def salpicadura():
    n = int(SR * 0.8)
    out, lp = [0.0] * n, 0.0
    for i in range(n):
        t = i / SR
        corte = 0.05 + 0.4 * math.exp(-t / 0.15)
        lp += corte * (ruido() - lp)
        out[i] = lp * env(t, 0.01, 0.22) * 1.5
    for _ in range(7):
        ini = random.randint(int(SR * 0.08), int(SR * 0.5))
        f0 = random.uniform(250, 500)
        fase = 0.0
        for j in range(int(SR * 0.06)):
            if ini + j >= n:
                break
            t = j / SR
            fase += 2 * math.pi * (f0 + f0 * 12 * t) / SR
            out[ini + j] += math.sin(fase) * math.sin(math.pi * t / 0.06) * 0.35
    return out


# ARPEGIO ALEGRE AL LLEGAR A LA META
def estrella():
    notas = [1046.5, 1318.5, 1568.0, 2093.0]
    n = int(SR * 0.9)
    out = [0.0] * n
    for k, f in enumerate(notas):
        ini = int(SR * 0.08 * k)
        for j in range(n - ini):
            t = j / SR
            tono = math.sin(2 * math.pi * f * t) + 0.3 * math.sin(4 * math.pi * f * t)
            out[ini + j] += tono * env(t, 0.005, 0.18) * 0.5
    return out


if __name__ == "__main__":
    os.makedirs(CARPETA, exist_ok=True)
    guardar("golpe", golpe())
    guardar("volteo", volteo())
    guardar("rotura", rotura())
    guardar("salpicadura", salpicadura())
    guardar("estrella", estrella())
