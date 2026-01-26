import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["grid", "list", "gridBtn", "listBtn"]

  connect() {
    this.loadPreference()
  }

  showGrid() {
    this.gridTarget.classList.remove("d-none")
    this.listTarget.classList.add("d-none")
    this.gridBtnTarget.classList.add("active")
    this.listBtnTarget.classList.remove("active")
    this.savePreference("grid")
  }

  showList() {
    this.gridTarget.classList.add("d-none")
    this.listTarget.classList.remove("d-none")
    this.gridBtnTarget.classList.remove("active")
    this.listBtnTarget.classList.add("active")
    this.savePreference("list")
  }

  savePreference(view) {
    localStorage.setItem("mediaItemsView", view)
  }

  loadPreference() {
    const preference = localStorage.getItem("mediaItemsView")
    if (preference === "grid") {
      this.showGrid()
    } else {
      this.showList()
    }
  }
}
