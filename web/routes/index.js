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

const express = require('express');
const router = express.Router();
const getProducts = require('../api/getProducts');


router.get('/', async (req, res) => {

  let products;
  
  try {
    products = await getProducts();
  } catch (err) {
  // products = await getProducts().catch(err => {
    // console.error('error: unable to fetch products' + err);
    const errorMsg =[{name: '[DATABASE ERROR: unable to fetch products] ' + Date.now()}];
    products = errorMsg;
  }

  res.render('index', { 
    title: 'Cloud Cookie Shop',
    location: 'Jersey City',
    products: products
  });
});

module.exports = router;
