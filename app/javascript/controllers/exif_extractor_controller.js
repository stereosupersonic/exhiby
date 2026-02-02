import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "file",
    "title",
    "description",
    "year",
    "copyright",
    "source",
    "mediaType",
    "exifPreview",
    "exifContent",
    "spinner",
    "filePreview",
    "previewImage"
  ]

  static values = {
    url: String
  }

  connect() {
    this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
  }

  async extractExif(event) {
    const file = event.target.files[0]
    if (!file) {
      this.hideFilePreview()
      this.hideExifPreview()
      return
    }

    // Show file preview for images
    if (file.type.startsWith("image/")) {
      this.showFilePreview(file)
    } else {
      this.hideFilePreview()
    }

    // Only extract EXIF for images
    if (!file.type.startsWith("image/")) {
      this.hideExifPreview()
      this.clearAutoFillFields()
      return
    }

    // Auto-select image type
    if (this.hasMediaTypeTarget) {
      this.mediaTypeTarget.value = "image"
    }

    this.showSpinner()

    try {
      const formData = new FormData()
      formData.append("file", file)

      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": this.csrfToken
        },
        body: formData
      })

      if (!response.ok) {
        throw new Error("Failed to extract EXIF data")
      }

      const data = await response.json()
      this.applySuggestedValues(data.suggested_values)
      this.displayExifData(data)
    } catch (error) {
      console.error("EXIF extraction error:", error)
      this.hideExifPreview()
    } finally {
      this.hideSpinner()
    }
  }

  applySuggestedValues(values) {
    // Clear all auto-fillable fields first
    this.clearAutoFillFields()

    if (!values) return

    // Fill fields with new values
    if (values.title && this.hasTitleTarget) {
      this.titleTarget.value = values.title
    }
    if (values.description && this.hasDescriptionTarget) {
      this.descriptionTarget.value = values.description
    }
    if (values.year && this.hasYearTarget) {
      this.yearTarget.value = values.year
    }
    if (values.copyright && this.hasCopyrightTarget) {
      this.copyrightTarget.value = values.copyright
    }
    if (values.source && this.hasSourceTarget) {
      this.sourceTarget.value = values.source
    }
  }

  clearAutoFillFields() {
    if (this.hasTitleTarget) this.titleTarget.value = ""
    if (this.hasDescriptionTarget) this.descriptionTarget.value = ""
    if (this.hasYearTarget) this.yearTarget.value = ""
    if (this.hasCopyrightTarget) this.copyrightTarget.value = ""
    if (this.hasSourceTarget) this.sourceTarget.value = ""
  }

  displayExifData(data) {
    if (!this.hasExifPreviewTarget || !this.hasExifContentTarget) return

    if (data.tags_count === 0) {
      this.hideExifPreview()
      return
    }

    // Update header badge with tag count
    const headerBadge = this.exifPreviewTarget.querySelector(".badge")
    if (headerBadge) {
      headerBadge.textContent = data.tags_count
    }

    let html = ""

    // Display grouped tags
    const groupLabels = {
      camera: "Kamera",
      image: "Bild",
      capture: "Aufnahme",
      date: "Datum",
      location: "GPS",
      author: "Autor/Copyright",
      description: "Beschreibung"
    }

    for (const [group, tags] of Object.entries(data.grouped_tags || {})) {
      if (!tags || Object.keys(tags).length === 0) continue

      html += `<h6 class="text-muted border-bottom pb-1 mb-2 small">${groupLabels[group] || group}</h6>`
      html += '<dl class="row small mb-2">'

      for (const [tag, value] of Object.entries(tags)) {
        html += `<dt class="col-sm-5 text-truncate" title="${tag}">${tag}</dt>`
        html += `<dd class="col-sm-7 text-truncate" title="${this.escapeHtml(value)}">${this.escapeHtml(value)}</dd>`
      }

      html += '</dl>'
    }

    // Add collapsible section for all tags
    if (data.all_tags && Object.keys(data.all_tags).length > 0) {
      html += `<details class="mt-2">
        <summary class="text-muted small">
          <i class="bi bi-list me-1"></i>
          Alle ${data.tags_count} EXIF-Tags anzeigen
        </summary>
        <div class="mt-2 border-top pt-2">
          <dl class="row small mb-0">`

      for (const [tag, value] of Object.entries(data.all_tags)) {
        html += `<dt class="col-sm-5 text-truncate" title="${tag}">${tag}</dt>`
        html += `<dd class="col-sm-7 text-truncate" title="${this.escapeHtml(value)}">${this.escapeHtml(value)}</dd>`
      }

      html += '</dl></div></details>'
    }

    this.exifContentTarget.innerHTML = html
    this.exifPreviewTarget.classList.remove("d-none")
  }

  escapeHtml(text) {
    if (text === null || text === undefined) return ""
    const str = String(text)
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }

  hideExifPreview() {
    if (this.hasExifPreviewTarget) {
      this.exifPreviewTarget.classList.add("d-none")
    }
  }

  showFilePreview(file) {
    if (!this.hasFilePreviewTarget || !this.hasPreviewImageTarget) return

    const reader = new FileReader()
    reader.onload = (e) => {
      this.previewImageTarget.src = e.target.result
      this.previewImageTarget.alt = file.name
      this.filePreviewTarget.classList.remove("d-none")
    }
    reader.readAsDataURL(file)
  }

  hideFilePreview() {
    if (this.hasFilePreviewTarget) {
      this.filePreviewTarget.classList.add("d-none")
    }
    if (this.hasPreviewImageTarget) {
      this.previewImageTarget.src = ""
    }
  }

  showSpinner() {
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.remove("d-none")
    }
  }

  hideSpinner() {
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.add("d-none")
    }
  }

  toggleAllTags(event) {
    event.preventDefault()
    const container = document.getElementById("exif-all-tags")
    if (container) {
      container.classList.toggle("d-none")
      event.target.textContent = container.classList.contains("d-none")
        ? "Alle Tags anzeigen"
        : "Tags ausblenden"
    }
  }
}
