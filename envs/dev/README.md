# infra/envs/dev - Instrucciones rápidas

## Requisitos previos
1. Tener AWS CLI configurado (`aws configure`) con credenciales con permisos suficientes.
2. Crear el bucket y la tabla DynamoDB que usa el backend:
   - S3 bucket: `bcjwf-terraform-state-dev`
   - DynamoDB table (locking): `bcjwf-terraform-locks`
   Estos recursos **deben existir** antes de `terraform init`. (Puedes crearlos con la consola o con AWS CLI).
3. Asegúrate de que los módulos referenciados en `../../modules/*` existan (vpc, dynamodb, rds-postgres, ecs-cluster, ecr, ecs-service, lambda, api-gateway, sqs-ses).

## Flujo de trabajo (dev)
Desde `infra/envs/dev`:

```bash
# inicializar (usa el backend configurado en backend.tf)
terraform init

# validar plan (usa tfvars)
terraform plan -var-file=terraform.tfvars

# aplicar (reemplaza -auto-approve si quieres)
terraform apply -var-file=terraform.tfvars
