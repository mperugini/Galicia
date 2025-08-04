# 🏦 **Galicia - App de Geofencing para Sucursales**

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://developer.apple.com/ios/)
[![Xcode](https://img.shields.io/badge/Xcode-15.0+-green.svg)](https://developer.apple.com/xcode/)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-lightgrey.svg)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 📋 **Descripción del Proyecto**

**Galicia** es una aplicación iOS desarrollada para Banco Galicia que permite el seguimiento automático de visitas a sucursales mediante tecnología de geofencing. La aplicación detecta automáticamente cuando un usuario entra y sale de las sucursales, registra la duración de la visita y permite seleccionar el tipo de servicio utilizado.

### 🎯 **Funcionalidades Principales**

- ✅ **Geofencing Automático**: Detección automática de entrada/salida de sucursales
- ✅ **Registro de Visitas**: Persistencia de datos con Core Data
- ✅ **Selección de Servicios**: Interfaz para elegir tipo de servicio
- ✅ **Historial de Visitas**: Vista de todas las visitas realizadas
- ✅ **Notificaciones Push**: Notificaciones locales y remotas
- ✅ **Analytics**: Integración con Firebase Analytics y Crashlytics
- ✅ **Arquitectura Limpia**: Implementación de Clean Architecture y SOLID

### 🗺️ **Roadmap Futuro**

- 🔄 **Múltiples Sucursales desde Backend**: Carga dinámica de sucursales
- 🔄 **Anillos de Geofence por Clusters**: Agrupación geográfica de sucursales
- 🔄 **Geofencing Inteligente**: Optimización de detección por clusters

---

## 🏗️ **Arquitectura del Proyecto**

### **Clean Architecture**
```
Galicia/
├── Domain/           # Lógica de negocio
│   ├── Models/       # Entidades del dominio
│   ├── Protocols/    # Interfaces y contratos
│   └── UseCases/     # Casos de uso
├── Data/             # Capa de datos
│   ├── CoreData/     # Persistencia local
│   ├── Repository/   # Implementación de repositorios
│   └── Services/     # Servicios externos
└── Presentation/     # Capa de presentación
    ├── ViewModels/   # ViewModels (MVVM)
    └── Views/        # Vistas SwiftUI
```

### **Principios SOLID Implementados**
- ✅ **Single Responsibility**: Cada clase tiene una responsabilidad específica
- ✅ **Open/Closed**: Extensible sin modificar código existente
- ✅ **Liskov Substitution**: Implementaciones intercambiables
- ✅ **Interface Segregation**: Protocolos específicos y enfocados
- ✅ **Dependency Inversion**: Dependencias de abstracciones

---

## 🚀 **Configuración del Proyecto**

### **Prerrequisitos**

- **Xcode 15.0+**
- **iOS 17.0+**
- **Swift 5.9+**
- **Cuenta de Apple Developer**
- **Proyecto Firebase configurado**

### **1. Clonar el Repositorio**

```bash
git clone https://github.com/mperugini/Galicia.git
cd Galicia
```

### **2. Configurar Firebase**

#### **2.1 Crear Proyecto Firebase**
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto o usa uno existente
3. Agrega una aplicación iOS con el Bundle ID: `com.bancogalicia.galicia`

#### **2.2 Descargar GoogleService-Info.plist**
1. Descarga el archivo `GoogleService-Info.plist`
2. Agrégalo al proyecto en Xcode:
   - Arrastra el archivo a la carpeta `Galicia/Galicia/`
   - Asegúrate de que esté incluido en el target `Galicia`

#### **2.3 Configurar Firebase Services**
- **Analytics**: Habilitado automáticamente
- **Crashlytics**: Habilitado para reportes de errores
- **Cloud Messaging**: Para notificaciones push

### **3. Configurar Apple Developer Portal**

#### **3.1 App ID Configuration**
1. Ve a [Apple Developer Portal](https://developer.apple.com/account/)
2. Certificates, Identifiers & Profiles > Identifiers
3. Crea un nuevo App ID o edita el existente
4. **Bundle ID**: `com.bancogalicia.galicia`

#### **3.2 Capabilities Requeridas**
Habilita las siguientes capabilities en tu App ID:

- ✅ **Push Notifications**
- ✅ **Background Modes**
- ✅ **Location Updates**

#### **3.3 Provisioning Profile**
1. Ve a **Profiles** en el Developer Portal
2. Crea un nuevo **Development Provisioning Profile**
3. Selecciona tu App ID
4. Incluye los certificados de desarrollo
5. Incluye los dispositivos de desarrollo

### **4. Configurar Xcode**

#### **4.1 Team y Signing**
1. Abre el proyecto en Xcode
2. Selecciona el target `Galicia`
3. Ve a **Signing & Capabilities**
4. **Team**: Selecciona tu equipo de desarrollo
5. **Bundle Identifier**: `com.bancogalicia.galicia`

#### **4.2 Capabilities en Xcode**
Agrega las siguientes capabilities:

**Background Modes:**
- ✅ Location updates
- ✅ Background fetch
- ✅ Background processing
- ✅ Remote notifications

**Push Notifications:**
- ✅ Habilitado automáticamente

#### **4.3 Info.plist Configuration**
El archivo ya está configurado con:

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Esta aplicación necesita acceso a tu ubicación para detectar cuando entras y sales de las sucursales de Banco Galicia.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Esta aplicación necesita acceso a tu ubicación para detectar cuando entras y sales de las sucursales de Banco Galicia.</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>Esta aplicación necesita acceso a tu ubicación para detectar cuando entras y sales de las sucursales de Banco Galicia, incluso cuando la aplicación está en segundo plano.</string>
```

### **5. Dependencias**

El proyecto usa **Swift Package Manager** para las dependencias:

#### **Firebase Dependencies**
- `FirebaseAnalytics`: Analytics y métricas
- `FirebaseCrashlytics`: Reportes de errores
- `FirebaseMessaging`: Notificaciones push

#### **Dependencias del Sistema**
- `CoreLocation`: Geofencing y ubicación
- `CoreData`: Persistencia local
- `UserNotifications`: Notificaciones locales
- `Combine`: Programación reactiva

### **6. Compilar y Ejecutar**

```bash
# Abrir proyecto en Xcode
open Galicia.xcodeproj

# O desde línea de comandos
xcodebuild -project Galicia.xcodeproj -scheme Galicia -destination 'platform=iOS Simulator,name=iPhone 15' build
```

---

## 🧪 **Configuración de Desarrollo**

### **Sucursales Configuradas**

Actualmente el proyecto incluye las siguientes sucursales de prueba:

```swift
// Sucursal Principal - Saladillo Centro
static let mainBranch = Branch(
    id: "saladillo-centro",
    name: "Sucursal Saladillo Centro",
    coordinate: CLLocationCoordinate2D(latitude: -35.6330328, longitude: -59.7783535),
    radius: 10.0
)

// Sucursal Norte - Saladillo
static let northBranch = Branch(
    id: "saladillo-norte", 
    name: "Sucursal Saladillo Norte",
    coordinate: CLLocationCoordinate2D(latitude: -35.64672601734939, longitude: -59.80101491680581),
    radius: 10.0
)

// Sucursal Sur - Saladillo
static let southBranch = Branch(
    id: "saladillo-sur",
    name: "Sucursal Saladillo Sur", 
    coordinate: CLLocationCoordinate2D(latitude: -35.6200000, longitude: -59.7900000),
    radius: 10.0
)
```

### **Testing**

Para probar el geofencing:

1. **Simulador**: Usa la función de ubicación personalizada en Xcode
2. **Dispositivo Físico**: Ve a las coordenadas configuradas
3. **Debug**: Usa los botones de debug en la UI

---

## 📱 **Uso de la Aplicación**

### **Flujo Principal**

1. **Primer Uso**: La app solicita permisos de ubicación
2. **Detección Automática**: Al entrar a una sucursal, se inicia automáticamente una visita
3. **Selección de Servicio**: Se muestra la pantalla para elegir el tipo de servicio
4. **Registro**: La visita se guarda con timestamp de entrada
5. **Salida**: Al salir de la sucursal, se completa la visita con duración
6. **Historial**: Todas las visitas se pueden ver en la pestaña de historial

### **Permisos Requeridos**

- **Ubicación "Siempre"**: Para geofencing en segundo plano
- **Notificaciones**: Para recibir notificaciones de entrada/salida

---

## 🐛 **Troubleshooting**

### **Problemas Comunes**

#### **1. Firebase no se inicializa**
```bash
# Verificar que GoogleService-Info.plist esté en el proyecto
# Verificar que esté incluido en el target
```

#### **2. Geofencing no funciona**
```bash
# Verificar permisos de ubicación
# Verificar que Background Modes esté habilitado
# Verificar coordenadas de las sucursales
```

#### **3. Push Notifications no funcionan**
```bash
# Verificar APNs certificate en Firebase Console
# Verificar provisioning profile con Push Notifications
# Verificar entitlements
```

#### **4. Errores de Compilación**
```bash
# Limpiar proyecto
Product > Clean Build Folder

# Resetear dependencias
File > Packages > Reset Package Caches

# Limpiar DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### **Logs de Debug**

La aplicación incluye logs detallados para debugging:

```
[GEOFENCE] Iniciando monitoreo para sucursal: Sucursal Saladillo Centro
[VIEWMODEL] Usuario entró a sucursal: Sucursal Saladillo Centro
[USECASE] Iniciando visita en sucursal: Sucursal Saladillo Centro
```

---

## 📊 **Analytics y Monitoreo**

### **Eventos de Firebase Analytics**

- `geofence_entered`: Usuario entró a sucursal
- `geofence_exited`: Usuario salió de sucursal
- `service_selected`: Usuario seleccionó tipo de servicio
- `location_permission_changed`: Cambio en permisos de ubicación
- `app_error`: Errores de la aplicación

### **Crashlytics**

- Reportes automáticos de crashes
- Información de contexto para debugging
- Stack traces detallados

---

## 🔄 **Roadmap Técnico**

### **Fase 1: Múltiples Sucursales desde Backend**
- [ ] API para cargar sucursales dinámicamente
- [ ] Cache local de configuración de sucursales
- [ ] Sincronización automática de datos

### **Fase 2: Anillos de Geofence por Clusters**
- [ ] Algoritmo de clustering geográfico
- [ ] Geofences anidados (cluster + sucursal)
- [ ] Optimización de detección por proximidad

### **Fase 3: Geofencing Inteligente**
- [ ] Machine Learning para predicción de visitas
- [ ] Optimización de batería y precisión
- [ ] Análisis de patrones de movimiento

---

## 👥 **Equipo de Desarrollo**

- **Arquitectura**: Clean Architecture + SOLID
- **UI Framework**: SwiftUI
- **Persistencia**: Core Data
- **Analytics**: Firebase Analytics + Crashlytics
- **Notificaciones**: Firebase Cloud Messaging
- **Geofencing**: CoreLocation

---

## 📄 **Licencia**

Este proyecto es propiedad de Banco Galicia y está destinado para uso interno.

---
