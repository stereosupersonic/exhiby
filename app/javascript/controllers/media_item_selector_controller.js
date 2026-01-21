import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "search", "results", "preview", "selected"]
  static values = {
    searchUrl: String,
    selectedId: Number,
    selectedTitle: String,
    selectedThumbnail: String
  }

  connect() {
    console.log("MediaItemSelector connected", this.searchUrlValue)
    this.debounceTimer = null
    if (this.selectedIdValue) {
      this.showSelectedItem()
    }
  }

  search(event) {
    const query = event.target.value.trim()
    console.log("Search called with query:", query)

    clearTimeout(this.debounceTimer)

    if (query.length < 2) {
      this.hideResults()
      return
    }

    this.debounceTimer = setTimeout(() => {
      console.log("Performing search for:", query)
      this.performSearch(query)
    }, 300)
  }

  async performSearch(query) {
    try {
      const response = await fetch(`${this.searchUrlValue}?q=${encodeURIComponent(query)}`)
      if (!response.ok) throw new Error("Search failed")

      const items = await response.json()
      this.displayResults(items)
    } catch (error) {
      console.error("Search error:", error)
      this.resultsTarget.innerHTML = "<div class='p-2 text-danger'>Fehler bei der Suche</div>"
      this.showResults()
    }
  }

  displayResults(items) {
    if (items.length === 0) {
      this.resultsTarget.innerHTML = "<div class='p-2 text-muted'>Keine Ergebnisse gefunden</div>"
      this.showResults()
      return
    }

    this.resultsTarget.innerHTML = items.map(item => `
      <div class="media-item-result d-flex align-items-center p-2 border-bottom cursor-pointer"
           data-action="click->media-item-selector#selectItem"
           data-id="${item.id}"
           data-title="${this.escapeHtml(item.title)}"
           data-thumbnail="${item.thumbnail_url || ''}">
        ${item.thumbnail_url
          ? `<img src="${item.thumbnail_url}" class="me-2 rounded" style="width: 50px; height: 50px; object-fit: cover;" alt="${this.escapeHtml(item.title)}">`
          : `<div class="me-2 bg-light d-flex align-items-center justify-content-center rounded" style="width: 50px; height: 50px;"><i class="bi bi-image text-muted"></i></div>`
        }
        <span class="flex-grow-1">${this.escapeHtml(item.title)}</span>
      </div>
    `).join("")
    this.showResults()
  }

  selectItem(event) {
    const target = event.currentTarget
    const id = target.dataset.id
    const title = target.dataset.title
    const thumbnail = target.dataset.thumbnail

    this.inputTarget.value = id
    this.selectedIdValue = id
    this.selectedTitleValue = title
    this.selectedThumbnailValue = thumbnail

    this.showSelectedItem()
    this.hideResults()
    this.searchTarget.value = ""
  }

  showSelectedItem() {
    const thumbnailHtml = this.selectedThumbnailValue
      ? `<img src="${this.selectedThumbnailValue}" class="me-2 rounded" style="width: 80px; height: 80px; object-fit: cover;" alt="${this.escapeHtml(this.selectedTitleValue)}">`
      : `<div class="me-2 bg-light d-flex align-items-center justify-content-center rounded" style="width: 80px; height: 80px;"><i class="bi bi-image text-muted" style="font-size: 2rem;"></i></div>`

    this.previewTarget.innerHTML = `
      <div class="d-flex align-items-center p-2 border rounded bg-light">
        ${thumbnailHtml}
        <div class="flex-grow-1">
          <strong>${this.escapeHtml(this.selectedTitleValue)}</strong>
        </div>
        <button type="button" class="btn btn-sm btn-outline-danger" data-action="click->media-item-selector#clearSelection">
          <i class="bi bi-x"></i>
        </button>
      </div>
    `
    this.previewTarget.classList.remove("d-none")
    this.selectedTarget.classList.add("d-none")
  }

  clearSelection(event) {
    event.preventDefault()
    this.inputTarget.value = ""
    this.selectedIdValue = null
    this.selectedTitleValue = ""
    this.selectedThumbnailValue = ""
    this.previewTarget.innerHTML = ""
    this.previewTarget.classList.add("d-none")
    this.selectedTarget.classList.remove("d-none")
  }

  showResults() {
    this.resultsTarget.classList.remove("d-none")
  }

  hideResults() {
    this.resultsTarget.classList.add("d-none")
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  // Close results when clicking outside
  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults()
    }
  }
}
