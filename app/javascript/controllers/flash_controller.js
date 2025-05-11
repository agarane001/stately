import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["message"]
    static values = { timeout: Number }

    connect() {
        if (this.timeoutValue) {
            setTimeout(() => {
                this.dismiss()
            }, this.timeoutValue)
        }
    }

    dismiss() {
        this.messageTarget.remove()
    }
}