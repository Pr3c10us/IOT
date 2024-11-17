resource "aws_iot_certificate" "device_cert" {
  active = true
}

resource "aws_iot_policy" "iot_policy" {
  name   = "IoTDevicePolicy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iot:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iot_policy_attachment" "policy_attach" {
  policy       = aws_iot_policy.iot_policy.name
  target       = aws_iot_certificate.device_cert.arn
}

resource "aws_iot_thing" "iot_thing" {
  name = "MyIoTDevice"
}

resource "aws_iot_thing_principal_attachment" "thing_attach" {
  principal = aws_iot_certificate.device_cert.arn
  thing     = aws_iot_thing.iot_thing.name
}
