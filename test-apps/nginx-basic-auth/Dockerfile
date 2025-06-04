FROM nginx:alpine

# Install htpasswd utility
RUN apk add --no-cache apache2-utils

# Copy configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY .htpasswd /etc/nginx/.htpasswd

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
