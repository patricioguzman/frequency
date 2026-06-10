# Frequency — Debug Session: Splash Screen Fix

**Fecha:** 11 Junio 2026
**Tablet:** Lenovo Yoga Tab 3 (Android 6.0, serial 0123456789ABCDEF)
**APK final:** `/home/pat/frequency/frequency.apk` (24K)

---

## Bugs encontrados y arreglados

### Bug 1: ERR_FILE_NOT_FOUND (causa raiz)
**Sintoma:** Splash infinito, pantalla en blanco con error
**Causa:** `MainActivity.java` cargaba `file:///android_asset/djfy.html` pero el archivo real es `index.html`
**Fix:** Cambiar `loadUrl("file:///android_asset/djfy.html")` → `loadUrl("file:///android_asset/index.html")`
**Archivo:** `app/src/main/java/com/hermes/djfy/MainActivity.java:58`

### Bug 2: Splash bloqueado por JS sincrono
**Sintoma:** Aun con la pagina cargando, el splash no se desvanecia al tocar
**Causa:** `start()` hacia el fade del splash y luego inmediatamente `renderPattern()` — 1.6 millones de iteraciones sincronas que bloquean el thread principal. El CSS no puede pintar la transicion porque JS esta ocupado.
**Fix:** Separar en dos fases:
  - `start()` → solo oculta el splash + guard `_started`
  - `initAudio()` → se llama via `setTimeout(100)` para dar tiempo a la transicion CSS
**Archivo:** `app/src/main/assets/index.html` lineas 466-493

### Bug 3: setXFader error — null gain
**Sintoma:** `Uncaught TypeError: Cannot read properties of null (reading 'gain')` en logcat
**Causa:** El slider crossfader dispara evento `input` al cargar la pagina (valor por defecto), pero `xGainA`/`xGainB` no existen hasta que `buildMaster()` corre dentro de `initAudio()` (100ms despues)
**Fix:** Guard `if(!xGainA||!xGainB)return;` al inicio de `setXFader()`
**Archivo:** `app/src/main/assets/index.html` linea 378

---

## Logs finales (app funcionando)

```
06-11 00:38:25  DJFY    : MainActivity.onCreate()
06-11 00:38:25  DJFY    : Loading index.html...
06-11 00:38:26  DJFY_JS : DJFY v3 boot — script start
06-11 00:38:26  DJFY_JS : DJFY v3: init complete, awaiting tap
06-11 00:38:26  DJFY    : onPageFinished: file:///android_asset/index.html
06-11 00:38:30  DJFY_JS : Frequency: start() called
06-11 00:38:30  DJFY_JS : DJFY: AudioContext created, state=running, rate=48000
06-11 00:38:30  DJFY_JS : building all patterns...
06-11 00:38:30  DJFY_JS : rendering pattern... (×5)
06-11 00:38:33  DJFY_JS : patterns done: 5
06-11 00:38:34  DJFY_JS : master graph built
06-11 00:38:34  DJFY_JS : ACTIVE — Deck A playing
```

Sin errores. Audio iniciando correctamente.

---

## Estado actual del APK

- Package: `com.hermes.djfy`
- Label: Frequency
- Toca "TOCA PARA INICIAR" → splash fade out → AudioContext resume → Deck A toca patron Kick
- 5 patrones procedurales: Kick, Hi-Hats, Snare, Bass, Pad
- 2 decks independientes con EQ, pitch, crossfader
- FX: Filter, Delay, Reverb
- BPM sync, tap tempo

---

## Lecciones

1. **Nunca asumir que el asset name es correcto** — verificar que `loadUrl()` y `assets/` coincidan
2. **CSS transitions requieren el thread libre** — diferir trabajo pesado con `setTimeout` despues de disparar la transicion
3. **Sliders disparan `input` al cargar** — poner guards contra valores no inicializados
4. **Android 6 `tile_manager` errors son cosmeticos** — la app funciona aunque salgan en logcat
