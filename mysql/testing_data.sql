-- Copyright 2019 Google LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

CREATE DATABASE  IF NOT EXISTS `cookiedb`;
USE `cookiedb`;

DROP TABLE IF EXISTS `product`;
CREATE TABLE `product` (
  `product_id` char(36) NOT NULL,
  `name` varchar(45) NOT NULL,
  `price` decimal(15,2) NOT NULL,
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `product_id_UNIQUE` (`product_id`)
);

LOCK TABLES `product` WRITE;
INSERT INTO `product` VALUES 
  ('964536ee-036e-4936-91c6-272eec6304b6','Chocolate Chip',0.95),
  ('999a1951-4200-42df-897c-87f8a1bb157d','Oatmeal',1.25),
  ('ce09d061-5e5e-4a7c-9572-a9628124a998','Peanut Butter',0.75);
UNLOCK TABLES;

GRANT ALL PRIVILEGES ON cookiedb.* TO 'root'@'%';