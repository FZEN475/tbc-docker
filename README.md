## tbc-docker

### Сравнение утилит.

| Утилита | Безопасность                  | hadolint | healthcheck | trivy | sbom | cosign |
|---------|-------------------------------|----------|-------------|-------|------|--------|
| buildah | Требует прав на монтирование* | Да       | External**  | Да    | Да   | Да     |
| dind    | --privileged                  | Да       | Да          | Да    | Да   | Да     |
| kaniko  |                               | Да       | External**  | Да    | Да   | Да     |

`*` Сейчас отключается appArmor на runner (`"appArmorProfile": { "type": "Unconfined" }`) требуется разобраться с Подключением профилей и системными вызовами.  
`**` Самостоятельная реализация job запуска контейнера.

### workflow.rules

```yaml
.tbc-workflow-rules:
  skip-back-merge:                            # Не запускать при обратном MR (из прод в feature)
  prefer-mr-pipeline:                         # => when: never
    - это обычный commit в ветку
    - и для этой ветки уже есть открытый MR
    - и ветка не prod и не integration
  extended-skip-ci:                           # Поиск в CI_COMMIT_MESSAGE паттерна [skip ci on ...]
    - "*tag" && $CI_COMMIT_TAG                # Не запускать на тэге
    - "*branch" && $CI_COMMIT_BRANCH          # Не запускать при обычном коммите
    - "*mr" && $CI_MERGE_REQUEST_ID           # Не запускать при MR
    - "*default" && $CI_COMMIT_REF_NAME =~ $CI_DEFAULT_BRANCH  # Не запускать на ветке по умолчанию
    - "*prod" && $CI_COMMIT_REF_NAME =~ $PROD_REF  # Не запускать на продакшене
    - "*integ" && $CI_COMMIT_REF_NAME =~ $INTEG_REF # Не запускать на интеграции
    - "*dev" && $CI_COMMIT_REF_NAME !~ $PROD_REF && $CI_COMMIT_REF_NAME !~ $INTEG_REF # Не запускать на продакшене и интеграции

```

### .test-policy
Правила применения тестирования
```yaml
.test-policy:                                
  - Это обычный commit -> on_success
  - ADAPTIVE_PIPELINE_DISABLED == "true" -> on_success
  - Ветка интеграции или релиза -> on_success
  - Это не MR и нет открытых -> manual && allow_failure=true
  - '$CI_MERGE_REQUEST_TITLE =~ /^Draft:.*/' ->  on_success && allow_failure=true
  - on_success
```

### .delivery-policy
Дополнительные правила при TBC_SBOM_MODE=onrelease
```yaml
.delivery-policy:
  - Тэг соответствует паттерну -> on_success
  - Ветка интеграции или релиза -> on_success
```

### variables
```yaml
variables:
  TBC_SBOM_MODE: "onrelease"
  TBC_DEFAULT_DOCKER_BUILD_TOOL: buildah
  # default production ref name (pattern)
  PROD_REF: '/^(master|main)$/'
  # default integration ref name (pattern)
  INTEG_REF: '/^develop$/'
  # default release tag name (pattern)
  RELEASE_REF: '/^v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9\-\.]+)?(\+[a-zA-Z0-9\-\.]+)?$/'

```

### stages

```yaml
stages:
  - build                                # docker-hadolint, 
  - test                                 # Нет job
  - package-build                        # docker-kaniko-build, docker-dind-build, docker-buildah-build
  - package-test                         # docker-healthcheck, docker-trivy, docker-sbom
  - infra                                # Нет job
  - deploy                               # Нет job
  - acceptance                           # Нет job
  - publish                              # docker-publish
  - infra-prod                           # Нет job
  - production                           # Нет job
```

### extends

```yaml
extends:
  .docker-base:
    .docker-kaniko-base:
      docker-kaniko-build:
    .docker-dind-base:
    docker-hadolint:
    docker-buildah-build:
    docker-trivy:
    docker-sbom:
    docker-publish:
```
### buildah

#### --format
По умолчанию собирает образы в формате OCI  
Эта спецификация не поддерживает HEALTHCHECK, поэтому либо 


### cosign

Ключи генерируются один раз и подписывают все артефакты в registry.  
#### key-based модель
Проверка подписи возможна только с открытым ключом.
Пример создания ключей:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cosign-test
  namespace: gitlab
