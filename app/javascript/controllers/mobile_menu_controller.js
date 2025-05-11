import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["menu", "openButton", "closeButton"]

    toggle() {
        this.menuTarget.classList.toggle("hidden")
        this.openButtonTarget.classList.toggle("hidden")
        this.closeButtonTarget.classList.toggle("hidden")
    }
}