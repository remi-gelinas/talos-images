package gielinor

import "github.com/siderolabs/talos/pkg/imager/profile"

// renovate: datasource=github-releases depName=siderolabs/talos
let TalosVersion = "v1.10.3"

let extensions = [
	// renovate: datasource=docker versioning=semver-coerced
	"ghcr.io/siderolabs/crun:1.21",

	// renovate: datasource=docker versioning=semver-coerced
	"ghcr.io/siderolabs/thunderbolt:v1.10.2",

	// renovate: datasource=docker versioning=loose
	"ghcr.io/siderolabs/intel-ucode:20250211",

	// renovate: datasource=docker versioning=loose
	"ghcr.io/siderolabs/i915-ucode:20241110",

	// renovate: datasource=docker versioning=semver
	"ghcr.io/siderolabs/util-linux-tools:2.40.4",
]

profile.#Profile

platform:   "metal"
arch:       "amd64"
version:    TalosVersion
secureboot: true

input: {
	kernel: path:    "/usr/install/amd64/vmlinuz"
	initramfs: path: "/usr/install/amd64/initramfs.xz"
	sdStub: path:    "/usr/install/amd64/systemd-stub.efi"
	sdBoot: path:    "/usr/install/amd64/systemd-boot.efi"

	baseInstaller: imageRef: "ghcr.io/siderolabs/installer-base:\(TalosVersion)"

	secureboot: {
		pcrSigner: keyPath: "/secureboot/PCR.pkcs1.key"
		platformKeyPath:    "/secureboot/PK.auth"
		keyExchangeKeyPath: "/secureboot/KEK.auth"
		signatureKeyPath:   "/secureboot/db.auth"

		secureBootSigner: {
			keyPath:  "/secureboot/PK.pkcs1.key"
			certPath: "/secureboot/PK.crt"
		}
	}

	systemExtensions: [for extension in extensions {imageRef: extension}]
}

customization: extraKernelArgs: []

output: {
	kind:      "installer"
	outFormat: "raw"
}

#profile: {
	name:     "gielinor"
	artifact: "\(output.kind)-\(arch)-secureboot.tar"
}
