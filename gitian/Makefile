all: clean prep build

nightly: clean prep-nightly build-nightly

alpha: clean prep-alpha build-alpha

beta: clean prep-beta build-beta

build:
	./mkbundle-linux.sh

build-nightly:
	./mkbundle-linux.sh versions.nightly
	./mkbundle-windows.sh versions.nightly
	./mkbundle-mac.sh versions.nightly
	./hash-bundles.sh versions.nightly

build-alpha:
	./mkbundle-linux.sh versions.alpha
	./mkbundle-windows.sh versions.alpha
	./mkbundle-mac.sh versions.alpha
	./hash-bundles.sh versions.alpha

build-beta:
	./mkbundle-linux.sh versions.beta
	./mkbundle-windows.sh versions.beta
	./mkbundle-mac.sh versions.beta
	./hash-bundles.sh versions.beta

sign:
	./upload-signature.sh versions

sign-alpha:
	./upload-signature.sh versions.alpha

sign-nightly:
	./upload-signature.sh versions.nightly

sign-beta:
	./upload-signature.sh versions.beta

match:
	./check-match.sh versions

match-nightly:
	./check-match.sh versions.nightly

match-alpha:
	./check-match.sh versions.alpha

match-beta:
	./check-match.sh versions.beta

prep:
	./check-prerequisites.sh
	./fetch-inputs.sh ../../gitian-builder/inputs/ versions

prep-nightly:
	./check-prerequisites.sh
	./fetch-inputs.sh ../../gitian-builder/inputs/ versions.nightly

prep-alpha:
	./check-prerequisites.sh
	./fetch-inputs.sh ../../gitian-builder/inputs/ versions.alpha

prep-beta:
	./check-prerequisites.sh
	./fetch-inputs.sh ../../gitian-builder/inputs/ versions.beta

clean: clean-utils clean-darkcoin clean-bundle
	rm -f ../../gitian-builder/inputs/*.yml
	rm -f ../../gitian-builder/inputs/bundle.inputs
	rm -f ../../gitian-builder/inputs/versions*

clean-utils: clean-bundle
	rm -f ../../gitian-builder/inputs/*utils.zip

clean-darkcoin: clean-bundle
	rm -f ../../gitian-builder/inputs/darkcoin-linux*
	rm -f ../../gitian-builder/inputs/darkcoin-mac*
	rm -f ../../gitian-builder/inputs/darkcoin-win*

clean-bundle:
	rm -f ../../gitian-builder/inputs/bundle-*

vmclean:
	rm -rf ../../gitian-builder/*.qcow2
	rm -rf ../../gitian-builder/base-*
	rm -rf ../../gitian-builder/target-{lucid,precise}*

distclean: vmclean
	rm -rf ../../gitian-builder/inputs/*
