import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.closeOnClickOutside = this.closeOnClickOutside.bind(this)
  }

  toggle(event) {
    event.preventDefault()
    if (this.menuTarget.classList.contains("show")) {
      this.close()
    } else {
      this.open()
    }
  }

  show() {
    this.menuTarget.classList.add("show")
  }

  hide() {
    this.menuTarget.classList.remove("show")
  }

  open() {
    this.menuTarget.classList.add("show")
    document.addEventListener("click", this.closeOnClickOutside)
  }

  close() {
    this.menuTarget.classList.remove("show")
    document.removeEventListener("click", this.closeOnClickOutside)
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnClickOutside)
  }
}
