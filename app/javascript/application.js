// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Loading spinner pour tous les formulaires
document.addEventListener('DOMContentLoaded', function() {
  const forms = document.querySelectorAll('form');

  forms.forEach(form => {
    form.addEventListener('submit', function() {
      const submitBtn = form.querySelector('input[type="submit"], button[type="submit"]');

      if (submitBtn) {
        // Ajouter la classe loading
        submitBtn.classList.add('btn-loading');

        // Wrap le texte et ajouter le spinner
        const originalText = submitBtn.value || submitBtn.textContent;
        submitBtn.innerHTML = `
          <span class="btn-text">${originalText}</span>
          <span class="spinner"></span>
        `;
      }
    });
  });
});
