FROM mysql:5.7

# copy testing data; MySQL will automatically run scripts in this dir
COPY testing_data.sql /docker-entrypoint-initdb.d

# see https://github.com/vishnubob/wait-for-it