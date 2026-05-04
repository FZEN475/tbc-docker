# tbc-docker

Пример применения полного цикла CI для Docker image:
- сборка
- анализ
- подпись
- зеркалирование

Основной акцент сделан на анализ работы [to-be-continuous/docker](https://gitlab.com/to-be-continuous/docker)

---

## Реализация

| Stage          | Utility / Implementation                                                        | Notes                       |
|----------------|---------------------------------------------------------------------------------|-----------------------------|
| build          | hadolint                                                                        |                             |
| package-build  | [buildah](./buildah.md)                                                         |                             |
| package-test   | [healthcheck](https://gitlab.fizn.ru/library/cicd/templates/ci-remote-exec.git) | Модуль `docker-healthcheck` |
| package-test   | trivy                                                                           |
| package-test   | sbom                                                                            |
| publish | [cosign](https://gitlab.fizn.ru/library/cicd/templates/sign.git)                | Модуль `oci-cosign`         |
| publish|skopeo | |

dockerfile_hash=$(echo "$DOCKER_FILE" | md5sum | cut -d" " -f1)
reports/docker-hadolint-$(echo "$DOCKER_FILE" | md5sum | cut -d" " -f1).codeclimate.json


---

reports/docker-healthcheck-report.log

---
docker_image=gitlab-registry.gitlab.svc:5000/library/cicd/examples/tbc-docker/buildah-snapshot:main
docker_image_digest=gitlab-registry.gitlab.svc:5000/library/cicd/examples/tbc-docker/buildah-snapshot@sha256:f479853f593ec5dfcbef04d2bcf969a6c9438fa920b4df5545e652aca19c8a11export docker_repository=$'\''gitlab-registry.gitlab.svc:5000/library/cicd/examples/tbc-docker/buildah-snapshot'\''
docker_repository=gitlab-registry.gitlab.svc:5000/library/cicd/examples/tbc-docker/buildah-snapshot
docker_tag=main
docker_digest=sha256:f479853f593ec5dfcbef04d2bcf969a6c9438fa920b4df5545e652aca19c8a11


### buildah

#### --format
По умолчанию собирает образы в формате OCI  
Эта спецификация не поддерживает HEALTHCHECK, поэтому либо 


```

```shell

```







