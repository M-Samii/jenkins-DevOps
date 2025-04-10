FROM node:12
WORKDIR /nodeapp
COPY package*.json ./
RUN npm install
COPY . .
CMD ["node", "app.js"]