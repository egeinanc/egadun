FROM node:18-alpine AS base

WORKDIR /appsrc

COPY package.json package-lock.json ./
COPY tsconfig.json ./
COPY /app ./app

RUN npm install
RUN npm run build


EXPOSE 3000

CMD npm start