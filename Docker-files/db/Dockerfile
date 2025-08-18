FROM mysql:8.0.33
LABEL "Project"="Vprofile"
LABEL "Author"="Imran"
LABEL "Description"="MySQL Database for VProfile Application"

# Environment variables for MySQL configuration
ENV MYSQL_ROOT_PASSWORD=${DB_PASSWORD:-vprodbpass}
ENV MYSQL_DATABASE=${DB_NAME:-accounts}
ENV MYSQL_USER=${DB_USERNAME:-vprouser}
ENV MYSQL_PASSWORD=${DB_PASSWORD:-vprodbpass}

# Copy database initialization script
COPY db_backup.sql /docker-entrypoint-initdb.d/01-init.sql

# Copy custom MySQL configuration if needed
# COPY my.cnf /etc/mysql/conf.d/

# Set proper permissions
RUN chmod 644 /docker-entrypoint-initdb.d/01-init.sql

# Expose MySQL port
EXPOSE 3306

# Health check to verify database is ready
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD mysqladmin ping -h localhost -u root -p$MYSQL_ROOT_PASSWORD || exit 1
