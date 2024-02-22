# shellcheck shell=bash
# shellcheck source=/dev/null
# shellcheck disable=SC2034
pkgname=mkxz
pkgver=2.1
<<<<<<< HEAD
=======
pkgrel=1
<<<<<<< HEAD
pkgname=mkxz
pkgver=2.1
>>>>>>> 19eca61 (	modified:   PKGBUILD)
pkgrel=1
=======
>>>>>>> 25e3ee2 (	modified:   PKGBUILD)
pkgdesc="A tool for archiving directories into .tar.xz files with options for excluding specific file types and generating a JSON index."
arch=('any')
url="https://github.com/seocringe/mkxz"
license=('GPL')
depends=('zsh' 'jq' 'tar' 'xz')
source=("${url}/archive/${pkgver}.tar.gz")
<<<<<<< HEAD
sha256sums=('actual_sha256_checksum_here') # Replace with the real checksum

package() {
  cd "${srcdir}/${pkgname}-${pkgver}" || return 1 # Error checking to ensure directory change was successful

  # Install the script to usr/bin making it executable
  install -Dm755 mkxz.zsh "${pkgdir}/usr/bin/mkxz"

  # Install the README.md to the documentation directory
=======
declare srcdir pkgdir
sha256sums=('actual_sha256_checksum_here')
package() {
  cd "${srcdir}/${pkgname}-${pkgver}" || return 1
  install -Dm755 mkxz.zsh "${pkgdir}/usr/bin/mkxz"
>>>>>>> 19eca61 (	modified:   PKGBUILD)
  install -Dm644 README.md "${pkgdir}/usr/share/doc/${pkgname}/README.md"
}