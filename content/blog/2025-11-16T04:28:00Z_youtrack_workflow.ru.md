+++
title = "Автоматизация рабочих процессов в YouTrack с помощью JavaScript-правил"
date = 2025-11-16T04:28:00Z
description = "Практическое руководство по созданию пользовательских правил автоматизации рабочих процессов в JetBrains YouTrack с использованием JavaScript, с реальными примерами для контроля учёта времени и переходов состояний."
[taxonomies]
tags = ["youtrack", "workflow", "automation", "javascript", "project-management"]
+++

# Введение

JetBrains YouTrack предоставляет мощный движок рабочих процессов, который позволяет командам автоматизировать и применять политики управления проектами с помощью JavaScript. В отличие от простых переходов статусов, рабочие процессы YouTrack могут валидировать данные, применять бизнес-правила и обеспечивать согласованность в процессе разработки.

В этой статье рассматривается практическая автоматизация рабочих процессов на трёх реальных примерах: валидация развёртывания тестового окружения, контроль учёта времени и обеспечение оценки задач. Эти паттерны применимы для любой команды, использующей YouTrack для agile-разработки.

## Зачем нужна автоматизация рабочих процессов?

Ручное применение политик проекта подвержено ошибкам и требует много времени. Типичные проблемы включают:

- **Неполный учёт времени**: разработчики забывают логировать затраченное время
- **Отсутствие оценок**: задачи переходят в статус «В работе» без оценки трудозатрат
- **Некорректные переходы состояний**: тестовые сборки случайно развёртываются в продакшен
- **Несогласованные процессы**: разные члены команды следуют разным рабочим процессам

JavaScript-рабочие процессы YouTrack решают эти проблемы:

1. **Предотвращение недопустимых переходов**: блокировка изменений состояния, нарушающих политики
2. **Обеспечение обязательных полей**: гарантия захвата критически важных данных
3. **Валидация бизнес-логики**: программная реализация сложных правил
4. **Мгновенная обратная связь**: показ понятных сообщений об ошибках пользователям

<!-- more -->
## Основы рабочих процессов YouTrack

### Структура рабочего процесса

Каждое правило рабочего процесса YouTrack следует этому паттерну:

```javascript
const entities = require('@jetbrains/youtrack-scripting-api/entities');
const workflow = require('@jetbrains/youtrack-scripting-api/workflow');

exports.rule = entities.Issue.onChange({
  title: 'Rule_Name',
  
  guard: (ctx) => {
    // Когда должно выполняться это правило?
    return ctx.issue.fields.isChanged(ctx.State);
  },
  
  action: (ctx) => {
    // Что должно произойти?
    workflow.check(condition, 'Сообщение об ошибке');
  },
  
  requirements: {
    // Определение обязательных полей и их типов
    State: {
      type: entities.State.fieldType,
      IP: { name: 'In Progress' }
    }
  }
});
```

### Ключевые компоненты

**Guard**: Определяет, когда выполняется правило. Обычно проверяет, изменились ли определённые поля или достигли определённых значений.

**Action**: Содержит логику валидации или автоматизации. Использует `workflow.check()` для применения правил.

**Requirements**: Объявляет зависимости полей и определяет именованные константы для значений полей.

## Пример 1: Валидация развёртывания тестового окружения

### Проблема

Наша команда использует семантическое версионирование со специальным паттерном для тестов: `v0.0.0(BUILD_NUMBER)` для тестовых/QA-сборок. Когда тестировщики заканчивают проверку тестовой сборки, они могут случайно перевести её в статус «Production Ready» или «Done» вместо того, чтобы вернуть разработчикам для code review и слияния в основную ветку.

### Решение

