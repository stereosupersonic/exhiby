import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "results", "items"]
  static values = {
    searchUrl: String,
    addUrl: String,
    removeUrl: String
  }

  connect() {
    this.debounceTimer = null
  }

  search(event) {
    const query = event.target.value.trim()

    clearTimeout(this.debounceTimer)

    if (query.length < 2) {
      this.hideResults()
      return
    }

    this.debounceTimer = setTimeout(() => {
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
           data-action="click->collection-items#addItem"
           data-id="${item.id}"
           data-title="${this.escapeHtml(item.title)}"
           data-thumbnail="${item.thumbnail_url || ''}">
        ${item.thumbnail_url
          ? `<img src="${item.thumbnail_url}" class="me-2 rounded" style="width: 50px; height: 50px; object-fit: cover;" alt="${this.escapeHtml(item.title)}">`
          : `<div class="me-2 bg-light d-flex align-items-center justify-content-center rounded" style="width: 50px; height: 50px;"><i class="bi bi-image text-muted"></i></div>`
        }
        <span class="flex-grow-1">${this.escapeHtml(item.title)}</span>
        <button type="button" class="btn btn-sm btn-outline-primary">
          <i class="bi bi-plus"></i>
        </button>
      </div>
    `).join("")
    this.showResults()
  }

  async addItem(event) {
    event.preventDefault()
    const target = event.currentTarget
    const mediaItemId = target.dataset.id

    try {
      const response = await fetch(this.addUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        },
        body: JSON.stringify({ media_item_id: mediaItemId })
      })

      if (response.ok) {
        const data = await response.json()
        if (data.html) {
          this.itemsTarget.innerHTML = data.html
        }
        this.searchTarget.value = ""
        this.hideResults()
      } else {
        const error = await response.json()
        alert(error.message || "Fehler beim Hinzufügen")
      }
    } catch (error) {
      console.error("Add error:", error)
      alert("Fehler beim Hinzufügen")
    }
  }

  async removeItem(event) {
    event.preventDefault()
    const button = event.currentTarget
    const mediaItemId = button.dataset.mediaItemId

    if (!confirm("Möchten Sie dieses Medium aus der Sammlung entfernen?")) {
      return
    }

    try {
      const response = await fetch(`${this.removeUrlValue}?media_item_id=${mediaItemId}`, {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        }
      })

      if (response.ok) {
        const data = await response.json()
        if (data.html) {
          this.itemsTarget.innerHTML = data.html
        }
      } else {
        alert("Fehler beim Entfernen")
      }
    } catch (error) {
      console.error("Remove error:", error)
      alert("Fehler beim Entfernen")
    }
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
}
