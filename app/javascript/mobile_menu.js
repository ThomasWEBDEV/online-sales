// Mobile Menu Toggle
function initMobileMenu() {
  const burgerBtn = document.getElementById('burgerBtn');
  const mobileMenu = document.getElementById('mobileMenu');
  
  if (!burgerBtn || !mobileMenu) return;

  burgerBtn.addEventListener('click', () => {
    burgerBtn.classList.toggle('active');
    mobileMenu.classList.toggle('active');
    document.body.style.overflow = mobileMenu.classList.contains('active') ? 'hidden' : '';
  });

  // Close menu when clicking on overlay
  mobileMenu.addEventListener('click', (e) => {
    if (e.target === mobileMenu) {
      burgerBtn.classList.remove('active');
      mobileMenu.classList.remove('active');
      document.body.style.overflow = '';
    }
  });

  // Close menu when clicking on a link
  document.querySelectorAll('.mobile-menu-item').forEach(item => {
    item.addEventListener('click', () => {
      burgerBtn.classList.remove('active');
      mobileMenu.classList.remove('active');
      document.body.style.overflow = '';
    });
  });
}

// Init on page load
document.addEventListener('DOMContentLoaded', initMobileMenu);

// Init on Turbo navigation
document.addEventListener('turbo:load', initMobileMenu);
