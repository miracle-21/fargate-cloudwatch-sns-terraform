#!/bin/bash
# 설치
yum install -y unzip docker git s3fs-fuse
# AWSCLI 설치 및 config
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
mkdir /home/ec2-user/.aws
cat > /home/ec2-user/.aws/credentials << EOF
[default]
aws_access_key_id=${access_key}
aws_secret_access_key=${secret_key}
region=${region}
EOF
sudo -u ec2-user aws eks update-kubeconfig
# kubenetes 설치
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc && source ~/.bashrc
# kubectl 명령어 자동완성
source <(sudo -u ec2-user kubectl completion bash)
sudo -u ec2-user echo "source <(kubectl completion bash)" >> ~/.bashrc
sudo -u ec2-user aws eks --region ${region} update-kubeconfig --name ${cluname}
# ingress
cd /home/ec2-user/ && git clone https://github.com/miracle-21/yaml_file.git
sed -i "s\ACM_ARN\${ACM_ARN}\g" /home/ec2-user/yaml_file/ingress-controller.yaml
sudo -u ec2-user kubectl apply -f /home/ec2-user/yaml_file/ingress-controller.yaml
sudo -u ec2-user kubectl apply -f /home/ec2-user/yaml_file/ingress.yaml
deploy metrics-server
git clone https://github.com/kubernetes-sigs/metrics-server.git
sudo -u ec2-user kubectl apply -k /home/ec2-user/metrics-server/manifests/base/
# cloudwatch
sudo -u ec2-user kubectl apply -f /home/ec2-user/yaml_file/ingress.yaml
sed -i 's/{{cluster_name}}/'${cluname}'/;s/{{region_name}}/'${region}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' /home/ec2-user/yaml_file/fluent-bit.yaml
sudo -u ec2-user kubectl apply -f /home/ec2-user/yaml_file/fluent-bit.yaml
# argoCD
sudo -u ec2-user kubectl create namespace argocd
sudo -u ec2-user kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/ha/install.yaml
sudo -u ec2-user kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
# docker 실행
systemctl start docker
systemctl enable docker
