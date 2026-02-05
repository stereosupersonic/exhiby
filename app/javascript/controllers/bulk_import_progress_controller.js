import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "progressBar",
    "progressText",
    "status",
    "totalFiles",
    "processedFiles",
    "successful",
    "failed"
  ]

  static values = {
    url: String,
    completed: { type: Boolean, default: false },
    interval: { type: Number, default: 2000 }
  }

  connect() {
    if (!this.completedValue) {
      this.startPolling()
    }
  }

  disconnect() {
    this.stopPolling()
  }

  startPolling() {
    this.poll()
    this.pollTimer = setInterval(() => this.poll(), this.intervalValue)
  }

  stopPolling() {
    if (this.pollTimer) {
      clearInterval(this.pollTimer)
      this.pollTimer = null
    }
  }

  async poll() {
    try {
      const response = await fetch(this.urlValue, {
        headers: {
          "Accept": "application/json"
        }
      })

      if (!response.ok) {
        console.error("Failed to fetch progress")
        return
      }

      const data = await response.json()
      this.updateProgress(data)

      if (data.completed) {
        this.stopPolling()
        this.completedValue = true
        this.reloadPage()
      }
    } catch (error) {
      console.error("Error polling progress:", error)
    }
  }

  updateProgress(data) {
    const percentage = data.progress_percentage

    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${percentage}%`
      this.progressBarTarget.setAttribute("aria-valuenow", percentage)
    }

    if (this.hasProgressTextTarget) {
      this.progressTextTarget.textContent = `${percentage}%`
    }

    if (this.hasTotalFilesTarget) {
      this.totalFilesTarget.textContent = data.total_files
    }

    if (this.hasProcessedFilesTarget) {
      this.processedFilesTarget.textContent = data.processed_files
    }

    if (this.hasSuccessfulTarget) {
      this.successfulTarget.textContent = data.successful_imports
    }

    if (this.hasFailedTarget) {
      this.failedTarget.textContent = data.failed_imports
    }

    if (this.hasStatusTarget) {
      this.updateStatusBadge(data.status)
    }
  }

  updateStatusBadge(status) {
    const statusClasses = {
      pending: "bg-secondary",
      processing: "bg-info",
      completed: "bg-success",
      failed: "bg-danger"
    }

    const statusLabels = {
      pending: "Ausstehend",
      processing: "Wird verarbeitet",
      completed: "Abgeschlossen",
      failed: "Fehlgeschlagen"
    }

    this.statusTarget.className = `badge ${statusClasses[status] || "bg-secondary"}`
    this.statusTarget.textContent = statusLabels[status] || status
  }

  reloadPage() {
    setTimeout(() => {
      window.location.reload()
    }, 500)
  }
}
