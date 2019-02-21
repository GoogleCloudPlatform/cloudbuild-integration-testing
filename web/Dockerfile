FROM node:10

WORKDIR /usr/src/app

COPY . .

RUN npm install

EXPOSE 3000

ARG DB_HOST=localhost
ENV DB_HOST=$DB_HOST

CMD ["npm","start"]