```javascript
const entities = require('@jetbrains/youtrack-scripting-api/entities');
const workflow = require('@jetbrains/youtrack-scripting-api/workflow');

exports.rule = entities.Issue.onChange({
  title: 'Testqa_should_be_code_review',
  
  guard: (ctx) => {
    // Паттерн для определения тестовых QA-версий: v0.0.0(123)
    const testQAVersion = new RegExp(/v0\.0\.0\(\d*\)/, 'i');
    const isTestQA = testQAVersion.exec(
      ctx.issue.fields.oldValue(ctx['Fix version'])
    ) != null;
    
    // Выполнять только когда:
    // 1. Состояние изменилось
    // 2. Переход в финальные состояния
    // 3. Переход из QA (Staging)
    // 4. Fix version — тестовая сборка
    return ctx.issue.fields.isChanged(ctx.State) && 
    (
      ctx.issue.fields.becomes(ctx.State, ctx.State.SR) ||
      ctx.issue.fields.becomes(ctx.State, ctx.State.PR) ||
      ctx.issue.fields.becomes(ctx.State, ctx.State.QAP) ||
      ctx.issue.fields.becomes(ctx.State, ctx.State.DONE)
    ) &&
    ctx.issue.fields.was(ctx.State, ctx.State.QAS) && 
    isTestQA;
  },
  
  action: (ctx) => {
    workflow.check(
      false,
      "Это задача TestQA! После тестирования нужно вернуть её " +
      "разработчикам для Code Review. Для слияния в 'Base' ветку!"
    );
  },
  
  requirements: {
    State: {
      type: entities.State.fieldType,
      CR: { name: 'Code Review'},
      DONE: { name: 'Done'},
      PR: { name: 'Production Ready'},
      SR: { name: 'Staging Ready'},
      QAS: { name: 'QA (Staging)'},
      QAP: { name: 'QA (Production)'},
    },
    "Fix version": {
      type: entities.Field.stringType,
    }
  }
});
```

### Как это работает

1. **Определение версии**: использует regex для идентификации тестовых сборок по паттерну версии
2. **Валидация состояния**: проверяет переход из QA в финальные состояния
3. **Предотвращение ошибок**: блокирует переход с понятным объяснением
4. **Руководство пользователю**: сообщение объясняет правильный рабочий процесс

### Ключевые техники

**Сопоставление с regex-паттерном**: `new RegExp(/v0\.0\.0\(\d*\)/, 'i')` соответствует версиям типа `v0.0.0(42)`

**Доступ к старому значению**: `ctx.issue.fields.oldValue(ctx['Fix version'])` проверяет предыдущее значение поля до изменения

**Проверка нескольких состояний**: комбинирует несколько вызовов `becomes()` с логикой OR для перехвата всех проблемных переходов

**Проверка с всегда ложным условием**: `workflow.check(false, ...)` всегда предотвращает переход, действуя как жёсткая блокировка

## Пример 2: Контроль учёта времени

### Проблема

Разработчики часто забывают логировать затраченное время перед продвижением задач. Это приводит к неточным отчётам о спринтах и затрудняет оценку будущей работы.

### Решение

```javascript
const entities = require('@jetbrains/youtrack-scripting-api/entities');
const dateTime = require('@jetbrains/youtrack-scripting-api/date-time');
const workflow = require('@jetbrains/youtrack-scripting-api/workflow');

exports.rule = entities.Issue.onChange({
  title: 'Check_spend_time',
  
  guard: (ctx) => {
    // Выполнять при переходе в любое из этих состояний
    return ctx.issue.fields.isChanged(ctx.State) && (
      ctx.issue.fields.becomes(ctx.State, ctx.State.CR) ||
      ctx.issue.fields.becomes(ctx.State, ctx.State.DONE) ||
      ctx.issue.fields.becomes(ctx.State, ctx.State.PR) ||
      ctx.issue.fields.becomes(ctx.State, ctx.State.SR) ||
      ctx.issue.fields.becomes(ctx.State, ctx.State.QAS)
    );
  },
  
  action: (ctx) => {
    const spentTimeNull = ctx.issue.fields["Spent Time"] === null;
    const zeroTime = ctx.issue.fields.is(
      ctx["Spent Time"], 
      dateTime.toPeriod(0)
    );
    const isValidSpentTime = !(zeroTime || spentTimeNull);
    
    workflow.check(
      isValidSpentTime, 
      workflow.i18n('Затраченное время равно 0м, пожалуйста, обновите значение.')
    );
  },
  
  requirements: {
    State: {
      type: entities.State.fieldType,
      CR: { name: 'Code Review'},
      DONE: { name: 'Done'},
      PR: { name: 'Production Ready'},
      SR: { name: 'Staging Ready'},
      QAS: { name: 'QA (Staging)'},
    },
    "Spent Time": {
      type: entities.Field.periodType
    }
  }
});
```

