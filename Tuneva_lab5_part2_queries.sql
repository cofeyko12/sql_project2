-- Часть 2. Запросы
-- Выполняется после части 1. Результаты учитывают изменения UPDATE из части 1.
USE marketing_agency;

-- Запрос получения списка проектов выбранного клиента.
SELECT c.client_name, p.project_name,
       p.start_date, p.planned_end_date, p.budget
FROM clients AS c, projects AS p
WHERE c.client_id = p.client_id
  AND c.client_id = 1
ORDER BY p.start_date;


-- Команда SELECT определяет поля результата: название клиента, название проекта, дату начала, плановую дату завершения и бюджет. Условие WHERE c.client_id = p.client_id соединяет проекты с соответствующими клиентами. Условие AND c.client_id = 1 ограничивает выборку проектами клиента «Кофейня Рассвет».Команда ORDER BY p.start_date сортирует проекты по дате начала в порядке возрастания.

-- Получение списка задач выбранного сотрудника с использованием JOIN.
SELECT e.full_name, t.task_name, p.project_name,
       t.due_date, s.status_name
FROM tasks AS t
JOIN employees AS e ON t.employee_id = e.employee_id
JOIN projects AS p ON t.project_id = p.project_id
JOIN task_statuses AS s ON t.task_status_id = s.task_status_id
WHERE e.employee_id = 1
ORDER BY t.due_date, t.task_id;

-- Запрос предназначен для просмотра задач выбранного сотрудника. Команда SELECT определяет поля результата: ФИО сотрудника, название задачи, название проекта, срок выполнения и статус задачи.
-- В FROM указана таблица tasks. Через JOIN к ней присоединяются таблицы employees, projects и task_statuses. После ON задаются условия соединения по соответствующим идентификаторам.

-- Контроль просроченных задач.
SELECT t.task_name, p.project_name, e.full_name,
       t.due_date, s.status_name
FROM tasks AS t
JOIN projects AS p ON t.project_id = p.project_id
JOIN employees AS e ON t.employee_id = e.employee_id
JOIN task_statuses AS s ON t.task_status_id = s.task_status_id
WHERE t.due_date < CURRENT_DATE()
  AND t.task_status_id NOT IN (4, 5)
ORDER BY t.due_date, t.task_id;

-- Получение данных о текущих проектах.
SELECT p.project_name, c.client_name,
       p.start_date, p.planned_end_date,
       p.budget, s.status_name
FROM projects AS p
JOIN clients AS c ON p.client_id = c.client_id
JOIN project_statuses AS s
  ON p.project_status_id = s.project_status_id
WHERE p.project_status_id = 2
ORDER BY p.planned_end_date, p.project_id;

-- Запрос предназначен для просмотра проектов со статусом «В работе». Команда SELECT выводит название проекта, клиента, дату начала, плановую дату завершения, бюджет и статус. Через JOIN таблица projects соединяется с таблицами clients и project_statuses. Условия после ON связывают записи по идентификаторам клиента и статуса проекта. Команда ORDER BY сортирует проекты по плановой дате завершения. 

-- Получение данных о текущей загрузке сотрудников.
SELECT e.employee_id, e.full_name,
       COUNT(t.task_id) AS current_tasks
FROM employees AS e
LEFT JOIN tasks AS t
  ON e.employee_id = t.employee_id
  AND t.task_status_id NOT IN (4, 5)
GROUP BY e.employee_id, e.full_name
ORDER BY current_tasks DESC, e.employee_id;

-- Запрос предназначен для подсчёта текущих задач каждого сотрудника. Выполненные и отменённые задачи исключаются условием NOT IN (4, 5).
-- Через LEFT JOIN таблица employees соединяется с таблицей tasks. Такое соединение позволяет вывести всех сотрудников. Если у сотрудника нет текущих задач, их количество будет равно нулю. Команда GROUP BY объединяет записи по сотрудникам. Функция COUNT(t.task_id) подсчитывает количество их текущих задач. Через AS результату присваивается название current_tasks. Команда ORDER BY сортирует сотрудников по убыванию количества текущих задач. При одинаковой загрузке используется сортировка по идентификатору сотрудника.

