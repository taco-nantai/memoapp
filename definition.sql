CREATE DATABASE memoapp ENCODING = 'UTF8' TEMPLATE template0;

CREATE TABLE memo
(id SERIAL NOT NULL,
title text,
main_text text,
created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY(id));
