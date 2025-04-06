# Лабораторная работа 3

## Доработки сервисов

- Расширена модель пользователя. Добавлены инициалы и роль, а также его активированность (TODO: сделать функционал бана).
- Добавлена асинхронность
- Добавлено использование PostgreSQL

## База данных

Добавлено использование PostgreSQL. Созданы 2 таблицы

```sql
CREATE TABLE public.projects (
	id serial4 NOT NULL,
	name varchar(50) NOT NULL,
	description varchar(50) NOT NULL,
	CONSTRAINT projects_name_key UNIQUE (name),
	CONSTRAINT projects_pkey PRIMARY KEY (id)
);
CREATE INDEX idx_projects_name ON public.projects USING btree (name);


CREATE TABLE public.users (
	id serial4 NOT NULL,
	initials varchar(100) NOT NULL,
	username varchar(50) NOT NULL,
	"role" varchar(10) NOT NULL,
	disabled bool NOT NULL DEFAULT false,
	"password" varchar(255) NULL,
	hashed_password varchar(255) NOT NULL,
	CONSTRAINT users_pkey PRIMARY KEY (id),
	CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['Guest'::character varying, 'User'::character varying, 'Admin'::character varying])::text[]))),
	CONSTRAINT users_username_key UNIQUE (username)
);
CREATE INDEX idx_users_username ON public.users USING btree (username);
```

При запуске сервисы автоматически создают таблицы, если их нет, а также создают тестовые данные и пользователя-администратора (того же, что и в ЛР2).

## Запуск

`docker-compose up --build` из папки `lab3`

Адреса сервиса авторизации и проектов соответственно:
"http://localhost:8000"
"http://localhost:8001"
