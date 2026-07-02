#!/bin/bash

# AI PPT Desktop Release Script
# This script automates the release process for the application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="AI PPT Desktop"
VERSION="1.0.0"
BUILD_NUMBER=$(date +%Y.%m.%d)
RELEASE_DIR="release"
DIST_DIR="dist"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed"
        exit 1
    fi
    
    # Check Dart
    if ! command -v dart &> /dev/null; then
        print_error "Dart is not installed"
        exit 1
    fi
    
    # Check if in project directory
    if [ ! -f "pubspec.yaml" ]; then
        print_error "Not in Flutter project directory"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to run tests
run_tests() {
    print_status "Running tests..."
    
    # Run unit tests
    flutter test
    
    # Run integration tests
    flutter test integration_test/
    
    print_success "All tests passed"
}

# Function to analyze code
analyze_code() {
    print_status "Analyzing code..."
    
    # Run static analysis
    flutter analyze
    
    # Check code formatting
    dart format --set-exit-if-changed .
    
    print_success "Code analysis passed"
}

# Function to build for macOS
build_macos() {
    print_status "Building for macOS..."
    
    # Clean previous builds
    flutter clean
    
    # Get dependencies
    flutter pub get
    
    # Build for macOS
    flutter build macos --release
    
    # Create DMG
    create_dmg
    
    print_success "macOS build completed"
}

