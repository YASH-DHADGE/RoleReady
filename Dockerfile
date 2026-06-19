FROM python:3.11-slim

# Install Node.js, supervisor, and build tools
RUN apt-get update && apt-get install -y \
    curl \
    supervisor \
    build-essential \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1. Setup Python Service
COPY python-service /app/python-service
WORKDIR /app/python-service
RUN pip install --no-cache-dir -r requirements.txt

# 2. Setup Node.js Backend Server
COPY server /app/server
WORKDIR /app/server
RUN npm install

# 3. Setup React Frontend Client
COPY client /app/client
WORKDIR /app/client
RUN npm install && npm run build
# Install serve to run the built frontend
RUN npm install -g serve

# 4. Copy Supervisor Config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports for all three services
# Frontend: 3000 (served via 'serve')
# Backend: 5000
# Python-service: 8000
EXPOSE 3000 5000 8000

# Start supervisor to manage all processes
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
