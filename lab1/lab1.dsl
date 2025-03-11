workspace {
    name "Project Management System"
    !identifiers hierarchical

    model {
        // Роли пользователей
        admin = Person "Admin" "Администратор системы, управляет пользователями и настройками системы"
        user = Person "User" "Обычный пользователь системы, создает проекты и задачи"
        guest = Person "Guest" "Гость, может просматривать публичные проекты"

        // Основная система
        pms = softwareSystem "Project Management System" {
            // Контейнеры
            authService = container "Authentication Service" {
                technology "Python FastAPI"
                description "Сервис для аутентификации и авторизации пользователей"
                component "AuthController" {
                    technology "Python FastAPI"
                    description "Получение данных пользователя"
                }
            }

            userService = container "User Service" {
                technology "Python FastAPI"
                description "Сервис управления пользователями"
                component "UserController" {
                    technology "Python FastAPI"
                    description "CRUD операции"
                }
                component "UserRepository" {
                    technology "PostgreSQL"
                    description "Хранение данных пользователей"
                }
            }

            projectService = container "Project Service" {
                technology "Python FastAPI"
                description "Сервис управления проектами"
                component "ProjectController" {
                    technology "Python FastAPI"
                    description "CRUD операции"
                }
                component "ProjectRepository" {
                    technology "PostgreSQL"
                    description "Хранение данных проектов"
                }
            }

            taskService = container "Task Service" {
                technology "Python FastAPI"
                description "Сервис управления задачами"
                component "TaskController" {
                    technology "Python FastAPI"
                    description "CRUD операции"
                }
                component "TaskRepository" {
                    technology "PostgreSQL"
                    description "Хранение данных задач"
                }
            }

            notificationService = container "Notification Service" {
                technology "Python FastAPI"
                description "Сервис для отправки уведомлений пользователям"
                component "NotificationController" {
                    technology "Python FastAPI"
                    description "Отправка уведомлений"
                }
                component "NotificationService" {
                    technology "aiogram"
                    description "Отправка сообщений в бота"
                }
            }

            frontend = container "Frontend Application" {
                technology "HTML, CSS, JavaScript"
                description "Веб-интерфейс для взаимодействия с системой"
                component "LoginPage" {
                    -> authService "Аутентификация пользователя" "REST"
                }
                component "DashboardPage" {
                    -> projectService "Получение списка проектов" "REST"
                    -> taskService "Получение списка задач" "REST"
                }
                component "ProjectPage" {
                    -> projectService "Получение данных проекта" "REST"
                    -> taskService "Получение задач проекта" "REST"
                }
            }

            // Взаимодействие между контейнерами
            authService -> userService "Получение данных пользователя" "REST"
            userService -> projectService "Создание проекта" "REST"
            userService -> taskService "Создание задачи" "REST"
            projectService -> taskService "Получение задач проекта" "REST"
            taskService -> notificationService "Отправка уведомлений о новых задачах" "REST"
        }

        // Взаимодействие пользователей с системой
        admin -> pms.userService "Управление пользователями" "REST"
        user -> pms.authService "Аутентификация" "REST"
        user -> pms.frontend "Работа с интерфейсом" "HTTP"
        guest -> pms.frontend "Просмотр публичных проектов" "HTTP"
        deploymentEnvironment "Production" {
        deploymentNode "Web Server" {
            technology "Nginx"
            containerInstance pms.frontend
        }

        deploymentNode "Application Server" {
            technology "Gunicorn"
            containerInstance pms.authService
            containerInstance pms.userService
            containerInstance pms.projectService
            containerInstance pms.taskService
            containerInstance pms.notificationService
        }

        deploymentNode "Database Server" {
            technology "PostgreSQL"
            containerInstance pms.userService
            containerInstance pms.projectService
            containerInstance pms.taskService
        }

    }


    }

    views {
        themes default

        systemContext pms "System-Context" {
            include *
            autoLayout lr
        }

        container pms "Containers" {
            include *
            autoLayout
        }

        dynamic pms "Create-Project-and-Task" {
            user -> pms.frontend "Вход в систему" "HTTP"
            pms.frontend -> pms.authService "Аутентификация" "REST"
            pms.authService -> pms.userService "Получение данных пользователя" "REST"
            user -> pms.frontend "Создание проекта" "HTTP"
            pms.frontend -> pms.projectService "Создание проекта" "REST"
            user -> pms.frontend "Создание задачи" "HTTP"
            pms.frontend -> pms.taskService "Создание задачи" "REST"
            pms.taskService -> pms.notificationService "Отправка уведомления" "REST"
            autoLayout lr
        }
    }


}
