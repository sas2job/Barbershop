# Модуль 3: аутентификация, роли и серверная авторизация

## Решение

В первой версии аккаунты принадлежат персоналу салона: `barber` или `admin`.
Клиентских аккаунтов нет — это соответствует `AGENTS.md` и product brief.
Клиентский доступ к записи будет реализован позже через случайный публичный
токен, а не через последовательный ID.

Rails authentication generator добавил пользователей, сессии на signed cookie,
выход и восстановление пароля. Регистрация пользователей через публичный
endpoint не добавлялась: создание staff-пользователя остаётся административной
операцией до появления отдельного безопасного интерфейса.

## Проверяемые правила

- каталог услуг доступен без аутентификации;
- staff dashboard требует входа;
- `barber` и `admin` могут открыть staff dashboard;
- admin dashboard доступен только `admin`;
- скрытие ссылки в интерфейсе не используется как защита endpoint — проверка
  выполняется в контроллере.

## Проверка

```text
bin/rails db:prepare
bin/rails test test/controllers/services_controller_test.rb \
  test/controllers/sessions_controller_test.rb \
  test/controllers/passwords_controller_test.rb \
  test/controllers/staff/dashboards_controller_test.rb \
  test/controllers/admin/dashboards_controller_test.rb \
  test/models/user_test.rb
```

Результат: 17 тестов, 68 assertions, 0 failures, 0 errors.

Из-за ограниченных прав локальной PostgreSQL-роли в `test/test_helper.rb`
отключена дополнительная проверка fixture foreign keys, которая пытается менять
`pg_constraint`. Сами ограничения внешних ключей остаются в базе данных.
