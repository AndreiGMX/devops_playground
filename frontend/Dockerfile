# Use the official nginx:alpine image
FROM nginx:alpine

# Copy the custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the index.html file into the nginx html directory
COPY index.html /usr/share/nginx/html/

# Fix permissions for index.html
RUN chmod 644 /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# nginx:alpine starts nginx automatically
