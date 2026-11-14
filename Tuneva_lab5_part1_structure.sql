-- Часть 1. Создание структуры БД

--  Создание базы данных маркетингового агентства
CREATE DATABASE marketing_agency
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;


USE marketing_agency;

CREATE TABLE clients (
    client_id INT NOT NULL AUTO_INCREMENT,
    client_name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(150) NOT NULL,
    phone VARCHAR(12) NOT NULL,
    email VARCHAR(254) NOT NULL,
    PRIMARY KEY (client_id)
);

CREATE TABLE project_statuses (
    project_status_id INT NOT NULL,
    status_name VARCHAR(40) NOT NULL,
    PRIMARY KEY (project_status_id),
    UNIQUE (status_name)
);

CREATE TABLE projects (
    project_id INT NOT NULL AUTO_INCREMENT,
    project_name VARCHAR(200) NOT NULL,
    client_id INT NOT NULL,
    start_date DATE NOT NULL,
    planned_end_date DATE NOT NULL,
    budget DECIMAL(12,2) NOT NULL,
    project_status_id INT NOT NULL DEFAULT 1,
    PRIMARY KEY (project_id),
    FOREIGN KEY (client_id)
        REFERENCES clients(client_id),
    FOREIGN KEY (project_status_id)
        REFERENCES project_statuses(project_status_id)
);

CREATE TABLE specializations (
    specialization_id INT NOT NULL,
    specialization_name VARCHAR(80) NOT NULL,
    PRIMARY KEY (specialization_id),
    UNIQUE (specialization_name)
);

CREATE TABLE employees (
    employee_id INT NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    specialization_id INT NOT NULL,
    phone VARCHAR(12) NOT NULL,
    email VARCHAR(254) NOT NULL,
    PRIMARY KEY (employee_id),
    FOREIGN KEY (specialization_id)
        REFERENCES specializations(specialization_id)
);

CREATE TABLE task_types (
    task_type_id INT NOT NULL,
    type_name VARCHAR(80) NOT NULL,
    PRIMARY KEY (task_type_id),
    UNIQUE (type_name)
);

CREATE TABLE task_statuses (
    task_status_id INT NOT NULL,
    status_name VARCHAR(40) NOT NULL,
    PRIMARY KEY (task_status_id),
    UNIQUE (status_name)
);

CREATE TABLE tasks (
    task_id INT NOT NULL AUTO_INCREMENT,
    project_id INT NOT NULL,
    task_name VARCHAR(200) NOT NULL,
    task_type_id INT NOT NULL,
    employee_id INT NOT NULL,
    assigned_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    task_status_id INT NOT NULL DEFAULT 1,
    PRIMARY KEY (task_id),
    FOREIGN KEY (project_id)
        REFERENCES projects(project_id),
    FOREIGN KEY (task_type_id)
        REFERENCES task_types(task_type_id),
    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id),
    FOREIGN KEY (task_status_id)
        REFERENCES task_statuses(task_status_id)
);

CREATE TABLE services (
    service_id INT NOT NULL AUTO_INCREMENT,
    service_name VARCHAR(150) NOT NULL,
    description VARCHAR(1000) NOT NULL,
    PRIMARY KEY (service_id),
    UNIQUE (service_name)
) ENGINE=InnoDB;

CREATE TABLE project_services (
    project_id INT NOT NULL,
    service_id INT NOT NULL,
    PRIMARY KEY (project_id, service_id),
    FOREIGN KEY (project_id)
        REFERENCES projects(project_id),
    FOREIGN KEY (service_id)
        REFERENCES services(service_id)
) ENGINE=InnoDB;

-- Добавим правило: бюджет проекта не может быть отрицательным.

ALTER TABLE projects
ADD CONSTRAINT chk_projects_budget
CHECK (budget >= 0);

-- Дата завершения проекта не должна быть раньше даты начала.

ALTER TABLE projects
ADD CONSTRAINT chk_projects_dates
CHECK (planned_end_date >= start_date);

-- Срок выполнения не должен быть раньше даты постановки.

ALTER TABLE tasks
ADD CONSTRAINT chk_tasks_dates
CHECK (due_date >= assigned_date);


INSERT INTO project_statuses
(project_status_id, status_name)
VALUES
(1, 'Запланирован'),
(2, 'В работе'),
(3, 'Приостановлен'),
(4, 'Завершён'),
(5, 'Отменён');

