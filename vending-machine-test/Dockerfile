 # official Node.js 16 as the base image
  FROM node:16

  # Set working directory
  WORKDIR /app

  # Copy package.json and package-lock.json
  COPY package*.json ./

  # Install dependencies
  RUN npm install

  # Copy the rest of the application code
  COPY . .

  # Build the application
  RUN npm run build

  # Expose port 3000
  EXPOSE 3000

  # Start the application
  CMD ["npm", "start"]
