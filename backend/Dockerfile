FROM node:20

WORKDIR /app

# Only copy package.json and lockfile first (to optimize build and prevent stale cache issues)
COPY package*.json ./

# Install dependencies (creates node_modules inside container)
RUN npm install

# Now copy the rest of the app
COPY . .

EXPOSE 8000

CMD ["npm", "run", "dev"]
