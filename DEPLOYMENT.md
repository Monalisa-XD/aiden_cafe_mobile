# Deployment Guide

This guide details how to build, run, and deploy the Aiden Cafe mobile frontend and containerized backend API.

---

## 1. Backend Deployment (Docker & MySQL)

The backend service is containerized using Docker and dynamically supports SQLite (default) and MySQL (production).

### Prerequisites
- [Docker](https://www.docker.com/)
- [MySQL Server](https://www.mysql.com/) (optional, required only for production)

### Local Docker Build & Run
To compile and run the backend inside a Docker container:
```bash
# Build the Docker image
docker build -t aiden-cafe-backend ./backend

# Run the container (using default local SQLite database)
docker run -d -p 5000:5000 --name aiden-cafe-api aiden-cafe-backend
```

### Production Deploy (with MySQL Database)
To run the container connected to a production MySQL database instance, inject the following environment variables:

| Variable | Description | Example |
|---|---|---|
| `MYSQL_HOST` | MySQL hostname | `db.aidencafe.com` |
| `MYSQL_USER` | Database username | `admin` |
| `MYSQL_PASSWORD`| Database password | `your_database_password` |
| `MYSQL_DATABASE`| Database name | `aiden_cafe` |
| `MYSQL_PORT` | Database connection port | `3306` |
| `MYSQL_SSL` | Enable SSL encryption (`true`/`false`) | `true` |

**Example command using environment variables:**
```bash
docker run -d -p 5000:5000 \
  -e MYSQL_HOST="db.aidencafe.com" \
  -e MYSQL_USER="admin" \
  -e MYSQL_PASSWORD="your_database_password" \
  -e MYSQL_DATABASE="aiden_cafe" \
  -e MYSQL_PORT="3306" \
  -e MYSQL_SSL="true" \
  --name aiden-cafe-api-production aiden-cafe-backend
```

---

## 2. Frontend Client Compiles (Flutter)

To package the mobile application for production, compile the release versions from the root folder:

### Android Release Build (APK)
Compiles a standard release APK:
```bash
flutter build apk --release
```
The output binary will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

### Web Release Build
Compiles the application to HTML/JS for hosting on CDNs:
```bash
flutter build web
```
The output directory will be:
`build/web/`
(This can be deployed to Vercel, Netlify, Github Pages, or static bucket storage).

### iOS Release Build
*Requires a macOS machine with Xcode installed:*
```bash
flutter build ipa --release
```
