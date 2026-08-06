# Use official Node.js alpine image for a lightweight container
FROM node:20-alpine

# Set working directory inside container
WORKDIR /app

# Copy package.json first to leverage Docker cache for package installation
COPY package.json ./

# Install production dependencies
RUN npm install --only=production

# Copy the rest of the application files
COPY . .

# Expose server port (default 5000)
EXPOSE 5000

# Command to run the application
CMD ["node", "server.js"]