INSERT INTO specializations
(specialization_id, specialization_name)
VALUES
(1, 'SMM-специалист'),
(2, 'Контент-креатор'),
(3, 'Видеограф'),
(4, 'Дизайнер'),
(5, 'Копирайтер'),
(6, 'Менеджер проектов');

INSERT INTO task_types
(task_type_id, type_name)
VALUES
(1, 'Создание контент-плана'),
(2, 'Написание текста'),
(3, 'Видеосъёмка'),
(4, 'Монтаж'),
(5, 'Дизайн'),
(6, 'Публикация'),
(7, 'Подготовка отчёта');

INSERT INTO task_statuses
(task_status_id, status_name)
VALUES
(1, 'Новая'),
(2, 'В работе'),
(3, 'На проверке'),
(4, 'Выполнена'),
(5, 'Отменена');

INSERT INTO services
(service_id, service_name, description)
VALUES
(1, 'SMM-сопровождение', 'Ведение социальных сетей клиента'),
(2, 'Создание контента', 'Подготовка текстов и изображений'),
(3, 'Создание видеоконтента', 'Съёмка и монтаж видеороликов'),
(4, 'Копирайтинг', 'Написание текстов для публикаций'),
(5, 'Дизайн', 'Разработка визуальных материалов'),
(6, 'Разработка контент-плана', 'Планирование публикаций'),
(7, 'Создание рекламных материалов', 'Подготовка рекламных макетов');

INSERT INTO clients
(client_id, client_name, contact_person, phone, email)
VALUES
(1, 'Кофейня Рассвет', 'Иванова Анна Сергеевна',
 '+79000000001', 'anna@example.com'),
(2, 'Студия Форма', 'Петров Иван Андреевич',
 '+79000000002', 'ivan@example.com'),
(3, 'Магазин Лист', 'Смирнова Мария Олеговна',
 '+79000000003', 'maria@example.com');

INSERT INTO employees
(employee_id, full_name, specialization_id, phone, email)
VALUES
(1, 'Соколова Елена Игоревна', 1,
 '+79000000011', 'elena@example.com'),
(2, 'Кузнецов Артём Сергеевич', 3,
 '+79000000012', 'artem@example.com'),
(3, 'Волкова Ольга Павловна', 4,
 '+79000000013', 'olga@example.com'),
(4, 'Орлов Максим Андреевич', 5,
 '+79000000014', 'maxim@example.com');

INSERT INTO projects
(project_id, project_name, client_id, start_date,
 planned_end_date, budget, project_status_id)
VALUES
(1, 'Продвижение кофейни', 1,
 '2026-10-01', '2026-11-30', 90000.00, 2),
(2, 'Рекламный ролик кофейни', 1,
 '2026-10-05', '2026-11-05', 45000.00, 2),
(3, 'Социальные сети студии', 2,
 '2026-10-01', '2026-12-01', 70000.00, 2),
(4, 'Дизайн для магазина', 3,
 '2026-09-01', '2026-09-30', 30000.00, 4);

INSERT INTO project_services
(project_id, service_id)
VALUES
(1, 1),
(1, 2),
(1, 6),
(2, 3),
(3, 1),
(3, 4),
(4, 5);

INSERT INTO tasks
(task_id, project_id, task_name, task_type_id,
 employee_id, assigned_date, due_date, task_status_id)
VALUES
(1, 1, 'Составить контент-план кофейни',
 1, 1, '2026-10-01', '2026-10-04', 4),
(2, 1, 'Написать текст о новом меню',
 2, 4, '2026-10-02', '2026-10-08', 4),
(3, 1, 'Опубликовать пост',
 6, 1, '2026-10-05', '2026-10-12', 2),
(4, 2, 'Снять рекламный ролик',
 3, 2, '2026-10-05', '2026-10-20', 3),
(5, 2, 'Смонтировать ролик',
 4, 2, '2026-10-06', '2026-11-01', 1),
(6, 3, 'Подготовить план публикаций',
 1, 1, '2026-10-01', '2026-10-07', 4),
(7, 3, 'Написать текст о студии',
 2, 4, '2026-10-08', '2026-11-02', 2),
