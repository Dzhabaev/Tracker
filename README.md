### Tracker

Tracker - приложение для отслеживания привычек и целей, разработанное для iOS. Помогает пользователям формировать полезные привычки и контролировать их выполнение.

#### Описание

Пользователи могут создавать трекеры для привычек и нерегулярных событий. Они могут задавать расписание, выбирать эмодзи и цвет для каждого трекера, а также просматривать статистику достижений. Приложение поддерживает темную тему, интегрированную аналитику и предоставляет возможность проведения скриншот тестов.

![ScreencastTracker](https://github.com/Dzhabaev/Dzhabaev/assets/137287126/b80954ed-098d-4c0a-8b91-fe5bb20b28bb)

#### Инструкция по развёртыванию или использованию

Приложение использует Core Data и SQL для хранения данных, поэтому для полноценной работы требуется подключение к интернету для аналитики.

Для запуска приложения необходимо клонировать репозиторий и запустить проект в Xcode выполнив следующие шаги:

1. Клонировать репозиторий на локальную машину:

   ```shell
   git clone https://github.com/Dzhabaev/Tracker.git
   ```

2. Перейти в папку проекта, к примеру:

   ```shell
   cd ~/Tracker
   ```

3. Открыть проект с помощью Xcode:

   ```shell
   open Tracker.xcworkspace
   ```

4. Запустить проект на симуляторе или устройстве.

#### Системные требования

- Xcode 12.0 или выше
- Swift 5.3 или выше
- iOS 13.4 или выше
- Поддержка iPhone X и выше
- Адаптация под iPhone SE
- Предусмотрен только портретный режим
- Вёрстка iPad не предусмотрена
- Зависимости: SnapshotTesting, YandexMobileMetrica

#### Планы по доработке

В планах по доработке:

- Скриншот-тесты для всех экранов.
- Переписать все экраны на архитектуру MVVM.
- Реализовать переключение между датами через swipe влево и вправо.

#### Стек технологий

Проект использует:

- Swift для разработки мобильного приложения.
- UIKit для построения пользовательского интерфейса.
- MVVM (Model-View-ViewModel) архитектура.
- Core Data и SQL для хранения данных.
- UICollectionView для отображения трекеров.
- UIPageViewController для онбординга.
- Snapshot Testing для создания скриншот тестов.

#### Расширенная техническая документация

##### Ссылки

- [Дизайн Figma](https://www.figma.com/design/gONgrq8Q5PfEs1LUo7KX4h/Tracker?node-id=0-1&t=52qsLhubl1ZYCm5m-0)

##### Структура проекта

- `Resources`: Дополнительные ресурсы.
  - `Colors`: Палитра цветов приложения.
  - `Localizable`: Локализация приложения.

- `Onboarding`: Модули для онбординга.
  - `TabBarController`: Основной контроллер вкладок.

- `Trackers`: Модули для трекеров.

  - `TrackersViewController`: Контроллер отображения трекеров.
  - `FiltersViewController`: Контроллер фильтров.
  - `TrackersCell`: Ячейки трекера.

  - `Creating`: Модули для создания трекеров.

    - `CreatingTrackerViewController`: Контроллер создания трекеров.
    - `BaseTrackerViewController`: Базовый контроллер трекеров.
    - `EditingHabitsViewController`: Контроллер редактирования трекеров.

    - `Regular`: Модули для привычек.
      - `NewRegularViewController`: Контроллер создания новых привычек.
      - `Schedule`: Модули для расписания.
        - `ScheduleViewController`: Контроллер расписания.

    - `Irregular`: Модули для нерегулярных событий.
      - `NewIrregularViewController`: Контроллер создания новых нерегулярных событий.

    - `Category`: Модули для категорий.
      - `CategoryViewController`: Контроллер категорий.
      - `CategoryListViewModel`: Модель представления списка категорий.
      - `NewCategoryViewController`: Контроллер создания новой категории.

- `Statistic`: Модули для статистики.

  - `StatisticsViewController`: Контроллер статистики.

  - `CustomView`: Пользовательские представления.

- `Models`: Модели данных.

  - `Tracker`: Модель трекера.

  - `TrackerCategory`: Модель категории трекера.

  - `TrackerRecord`: Модель записи трекера.

  - `Schedule`: Модель расписания.

- `Extensions`: Расширения для различных классов.
  - `UITextField+Extension`: Расширения для текстового поля.

- `CoreData`: Модули для работы с Core Data.

  - `TrackerStore`: Хранилище трекеров.

  - `TrackerCategoryStore`: Хранилище категорий трекеров.

  - `TrackerRecordStore`: Хранилище записей трекеров.

  - `UIColorMarshalling`: Утилиты для работы с цветами.

- `Analytics`: Модули для аналитики.

- `TrackerTests`: Модуль для тестирования.

#### Настройка CI для запуска

Проект можно интегрировать с любой CI/CD системой, поддерживающей сборку проектов Swift и Xcode.

#### Создатели

Чингиз Джабаев
