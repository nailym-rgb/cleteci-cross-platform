# --- First Stage: Build the app ---

FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set the working directory
WORKDIR /app

# Copy the project files into the container
COPY . .

# Enable Flutter web support
RUN flutter config --enable-web

# Get dependencies
RUN flutter pub get

# Build the web application
RUN flutter build web --release

# --- Second Stage: Serve the built files ---

# Use a lightweight Nginx server for the production image
FROM nginx:alpine

# Copy the built web app from the 'build' stage to Nginx's public directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80 outside the container
EXPOSE 80

# The command to start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]