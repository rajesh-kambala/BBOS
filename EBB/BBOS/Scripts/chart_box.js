class ChartBox extends HTMLElement {
  constructor() {
    super();
    this.id = Date.now();
    this.value = "A";
  }

  // component attributes
  static get observedAttributes() {
    return ["id", "value"];
  }

  connectedCallback() {
    if (this.value == "" || this.value == null || this.value == undefined) {
      this.innerHTML = `<p class="tw-font-semibold">N/A</p>`;
    } else {
      const aaRatings = ["F", "E", "D", "C", "B", "A", "AA"];
      // const extraAaRatings = ["(149)", "(81)", "AB"];
      const extraXxRatings = ["XX147", "XXX148"];
      const xxRatings = ["X", "XX", "XXX", "XXXX"];
      const htmlstring = ['<div class="tw-flex tw-grow tw-gap-0.5">'];
      let chosenRating = null;

      const combinedxRating = xxRatings.concat(extraXxRatings);

      if (combinedxRating.indexOf(this.value.toUpperCase()) >= 0) {
        chosenRating = xxRatings;
      } else {
        chosenRating = aaRatings;
      }

      // xating can be also XX147 (XX-xxx) and XXX148 (xx-XXX)
      // Paydescription can be (149) (81) and AB as well

      // Add either F E D selected C B A AA
      // or X XX XXX selected XXXX
      chosenRating.forEach((element) => {
        const css =
          element.toLowerCase() +
          (element == this.value.toUpperCase() ? " selected" : "");

        htmlstring.push(`<span class="${css}">${element}</span>`);
      });
      htmlstring.push("</div>");

      // DO NOT DELETE THIS COMMENT
      // TAILWIND WILL NOT MAKE CSS IF HTML DOES NOT EXIST
      // <span class="aa b c d e f xxxx xxx xx x selected xxx tw-border tw-border-2 tw-border-border-red">F</span>

      this.innerHTML = htmlstring.join("");

      // Edge cases
      if (this.value.toUpperCase() == "XX147") {
        this.querySelector(".xx").classList.add("selected");
        this.querySelector(".xxx").classList.add("partial");
      } else if (this.value.toUpperCase() == "XXX148") {
        this.querySelector(".xxx").classList.add("selected");
        this.querySelector(".xx").classList.add("partial");
      } else if (this.value.toUpperCase() == "(81)") {
          // no extra css needed here for now
      } else if (this.value.toUpperCase() == "(149)") {
          // no extra css needed here for now
      }
    }
  }

  // attribute change
  attributeChangedCallback(property, oldValue, newValue) {
    if (oldValue === newValue) return;
    this[property] = newValue;
  }
}

customElements.define("chart-box", ChartBox);
