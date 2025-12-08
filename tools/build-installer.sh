#!/bin/bash

# Script para generar instaladores de APU The Manager para Linux
# Compatible con: Ubuntu, Debian, Fedora, Arch Linux, y otras distribuciones

set -e  # Salir si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mensajes
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Obtener versión del pubspec.yaml
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | cut -d'+' -f1)
BUILD_NUMBER=$(grep '^version:' pubspec.yaml | sed 's/version: //' | cut -d'+' -f2)

if [ -z "$VERSION" ]; then
    error "No se pudo determinar la versión desde pubspec.yaml"
    exit 1
fi

info "Versión detectada: $VERSION (Build: $BUILD_NUMBER)"

# Variables
APP_NAME="apu-the-manager"
DISPLAY_NAME="APU The Manager"
BUILD_DIR="build/linux/x64/release"
DIST_DIR="dist"
BUNDLE_DIR="$BUILD_DIR/bundle"

# Crear directorio de distribución
mkdir -p "$DIST_DIR"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        Generador de Instaladores - APU The Manager            ║"
echo "║                    Versión: $VERSION                          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Verificar dependencias
info "Verificando dependencias del sistema..."

check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        warning "$1 no está instalado. Se omitirá la generación de algunos formatos."
        return 1
    else
        success "$1 encontrado"
        return 0
    fi
}

# Verificar Flutter
if ! command -v flutter &> /dev/null; then
    error "Flutter no está instalado. Instálalo desde https://flutter.dev"
    exit 1
fi
success "Flutter encontrado"

# Compilar la aplicación
echo ""
info "Compilando aplicación Flutter para Linux (Release)..."
flutter clean
flutter pub get
flutter build linux --release

if [ ! -d "$BUNDLE_DIR" ]; then
    error "La compilación falló. No se encontró $BUNDLE_DIR"
    exit 1
fi

success "Aplicación compilada exitosamente"

# ============================================================================
# FORMATO 1: TAR.GZ con script de instalación
# ============================================================================
echo ""
info "Generando paquete .tar.gz..."

TAR_NAME="${APP_NAME}_${VERSION}_linux_x64"
TAR_DIR="$DIST_DIR/$TAR_NAME"

# Limpiar directorio temporal si existe
rm -rf "$TAR_DIR"
mkdir -p "$TAR_DIR"

