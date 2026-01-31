(function() {
    'use strict';

    function addCSS() {
        if (document.querySelector('link[href="menu-projects.css"]')) {
            return;
        }

        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = 'menu-projects.css';
        document.head.appendChild(link);
    }

    function initProjectsMenu() {
        if (document.querySelector('.projects-menu-item')) {
            return;
        }

        const projectsMenuItem = document.querySelector('.menu__inner li a[href*="/projects"]');
        if (!projectsMenuItem) {
            return;
        }

        const parentLi = projectsMenuItem.parentElement;
        parentLi.classList.add('projects-menu-item');

        const currentPath = window.location.pathname;
        const isRussian = currentPath.startsWith('/ru/') || currentPath === '/ru';
        const langPrefix = isRussian ? '/ru' : '';
        
        const isProjectsPage = currentPath.includes('/projects/');
        const isMainProjectsPage = currentPath === '/projects/' || currentPath === '/projects' ||
                                   currentPath === '/ru/projects/' || currentPath === '/ru/projects';

        const subMenu = document.createElement('ul');
        subMenu.className = 'menu__sub-inner-projects';

        const projects = [
            { name: 'WireDeskVR', path: '/projects/WireDeskVR/' },
            { name: 'SyncLProj', path: '/projects/SyncLProj/' },
            { name: 'BlazeFM', path: '/projects/BlazeFM/' },
            { name: 'NetMonRS', path: '/projects/Netmonrs/' },
            { name: 'RFIDReader', path: '/projects/RFIDReader/' },
            { name: 'F-Skating Acc', path: 'https://bimawa.net/FSkatingAcc/', external: true },
        ];

        projects.forEach(project => {
            const li = document.createElement('li');
            const a = document.createElement('a');

            if (project.external) {
                a.href = project.path;
                a.target = '_blank';
                a.rel = 'noopener noreferrer';
            } else {
                a.href = langPrefix + project.path;
                if (isProjectsPage && currentPath.includes(project.path)) {
                    li.classList.add('active');
                }
            }

            a.textContent = project.name;

            li.appendChild(a);
            subMenu.appendChild(li);
        });

        parentLi.appendChild(subMenu);
        setupMenuHandlers(parentLi, subMenu);
    }

    function setupMenuHandlers(menuItem, subMenu) {
        if (window.matchMedia('(min-width: 769px)').matches) {
            menuItem.addEventListener('mouseenter', () => {
                subMenu.classList.add('active');
            });

            menuItem.addEventListener('mouseleave', () => {
                subMenu.classList.remove('active');
            });
        } else {
            menuItem.addEventListener('click', function(e) {
                if (e.target.closest('.menu__sub-inner-projects')) {
                    return;
                }

                if (e.target.tagName === 'A' && e.target.getAttribute('href').includes('/projects')) {
                    e.preventDefault();
                }

                subMenu.classList.toggle('active');
            });
        }

        document.addEventListener('click', function(e) {
            if (!menuItem.contains(e.target)) {
                subMenu.classList.remove('active');
            }
        });

        window.addEventListener('resize', function() {
            subMenu.classList.remove('active');
        });
    }

    document.addEventListener('DOMContentLoaded', function() {
        addCSS();
        initProjectsMenu();
    });

    if (document.readyState === 'complete' || document.readyState === 'interactive') {
        setTimeout(function() {
            addCSS();
            initProjectsMenu();
        }, 1);
    }
})();
