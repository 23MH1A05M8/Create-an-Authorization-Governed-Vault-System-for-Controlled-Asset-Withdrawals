FROM node:18-alpine

WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install
COPY . .
RUN chmod +x docker/entrypoint.sh
ENTRYPOINT ["sh", "docker/entrypoint.sh"]