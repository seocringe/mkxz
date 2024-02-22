pkgname=mkxz
pkgver=1.0
pkgrel=1
pkgdesc="A tool for archiving directories into .tar.xz files with options for excluding specific file types and generating a JSON index."
arch=('any')
url="https://github.com/seocringe/mkxz"
license=('GPL')
depends=('zsh' 'jq' 'tar' 'xz') # Добавлен jq в список зависимостей
source=("${url}/archive/${pkgver}.tar.gz")
sha256sums=('SKIP')

package() {
  cd "${srcdir}/${pkgname}-${pkgver}"
  install -Dm755 mkxz.zsh "${pkgdir}/usr/bin/mkxz" # Убедитесь, что скрипт имеет права на выполнение
  install -Dm644 README.md "${pkgdir}/usr/share/doc/${pkgname}/README.md"
}