spec:
  restartPolicy: Never
  containers:
    - name: cosign
      image: bitnami/cosign
      command:
        - /bin/sh
        - -c
        - sleep infinity
      env:
        - name: GITLAB_HOST
          value: "https://gitlab.fizn.ru"
        - name: COSIGN_PASSWORD
          value: "123"
      volumeMounts:
        - name: signing-configs
          mountPath: /signing_config_full.json
          subPath: signing_config_full.json
        - name: gitlab-ca
          mountPath: /etc/ssl/certs/ca.crt
          subPath: ca.crt
          readOnly: true
        - name: registry-secret
          mountPath: /.docker/config.json
          subPath: config.json
  volumes:
    - name: signing-configs
      configMap:
        name: signing-configs-cm
        items:
          - key: signing_config_full.json
            path: signing_config_full.json
    - name: gitlab-ca
      secret:
        secretName: cm-gitlab-tls
        items:
          - key: ca.crt
            path: ca.crt
    - name: registry-secret
      secret:
        secretName: gitlab-registry-access
        items:
          - key: .dockerconfigjson
            path: config.json
---
apiVersion: v1
data:
  signing_config_full.json: |
    {
      "mediaType": "application/vnd.dev.sigstore.signingconfig.v0.2+json",
      "caUrls": [
        {
          "url": "https://fulcio.sigstore.dev",
          "majorApiVersion": 1,
          "validFor": {
            "start": "2022-04-13T20:06:15.000Z"
          },
          "operator": "sigstore.dev"
        }
      ],
      "oidcUrls": [
        {
          "url": "https://oauth2.sigstore.dev/auth",
          "majorApiVersion": 1,
          "validFor": {
            "start": "2022-04-13T20:06:15.000Z"
          },
          "operator": "sigstore.dev"
        }
      ],
      "rekorTlogUrls": [
        {
          "url": "https://rekor.sigstore.dev",
          "majorApiVersion": 1,
          "validFor": {
            "start": "2021-01-12T11:53:27.000Z"
          },
          "operator": "sigstore.dev"
        }
      ],
      "tsaUrls": [
        {
          "url": "https://timestamp.sigstore.dev/api/v1/timestamp",
          "majorApiVersion": 1,
          "validFor": {
            "start": "2025-07-04T00:00:00Z"
          },
          "operator": "sigstore.dev"
        }
      ],
      "rekorTlogConfig": {
        "selector": "ANY"
      },
      "tsaConfig": {
        "selector": "ANY"
      }
    }
kind: ConfigMap
metadata:
  name: signing-configs-cm
  namespace: gitlab
```
```shell
# Токен с правами на создание values в репозитории
export GITLAB_TOKEN=glpat-
# Команда создаёт values в репозитории, которыми подписывается хэш
cosign --verbose generate-key-pair gitlab://<repo-id>
# Выгрузка ключа
cosign public-key --key gitlab://<repo-id> > cosign.pub
# Прямая проверка 
# --insecure-ignore-tlog=true - Игнорировать хранилище Rekor, если не использовалось (
cosign verify --key gitlab://<repo-id> gitlab://<Образ>:<Тег или SHA>
# По ключу
cosign verify --key cosign.pub gitlab://<Образ>:<Тег или SHA>

cosign verify --insecure-ignore-tlog=true --key
```

#### v2.5.0

Создаёт в registry sha256.*.att и sha256.*.sig подписи.

#### v3.*.*

Хранит подписи в манифесте хэша, поэтому нет sha256.*.att и sha256.*.sig

На данный момент это ломает стандартный pipline gitlab на этапе docker-publish из-за:
```shell
skopeo copy ... "docker://${snapshot_repository}:${sha}.sig" "docker://${release_repository}:${sha}.sig"
```
Жесткая привязка ломает копирование.


### skopeo

Утилита для копирования образов в registry

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: skopeo-test
  namespace: gitlab
spec:
  restartPolicy: Never
  containers:
    - name: skopeo
      image: quay.io/containers/skopeo:latest
      command:
        - /bin/sh
        - -c
        - sleep infinity
      env:
        - name: GITLAB_HOST
          value: "https://gitlab.fizn.ru"
        - name: COSIGN_PASSWORD
          value: "123"
      volumeMounts:
        - name: gitlab-ca
          mountPath: /etc/ssl/certs/ca.crt
          subPath: ca.crt
          readOnly: true
        - name: registry-secret
          mountPath: /.docker/config.json
          subPath: config.json
  volumes:
    - name: gitlab-ca
      secret:
        secretName: cm-gitlab-tls
        items:
          - key: ca.crt
            path: ca.crt
    - name: registry-secret
      secret:
        secretName: gitlab-registry-access
        items:
          - key: .dockerconfigjson
            path: config.json

```

```shell

```