-- Отбор сотрудников с количеством текущих задач больше одной
SELECT e.full_name, COUNT(t.task_id) AS current_tasks
FROM employees e
LEFT JOIN tasks t
  ON e.employee_id = t.employee_id
  AND t.task_status_id NOT IN (4, 5)
GROUP BY e.employee_id, e.full_name
HAVING COUNT(t.task_id) > 1
ORDER BY current_tasks DESC;

-- Расчёт сводных показателей текущих проектов.
SELECT COUNT(*) AS project_count,
       SUM(budget) AS total_budget,
       AVG(budget) AS average_budget,
       MAX(budget) AS maximum_budget,
       MIN(budget) AS minimum_budget
FROM projects
WHERE project_status_id = 2;

-- Запрос рассчитывает показатели проектов со статусом «В работе». Для их отбора используется условие WHERE project_status_id = 2. Функция COUNT(*) считает количество проектов. SUM(budget) вычисляет общий бюджет. AVG(budget) определяет средний бюджет. MAX(budget) и MIN(budget) находят наибольший и наименьший бюджеты. Через AS задаются названия столбцов результата.

-- Продолжение части 2

-- Получение списка проектов сотрудника с помощью подзапроса IN
SELECT project_id, project_name
FROM projects
WHERE project_id IN (
    SELECT project_id
    FROM tasks
    WHERE employee_id = 1
)
ORDER BY project_id;

-- Вложенный запрос выбирает из таблицы tasks номера проектов, по которым у сотрудника есть задачи. Внешний запрос обращается к таблице projects и выводит номера и названия этих проектов. Оператор IN проверяет, входит ли номер проекта в список, полученный из вложенного запроса. Результат сортируется по номеру проекта.

-- Контроль сроков текущих проектов с помощью подзапроса ALL

SELECT project_name, planned_end_date
FROM projects
WHERE project_status_id = 2
  AND planned_end_date <= ALL (
      SELECT planned_end_date
      FROM projects
      WHERE project_status_id = 2
  );

-- Запрос предназначен для контроля сроков текущих проектов. Вложенный запрос получает плановые даты завершения проектов со статусом «В работе». Оператор ALL позволяет выбрать проект с самой ранней плановой датой завершения.

-- Контроль сроков выполнения задач с помощью IF и CASE

SELECT task_name, due_date,
       IF(due_date < CURRENT_DATE()
          AND task_status_id NOT IN (4, 5),
          'Да', 'Нет') AS is_overdue,
       CASE
           WHEN task_status_id = 4 THEN 'Выполнена'
           WHEN task_status_id = 5 THEN 'Отменена'
           WHEN due_date < CURRENT_DATE() THEN 'Срок прошёл'
           WHEN due_date = CURRENT_DATE() THEN 'Срок сегодня'
           ELSE 'Срок ещё не наступил'
       END AS deadline_state
FROM tasks
ORDER BY due_date, task_id;

-- Запрос выводит название задачи и срок её выполнения. Функция IF показывает, есть ли просрочка. Задача считается просроченной, если её срок уже прошёл, а сама задача ещё не выполнена и не отменена. Выражение CASE проверяет условия по порядку. Сначала оно проверяет статус задачи, затем сравнивает срок с текущей датой.

-- Создание представления для контроля просроченных задач

CREATE VIEW overdue_tasks_report AS
SELECT t.task_id, t.task_name, p.project_name,
       e.full_name, t.due_date, s.status_name
FROM tasks AS t
JOIN projects AS p ON p.project_id = t.project_id
JOIN employees AS e ON e.employee_id = t.employee_id
JOIN task_statuses AS s ON s.task_status_id = t.task_status_id
WHERE t.due_date < CURRENT_DATE()
  AND t.task_status_id NOT IN (4, 5);

SELECT *
FROM overdue_tasks_report
ORDER BY due_date, task_id;