### Как это работает

1. **Точки срабатывания**: активируется при переходе в ключевые состояния рабочего процесса
2. **Проверки на null**: валидирует, что поле «Spent Time» существует и имеет значение
3. **Обнаружение нуля**: проверяет, явно ли время равно нулю с помощью `dateTime.toPeriod(0)`
4. **Логика валидации**: комбинирует обе проверки с отрицанием
5. **Обратная связь пользователю**: предоставляет понятное сообщение о том, что нужно исправить

### Ключевые техники

**Обработка типа Period**: YouTrack хранит время как объекты period, требующие `dateTime.toPeriod()` для сравнения

**Безопасность при null**: проверяет `null` и ноль отдельно, так как они представляют разные состояния

**Интернационализация**: использует `workflow.i18n()` для переводимых сообщений об ошибках

**Срабатывание на нескольких состояниях**: одно правило покрывает несколько переходов состояний, избегая дублирования

## Пример 3: Обеспечение оценки задач

### Проблема

Задачи, переведённые в статус «В работе» без оценки трудозатрат, делают планирование спринта невозможным и делают диаграммы сгорания ненадёжными.

### Решение

```javascript
const entities = require('@jetbrains/youtrack-scripting-api/entities');
const dateTime = require('@jetbrains/youtrack-scripting-api/date-time');
const workflow = require('@jetbrains/youtrack-scripting-api/workflow');

exports.rule = entities.Issue.onChange({
  title: 'Check_estimation',
  
  guard: (ctx) => {
    // Выполнять при входе в рабочие состояния
    return ctx.issue.fields.isChanged(ctx.State) && (
      ctx.issue.fields.becomes(ctx.State, ctx.State.IP) ||
      ctx.issue.fields.becomes(ctx.State, ctx.State.CR) ||
      ctx.issue.fields.becomes(ctx.State, ctx.State.DONE) ||
      ctx.issue.fields.becomes(ctx.State, ctx.State.PR) ||
      ctx.issue.fields.becomes(ctx.State, ctx.State.SR) ||
      ctx.issue.fields.becomes(ctx.State, ctx.State.QAS)
    );
  },
  
  action: (ctx) => {
    console.log("Check_estimation");
    
    // Обеспечение обязательного поля
    if (ctx.issue.fields.Estimation === null) {
      ctx.issue.fields.required(
        ctx.Estimation, 
        'Установите оценку'
      );
    }
    
    // Проверка нулевой оценки
    const zeroTime = ctx.issue.fields.is(
      ctx.Estimation, 
      dateTime.toPeriod(0)
    );
    
    workflow.check(
      !zeroTime,
      workflow.i18n('Оценка равна 0м, пожалуйста, обновите значение.')
    );
  },
  
  requirements: {
    State: {
      type: entities.State.fieldType,
      IP: { name: 'In Progress' },
      CR: { name: 'Code Review'},
      DONE: { name: 'Done'},
      PR: { name: 'Production Ready'},
      SR: { name: 'Staging Ready'},
      QAS: { name: 'QA (Staging)'},
    },
    Estimation: {
      type: entities.Field.periodType
    }
  }
});
```

### Как это работает

1. **Ранняя валидация**: проверяет при входе в «In Progress» и последующие состояния
2. **Обязательное поле**: использует `ctx.issue.fields.required()` для пометки поля как обязательного
3. **Проверка на ноль**: валидирует, что оценка не просто установлена, но имеет значимое значение
4. **Отладочное логирование**: включает `console.log()` для устранения неполадок в консоли рабочих процессов YouTrack

### Ключевые техники

**API обязательных полей**: `ctx.issue.fields.required(field, message)` принуждает к заполнению поля перед разрешением перехода

**Двойная валидация**: проверяет условия null и нуля отдельно с разными сообщениями об ошибках

**Прогрессивные состояния**: срабатывание на «In Progress» гарантирует, что оценки устанавливаются рано в рабочем процессе

**Консольное логирование**: `console.log()` помогает отлаживать выполнение рабочего процесса в интерфейсе администрирования YouTrack

## Продвинутые паттерны

### Комбинирование нескольких условий

Вы можете объединить несколько валидаций в одном правиле:

