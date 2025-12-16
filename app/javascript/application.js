// Configure your import map in config/importmap.rb
import "@hotwired/turbo-rails"
import "controllers"
import "mobile_menu"

// Loading spinner pour tous les formulaires
document.addEventListener('DOMContentLoaded', function() {
  const forms = document.querySelectorAll('form');
  forms.forEach(form => {
    form.addEventListener('submit', function() {
      const submitBtn = form.querySelector('input[type="submit"], button[type="submit"]');
      if (submitBtn) {
        submitBtn.classList.add('btn-loading');
        const originalText = submitBtn.value || submitBtn.textContent;
        submitBtn.innerHTML = `
          <span class="btn-text">${originalText}</span>
          <span class="spinner"></span>
        `;
      }
    });
  });
});

// Auto-scroll to search results
document.addEventListener('turbo:load', function() {
  if (window.location.hash === '#produits' || window.location.search.includes('query') || window.location.search.includes('sort')) {
    setTimeout(function() {
      const target = document.getElementById('produits');
      if (target) {
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    }, 100);
  }
});