# Copiar archivos del bundle
cp -r "$BUNDLE_DIR"/* "$TAR_DIR/"

# Crear script de instalación
cat > "$TAR_DIR/install.sh" << 'INSTALL_SCRIPT'
#!/bin/bash

set -e

APP_NAME="apu-the-manager"
DISPLAY_NAME="APU The Manager"
INSTALL_DIR="/opt/$APP_NAME"
BIN_LINK="/usr/local/bin/$APP_NAME"
DESKTOP_FILE="/usr/share/applications/$APP_NAME.desktop"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     Instalador de APU The Manager para Linux                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then 
    echo "⚠ Este script requiere privilegios de root."
    echo "Por favor ejecuta: sudo ./install.sh"
    exit 1
fi

# Verificar dependencias
echo "ℹ Verificando dependencias del sistema..."

if ! pkg-config --exists libsecret-1; then
    echo "⚠ libsecret-1 no está instalado."
    echo ""
    echo "Para instalarlo:"
    echo "  Ubuntu/Debian: sudo apt-get install libsecret-1-dev"
    echo "  Fedora/RHEL:   sudo dnf install libsecret-devel"
    echo "  Arch Linux:    sudo pacman -S libsecret"
    echo ""
    read -p "¿Deseas continuar de todos modos? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 1
    fi
else
    echo "✓ libsecret-1 encontrado"
fi

# Crear directorio de instalación
echo "ℹ Instalando en $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"

# Copiar archivos
cp -r ./* "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/$APP_NAME"

# Crear enlace simbólico
echo "ℹ Creando enlace simbólico en $BIN_LINK..."
ln -sf "$INSTALL_DIR/$APP_NAME" "$BIN_LINK"

# Crear .desktop file
echo "ℹ Creando entrada de escritorio..."
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=$DISPLAY_NAME
Comment=Gestor de FileSearchStores y Documents de Gemini API
Exec=$INSTALL_DIR/$APP_NAME
Icon=$INSTALL_DIR/data/flutter_assets/assets/imgs/apu-the-manager.png
Terminal=false
Type=Application
Categories=Utility;Development;
Keywords=gemini;ai;filesearch;documents;
EOF

chmod 644 "$DESKTOP_FILE"

# Actualizar base de datos de aplicaciones
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database /usr/share/applications
fi

echo ""
echo "✓ ¡Instalación completada!"
echo ""
echo "Para ejecutar la aplicación:"
echo "  - Desde terminal: $APP_NAME"
echo "  - Desde el menú de aplicaciones: Busca '$DISPLAY_NAME'"
echo ""
INSTALL_SCRIPT

chmod +x "$TAR_DIR/install.sh"

# Crear script de desinstalación
cat > "$TAR_DIR/uninstall.sh" << 'UNINSTALL_SCRIPT'
#!/bin/bash

set -e

APP_NAME="apu-the-manager"
INSTALL_DIR="/opt/$APP_NAME"
BIN_LINK="/usr/local/bin/$APP_NAME"
DESKTOP_FILE="/usr/share/applications/$APP_NAME.desktop"

echo "Desinstalando APU The Manager..."

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then 
    echo "⚠ Este script requiere privilegios de root."
    echo "Por favor ejecuta: sudo ./uninstall.sh"
    exit 1
fi

# Eliminar archivos
rm -rf "$INSTALL_DIR"
rm -f "$BIN_LINK"
rm -f "$DESKTOP_FILE"

# Actualizar base de datos de aplicaciones
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database /usr/share/applications
fi

echo "✓ APU The Manager ha sido desinstalado"
echo ""
echo "Los datos del usuario en ~/.local/share/com.example.apu_the_manager"
echo "y en el keyring NO han sido eliminados."
echo ""
UNINSTALL_SCRIPT

chmod +x "$TAR_DIR/uninstall.sh"

# Crear README para el paquete
cat > "$TAR_DIR/README.txt" << EOF
═══════════════════════════════════════════════════════════════════════════
                     APU The Manager v$VERSION
                   Instalador para Linux (x64)
═══════════════════════════════════════════════════════════════════════════

INSTALACIÓN
───────────────────────────────────────────────────────────────────────────

1. Extraer el archivo:
   $ tar -xzf ${APP_NAME}_${VERSION}_linux_x64.tar.gz
   $ cd ${APP_NAME}_${VERSION}_linux_x64

2. Ejecutar el instalador:
   $ sudo ./install.sh

3. La aplicación se instalará en: /opt/$APP_NAME


DEPENDENCIAS DEL SISTEMA
───────────────────────────────────────────────────────────────────────────

Esta aplicación requiere libsecret-1 para el almacenamiento seguro.

Para instalar:
  Ubuntu/Debian:  sudo apt-get install libsecret-1-0
  Fedora/RHEL:    sudo dnf install libsecret
  Arch Linux:     sudo pacman -S libsecret


USO
───────────────────────────────────────────────────────────────────────────

Después de la instalación, puedes ejecutar la aplicación:
  - Desde terminal: apu-the-manager
  - Desde el menú de aplicaciones: Busca "APU The Manager"


DESINSTALACIÓN
───────────────────────────────────────────────────────────────────────────

$ sudo ./uninstall.sh

O manualmente:
  $ sudo rm -rf /opt/$APP_NAME
  $ sudo rm /usr/local/bin/$APP_NAME
  $ sudo rm /usr/share/applications/$APP_NAME.desktop


CONFIGURACIÓN
───────────────────────────────────────────────────────────────────────────

Al iniciar la aplicación por primera vez:
1. Ve a Configuración (ícono ⚙️)
2. Ingresa tu Gemini API Key
3. Presiona Guardar

La API key se almacenará de forma segura en el keyring del sistema.


SOPORTE
───────────────────────────────────────────────────────────────────────────

Para reportar problemas o obtener ayuda:
- GitHub: [URL del repositorio]
- Email: [tu email]

═══════════════════════════════════════════════════════════════════════════
EOF

# Crear el archivo tar.gz
cd "$DIST_DIR"
tar -czf "${TAR_NAME}.tar.gz" "$TAR_NAME"
cd - > /dev/null

# Limpiar directorio temporal
rm -rf "$TAR_DIR"

success "Paquete .tar.gz generado: $DIST_DIR/${TAR_NAME}.tar.gz"

# ============================================================================
# FORMATO 2: .DEB para Debian/Ubuntu
# ============================================================================
echo ""
info "Generando paquete .deb..."

if command -v dpkg-deb &> /dev/null; then
    DEB_NAME="${APP_NAME}_${VERSION}_amd64"
    DEB_DIR="$DIST_DIR/$DEB_NAME"
    
    # Estructura de directorios para .deb
    mkdir -p "$DEB_DIR/DEBIAN"
    mkdir -p "$DEB_DIR/opt/$APP_NAME"
    mkdir -p "$DEB_DIR/usr/share/applications"
    mkdir -p "$DEB_DIR/usr/share/pixmaps"
    
    # Copiar archivos de la aplicación
    cp -r "$BUNDLE_DIR"/* "$DEB_DIR/opt/$APP_NAME/"
    
    # Crear archivo control
    cat > "$DEB_DIR/DEBIAN/control" << EOF
Package: $APP_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: amd64
Depends: libsecret-1-0, libgtk-3-0, libglib2.0-0
Maintainer: Tu Nombre <tu@email.com>
Description: Gestor de FileSearchStores y Documents de Gemini API
 APU The Manager es una aplicación Flutter para gestionar
 FileSearchStores y Documents de la API de Gemini.
 Permite crear, listar, y eliminar stores y documentos.
Homepage: https://github.com/tu-usuario/apu-the-manager
EOF
    
    # Crear script postinst
    cat > "$DEB_DIR/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e

# Crear enlace simbólico
ln -sf /opt/apu-the-manager/apu_the_manager /usr/local/bin/apu-the-manager

# Actualizar base de datos de aplicaciones
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database /usr/share/applications 2>/dev/null || true
fi

exit 0
EOF
    chmod 755 "$DEB_DIR/DEBIAN/postinst"
    
    # Crear script prerm
    cat > "$DEB_DIR/DEBIAN/prerm" << 'EOF'
#!/bin/bash
set -e

# Eliminar enlace simbólico
rm -f /usr/local/bin/apu-the-manager

exit 0
EOF
    chmod 755 "$DEB_DIR/DEBIAN/prerm"
    
    # Crear .desktop file
    cat > "$DEB_DIR/usr/share/applications/$APP_NAME.desktop" << EOF
[Desktop Entry]
Name=$DISPLAY_NAME
Comment=Gestor de FileSearchStores y Documents de Gemini API
Exec=/opt/$APP_NAME/apu_the_manager
Icon=apu-the-manager
Terminal=false
Type=Application
Categories=Utility;Development;
Keywords=gemini;ai;filesearch;documents;
EOF
    
    # Copiar icono si existe
    if [ -f "assets/imgs/apu-the-manager.png" ]; then
        cp "assets/imgs/apu-the-manager.png" "$DEB_DIR/usr/share/pixmaps/apu-the-manager.png"
    fi
    
    # Construir el paquete .deb
    dpkg-deb --build "$DEB_DIR"
    mv "$DEB_DIR.deb" "$DIST_DIR/${APP_NAME}_${VERSION}_amd64.deb"
    
    # Limpiar
    rm -rf "$DEB_DIR"
    
    success "Paquete .deb generado: $DIST_DIR/${APP_NAME}_${VERSION}_amd64.deb"
else
    warning "dpkg-deb no encontrado. Omitiendo generación de .deb"
fi

# ============================================================================
# FORMATO 3: AppImage (el más portable)
# ============================================================================
echo ""
info "Generando AppImage..."

if check_dependency "appimagetool" || check_dependency "linuxdeploy"; then
    APPIMAGE_NAME="${DISPLAY_NAME// /-}-${VERSION}-x86_64"
    APPDIR="$DIST_DIR/$APP_NAME.AppDir"
    
    # Crear estructura AppDir
    mkdir -p "$APPDIR/usr/bin"
    mkdir -p "$APPDIR/usr/lib"
    mkdir -p "$APPDIR/usr/share/applications"
    mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"
    
    # Copiar binario y recursos
    cp -r "$BUNDLE_DIR"/* "$APPDIR/usr/bin/"
    
    # Crear .desktop file
    cat > "$APPDIR/$APP_NAME.desktop" << EOF
[Desktop Entry]
Name=$DISPLAY_NAME
Exec=apu_the_manager
Icon=apu-the-manager
Type=Application
Categories=Utility;Development;
EOF
    
    cp "$APPDIR/$APP_NAME.desktop" "$APPDIR/usr/share/applications/"
    
    # Copiar icono
    if [ -f "assets/imgs/apu-the-manager.png" ]; then
        cp "assets/imgs/apu-the-manager.png" "$APPDIR/apu-the-manager.png"
        cp "assets/imgs/apu-the-manager.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/apu-the-manager.png"
    fi
    
    # Crear AppRun script
    cat > "$APPDIR/AppRun" << 'EOF'
#!/bin/bash
APPDIR="$(dirname "$(readlink -f "${0}")")"
export LD_LIBRARY_PATH="$APPDIR/usr/lib:$LD_LIBRARY_PATH"
export PATH="$APPDIR/usr/bin:$PATH"
exec "$APPDIR/usr/bin/apu_the_manager" "$@"
EOF
    chmod +x "$APPDIR/AppRun"
    
    # Generar AppImage
    if command -v appimagetool &> /dev/null; then
        ARCH=x86_64 appimagetool "$APPDIR" "$DIST_DIR/$APPIMAGE_NAME.AppImage"
        success "AppImage generado: $DIST_DIR/$APPIMAGE_NAME.AppImage"
    elif command -v linuxdeploy &> /dev/null; then
        linuxdeploy --appdir "$APPDIR" --output appimage
        mv *.AppImage "$DIST_DIR/$APPIMAGE_NAME.AppImage" 2>/dev/null || true
        success "AppImage generado: $DIST_DIR/$APPIMAGE_NAME.AppImage"
    fi
    
    # Limpiar
    rm -rf "$APPDIR"
else
    warning "Ni appimagetool ni linuxdeploy encontrados. Omitiendo AppImage"
    info "Para generar AppImages, instala:"
    info "  wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    info "  chmod +x appimagetool-x86_64.AppImage"
    info "  sudo mv appimagetool-x86_64.AppImage /usr/local/bin/appimagetool"
fi

# ============================================================================
# Resumen Final
# ============================================================================
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                  ✓ Generación Completada                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
success "Paquetes generados en: $DIST_DIR/"
echo ""
ls -lh "$DIST_DIR"
echo ""

# Generar checksums SHA256
echo ""
info "Generando checksums SHA256..."
cd "$DIST_DIR"
sha256sum *.{tar.gz,deb,AppImage} 2>/dev/null > SHA256SUMS.txt || sha256sum * > SHA256SUMS.txt
cd - > /dev/null
success "Checksums guardados en: $DIST_DIR/SHA256SUMS.txt"

echo ""
info "Formatos generados:"
echo "  • .tar.gz  → Universal (con scripts install/uninstall)"
echo "  • .deb     → Debian, Ubuntu, Linux Mint, Pop!_OS, etc."
echo "  • AppImage → Portable (un solo archivo ejecutable)"
echo ""
info "Tamaño total de distribución:"
du -sh "$DIST_DIR"

echo ""
success "¡Listo para distribuir!"
