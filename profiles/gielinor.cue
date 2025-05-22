package gielinor

import "github.com/siderolabs/talos/pkg/imager/profile"

let TalosVersion = "v1.10.1"

let extensions = [
	"ghcr.io/siderolabs/crun:1.21",
	"ghcr.io/siderolabs/thunderbolt:v1.10.0",
	"ghcr.io/siderolabs/intel-ucode:20250211",
	"ghcr.io/siderolabs/i915-ucode:20241110",
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

artifactName: "\(output.kind)-\(arch)-secureboot.tar"
