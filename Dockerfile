# Use the official PostgreSQL image from Docker Hub
FROM postgres:16.4

# Update package list and install pgaudit and set_user extensions
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  postgresql-16-pgaudit \
  build-essential \
  postgresql-server-dev-all

# Copy the set_user source code into the image
COPY ./set_user /usr/src/set_user

# Build and install the set_user extension
RUN cd /usr/src/set_user && make && make install

# Copy the custom PostgreSQL configuration file
COPY postgresql.conf /etc/postgresql/postgresql.conf

# Copy SSL certificates into the container
COPY Certificate/server.crt /var/lib/postgresql/server.crt
COPY Certificate/server.key /var/lib/postgresql/server.key

# Set proper permissions for the SSL certificate files
RUN chmod 600 /var/lib/postgresql/server.key
RUN chown postgres:postgres /var/lib/postgresql/server.crt /var/lib/postgresql/server.key

# Ensure umask and permissions are set correctly
RUN echo 'umask 0077' >> /root/.bashrc

# Set the PostgreSQL configuration to use the custom config file and preload libraries
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf", "-c", "shared_preload_libraries=pgaudit,set_user"]

# Expose the default PostgreSQL port
EXPOSE 5432
