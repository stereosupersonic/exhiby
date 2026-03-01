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
    this.boundCloseOnEscape = this.handleKeydown.bind(this)
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

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    } else if (event.key === "ArrowRight") {
      event.preventDefault()
      this.navigate(1)
    } else if (event.key === "ArrowLeft") {
      event.preventDefault()
      this.navigate(-1)
    }
  }

  getSiblings() {
    return Array.from(document.querySelectorAll("[data-controller~='lightbox']"))
  }

  navigate(direction) {
    const siblings = this.getSiblings()
    if (siblings.length <= 1) return

    const currentIndex = siblings.indexOf(this.element)
    const nextIndex = (currentIndex + direction + siblings.length) % siblings.length
    const nextElement = siblings[nextIndex]

    this.close()
    nextElement.click()
  }

  createModal() {
    const siblings = this.getSiblings()
    const currentIndex = siblings.indexOf(this.element)
    const hasNav = siblings.length > 1

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

    const counterHtml = hasNav
      ? `<span class="lightbox-counter">${currentIndex + 1} / ${siblings.length}</span>`
      : ""

    const prevButton = hasNav
      ? `<button type="button" class="lightbox-nav lightbox-prev" aria-label="Vorheriges Bild"><i class="bi bi-chevron-left"></i></button>`
      : ""

    const nextButton = hasNav
      ? `<button type="button" class="lightbox-nav lightbox-next" aria-label="Nächstes Bild"><i class="bi bi-chevron-right"></i></button>`
      : ""

    this.modal = document.createElement("div")
    this.modal.className = "lightbox-modal"
    this.modal.innerHTML = `
      <div class="lightbox-content">
        <button type="button" class="lightbox-close" aria-label="Schließen">
          <i class="bi bi-x-lg"></i>
        </button>
        ${counterHtml}
        <div class="lightbox-image-container">
          ${prevButton}
          <img src="${this.imageUrlValue}" alt="${this.escapeHtml(this.titleValue || "")}" class="lightbox-image">
          ${nextButton}
        </div>
        ${infoHtml}
      </div>
    `

    document.body.appendChild(this.modal)

    const closeButton = this.modal.querySelector(".lightbox-close")
    closeButton.addEventListener("click", () => this.close())

    if (hasNav) {
      this.modal.querySelector(".lightbox-prev").addEventListener("click", (e) => {
        e.stopPropagation()
        this.navigate(-1)
      })
      this.modal.querySelector(".lightbox-next").addEventListener("click", (e) => {
        e.stopPropagation()
        this.navigate(1)
      })
    }

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
