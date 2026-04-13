# Fedora OCI

Custom Fedora Kinoite OCI images built with Containerfiles and GitHub Actions.

## Installation

To rebase to the latest image, use the following:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:quay.io/fedora-oci/<target>:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://quay.io/fedora-oci/<target>:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

The images built in this repository are:

* quay.io/fedora-oci/nvidia:latest
* quay.io/fedora-oci/amd:latest

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub quay.io/fedora-oci/<target>
```
