# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

MYPN=TAUOLA

DESCRIPTION="tau decay Monte Carlo generator"
HOMEPAGE="http://tauolapp.web.cern.ch/tauolapp/"
SRC_URI=""
LICENSE="unknown"

SLOT="0"
KEYWORDS="~x86"
IUSE="doc examples hepmc tau-spinner"

RDEPEND="hepmc? ( sci-physics/hepmc )
	tau-spinner? ( sci-physics/lhapdf )
"
DEPEND="${RDEPEND}
	net-misc/wget
	doc? ( app-doc/doxygen
		app-text/ghostscript-gpl
		app-text/texlive )
"

S="${WORKDIR}/${MYPN}"

src_unpack() {
	#there is no public svn, just generated tarball, so fetch it
	wget "http://tauolapp.web.cern.ch/tauolapp/resources/${MYPN}.development.version/${MYPN}.development.version.tar.gz" || die
	unpack "./${MYPN}.development.version.tar.gz"
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-1.1.3-makefile.patch" "${FILESDIR}/${PN}-1.1.3-tau-spinner-makefile.patch"
}

src_configure() {
	econf \
		--without-mc-tester \
		--without-pythia8 \
		$(use_with hepmc hepmc "/usr") \
		$(use_with tau-spinner) \
		$(use_with tau-spinner lhapdf "/usr")
}

src_compile() {
	emake
	if use doc;
	then
		cd "${S}/documentation/doxy_documentation" || die
		make || die
		cd "${S}/documentation/latex_documentation" || die
		make || die
	fi
}

src_install() {
	emake PREFIX="${D}/usr" install

	if use doc; then
		dohtml documentation/doxy_documentation/html/*
		dodoc documentation/latex_documentation/Tauola_interface_design.pdf
	fi

	if use examples;
	then
		dodoc -r examples
		use tau-spinner && docinto tau-spinner && dodoc -r TauSpinner/examples
	fi
}