-- Для ежедневного контроля сроков создано представление overdue_tasks_report. Оно выводит название задачи, проект, исполнителя, срок и статус. В список попадают задачи, срок которых уже прошёл. Выполненные и отменённые задачи исключаются. При каждом обращении список формируется по текущей дате и данным базы.

-- Расчёт загрузки сотрудников с помощью WITH

WITH task_load AS (
    SELECT employee_id, COUNT(*) AS current_tasks
    FROM tasks
    WHERE task_status_id NOT IN (4, 5)
    GROUP BY employee_id
)
SELECT e.full_name,
       COALESCE(l.current_tasks, 0) AS current_tasks
FROM employees AS e
LEFT JOIN task_load AS l ON l.employee_id = e.employee_id
ORDER BY current_tasks DESC, e.employee_id;


-- В блоке WITH подсчитывается количество текущих задач каждого сотрудника. Выполненные и отменённые задачи исключаются. Промежуточный результат task_load используется только в этом запросе. Через LEFT JOIN он соединяется со списком сотрудников. Функция COALESCE выводит ноль, если у сотрудника нет текущих задач.

-- Анализ запроса до создания составного индекса
EXPLAIN
SELECT task_id, task_name, due_date
FROM tasks
WHERE employee_id = 1
ORDER BY due_date;

-- Создание составного индекса. Выполняется один раз.
CREATE INDEX idx_tasks_employee_due
ON tasks (employee_id, due_date);

-- Повторный анализ того же запроса
EXPLAIN
SELECT task_id, task_name, due_date
FROM tasks
WHERE employee_id = 1
ORDER BY due_date;

-- Сравниваются key, rows и Extra. На небольшой таблице индекс может не выбираться.
-- Транзакция демонстрирует изменение данных и откат к состоянию перед её началом.
-- Значения UPDATE уже установлены в части 1. Повторное присваивание может
-- затронуть 0 изменённых строк. ROLLBACK возвращает состояние перед транзакцией.

START TRANSACTION;

-- Изменение почты клиента
UPDATE clients
SET email = 'rassvet@example.com'
WHERE client_id = 1;

SELECT client_name, email
FROM clients
WHERE client_id = 1;

-- Изменение бюджета проекта
UPDATE projects
SET budget = 95000.00
WHERE project_id = 1;

SELECT project_name, budget
FROM projects
WHERE project_id = 1;

-- Назначение другого исполнителя
UPDATE tasks
SET employee_id = 1
WHERE task_id = 7;

SELECT t.task_name, e.full_name
FROM tasks AS t
JOIN employees AS e ON t.employee_id = e.employee_id
WHERE t.task_id = 7;

-- Изменение статуса проекта
UPDATE projects
SET project_status_id = 3
WHERE project_id = 2;

SELECT p.project_name, s.status_name
FROM projects AS p
JOIN project_statuses AS s
  ON p.project_status_id = s.project_status_id
WHERE p.project_id = 2;

ROLLBACK;

-- Команда START TRANSACTION начинает транзакцию. В ней изменяются почта клиента, бюджет проекта, исполнитель задачи и статус проекта. После каждого изменения запрос SELECT показывает новое значение. В конце команда ROLLBACK отменяет изменения.

-- Просмотр задач сотрудника с помощью подготовленного запроса

PREPARE employee_tasks_query FROM
'SELECT task_name, due_date, task_status_id
 FROM tasks
 WHERE employee_id = ?
 ORDER BY due_date, task_id';

SET @selected_employee = 1;
EXECUTE employee_tasks_query USING @selected_employee;

SET @selected_employee = 2;
EXECUTE employee_tasks_query USING @selected_employee;

DEALLOCATE PREPARE employee_tasks_query;

-- PREPARE подготавливает запрос. Знак ? оставляет место для номера сотрудника. EXECUTE ... USING подставляет номер и запускает запрос. DEALLOCATE PREPARE удаляет подготовленный запрос из текущего сеанса.
