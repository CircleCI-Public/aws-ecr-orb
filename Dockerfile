FROM readytalk/nodejs

# Add our configuration files and scripts
WORKDIR /app
ADD . /app
EXPOSE 80

ENTRYPOINT ["/nodejs/bin/npm", "start"]