(8, 4, 'Разработать макет афиши',
 5, 3, '2026-09-01', '2026-09-20', 4);

-- задача № 5 относится к проекту № 2. Её тип: монтаж. Исполнитель: сотрудник № 2. Статус 1: «Новая».

UPDATE tasks
SET task_status_id = 2
WHERE task_id = 5;

-- Изменение контактных данных клиента

UPDATE clients 
SET email = 'rassvet@example.com' 
WHERE client_id = 1;

-- Изменение бюджета проекта

UPDATE projects 
SET budget = 95000.00 
WHERE project_id = 1;

-- Назначение другого исполнителя задачи

UPDATE tasks 
SET employee_id = 1 
WHERE task_id = 7;

-- Изменение статуса проекта на «Приостановлен»

UPDATE projects
 SET project_status_id = 3 
WHERE project_id = 2;

-- изменим статус задачи № 5 с «Новая» на «В работе».
INSERT INTO clients
(client_name, contact_person, phone, email)
VALUES
('Тестовый клиент для удаления', 'Тестовое лицо',
 '+79000000099', 'test@example.com');

-- подготовим клиента под удаление 

DELETE FROM clients
WHERE client_name = 'Тестовый клиент для удаления'
  AND email = 'test@example.com';

CREATE USER 'agency_manager'@'localhost'
IDENTIFIED BY 'Manager_Lab5_2026!';

-- создадим пользователя для менеджера проектов

GRANT SELECT ON marketing_agency.*
TO 'agency_manager'@'localhost';

GRANT INSERT, UPDATE ON marketing_agency.clients
TO 'agency_manager'@'localhost';

GRANT INSERT, UPDATE ON marketing_agency.employees
TO 'agency_manager'@'localhost';

GRANT INSERT, UPDATE ON marketing_agency.projects
TO 'agency_manager'@'localhost';

GRANT INSERT, UPDATE ON marketing_agency.tasks
TO 'agency_manager'@'localhost';

GRANT INSERT ON marketing_agency.project_services
TO 'agency_manager'@'localhost';

CREATE USER 'agency_director'@'localhost'
IDENTIFIED BY 'Director_Lab5_2026!';

GRANT SELECT ON marketing_agency.*
TO 'agency_director'@'localhost';

-- создадим учётную запись руководителя

CREATE USER 'agency_employee_1'@'localhost'
IDENTIFIED BY 'Employee_Lab5_2026!';

-- создадим учётную запись сотрудника № 1

CREATE ALGORITHM=MERGE
SQL SECURITY DEFINER
VIEW employee_1_tasks AS
SELECT task_id, project_id, task_name,
       task_type_id, employee_id,
       assigned_date, due_date, task_status_id
FROM tasks
WHERE employee_id = 1
WITH CASCADED CHECK OPTION;

-- Теперь создадим представление, сохранённый запрос, который показывает сотруднику только его задачи.

GRANT SELECT, UPDATE (task_status_id)
ON marketing_agency.employee_1_tasks
TO 'agency_employee_1'@'localhost';
-- Теперь разрешим сотруднику читать свои задачи и менять их статус.
CREATE SQL SECURITY DEFINER
VIEW employee_1_projects AS
SELECT project_id, project_name,
       start_date, planned_end_date,
       project_status_id
FROM projects
WHERE project_id IN (
    SELECT project_id
    FROM tasks
    WHERE employee_id = 1
);
-- Теперь дадим сотруднику доступ к проектам, в которых у него есть задачи.
GRANT SELECT
ON marketing_agency.employee_1_projects
TO 'agency_employee_1'@'localhost';
-- Теперь разрешим сотруднику видеть названия типов задач и статусов.

GRANT SELECT ON marketing_agency.task_types
TO 'agency_employee_1'@'localhost';

GRANT SELECT ON marketing_agency.task_statuses
TO 'agency_employee_1'@'localhost';

GRANT SELECT ON marketing_agency.project_statuses
TO 'agency_employee_1'@'localhost';

-- Метаданные всех таблиц
DESCRIBE clients;
DESCRIBE project_statuses;
DESCRIBE projects;
DESCRIBE specializations;
DESCRIBE employees;
DESCRIBE task_types;
DESCRIBE task_statuses;
DESCRIBE tasks;
DESCRIBE services;
DESCRIBE project_services;
