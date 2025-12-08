# Guía de Distribución - APU The Manager

## 🚀 Generar Instaladores

Para generar todos los formatos de instalación disponibles:

```bash
./build-installer.sh
```

Este script generará:
- ✅ **`.tar.gz`** - Paquete universal con scripts de instalación
- ✅ **`.deb`** - Paquete para Debian/Ubuntu
- ✅ **`AppImage`** - Archivo ejecutable portable (si tienes appimagetool)

Todos los instaladores se generarán en el directorio `dist/`.

---

## 📦 Formatos de Instalación

### 1. TAR.GZ (Recomendado para compartir)

**Ventajas:**
- ✅ Universal - funciona en todas las distribuciones Linux
- ✅ Incluye scripts de instalación/desinstalación
- ✅ Fácil de distribuir y descargar
- ✅ No requiere herramientas especiales

**Instalación:**
```bash
tar -xzf apu-the-manager_1.0.0_linux_x64.tar.gz
cd apu-the-manager_1.0.0_linux_x64
sudo ./install.sh
```

**Desinstalación:**
```bash
sudo ./uninstall.sh
```

---

### 2. DEB (Debian/Ubuntu)

**Ventajas:**
- ✅ Integración nativa con apt
- ✅ Gestión automática de dependencias
- ✅ Desinstalación fácil

**Distribuciones compatibles:**
- Debian
- Ubuntu
- Linux Mint
- Pop!_OS
- Elementary OS
- Zorin OS

**Instalación:**
```bash
sudo dpkg -i apu-the-manager_1.0.0_amd64.deb
sudo apt-get install -f  # Instalar dependencias si es necesario
```

**Desinstalación:**
```bash
sudo apt remove apu-the-manager
```

---

### 3. AppImage (MÁS PORTABLE)

**Ventajas:**
- ✅ Un solo archivo ejecutable
- ✅ No requiere instalación
- ✅ Funciona en cualquier distribución moderna
- ✅ Portable - puedes ejecutarlo desde USB

**Instalación:**
```bash
chmod +x APU-The-Manager-1.0.0-x86_64.AppImage
./APU-The-Manager-1.0.0-x86_64.AppImage
```

**Integración con el sistema (opcional):**
```bash
# Mover a /opt
sudo mv APU-The-Manager-1.0.0-x86_64.AppImage /opt/apu-the-manager.AppImage

# Crear enlace simbólico
sudo ln -s /opt/apu-the-manager.AppImage /usr/local/bin/apu-the-manager

# Ejecutar desde terminal
apu-the-manager
```

---

## 🛠️ Requisitos para Generar Instaladores

### Básicos (Requeridos)
```bash
# Flutter debe estar instalado
flutter --version
```

### Para generar .deb
```bash
# Ubuntu/Debian
sudo apt-get install dpkg-dev

# Ya viene preinstalado en la mayoría de sistemas Debian/Ubuntu
```

### Para generar AppImage (Opcional)
```bash
# Descargar appimagetool
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
sudo mv appimagetool-x86_64.AppImage /usr/local/bin/appimagetool

# O usar linuxdeploy
wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage
sudo mv linuxdeploy-x86_64.AppImage /usr/local/bin/linuxdeploy
```

---

## 📤 Compartir los Instaladores

### GitHub Releases (Recomendado)

1. Crea un nuevo release en GitHub
2. Sube los archivos desde `dist/`:
   - `apu-the-manager_X.X.X_linux_x64.tar.gz`
   - `apu-the-manager_X.X.X_amd64.deb`
   - `APU-The-Manager-X.X.X-x86_64.AppImage`
   - `SHA256SUMS.txt`

