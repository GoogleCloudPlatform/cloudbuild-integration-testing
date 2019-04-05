// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

var mysql = require('mysql');

// set database host from environment var; defaults to localhost
const db_host = process.env.DB_HOST || 'localhost';

console.info(`db_host: ${db_host}`);

const pool = mysql.createPool({
  connectionLimit: 1,
  host    : db_host,
  port    : 3306,
  user    : 'root',
  password: 'password',
  database: 'cookiedb'
});

module.exports = pool;