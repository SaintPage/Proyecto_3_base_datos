# backend/Dockerfile
FROM node:18-alpine
WORKDIR /usr/src/app

# Copia y instala dependencias
COPY package.json package-lock.json ./
RUN npm install

# Copia el código fuente
COPY . .

# Expone el puerto de la API
EXPOSE 3001

# Comando por defecto (dev)
CMD ["npm", "run", "dev"]