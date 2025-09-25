terraform {
  backend "s3" {
    bucket         = "peryloth"                    # debes crearlo a mano la primera vez
    key            = "infra/dev/terraform.tfstate" # aquí se guardará el state de dev
    region         = "us-east-1"
    dynamodb_table = "terraform-locks" # opcional, para bloqueo de estado
  }
}
