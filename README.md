<div align="center">
  <h1>🐳 Inception</h1>
  <p>Docker Compose를 활용한 시스템 관리 및 인프라 구축 프로젝트</p>

  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white">
  <img src="https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white">
  <img src="https://img.shields.io/badge/WordPress-21759B?style=for-the-badge&logo=wordpress&logoColor=white">
  <img src="https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white">
  <img src="https://img.shields.io/badge/Alpine_Linux-0D597F?style=for-the-badge&logo=alpinedotlinux&logoColor=white">
</div>

<br>

## 📖 프로젝트 개요

**Inception**은 시스템 관리 지식을 넓히기 위해 Docker를 사용하여 작은 인프라를 구축하는 프로젝트입니다.
`docker run`과 같은 간단한 명령어가 아닌, **Alpine Linux**를 베이스로 각 서비스(Nginx, WordPress, MariaDB)의 Dockerfile을 직접 작성하고 `docker-compose.yml`을 통해 오케스트레이션합니다.

---

## 🏗️ 아키텍처

이 인프라는 다음과 같은 구조로 독립적인 컨테이너들이 상호작용합니다.

| 서비스 (Service) | 설명 (Description) | 포트 (Port) |
| :--- | :--- | :--- |
| **Nginx** | TLSv1.2/v1.3 프로토콜을 지원하는 웹 서버로, 프로젝트의 유일한 진입점입니다. | 443 |
| **WordPress** | PHP-FPM을 통해 동작하는 CMS이며, Nginx와 MariaDB를 연결합니다. | 9000 (Internal) |
| **MariaDB** | WordPress 데이터를 저장하는 데이터베이스입니다. | 3306 (Internal) |

### 네트워크 및 볼륨
- **네트워크**: `inception` (bridge driver) - 모든 컨테이너가 이 네트워크를 통해 통신합니다.
- **볼륨**:
    - `wp_data`: WordPress 웹 파일 저장 (`/var/www/html`)
    - `db_data`: MariaDB 데이터베이스 저장 (`/var/lib/mysql`)

---

## 📂 디렉토리 구조

```plaintext
Inception/
├── Makefile                # 프로젝트 빌드 및 실행 자동화
├── srcs/
│   ├── docker-compose.yml  # 서비스 오케스트레이션 설정
│   └── requirements/       # 각 서비스별 설정 및 Dockerfile
│       ├── mariadb/
│       ├── nginx/
│       └── wordpress/
```

---

## 🚀 시작하기 (Getting Started)

### 사전 요구사항 (Prerequisites)
- Docker Desktop 또는 Docker Engine
- Docker Compose
- Make

### 설치 및 실행 (Installation & Usage)

1. **레포지토리 클론**
   ```bash
   git clone <repository-url>
   cd Inception
   ```

2. **프로젝트 실행**
   Makefile을 통해 간편하게 실행할 수 있습니다.
   ```bash
   make up
   ```
   > **실행 과정**:
   > 1. 필요한 호스트 데이터 디렉토리를 생성합니다.
   > 2. 각 서비스의 Docker 이미지를 빌드합니다.
   > 3. 컨테이너를 백그라운드에서 실행합니다.

3. **서비스 중지**
   ```bash
   make down
   ```

4. **상태 확인**
   ```bash
   make status
   ```
   
5. **로그 확인**
   ```bash
   make logs
   ```

6. **초기화 (주의)**
   ```bash
   make clean
   ```
   > ⚠️ **주의**: 모든 컨테이너, 네트워크, 이미지를 삭제하고 **볼륨 데이터까지 영구적으로 삭제**합니다.

---

## ⚙️ 설정 (Configuration)

모든 서비스 설정은 `srcs/docker-compose.yml` 파일과 `.env` 파일을 통해 관리됩니다.
환경 변수를 통해 데이터베이스 비밀번호, 사용자 이름 등을 안전하게 주입하여 컨테이너를 실행합니다.
