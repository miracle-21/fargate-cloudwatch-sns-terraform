

## AWS Architecture
![](https://blog.kakaocdn.net/dn/oZf6t/btsqaOVMFL4/qQvh47Bmgr1xjWHI5uafl1/img.png)

## 목적
- Fargate에 웹/앱 서비스 배포
- Fargate(web - was) - RDS 연동으로 3tier 아키텍처 구축
- HPA AutoScaling 자동화
- CloudWatch Container Insights로 EKS 모니터링
- EKS Pod CPU Utilization 및 Memory Utilization 에 따른 SNS 알림
- ACM인증을 통한 Nginx Ingress(Network LoadBalancer)

## 구성
### 00. var.tf
terraform 파일에서 사용되는 변수
### 01. init.tf
terraform 설정 파일
### 02. vpc.tf
VCP 생성
### 03. eks.tf
EKS 클러스터, 노드그룹, IAM 역할 및 IAM 정책 생성
### 04. fargate.tf
fargate profile, fargate 배포, IAM 역할 및 IAM 정책 생성
### 05. sg.tf
클러스터 및 데이터베이스 보안 그룹
### 06. bastion.tf
kubenetes 및 AWS CLI 설치된 bastion 생성
### 07. rds.tf
MariaDB RDS 생성
### 08. sns.tf
CloudWatch 메트릭, SNS 주제, SNS 구독 대상 지정