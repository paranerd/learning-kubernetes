# Use an official Node.js runtime as a parent image
FROM node:22-alpine

# Set the working directory in the container to /app
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY src/package*.json ./

# Install any necessary dependencies
RUN npm install --production

# Copy the rest of the application code to the working directory.
COPY src/* /app

# Expose the port that the app listens on
EXPOSE 8080

# Define the command to run the application using npm start
CMD ["npm", "start"]
