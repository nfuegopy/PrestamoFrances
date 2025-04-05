# Calculadora de Préstamos

![Flutter](https://img.shields.io/badge/Flutter-3.29.2-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.7.2-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg)

**Calculadora de Préstamos** es una aplicación móvil desarrollada en Flutter que permite calcular y gestionar préstamos utilizando el sistema de amortización francés. Esta app está diseñada para usuarios que desean obtener un resumen claro y detallado de sus préstamos, generar proformas en formato PDF, y compartirlas fácilmente. Es ideal para profesionales financieros, prestamistas, o cualquier persona que necesite calcular cuotas mensuales, intereses, y saldos de préstamos.

## Características principales

- **Cálculo de préstamos (Sistema Francés):** Calcula cuotas mensuales, intereses totales, y el monto total a pagar basado en el capital, la tasa de interés anual, y el plazo en meses.
- **Soporte para múltiples monedas:** Permite calcular préstamos en Guaraníes (₲) o Dólares (USD), con formatos de número personalizados (por ejemplo, `₲ 1.000.000` para guaraníes y `$1,000,000` para dólares).
- **Datos del cliente personalizables:** Ingresa el nombre del cliente, identificación, y fechas relevantes (fecha de emisión y fecha de vencimiento). Incluye opciones para omitir datos como el cliente (innominado) o la fecha de vencimiento.
- **Resumen financiero:** Muestra un resumen claro con la cuota mensual, el total a pagar, y los intereses acumulados.
- **Tabla de amortización:** Genera una tabla detallada con el desglose de cada mes, incluyendo cuota, interés, capital amortizado, y saldo pendiente.
- **Generación y descarga de PDF:** Crea proformas en formato PDF con todos los detalles del préstamo, incluyendo datos del cliente y la tabla de amortización.
- **Compartir PDF:** Permite compartir el PDF generado a través de aplicaciones como WhatsApp, correo, o cualquier app compatible.
- **Interfaz intuitiva y estética:** Diseño limpio y moderno con secciones bien organizadas, un footer personalizado ("Desarrollado por Antonio Barrios"), y opciones para ocultar/mostrar la tabla de amortización.

## Capturas de pantalla

*Próximamente se agregarán capturas de pantalla para mostrar la interfaz de la app.*

## Requisitos previos

Antes de ejecutar este proyecto, asegúrate de cumplir con los siguientes requisitos:

- **Flutter SDK:** Versión 3.29.2 o superior.
- **Dart:** Versión 3.7.2 o superior (incluida con Flutter).
- **Dispositivo o emulador:** Un dispositivo Android (API 21 o superior) o iOS (iOS 12.0 o superior), o un emulador configurado.
- **Entorno de desarrollo:**
  - Android Studio o Visual Studio Code con los plugins de Flutter y Dart instalados.
  - Configura el entorno de desarrollo según las instrucciones oficiales de Flutter: [Instalación de Flutter](https://docs.flutter.dev/get-started/install).
- **JDK:** Versión 21 (recomendado, incluido con Android Studio).

## Instalación y ejecución

Sigue estos pasos para clonar, configurar y ejecutar el proyecto en tu máquina local:

1. **Clona el repositorio:**
   ```bash
   git clone https://github.com/AntonioBarrios/calculadora_prestamos.git
   cd calculadora_prestamos
   ```

2. **Instala las dependencias:** Asegúrate de tener Flutter instalado y ejecuta el siguiente comando para descargar las dependencias:
   ```bash
   flutter pub get
   ```

3. **Configura el ícono de la app (opcional):**
   - Si deseas personalizar el ícono de la app, coloca tu ícono en `assets/icons/app_icon.png` (1024x1024 píxeles, formato PNG).
   - Asegúrate de que el archivo `flutter_launcher_icons.yaml` esté configurado:
     ```yaml
     flutter_launcher_icons:
       android: true
       ios: true
       image_path: "assets/icons/app_icon.png"
       min_sdk_android: 21
     ```
   - Genera los íconos:
     ```bash
     dart run flutter_launcher_icons
     ```

4. **Ejecuta la app:** Conecta un dispositivo Android/iOS o inicia un emulador, y ejecuta:
   ```bash
   flutter run
   ```
   Esto compilará y lanzará la app en tu dispositivo o emulador.

## Generar un APK para instalación

Para generar un APK que puedas instalar en un dispositivo Android:

1. **Limpia el proyecto:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Construye el APK:** Genera un APK en modo release:
   ```bash
   flutter build apk --release
   ```
   El APK se generará en:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

3. **Instala el APK:**
   - Transfiere el archivo `app-release.apk` a tu dispositivo Android (por ejemplo, mediante USB o correo).
   - Habilita "Fuentes desconocidas" en la configuración de seguridad de tu dispositivo.
   - Abre el archivo y sigue las instrucciones para instalarlo.

## Permisos

La app utiliza los siguientes permisos mínimos necesarios:

- **Android:**
  - `WRITE_EXTERNAL_STORAGE` y `READ_EXTERNAL_STORAGE` (solo para Android 9 y versiones anteriores, para compartir PDFs).
- **iOS:**
  - `LSSupportsOpeningDocumentsInPlace` y `UIFileSharingEnabled` (para compartir PDFs).

Estos permisos están configurados en:
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

## Estructura del proyecto

- `lib/`: Contiene el código fuente de la app.
  - `main.dart`: Punto de entrada de la aplicación.
  - `models/amortizacion_model.dart`: Modelo de datos para manejar los cálculos y la lógica del préstamo.
  - `screens/calculadora_screen.dart`: Pantalla principal con la interfaz de usuario.
  - `screens/pdf_preview_screen.dart`: Pantalla para previsualizar y descargar el PDF.
  - `utils/pdf_generator.dart`: Lógica para generar el PDF.
- `assets/`: Carpeta para recursos estáticos como el ícono de la app (`assets/icons/app_icon.png`).
- `android/`: Configuración específica para Android.
- `ios/`: Configuración específica para iOS.
- `pubspec.yaml`: Archivo de configuración de dependencias y assets.

## Dependencias utilizadas

- `flutter`: SDK principal.
- `provider: ^6.1.2`: Para la gestión del estado.
- `intl: ^0.20.2`: Para el formato de fechas y números.
- `pdf: ^3.11.3`: Para generar archivos PDF.
- `printing: ^5.14.2`: Para previsualizar y compartir PDFs.
- `share_plus: ^10.1.4`: Para compartir archivos.
- `path_provider: ^2.1.5`: Para acceder a directorios temporales.
- `flutter_launcher_icons: ^0.13.1`: Para generar íconos de instalación (dev dependency).

## Contribuir

Si deseas contribuir a este proyecto:

1. Haz un fork del repositorio.
2. Crea una rama para tu funcionalidad (`git checkout -b nueva-funcionalidad`).
3. Realiza tus cambios y haz commit (`git commit -m "Agrega nueva funcionalidad"`).
4. Sube los cambios a tu fork (`git push origin nueva-funcionalidad`).
5. Crea un pull request en este repositorio.

## Créditos

- **Desarrollador:** Antonio Barrios
- **Tecnología:** Flutter y Dart
- **Diseño:** Interfaz personalizada con un enfoque en usabilidad y estética.

## Licencia

Este proyecto está licenciado bajo la .

---

**Desarrollado por Antonio Barrios**

*Última actualización: 05 de abril de 2025*