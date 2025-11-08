# Stage: Vite dev server
FROM node:20

# Set working directory
WORKDIR /var/www

# Copy package.json & package-lock.json first
COPY MyTLUWebsite/MyTLU_Frontend/package*.json ./

# Install dependencies
RUN npm install

# Copy full frontend code
COPY MyTLUWebsite/MyTLU_Frontend ./

# Expose Vite dev port
EXPOSE 5173

# Run Vite dev server
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5173"]
