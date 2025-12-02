variable "aws_region" {
  description = "Região AWS"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo da instância"
  default     = "t3.small"
}

variable "spot_price" {
  description = "Preço máximo spot"
  default     = "0.02"
}

variable "worker_count" {
  description = "Quantidade de workers"
  default     = 1
}

variable "key_name" {
  description = "Key pair SSH"
  default     = ""
}
