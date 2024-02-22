# shellcheck shell=bash
# shellcheck source=/dev/null
# shellcheck disable=SC2034
pkgname=mkxz
pkgver=2.1
pkgrel=1
pkgdesc="A tool for archiving directories into .tar.xz files with options for excluding specific file types and generating a JSON index."
arch=('any')
url="https://github.com/seocringe/mkxz"
license=('GPL')
depends=('zsh' 'jq' 'tar' 'xz')
source=("${url}/archive/refs/tags/aur.tar.gz")
declare srcdir pkgdir
sha256sums=('edda99031a0e1d42fde2114077112fccea00cb73c1c1bb4993923d85a705e288')

package() {
  cd "${srcdir}/mkxz-aur" || return 1
  install -Dm755 mkxz.zsh "${pkgdir}/usr/bin/mkxz"
  install -Dm644 README.md "${pkgdir}/usr/share/doc/${pkgname}/README.md"
}
