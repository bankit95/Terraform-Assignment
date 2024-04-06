resource "aws_efs_file_system" "sm-efs" {
  creation_token   = "sm-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"
  tags = {
    Name        = "sm-storage"
    Environment = "test"
  }
}

resource "aws_efs_mount_target" "sm-efs-1" {
  file_system_id  = aws_efs_file_system.sm-efs.id
  subnet_id       = var.subnet1_id
  security_groups = [var.efs-mt1-sg]
}

resource "aws_efs_mount_target" "sm-efs-2" {
  file_system_id  = aws_efs_file_system.sm-efs.id
  subnet_id       = var.subnet2_id
  security_groups = [var.efs-mt2-sg]
}

resource "aws_efs_mount_target" "sm-efs-3" {
  file_system_id  = aws_efs_file_system.sm-efs.id
  subnet_id       = var.subnet3_id
  security_groups = [var.efs-mt3-sg]
}

output "efs_id" {
  value = aws_efs_file_system.sm-efs.id
}

output "efs_mt1_id" {
  value = aws_efs_mount_target.sm-efs-1.id
}

output "efs_mt2_is" {
  value = aws_efs_mount_target.sm-efs-2.id
}

output "efs_mt3_is" {
  value = aws_efs_mount_target.sm-efs-3.id
}