# Function to create DMG
create_dmg() {
    print_status "Creating DMG..."
    
    # Create release directory
    mkdir -p $RELEASE_DIR/macos
    
    # Copy build files
    cp -r build/macos/Build/Products/Release/*.app $RELEASE_DIR/macos/
    
    # Create DMG using create-dmg (if available)
    if command -v create-dmg &> /dev/null; then
        create-dmg \
            --volname "$APP_NAME" \
            --volicon "assets/icons/app_icon.icns" \
            --window-pos 200 120 \
            --window-size 600 400 \
            --icon-size 100 \
            --icon "AI PPT Desktop.app" 175 190 \
            --hide-extension "AI PPT Desktop.app" \
            --app-drop-link 425 190 \
            "$RELEASE_DIR/macos/$APP_NAME-$VERSION.dmg" \
            "$RELEASE_DIR/macos/"
    else
        print_warning "create-dmg not found, skipping DMG creation"
    fi
}

# Function to build for Windows
build_windows() {
    print_status "Building for Windows..."
    
    # Clean previous builds
    flutter clean
    
    # Get dependencies
    flutter pub get
    
    # Build for Windows
    flutter build windows --release
    
    # Create MSIX
    create_msix
    
    print_success "Windows build completed"
}

# Function to create MSIX
create_msix() {
    print_status "Creating MSIX..."
    
    # Create release directory
    mkdir -p $RELEASE_DIR/windows
    
    # Copy build files
    cp -r build/windows/runner/Release/* $RELEASE_DIR/windows/
    
    # Create MSIX using msix package
    dart run msix:create
    
    print_success "MSIX created"
}

# Function to build for Linux
build_linux() {
    print_status "Building for Linux..."
    
    # Clean previous builds
    flutter clean
    
    # Get dependencies
    flutter pub get
    
    # Build for Linux
    flutter build linux --release
    
    # Create packages
    create_linux_packages
    
    print_success "Linux build completed"
}

# Function to create Linux packages
create_linux_packages() {
    print_status "Creating Linux packages..."
    
    # Create release directory
    mkdir -p $RELEASE_DIR/linux
    
    # Copy build files
    cp -r build/linux/x64/release/bundle/* $RELEASE_DIR/linux/
    
    # Create DEB package (if dpkg-deb is available)
    if command -v dpkg-deb &> /dev/null; then
        create_deb_package
    fi
    
    # Create RPM package (if rpmbuild is available)
    if command -v rpmbuild &> /dev/null; then
        create_rpm_package
    fi
}

# Function to create DEB package
create_deb_package() {
    print_status "Creating DEB package..."
    
    # Create DEB structure
    mkdir -p $RELEASE_DIR/linux/deb/DEBIAN
    mkdir -p $RELEASE_DIR/linux/deb/usr/local/bin
    mkdir -p $RELEASE_DIR/linux/deb/usr/share/applications
    mkdir -p $RELEASE_DIR/linux/deb/usr/share/icons
    
    # Copy files
    cp -r $RELEASE_DIR/linux/* $RELEASE_DIR/linux/deb/usr/local/bin/
    
    # Create control file
    cat > $RELEASE_DIR/linux/deb/DEBIAN/control << EOL
Package: ai-ppt-desktop
Version: $VERSION
Section: utils
Priority: optional
Architecture: amd64
Maintainer: AI PPT Desktop Team <support@ai-ppt.com>
Description: AI-powered PPT creation desktop application
 AI PPT Desktop is a powerful presentation creation tool that uses
 artificial intelligence to help you create professional presentations
 quickly and easily.
EOL
    
    # Create desktop file
    cat > $RELEASE_DIR/linux/deb/usr/share/applications/ai-ppt-desktop.desktop << EOL
[Desktop Entry]
Name=AI PPT Desktop
Comment=AI-powered PPT creation application
Exec=/usr/local/bin/ai_ppt_desktop
Icon=ai-ppt-desktop
Terminal=false
Type=Application
Categories=Office;Presentation;
EOL
    
    # Build DEB package
    dpkg-deb --build $RELEASE_DIR/linux/deb $RELEASE_DIR/linux/ai-ppt-desktop-$VERSION-amd64.deb
    
    print_success "DEB package created"
}

# Function to create RPM package
create_rpm_package() {
    print_status "Creating RPM package..."
    
    # Create RPM spec file
    cat > $RELEASE_DIR/linux/ai-ppt-desktop.spec << EOL
Name: ai-ppt-desktop
Version: $VERSION
Release: 1
Summary: AI-powered PPT creation desktop application
License: MIT
URL: https://ai-ppt.com

%description
AI PPT Desktop is a powerful presentation creation tool that uses
artificial intelligence to help you create professional presentations
quickly and easily.

%install
mkdir -p %{buildroot}/usr/local/bin
cp -r * %{buildroot}/usr/local/bin/

%files
/usr/local/bin/ai_ppt_desktop
EOL
    
    # Build RPM package
    rpmbuild -bb $RELEASE_DIR/linux/ai-ppt-desktop.spec
    
    print_success "RPM package created"
}

# Function to generate release notes
generate_release_notes() {
    print_status "Generating release notes..."
    
    cat > $RELEASE_DIR/RELEASE_NOTES.md << EOL
# AI PPT Desktop v$VERSION

**Release Date**: $(date +%Y-%m-%d)
**Build Number**: $BUILD_NUMBER

## 🚀 New Features
- AI-powered PPT content generation
- Smart template recommendations
- Automatic layout and design
- Voice to PPT conversion
- Video to PPT conversion
- Real-time team collaboration
- Enterprise brand management
- Comprehensive help documentation

## 🔧 Improvements
- Optimized AI inference performance
- Enhanced error handling and recovery
- Improved user interface responsiveness
- Better memory management
- Faster application startup

## 🐛 Bug Fixes
- Fixed voice recognition accuracy issues
- Resolved video processing stability problems
- Fixed collaboration synchronization bugs
- Addressed brand application color issues
- Corrected layout calculation errors

## 📋 System Requirements
- **macOS**: 10.15 or later
- **Windows**: 10 or later
- **Linux**: Ubuntu 20.04 or later
- **RAM**: 4GB minimum
- **Storage**: 500MB free space

## 📦 Installation
### macOS
1. Download the DMG file
2. Open and drag to Applications
3. Launch from Applications folder

### Windows
1. Download the MSIX installer
2. Run the installer
3. Follow the setup wizard

### Linux
1. Download the DEB or RPM package
2. Install using package manager
3. Launch from application menu

## 📚 Documentation
- [User Manual](docs/user_manual.md)
- [API Documentation](docs/api_documentation.md)
- [Troubleshooting Guide](docs/troubleshooting.md)

## 🤝 Support
- **Email**: support@ai-ppt.com
- **Website**: https://ai-ppt.com
- **GitHub**: https://github.com/ai-ppt/desktop

## 🙏 Acknowledgments
Thank you to all our beta testers and contributors who helped make this release possible!

---
**Full Changelog**: https://github.com/ai-ppt/desktop/blob/main/CHANGELOG.md
EOL
    
    print_success "Release notes generated"
}

# Function to create checksums
create_checksums() {
    print_status "Creating checksums..."
    
    cd $RELEASE_DIR
    
    # Create checksums for all release files
    find . -type f -name "*.dmg" -o -name "*.msix" -o -name "*.deb" -o -name "*.rpm" | while read file; do
        sha256sum "$file" >> checksums.txt
    done
    
    cd ..
    
    print_success "Checksums created"
}

# Function to create release archive
create_release_archive() {
    print_status "Creating release archive..."
    
    # Create release archive
    tar -czf "$APP_NAME-$VERSION-$BUILD_NUMBER.tar.gz" -C $RELEASE_DIR .
    
    print_success "Release archive created"
}

# Main release function
main() {
    echo "=========================================="
    echo "   $APP_NAME Release Script"
    echo "   Version: $VERSION"
    echo "   Build: $BUILD_NUMBER"
    echo "=========================================="
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Run tests
    run_tests
    
    # Analyze code
    analyze_code
    
    # Create release directory
    mkdir -p $RELEASE_DIR
    
    # Build for all platforms
    build_macos
    build_windows
    build_linux
    
    # Generate release notes
    generate_release_notes
    
    # Create checksums
    create_checksums
    
    # Create release archive
    create_release_archive
    
    echo ""
    echo "=========================================="
    echo "   Release Complete!"
    echo "=========================================="
    echo ""
    echo "Release files are in: $RELEASE_DIR/"
    echo ""
    echo "Next steps:"
    echo "1. Test the release packages"
    echo "2. Upload to distribution channels"
    echo "3. Update release notes"
    echo "4. Notify users"
    echo ""
}

# Run main function
main