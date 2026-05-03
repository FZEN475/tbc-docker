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




### buildah

#### --format
По умолчанию собирает образы в формате OCI  
Эта спецификация не поддерживает HEALTHCHECK, поэтому либо 


```

```shell

```







