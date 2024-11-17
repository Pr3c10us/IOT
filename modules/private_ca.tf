resource "aws_acmpca_certificate_authority" "private_ca" {
  type          = "SUBORDINATE"
  key_algorithm = "RSA_2048"
  signing_algorithm = "SHA256WITHRSA"
  subject {
    common_name = "MyPrivateCA"
  }
}