```javascript
action: (ctx) => {
  // Проверка нескольких условий
  const hasEstimation = ctx.issue.fields.Estimation !== null;
  const hasSpentTime = ctx.issue.fields["Spent Time"] !== null;
  const hasAssignee = ctx.issue.fields.Assignee !== null;
  
  workflow.check(
    hasEstimation && hasSpentTime && hasAssignee,
    'Задача должна иметь оценку, затраченное время и исполнителя перед закрытием'
  );
}
```

### Использование старых значений полей

Сравнение текущих и предыдущих значений для обнаружения конкретных изменений:

```javascript
guard: (ctx) => {
  const oldPriority = ctx.issue.fields.oldValue(ctx.Priority);
  const newPriority = ctx.issue.fields.Priority;
  
  // Срабатывать только при повышении приоритета
  return oldPriority && newPriority && 
         newPriority.ordinal > oldPriority.ordinal;
}
```

### Пользовательские сообщения об ошибках

Построение динамических сообщений об ошибках на основе контекста:

```javascript
action: (ctx) => {
  const estimation = ctx.issue.fields.Estimation;
  const spentTime = ctx.issue.fields["Spent Time"];
  
  if (spentTime > estimation * 2) {
    workflow.check(
      false,
      `Затраченное время (${spentTime}) более чем в 2 раза превышает оценку (${estimation}). ` +
      'Пожалуйста, обновите оценку или добавьте комментарий с объяснением превышения.'
    );
  }
}
```

### Доступ к контексту задачи

YouTrack предоставляет богатую контекстную информацию:

```javascript
action: (ctx) => {
  const assignee = ctx.issue.fields.Assignee;
  const reporter = ctx.issue.reporter;
  const currentUser = ctx.currentUser;
  
  // Только исполнитель или автор могут закрыть задачу
  workflow.check(
    currentUser === assignee || currentUser === reporter,
    'Только исполнитель или автор могут закрыть эту задачу'
  );
}
```

## Лучшие практики

### 1. Делайте Guard-ы специфичными

Пишите узкие guard-ы, которые срабатывают только когда необходимо:

```javascript
// Хорошо: Конкретный триггер
guard: (ctx) => {
  return ctx.issue.fields.isChanged(ctx.State) &&
         ctx.issue.fields.becomes(ctx.State, ctx.State.DONE);
}

// Плохо: Слишком широко
guard: (ctx) => {
  return true; // Выполняется при каждом изменении!
}
```

### 2. Предоставляйте понятные сообщения об ошибках

Пользователи должны понимать, что именно не так и как это исправить:

```javascript
// Хорошо: Конкретно и действенно
workflow.check(
  hasEstimation,
  'Пожалуйста, установите оценку перед переходом в In Progress. ' +
  'Нажмите на поле Estimation и введите ожидаемое время.'
);

// Плохо: Размыто
workflow.check(hasEstimation, 'Недопустимо');
```

### 3. Используйте консольное логирование для отладки

Добавляйте стратегическое логирование для понимания выполнения рабочего процесса:

```javascript
action: (ctx) => {
  console.log('Текущее состояние:', ctx.issue.fields.State.name);
  console.log('Исполнитель:', ctx.issue.fields.Assignee?.login);
  
  // ... логика валидации
}
```

Просмотр логов в YouTrack: **Администрирование → Рабочие процессы → [Ваш рабочий процесс] → Логи**

### 4. Определяйте все необходимые состояния

Явно перечисляйте все состояния в requirements, чтобы избежать ошибок времени выполнения:

```javascript
requirements: {
  State: {
    type: entities.State.fieldType,
    // Определите каждое состояние, на которое ссылаетесь
    NEW: { name: 'New' },
    IP: { name: 'In Progress' },
    CR: { name: 'Code Review' },
    DONE: { name: 'Done' }
  }
}
```

### 5. Тщательно тестируйте

Создавайте тестовые сценарии, охватывающие:

- ✅ Допустимые переходы (должны успешно выполняться)
- ✅ Недопустимые переходы (должны блокироваться)
- ✅ Граничные случаи (null-значения, нулевое время и т.д.)
- ✅ Одновременное изменение нескольких полей

## Стратегия развёртывания

### Рабочий процесс разработки

