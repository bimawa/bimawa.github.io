/**
 * Универсальное решение для добавления выпадающего меню Projects
 * Работает на всех страницах сайта без необходимости изменять HTML-код
 *
 * Особенности:
 * 1. Динамически добавляет CSS стили
 * 2. Создает структуру меню Projects
 * 3. Работает как на десктопах (при наведении), так и на мобильных устройствах (при клике)
 * 4. Автоматически определяет текущую страницу и подсвечивает активный проект
 * 5. Не требует изменений в HTML-коде страниц
 */

(function() {
    'use strict';

    // Добавляем CSS стили динамически
    function addCSS() {
        // Проверяем, добавлены ли уже стили
        if (document.querySelector('link[href="/menu-projects.css"]')) {
            return;
        }

        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = '/menu-projects.css';
        document.head.appendChild(link);
    }

    // Основная функция инициализации меню
    function initProjectsMenu() {
        // Проверяем, есть ли уже меню Projects на странице
        if (document.querySelector('.projects-menu-item')) {
            return;
        }

        // Находим элемент меню Projects
        const projectsMenuItem = document.querySelector('.menu__inner li a[href*="/projects"]');
        if (!projectsMenuItem) {
            return;
        }

        // Создаем контейнер для дополнительного меню
        const parentLi = projectsMenuItem.parentElement;
        parentLi.classList.add('projects-menu-item');

        // Определяем текущий путь для подсветки активного проекта
        const currentPath = window.location.pathname;
        const isProjectsPage = currentPath.includes('/projects/');
        const isMainProjectsPage = currentPath === '/projects/' || currentPath === '/projects';

        // Создаем структуру дополнительного меню
        const subMenu = document.createElement('ul');
        subMenu.className = 'menu__sub-inner-projects';

        // Список проектов
        const projects = [
            { name: 'WireDeskVR', url: '/projects/WireDeskVR/', path: '/projects/WireDeskVR/' },
            { name: 'SyncLProj', url: '/projects/SyncLProj/', path: '/projects/SyncLProj/' },
            { name: 'BlazeFM', url: '/projects/BlazeFM/', path: '/projects/BlazeFM/' },
        ];

        // Добавляем проекты в меню
        projects.forEach(project => {
            const li = document.createElement('li');
            const a = document.createElement('a');
            a.href = project.url;
            a.textContent = project.name;

            // Подсвечиваем активный проект
            if (isProjectsPage && (currentPath.includes(project.path) ||
               (project.path === '/projects/' && isMainProjectsPage))) {
                li.classList.add('active');
            }

            li.appendChild(a);
            subMenu.appendChild(li);
        });

        // Добавляем подменю к элементу Projects
        parentLi.appendChild(subMenu);

        // Добавляем обработчики событий
        setupMenuHandlers(parentLi, subMenu);
    }

    // Настройка обработчиков событий для меню
    function setupMenuHandlers(menuItem, subMenu) {
        // Для десктопов - показываем меню при наведении
        if (window.matchMedia('(min-width: 769px)').matches) {
            menuItem.addEventListener('mouseenter', () => {
                subMenu.classList.add('active');
            });

            menuItem.addEventListener('mouseleave', () => {
                subMenu.classList.remove('active');
            });
        }
        // Для мобильных устройств - переключаем меню при клике
        else {
            menuItem.addEventListener('click', function(e) {
                // Если клик по ссылке внутри подменю, ничего не делаем
                if (e.target.closest('.menu__sub-inner-projects')) {
                    return;
                }

                // Предотвращаем переход по ссылке на мобильных устройствах
                if (e.target.tagName === 'A' && e.target.getAttribute('href').includes('/projects')) {
                    e.preventDefault();
                }

                subMenu.classList.toggle('active');
            });
        }

        // Закрываем меню при клике вне его
        document.addEventListener('click', function(e) {
            if (!menuItem.contains(e.target)) {
                subMenu.classList.remove('active');
            }
        });

        // Закрываем меню при изменении размера окна (переключение между мобильной и десктопной версией)
        window.addEventListener('resize', function() {
            subMenu.classList.remove('active');
        });
    }

    // Инициализация при загрузке страницы
    document.addEventListener('DOMContentLoaded', function() {
        addCSS();
        initProjectsMenu();
    });

    // Дополнительная инициализация при динамической загрузке контента (например, через AJAX)
    if (document.readyState === 'complete' || document.readyState === 'interactive') {
        setTimeout(function() {
            addCSS();
            initProjectsMenu();
        }, 1);
    }
})();
