# tbc-docker

Пример применения полного цикла CI для Docker image.

Используемые Gitlab CI Template:

| Name                    | Module             | URL                                                                                                   |
|-------------------------|--------------------|-------------------------------------------------------------------------------------------------------|
| `to-be-continuous/docker` | `gitlab-ci-docker`   | https://gitlab.com/to-be-continuous/docker                                                            |
| `ci-remote-exec`          | `docker-healthcheck` | [ci-remote-exec/docker-healthcheck](https://gitlab.fizn.ru/library/cicd/templates/ci-remote-exec.git) |
| `sign`                    | `oci-cosign`         | [sign/oci-cosign](https://gitlab.fizn.ru/library/cicd/templates/sign.git)                             |
| `mirroring`               | `oci-repository`     | [mirroring/oci-repository](https://gitlab.fizn.ru/library/cicd/templates/mirroring.git)               |

---

## 

| Stage           | Utility / Implementation | Notes                       |
|-----------------|--------------------------|-----------------------------|
| `build`         | hadolint                 |                             |
| `package-build` | [buildah](./buildah.md)  |                             |
| `package-test`  | `healthcheck`            | Модуль `docker-healthcheck` |
| `package-test`  | `trivy`                  |
| `package-test`  | `sbom`                   |
| `publish`       | `cosign`                 | Модуль `oci-cosign`         |
| `publish`       | `skopeo`                 |                             |



---



---


### buildah

#### --format
По умолчанию собирает образы в формате OCI  
Эта спецификация не поддерживает HEALTHCHECK, поэтому либо 


```

```shell

```



docker_image=gitlab-registry.gitlab.svc:5000/library/cicd/examples/tbc-docker/buildah-snapshot:main
docker_image_digest=gitlab-registry.gitlab.svc:5000/library/cicd/examples/tbc-docker/buildah-snapshot@sha256:f479853f593ec5dfcbef04d2bcf969a6c9438fa920b4df5545e652aca19c8a11export docker_repository=$'\''gitlab-registry.gitlab.svc:5000/library/cicd/examples/tbc-docker/buildah-snapshot'\''
docker_repository=gitlab-registry.gitlab.svc:5000/library/cicd/examples/tbc-docker/buildah-snapshot
docker_tag=main
docker_digest=sha256:f479853f593ec5dfcbef04d2bcf969a6c9438fa920b4df5545e652aca19c8a11



