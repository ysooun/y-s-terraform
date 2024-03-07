### terraform 구성
---
<img width="792" alt="스크린샷 2024-03-08 오전 3 37 36" src="https://github.com/ysooun/y-s-terraform/assets/154872496/ae6aa4ad-a49f-469f-8526-238146677bad">

1. terraform은 크게 vpc모듈, eks모듈, ec2모듈로 나누어 관리합니다.
2. bastion을 사용하여 eks와 database를 접근합니다.
3. eks version은 1.29 가장 최신버전을 사용했습니다.
4. RDS와 ec2 내부에 mysql을 설치하는 것을 고려했지만 비용적인 측면을 고려하여 ec2안에 데이터베이스를 설치했습니다.
5. ACM 서비스를 이용하여 ssl/tls (https)를 구현했습니다.
6. Route 53 서비스를 이용하여 도메인을 등록했습니다. (연결은 eks내부의 external-dns를 사용하여 연결합니다.)
7. terraform으로 정리된 내용은 s3에 vpc/eks/ec2의 폴더로 백업됩니다.

