class CardTitle extends HTMLElement {
  constructor() {
    super();
    this.id = Date.now();
    this.title = "Title";
    this.popover_content = "";
    this.caption = ""; // optional
  }

  // component attributes
  static get observedAttributes() {
    return ["id", "title", "popover_content", "caption"];
  }

  connectedCallback() {
    const popoverHTML =
      this.popover_content == ""
        ? ""
        : `
    <button
      tabindex="0"
      class="bbsButton bbsButton-tertiary small"
      role="button"
      data-bs-toggle="popover"
      data-bs-title="${this.title}"
      data-bs-trigger="focus"
      data-bs-custom-class="help-popover"
      data-bs-html="true"
      data-bs-content="${this.popover_content}"
    >
      <span class="msicon notranslate">help</span>
    </button>
    `;
    const innerHTML = `
    <div>
      <div class="tw-flex tw-items-center">
        <h5 class="tw-flex-grow">${this.title}</h5>
        ${popoverHTML}
      </div>
      <p class="caption">${this.caption}</p>
    </div>
    `;

    this.innerHTML = innerHTML;
  }

  // attribute change
  attributeChangedCallback(property, oldValue, newValue) {
    if (oldValue === newValue) return;
    this[property] = newValue;
  }
}

customElements.define("card-title", CardTitle);
