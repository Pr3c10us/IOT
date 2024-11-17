resource "aws_acmpca_certificate_authority" "private_ca" {
  type          = "SUBORDINATE"
  certificate_authority_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      common_name = "MyPrivateCA"
    }
  }
}
