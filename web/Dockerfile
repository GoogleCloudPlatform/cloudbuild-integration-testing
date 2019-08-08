FROM node:10

WORKDIR /usr/src/app

COPY . .

# TODO: remove this step. We should be able to copy over the built app from a previous step
RUN npm install

EXPOSE 3000

ARG DB_HOST=localhost
ENV DB_HOST=$DB_HOST

CMD ["npm","start"]