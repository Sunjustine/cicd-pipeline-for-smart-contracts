# You need to create 
# ssh-key-pair named "jenkins_key"


resource "aws_key_pair" "deployer" {
  key_name   = "jenkins_key"
  public_key = file("~/.ssh/jenkins_key.pub")
}
