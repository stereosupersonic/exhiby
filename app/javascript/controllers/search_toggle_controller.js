import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "icon", "form"]
  static values = { expanded: Boolean }

  connect() {
    this.closeOnClickOutside = this.closeOnClickOutside.bind(this)

    // If there's a query value, keep it expanded
    if (this.inputTarget.value.trim() !== "") {
      this.expand()
    }
  }

  handleClick(event) {
    // If not expanded, prevent form submission and expand instead
    if (!this.expandedValue) {
      event.preventDefault()
      event.stopPropagation()
      this.expand()
    }
    // If expanded, let the form submit normally (Enter key or button click)
  }

  expand() {
    this.expandedValue = true
    this.element.classList.add("expanded")
    // Small delay to ensure the input is visible before focusing
    setTimeout(() => {
      this.inputTarget.focus()
    }, 50)
    document.addEventListener("click", this.closeOnClickOutside)
  }

  collapse() {
    // Don't collapse if there's text in the input
    if (this.inputTarget.value.trim() !== "") {
      return
    }

    this.expandedValue = false
    this.element.classList.remove("expanded")
    document.removeEventListener("click", this.closeOnClickOutside)
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.collapse()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnClickOutside)
  }
}