3. En las release notes, incluye:
   ```markdown
   ## Instalación

   ### Opción 1: TAR.GZ (Universal)
   \`\`\`bash
   tar -xzf apu-the-manager_X.X.X_linux_x64.tar.gz
   cd apu-the-manager_X.X.X_linux_x64
   sudo ./install.sh
   \`\`\`

   ### Opción 2: DEB (Debian/Ubuntu)
   \`\`\`bash
   sudo dpkg -i apu-the-manager_X.X.X_amd64.deb
   \`\`\`

   ### Opción 3: AppImage (Portable)
   \`\`\`bash
   chmod +x APU-The-Manager-X.X.X-x86_64.AppImage
   ./APU-The-Manager-X.X.X-x86_64.AppImage
   \`\`\`

   ## Verificar Integridad
   \`\`\`bash
   sha256sum -c SHA256SUMS.txt
   \`\`\`
   ```

### Otras opciones

- **Google Drive / Dropbox**: Sube el .tar.gz o AppImage
- **Tu propio servidor**: Usa `wget` o `curl` para descargas
- **Flathub** (avanzado): Publica en la tienda de Flatpak
- **Snapcraft** (avanzado): Publica en la tienda de Snap

---

## 🔐 Firmar los Paquetes (Opcional pero Recomendado)

### Firmar con GPG

```bash
# Generar clave GPG si no tienes una
gpg --gen-key

# Firmar los paquetes
cd dist/
for file in *.{tar.gz,deb,AppImage}; do
    gpg --armor --detach-sign "$file"
done

# Los usuarios pueden verificar con:
gpg --verify archivo.tar.gz.asc archivo.tar.gz
```

---

## 📊 Estructura del Directorio `dist/`

Después de ejecutar `./build-installer.sh`:

```
dist/
├── apu-the-manager_1.0.0_linux_x64.tar.gz      (Universal)
├── apu-the-manager_1.0.0_amd64.deb             (Debian/Ubuntu)
├── APU-The-Manager-1.0.0-x86_64.AppImage       (Portable)
└── SHA256SUMS.txt                              (Checksums)
```

---

## 🎯 Recomendación de Distribución

**Para la mayoría de usuarios:**
→ **AppImage** (más fácil, no requiere instalación)

**Para usuarios técnicos de Debian/Ubuntu:**
→ **.deb** (integración con sistema de paquetes)

**Para máxima compatibilidad:**
→ **.tar.gz** (incluye scripts, funciona en todas partes)

---

## 📝 Checklist antes de Publicar

- [ ] Actualizada versión en `pubspec.yaml`
- [ ] Probada compilación en limpio: `flutter clean && flutter build linux --release`
- [ ] Ejecutado `./build-installer.sh` sin errores
- [ ] Probado cada formato de instalador en VM o sistema limpio
- [ ] Generados checksums SHA256
- [ ] (Opcional) Firmado con GPG
- [ ] Creado release notes con instrucciones de instalación
- [ ] Subido a GitHub Releases o plataforma de distribución

---

## 🐛 Troubleshooting

### Error: "libsecret-1 not found"
```bash
# El usuario final debe instalar:
sudo apt-get install libsecret-1-0  # Debian/Ubuntu
sudo dnf install libsecret           # Fedora
sudo pacman -S libsecret             # Arch
```

### AppImage no se genera
```bash
# Instalar appimagetool o linuxdeploy (ver sección de requisitos)
```

### .deb no se genera
```bash
# Instalar dpkg-dev
sudo apt-get install dpkg-dev
```

---

## 🔄 Automatizar con CI/CD

### GitHub Actions

Crea `.github/workflows/release.yml`:

```yaml
name: Build Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: sudo apt-get install -y libsecret-1-dev dpkg-dev
      - run: ./build-installer.sh
      - uses: actions/upload-artifact@v3
        with:
          name: linux-installers
          path: dist/*
```

---

## 📚 Referencias

- [Flutter Linux Desktop](https://docs.flutter.dev/platform-integration/linux/building)
- [AppImage Documentation](https://docs.appimage.org/)
- [Debian Package Guidelines](https://www.debian.org/doc/debian-policy/)
