
# Propuesta Técnica – Geofencing Escalable en iOS (App Galicia)

## 🎯 Objetivo

Implementar una solución eficiente y escalable para detectar entrada y salida de sucursales de Galicia en iOS, sin requerir permisos de ubicación en segundo plano ("Always"), priorizando la experiencia del usuario, el consumo de batería y la tasa de adopción del feature.

---

## 🧠 Enfoque Técnico

Se propone una arquitectura híbrida que combina:

1. `startMonitoringSignificantLocationChanges()`  
   → Despierta la app cuando el usuario se mueve >500 metros, con bajo consumo energético.

2. Geofences dinámicas con `CLCircularRegion`  
   → Se activan hasta 20 geofences en tiempo real para sucursales cercanas y/ o promociones comerciales, dentro de un radio de 100-200 metros.

3. Notificaciones locales (`UNUserNotificationCenter`)  
   → Se disparan al detectar una promocion cercana, mejorando la experiencia contextual.

---

## 🔄 Flujo Técnico

1. App solicita permisos “al usar” y notificaciones.
2. Se activa el monitoreo de movimientos significativos.
3. Cuando el usuario se desplaza, la app se reactiva en background:
   - Obtiene la nueva ubicación.
   - Calcula sucursales cercanas por clúster.
   - Activa hasta 20 geofences para esas sucursales o comercios adheridos.
4. Al detectar entrada o salida, se dispara una notificación local o simplemente se trackea a nuestro servidor.

---

## 📈 Penetración Estimada

- Permisos “al usar” + notificaciones: 30–45% de usuarios activos.
- Mucho más accesible que pedir permiso “Siempre” (~15–20%) segun benchmark.

---

## 🛠️ Escalabilidad Funcional

Esta solución no solo permite detectar visitas a sucursales, sino que habilita nuevas experiencias de alto valor percibido:

| Funcionalidad | Descripción | Valor |
|---------------|-------------|-------|
| 🚪 Apertura automática del cajero | El usuario puede ingresar sin pasar tarjeta, autenticado desde la app. | Innovación, seguridad |
| 📲 Turno automático | La app asigna turno al llegar, sin usar tótem. | Ahorro de tiempo |
| ⭐ Atención prioritaria | Para perfiles especiales (VIP, mayores, etc.) | Inclusión y personalización |
| 🛎️ Servicios contextuales | Mostrar servicios disponibles según la sucursal. | Relevancia contextual |

---

## ✅ Ventajas

- Alta adopción sin fricción de permisos
- Bajo impacto en batería
- Persistencia incluso tras reinicios
- Escalable a más de 100 sucursales
- Plataforma para nuevas funcionalidades presenciales

---

