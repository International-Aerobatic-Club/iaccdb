# Use the official Ruby image as the base image
FROM ruby:2.7.8

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    yarnpkg \
    default-mysql-client \
    default-libmysqlclient-dev \
    libxml2-dev \
    gzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN gem update --system 3.3.26 && gem install bundler -v 2.3.22

# Set the working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install Ruby dependencies
RUN bundle _2.3.22_ install

# Copy the application code
COPY . .

# Install entrypoint outside the bind-mounted app directory
COPY docker/entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Precompile assets (optional, can be done at runtime)
# RUN bundle exec rake assets:precompile

# Expose port 3000
EXPOSE 3000

# Use entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
