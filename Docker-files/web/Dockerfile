FROM nginx:alpine
LABEL "Project"="Vprofile"
LABEL "Author"="Imran"
LABEL "Description"="Nginx Reverse Proxy for VProfile Application"

# Install additional tools
RUN apk add --no-cache curl

# Remove default nginx configuration
RUN rm -rf /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY nginvproapp.conf /etc/nginx/conf.d/vproapp.conf

# Copy custom nginx.conf for better performance (optional)
# COPY nginx.conf /etc/nginx/nginx.conf

# Create cache directory
RUN mkdir -p /var/cache/nginx/client_temp

# Set proper permissions
RUN chown -R nginx:nginx /var/cache/nginx

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]