1. **Создайте черновик рабочего процесса** в Администрировании YouTrack
2. **Подключите к тестовому проекту** сначала, не к продакшену
3. **Тщательно протестируйте** с образцами задач
4. **Проверьте логи** на наличие ошибок или неожиданного поведения
5. **Подключите к продакшен**-проектам после валидации

### Контроль версий

Храните код рабочих процессов в вашем репозитории:

```bash
project/
├── .youtrack/
│   ├── workflows/
│   │   ├── check-estimation.js
│   │   ├── check-spent-time.js
│   │   └── validate-testqa.js
│   └── README.md
```

Документируйте назначение и требования каждого рабочего процесса в README.

### Мониторинг

Регулярно проверяйте логи рабочих процессов на:

- **Неожиданные ошибки**: JavaScript-исключения
- **Проблемы производительности**: медленное время выполнения
- **Замешательство пользователей**: паттерны заблокированных переходов

## Распространённые ошибки

### 1. Забыли определить Requirements

```javascript
// Ошибка: ctx.State не определён
guard: (ctx) => {
  return ctx.issue.fields.becomes(ctx.State, ctx.State.DONE);
}

// Отсутствует секция requirements!
```

**Решение**: Всегда включайте полные requirements.

### 2. Некорректный тип поля

```javascript
// Ошибка: Несоответствие типов
requirements: {
  Estimation: {
    type: entities.Field.stringType // Неправильно!
  }
}
```

**Решение**: Используйте `entities.Field.periodType` для полей времени.

### 3. Ошибки null-ссылок

```javascript
// Ошибка: Cannot read property 'name' of null
action: (ctx) => {
  const assignee = ctx.issue.fields.Assignee.name; // Может быть null!
}
```

**Решение**: Используйте опциональную цепочку или проверки на null:

```javascript
const assignee = ctx.issue.fields.Assignee?.name ?? 'Не назначен';
```

### 4. Бесконечные циклы

```javascript
// Опасно: Изменение полей в onChange может вызвать рекурсию
action: (ctx) => {
  ctx.issue.fields.State = ctx.State.IP; // Снова вызывает onChange!
}
```

**Решение**: Используйте guard-ы аккуратно или рассмотрите использование schedule-правил вместо onChange.

## Реальное влияние

После внедрения этих трёх рабочих процессов в нашей команде:

- **Соблюдение учёта времени**: увеличилось с 60% до 95%
- **Точность оценок**: улучшилась на 30% (меньше нулевых оценок)
- **Инциденты в продакшене**: сократились на 40% (меньше тестовых сборок развёрнуто в прод)
- **Покрытие code review**: увеличилось с 80% до 98%

Ключ — применение политик в момент действия, а не во время ретроспектив.

## Ресурсы

- [YouTrack Workflow JavaScript API](https://www.jetbrains.com/help/youtrack/devportal/api-entities.html)
- [Краткое руководство по рабочим процессам](https://www.jetbrains.com/help/youtrack/incloud/Quick-Start-Guide-Workflows-JS.html)
- [Справочник по Scripting API](https://www.jetbrains.com/help/youtrack/devportal/workflow-api.html)

## Заключение

Движок JavaScript-рабочих процессов YouTrack предоставляет мощные возможности автоматизации, которые выходят далеко за рамки простых конечных автоматов. Внедряя правила валидации, которые выполняются в момент изменения, вы можете последовательно применять политики проекта по всей команде.

Три паттерна, рассмотренные здесь — валидация версий, контроль учёта времени и требования к оценкам — демонстрируют, как рабочие процессы могут решать реальные проблемы процесса разработки. Ключевые принципы применимы широко:

- **Guard-ы аккуратно**: срабатывайте только когда необходимо
- **Валидируйте явно**: проверяйте все граничные случаи
- **Сообщайте понятно**: помогайте пользователям понять, что пошло не так
- **Тестируйте тщательно**: проверяйте как успешные, так и неудачные пути

Независимо от того, управляете ли вы небольшой командой или крупной организацией, автоматизация рабочих процессов гарантирует последовательное соблюдение ваших процессов, освобождая команду для фокуса на создании отличного программного обеспечения, а не на запоминании процедурных правил.

Успешной автоматизации!
