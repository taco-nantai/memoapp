CREATE DATABASE memoapp ENCODING = 'UTF8' TEMPLATE template0;

CREATE TABLE memo
(id serial not null,
title text,
"text" text,
created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY(id));
