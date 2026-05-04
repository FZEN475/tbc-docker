# tbc-docker

Пример применения полного цикла CI для Docker image.

---

## Description

Используемые Gitlab CI Template:

| Name                    | Module             | URL                                                                                                   |
|-------------------------|--------------------|-------------------------------------------------------------------------------------------------------|
| `to-be-continuous/docker` | `gitlab-ci-docker`   | https://gitlab.com/to-be-continuous/docker                                                            |
| `ci-remote-exec`          | `docker-healthcheck` | [ci-remote-exec/docker-healthcheck](https://gitlab.fizn.ru/library/cicd/templates/ci-remote-exec.git) |
| `sign`                    | `oci-cosign`         | [sign/oci-cosign](https://gitlab.fizn.ru/library/cicd/templates/sign.git)                             |
| `mirroring`               | `oci-repository`     | [mirroring/oci-repository](https://gitlab.fizn.ru/library/cicd/templates/mirroring.git)               |

Отчёт по анализу работы [tbc-docker](tbc-docker.md) и пояснения к [inputs](./.gitlab-ci.docker-example.yml).

Заметки при настройке [buildah](./buildah.md).

| Stage           | Utility / Implementation | Notes                       |
|-----------------|--------------------------|-----------------------------|
| `build`         | hadolint                 |                             |
| `package-build` | [buildah](./buildah.md)  |                             |
| `package-test`  | `healthcheck`            | Модуль `docker-healthcheck` |
| `package-test`  | `trivy`                  |                             |
| `package-test`  | `sbom`                   |                             |
| `publish`       | `cosign`                 | Модуль `oci-cosign`         |
| `publish`       | `skopeo`                 |                             |
---

