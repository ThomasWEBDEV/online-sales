// Mobile Menu - Version sans redéclaration
(function() {
  'use strict';
  
  let mobileMenuInitialized = false;

  function initMobileMenu() {
    // Éviter la double initialisation
    if (mobileMenuInitialized) return;
    
    const burger = document.getElementById('burgerBtn');
    const menu = document.getElementById('mobileMenu');
    
    if (!burger || !menu) return;

    mobileMenuInitialized = true;

    // Toggle
    burger.onclick = function() {
      burger.classList.toggle('active');
      menu.classList.toggle('active');
      document.body.style.overflow = menu.classList.contains('active') ? 'hidden' : '';
    };

    // Close on overlay
    menu.onclick = function(e) {
      if (e.target === menu) {
        burger.classList.remove('active');
        menu.classList.remove('active');
        document.body.style.overflow = '';
      }
    };

    // Close on link click
    const links = menu.querySelectorAll('.mobile-menu-item');
    for (let i = 0; i < links.length; i++) {
      links[i].onclick = function() {
        burger.classList.remove('active');
        menu.classList.remove('active');
        document.body.style.overflow = '';
      };
    }
  }

  // Init
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initMobileMenu);
  } else {
    initMobileMenu();
  }

  // Turbo
  document.addEventListener('turbo:load', function() {
    mobileMenuInitialized = false;
    initMobileMenu();
  });

  // Cleanup
  document.addEventListener('turbo:before-cache', function() {
    const burger = document.getElementById('burgerBtn');
    const menu = document.getElementById('mobileMenu');
    
    if (burger) burger.classList.remove('active');
    if (menu) menu.classList.remove('active');
    document.body.style.overflow = '';
    mobileMenuInitialized = false;
  });
})();
