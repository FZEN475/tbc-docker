
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

### workflow.rules

```yaml
.tbc-workflow-rules:

  # 1. Не запускать pipeline для обратных MR
  # (если source-ветка = prod или integration)
  skip-back-merge:
    - MR из prod или integration → pipeline не запускается

  # 2. Предпочесть MR pipeline вместо branch pipeline
  # Условия:
  # - это commit в ветку
  # - для ветки уже есть открытый MR
  # - ветка НЕ prod и НЕ integration
  prefer-mr-pipeline:
    - тогда branch pipeline отключается

  # 3. (Альтернатива) Предпочесть branch pipeline
  # Если используется это правило — MR pipeline отключается
  prefer-branch-pipeline:
    - любой MR → pipeline не запускается

  # 4. Расширенный skip CI через commit message
  # Формат:
  # [skip ci on <scope1,scope2,...>]
  #
  # Где scope:
  # - tag      → пропуск для тегов
  # - branch   → пропуск для branch pipeline
  # - mr       → пропуск для MR pipeline
  # - default  → пропуск для default branch
  # - prod     → пропуск для prod
  # - integ    → пропуск для integration
  # - dev      → пропуск для всех, кроме prod и integration
  extended-skip-ci:
    - если commit message содержит соответствующий scope → pipeline не запускается
```

### .test-policy
Правила применения тестирования
```yaml
.test-policy:

  # 1. Всегда запускать тесты автоматически (и падать при ошибке), если:
  - это tag
  - ADAPTIVE_PIPELINE_DISABLED == "true"
  - ветка = prod или integration

  # 2. Ранний этап разработки (dev-ветка без MR)
  - нет MR и нет открытых MR для ветки
    → запуск вручную (manual)
    → падение не влияет (allow_failure=true)

  # 3. Draft MR
  - MR с заголовком "Draft: ...":
    → запускается автоматически
    → падение не влияет (allow_failure=true)

  # 4. Обычный (готовый) MR
  - всё остальное
    → запускается автоматически
    → падение критично (pipeline падает)
```

### .delivery-policy
Дополнительные правила при TBC_SBOM_MODE=onrelease
```yaml
.delivery-policy:

  # Job запускается автоматически, если выполняется хотя бы одно из условий:

  - это tag, который соответствует release-паттерну

  - ветка = prod или integration
```