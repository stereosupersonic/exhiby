import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    imageUrl: String,
    title: String,
    description: String,
    artist: String,
    year: String,
    technique: String
  }

  connect() {
    this.modal = null
    this.boundCloseOnEscape = this.closeOnEscape.bind(this)
    this.boundCloseOnBackground = this.closeOnBackground.bind(this)
  }

  open(event) {
    event.preventDefault()
    this.createModal()
    document.body.classList.add("overflow-hidden")
  }

  close() {
    if (this.modal) {
      document.removeEventListener("keydown", this.boundCloseOnEscape)
      this.modal.removeEventListener("click", this.boundCloseOnBackground)
      this.modal.remove()
      this.modal = null
      document.body.classList.remove("overflow-hidden")
    }
  }

  closeOnBackground(event) {
    if (event.target === this.modal) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  createModal() {
    // Build info HTML
    const infoItems = []
    if (this.hasTitleValue && this.titleValue) {
      infoItems.push(`<h4 class="mb-3">${this.escapeHtml(this.titleValue)}</h4>`)
    }
    if (this.hasArtistValue && this.artistValue) {
      infoItems.push(`<p class="mb-1"><strong>Künstler:</strong> ${this.escapeHtml(this.artistValue)}</p>`)
    }
    if (this.hasYearValue && this.yearValue) {
      infoItems.push(`<p class="mb-1"><strong>Jahr:</strong> ${this.escapeHtml(this.yearValue)}</p>`)
    }
    if (this.hasTechniqueValue && this.techniqueValue) {
      infoItems.push(`<p class="mb-1"><strong>Technik:</strong> ${this.escapeHtml(this.techniqueValue)}</p>`)
    }
    if (this.hasDescriptionValue && this.descriptionValue) {
      infoItems.push(`<p class="mt-3">${this.escapeHtml(this.descriptionValue)}</p>`)
    }

    const infoHtml = infoItems.length > 0
      ? `<div class="lightbox-info p-3 bg-white">${infoItems.join("")}</div>`
      : ""

    this.modal = document.createElement("div")
    this.modal.className = "lightbox-modal"
    this.modal.innerHTML = `
      <div class="lightbox-content">
        <button type="button" class="lightbox-close" aria-label="Schließen">
          <i class="bi bi-x-lg"></i>
        </button>
        <div class="lightbox-image-container">
          <img src="${this.imageUrlValue}" alt="${this.escapeHtml(this.titleValue || "")}" class="lightbox-image">
        </div>
        ${infoHtml}
      </div>
    `

    document.body.appendChild(this.modal)

    // Add event listeners
    const closeButton = this.modal.querySelector(".lightbox-close")
    closeButton.addEventListener("click", () => this.close())
    closeButton.focus()

    this.modal.addEventListener("click", this.boundCloseOnBackground)
    document.addEventListener("keydown", this.boundCloseOnEscape)
  }

  escapeHtml(text) {
    if (!text) return ""
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  disconnect() {
    this.close()
  }
}
