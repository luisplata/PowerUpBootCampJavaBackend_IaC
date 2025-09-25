🗂️ Contexto del Proyecto (Infraestructura en AWS con Terraform)
🔹 Repositorios GIT

3 microservicios Java Webflux:

auth-service → usa RDS PostgreSQL (auth_db).

solicitudes-service → usa RDS PostgreSQL (solicitudes_db).

reportes-service → usa DynamoDB (reportes_table).

2 Lambdas:

lambda-capacidad → expuesta por API Gateway, conectada a DynamoDB (reportes_table).

lambda-envio-correo → consumidora de SQS, envía con SES.

🔹 Recursos AWS

Bases de datos:

2x RDS PostgreSQL (Auth, Solicitudes).

1x DynamoDB (Reportes).

Compute:

3 Microservicios Java en ECS/Fargate (uno por repo).

2 Lambdas (Capacidad, EnvíoCorreo).

Conectores y mensajería:

API Gateway (frente a Lambda Capacidad).

SQS Queue (para EnvíoCorreo).

SES (envío de emails).

🔹 Integraciones

Lambda Capacidad ← API Gateway → DynamoDB.

Auth-Service → PostgreSQL Auth.

Solicitudes-Service → PostgreSQL Solicitudes.

Reportes-Service → DynamoDB.

Lambda EnvíoCorreo ← SQS → SES.

🔹 Terraform

Estructura modular:

/modules → vpc, rds, dynamodb, ecs-service, lambda, api-gateway, sqs-ses, etc.

/envs/dev, /envs/prod → variables + main.tf para cada ambiente.

Cada repo de micro o lambda genera artefacto (Docker image o ZIP) y Terraform los consume desde ECR/S3.
```batch
infra/
├── modules/                # Módulos reutilizables (infra genérica)
│   ├── vpc/
│   ├── rds/
│   ├── dynamodb/
│   ├── ecs-cluster/
│   ├── ecs-service/
│   ├── ecr/
│   ├── lambda/
│   ├── api-gateway/
│   ├── sqs-ses/
│   └── security-groups/
│
├── envs/                   # Definición por ambiente (dev, prod, staging…)
│   ├── dev/
│   │   ├── main.tf         # Instancia módulos con valores de dev
│   │   ├── variables.tf    # Variables del ambiente
│   │   ├── terraform.tfvars # Valores específicos de dev
│   │   └── outputs.tf
│   ├── prod/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
│   └── staging/ (opcional)
│
├── global/                 # Configuración global de backend y providers
│   ├── provider.tf         # aws provider, versión de terraform
│   ├── backend.tf          # remote state (ej: S3 + DynamoDB lock)
│   └── locals.tf           # tags comunes, prefijos, naming
│
└── README.md
```