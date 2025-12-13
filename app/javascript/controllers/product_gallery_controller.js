import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mainImage", "thumbnail"]
  static values = { totalPhotos: Number }

  connect() {
    this.currentPhotoIndex = 0
  }

  showPhoto(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.updatePhoto(index)
  }

  changePhoto(event) {
    const direction = parseInt(event.currentTarget.dataset.direction)
    this.currentPhotoIndex += direction

    // Boucler
    if (this.currentPhotoIndex < 0) {
      this.currentPhotoIndex = this.totalPhotosValue - 1
    } else if (this.currentPhotoIndex >= this.totalPhotosValue) {
      this.currentPhotoIndex = 0
    }

    this.updatePhoto(this.currentPhotoIndex)
  }

  updatePhoto(index) {
    // Retirer active de toutes les images
    this.mainImageTargets.forEach(img => img.classList.remove('active'))
    this.thumbnailTargets.forEach(thumb => thumb.classList.remove('active'))

    // Ajouter active à l'image sélectionnée
    this.mainImageTargets[index].classList.add('active')
    this.thumbnailTargets[index].classList.add('active')

    this.currentPhotoIndex = index
  }
}
