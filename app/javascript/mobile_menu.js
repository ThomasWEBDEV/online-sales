// Mobile Menu Toggle - Compatible Turbo
function initMobileMenu() {
  const burgerBtn = document.getElementById('burgerBtn');
  const mobileMenu = document.getElementById('mobileMenu');
  
  if (!burgerBtn || !mobileMenu) return;

  // Supprimer les anciens listeners pour éviter les doublons
  const newBurgerBtn = burgerBtn.cloneNode(true);
  burgerBtn.parentNode.replaceChild(newBurgerBtn, burgerBtn);
  
  const newMobileMenu = mobileMenu.cloneNode(true);
  mobileMenu.parentNode.replaceChild(newMobileMenu, mobileMenu);

  // Récupérer les nouveaux éléments
  const burger = document.getElementById('burgerBtn');
  const menu = document.getElementById('mobileMenu');

  // Toggle menu
  burger.addEventListener('click', () => {
    burger.classList.toggle('active');
    menu.classList.toggle('active');
    document.body.style.overflow = menu.classList.contains('active') ? 'hidden' : '';
  });

  // Close on overlay click
  menu.addEventListener('click', (e) => {
    if (e.target === menu) {
      burger.classList.remove('active');
      menu.classList.remove('active');
      document.body.style.overflow = '';
    }
  });

  // Close on link click
  menu.querySelectorAll('.mobile-menu-item').forEach(item => {
    item.addEventListener('click', () => {
      burger.classList.remove('active');
      menu.classList.remove('active');
      document.body.style.overflow = '';
    });
  });
}

// Init on page load
document.addEventListener('DOMContentLoaded', initMobileMenu);

// Init on Turbo navigation
document.addEventListener('turbo:load', initMobileMenu);

// Cleanup on before cache (important pour Turbo)
document.addEventListener('turbo:before-cache', () => {
  const burger = document.getElementById('burgerBtn');
  const menu = document.getElementById('mobileMenu');
  
  if (burger) burger.classList.remove('active');
  if (menu) menu.classList.remove('active');
  document.body.style.overflow = '';
});
