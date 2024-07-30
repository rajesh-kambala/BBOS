// Escape key press for the bootstrap dropdown
document.addEventListener("keydown", function (event) {
    const key = event.key;
    if (key == "Escape") {
        closeALLMenu();
        [...document.querySelectorAll('[data-bs-toggle="dropdown"]')].forEach(
            (dropdown) => {
                const instance = bootstrap.Dropdown.getOrCreateInstance(dropdown);
                if (instance) {
                    instance.classList.add("tw-hidden");
                }
            },
        );
    }
});

const toggleAccordion = (event) => {
    const parentElement = event.currentTarget.parentElement;
    const isOpen = parentElement.classList.toggle("open");
    const contentWrapper = parentElement.querySelector(".content-wrapper");
    if (isOpen) {
        contentWrapper.querySelector("fieldset").removeAttribute("disabled");

        contentWrapper.style.height = contentWrapper.clientHeight + "px";

        // unset it so that it can expand with new content
        contentWrapper.style.height = "unset";
    } else {
        contentWrapper
            .querySelector("fieldset")
            .setAttribute("disabled", "disabled");
        contentWrapper.style.height = "0px";
    }

    // This is needed so .NET form does not automatically post back
    event.preventDefault();
};

const checkboxes_filldata = (containerID, csvOptionValue) => {
    if (csvOptionValue == null) return;
    const container = document.querySelector("#" + containerID.trim());
    const checkboxValues = csvOptionValue.split(",");
    checkboxValues.forEach((value) => {
        const checkbox = container.querySelector(
            `input[type=checkbox][value="${value}"]`,
        );
        if (checkbox) {
            checkbox.checked = true;
            if (checkbox.onchange) checkbox.onchange();
        }
    });
};

/**
 * This method uses mulSel_filldata to set the
 * states selected for a particular country
 * @param {string} countryId
 * @param {string} csvStateIds
 */
const countryState_setData = (countryId, csvStateIds) => {
    // countryState_setData(1) - just select USA no state
    // countryState_setData(1, "") - Just select USA no state
    // countryState_setData(1, "1,2,3,4"); - USA and first four state
    // countryState_setData(5); -- Other - Aruba
    // countryState_setData(5, ""); -- Other - Aruba
    // countryState_setData(5, "1,2,3,4"); -- Other - Aruba

    // these radio elements objects are created in index.html due to aspx bad intelligence.
    const radioElement =
        !countryId || countryId == 0
            ? radio_country_none
            : countryId == 1
                ? radio_country_usa
                : countryId == 2
                    ? radio_country_canada
                    : countryId == 3
                        ? radio_country_mexico
                        : radio_country_other;

    radioElement.checked = true;
    // The following onchange event causes the state selection to reset.
    radioElement.onchange();

    if (countryId == null || countryId < 1) {
        // select none
        // already happened above.
    } else if (countryId < 4) {
        mulSel_filldata("countryState-mulSel", csvStateIds);
    } else {
        // select other country and its id
        const otherCountrySelect = enableOtherCountriesInput("otherCountries");
        otherCountrySelect.value = countryId;
        Update_UpdatePanel();
    }
};

/**
 * This method just selects one state id from given the name of the state
 * @param {string} stateName
 */
const mulSel_selectSingleStateByName = (stateName) => {
    if (states) {
        const state = states.find((state) => state.prst_State.toLowerCase() == stateName.trim().toLowerCase())
        if (state) {
            mulSel_filldata("countryState-mulSel", String(state.prst_StateId));
        }
    }
}


/**
 * This method iterates over the menu options in the
 * multiselect and then performs a click action on
 * items that match the ids in the argument csv string.
 * @param {string} mulSel_id
 * @param {string} csvOptionIds
 * @returns
 */
const mulSel_filldata = (mulSel_id, csvOptionIds) => {
    if (csvOptionIds == null) return;
    const optionIds = csvOptionIds.split(",");
    const mulSel_parent = document.querySelector("#" + mulSel_id);
    optionIds.forEach((optionId) => {
        // find the menu item and make is selected
        const menuitem = mulSel_parent.querySelector(
            `li[data-mulSel_id="${optionId}"]:not(.selected)`,
        );
        if (menuitem) menuitem.click();
    });
    const mulSel_input = mulSel_parent.querySelector(".bbs-mulSel-input input");
    if (mulSel_input) {
        mulSel_input.blur();
    }
};

/**
 * Remove all the selected items from the multi_select
 * @param {string} mulSel_id
 */
const mulSel_reset = (mulSel_id) => {
    // pick all the selected items and perform click event
    // on them to unselect them
    const mulSel_parent = document.querySelector("#" + mulSel_id);
    [...mulSel_parent.querySelectorAll("li.selected")].forEach((option) => {
        option.click();
    });
};

/**
 * if a removable bbsButton bbsButton-tag-secondary is clicked, this is the function that needs to be called to remove it
 * @param {object} event
 */
const mulSel_onclickTag = (event) => {
    // TODO:PT - low priority, Make on the X on the tag clicable and focasable

    const mulSelParent = event.currentTarget.closest(".bbs-mulSel");
    const menu = mulSelParent.querySelector(".dropdown-menu");
    const mulSel_id = event.currentTarget.getAttribute("data-mulSel_id");

    // Find the corresponding item related to the clicked tag
    const menuitem = menu.querySelector(
        `li.selected[data-mulSel_id="${mulSel_id}"]`,
    );

    // click on the menuitem so that it can
    // finish other related actions pertaining to
    // removing the selected item.
    if (menuitem) {
        menuitem.click();
    }

    const nextsibling = event.currentTarget.nextElementSibling;
    const prevsibling = event.currentTarget.previousElementSibling;
    if (nextsibling) {
        nextsibling.focus();
        nextsibling.classList.add("focus-visible");
    } else if (prevsibling) {
        prevsibling.focus();
        prevsibling.classList.add("focus-visible");
    }
    event.currentTarget.remove();
};

/**
 * Handle arrow up and down from the multiselect input to focus
 * on the items in drop down menu
 * @param {object} event
 */
const mulSel_onkeydown = (event) => {
    const key = event.key;

    // Bootstrap stuff!!
    // find the instance of the dropdown
    // this is the div with data-bs-toggle="dropdown" attribute
    const instance = bootstrap.Dropdown.getOrCreateInstance(
        event.currentTarget.closest('[data-bs-toggle="dropdown"]'),
    );

    if (key == "ArrowDown" || key == "ArrowUp") {
        event.preventDefault();

        if (instance) {
            instance.show();
            instance._selectMenuItem(event);
        }
    }
};

/**
 * Handle typing inside mulSel .bbs-mulSel
 * open the dropdown
 * and filters the content
 * @param {object} event
 */
const mulSel_oninput = (event) => {
    const inputValue = event.currentTarget.value;
    const inputValueNormalized = inputValue.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
    const menu = event.currentTarget
        .closest(".bbs-mulSel")
        .querySelector(".dropdown-menu");

    const instance = bootstrap.Dropdown.getOrCreateInstance(
        event.currentTarget.closest(".bbs-mulSel-input"),
    );
    if (instance) {
        instance.show();
    }

    // Filter the menu items based on the input
    const optionss = menu.querySelectorAll("li");
    optionss.forEach((htmlElement) => {
        // text-label
        const value = htmlElement
            .getAttribute("data-search_string")
            .toLowerCase()
            .trim()
            .normalize("NFD").replace(/[\u0300-\u036f]/g, "");
        if (value.includes(inputValueNormalized.toLowerCase().trim())) {
            htmlElement.classList.remove("tw-hidden");
        } else {
            htmlElement.classList.add("tw-hidden");
        }
    });

    // Show no options if empty
    if (menu.querySelectorAll("li:not(.tw-hidden)").length <= 0) {
        let noResults = menu.querySelector("p.notfound");
        if (!noResults) noResults = document.createElement("p");
        noResults.setAttribute("class", "menu-no-data notfound");
        noResults.innerHTML = "No results found with the string " + inputValue;
        menu.appendChild(noResults);
    } else {
        const nodata = menu.querySelector(".menu-no-data");
        if (nodata) {
            nodata.remove();
        }
    }

    event.stopPropagation();
};

/**
 * helper function for creating tags for the multiselect
 * @param {object} event
 */
const mulSel_getOrCreateTagContainer = (mulSelParent) => {
    let tagContainer = mulSelParent.querySelector(".mulSel-tag-container");
    if (!tagContainer) {
        // create a tag container
        // and append it to the parent of the input
        tagContainer = document.createElement("div");
        tagContainer.setAttribute("class", "mulSel-tag-container");
        mulSelParent.appendChild(tagContainer);
    }
    return tagContainer;
};

// Based on the country,
// this function adds options in the
// .bbs-mulSel's menu.
const mulSel_createOpt_TerminalMkt = (terminalMarketList) => {
    const mulSel = document.querySelector("#terminalMkt-mulSel");
    if (mulSel == null) return;
    // Clear the existing multiseled tags
    mulSel.querySelector(".mulSel-tag-container").innerHTML = "";

    const optionContainer = mulSel.querySelector("ul.dropdown-menu");

    // clear the previous list
    optionContainer.innerHTML = "";

    // const terminalMarkets = [
    // {
    //   prtm_TerminalMarketId: "0",
    //   prtm_FullMarketName:
    //     "Jefferson County Truck Growers Association/Alabama Farmers Market",
    //   prtm_City: "Birmingham",
    //   prtm_State: "AL",
    // }
    // ],

    // populate the terminalMarket mulSel
    for (let i in terminalMarketList) {
        const name = terminalMarketList[i].prtm_FullMarketName;
        const city = terminalMarketList[i].prtm_City;
        const state = terminalMarketList[i].prtm_State;

        const outer = document.createElement("li");
        optionContainer.appendChild(outer);

        const option = document.createElement("button");
        outer.appendChild(option);

        outer.setAttribute(
            "onclick",
            `mulSel_onclickOpt_TerminalMkt(event, "${terminalMarketList[i].prtm_TerminalMarketId}")`,
        );
        // terminal_id;
        outer.setAttribute(
            "data-mulSel_id",
            terminalMarketList[i].prtm_TerminalMarketId,
        );
        outer.setAttribute("data-search_string", name + " " + city + " " + state);
        option.setAttribute("tabindex", "-1");
        option.setAttribute("class", "bbsButton bbsButton-menu-item dropdown-item");
        option.setAttribute("role", "option");
        option.setAttribute("type", "button");
        option.innerHTML = `
      <div class="tw-flex tw-flex-col">
        <span class="text-label">${name}</span>
        <span class="caption">${city}, ${state}</span>
      </div>
      <span class="msicon notranslate">check</span>
      `;
    }
};

const mulSel_onclickOpt_TerminalMkt = (event, optionId) => {
    // const terminalMarkets = [
    //   {
    //   prtm_TerminalMarketId: "0",
    //   prtm_FullMarketName:
    //     "Jefferson County Truck Growers Association/Alabama Farmers Market | Birmingham, AL",
    // }],

    // find the market
    const terminalMarket = terminalMarkets.find(
        (object) => object.prtm_TerminalMarketId == optionId,
    );

    event.stopPropagation();
    event.preventDefault();

    const mulSelParent = event.currentTarget.closest(".bbs-mulSel");

    const tagContainer = mulSel_getOrCreateTagContainer(mulSelParent);

    const name = terminalMarket.prtm_FullMarketName;
    const city = terminalMarket.prtm_City;

    const tagLabel = name.substring(0, 15) + "..., " + city;

    // check if there is any tag with that value exist in the parent
    const tagElement = tagContainer.querySelector(
        `button[data-mulSel_id="${optionId}"]`,
    );
    if (!tagElement) {
        // create the tag if it does not exists
        // and mark item as selected
        const newTag = document.createElement("button");
        newTag.setAttribute("class", "bbsButton bbsButton-tag-secondary small");
        newTag.setAttribute("data-mulSel_id", optionId);
        newTag.setAttribute("onclick", "mulSel_onclickTag(event)");
        newTag.innerHTML = `
    <span>${tagLabel}</span>
    <span class="msicon notranslate">clear</span>
    `;
        tagContainer.appendChild(newTag);

        // mark option as selected
        const menuoption = event.currentTarget.closest("li");
        menuoption.classList.add("selected");
    } else {
        // remove the tag element and mark the item non selected
        tagElement.remove();
        // mark option as unselected
        const menuoption = event.currentTarget.closest("li");
        menuoption.classList.remove("selected");
    }

    // update dropdown position
    const instance = bootstrap.Dropdown.getOrCreateInstance(
        mulSelParent.querySelector('[data-bs-toggle="dropdown"]'),
    );
    if (instance) {
        instance.update();
        // keep the dropdown open
        instance.show();
    }

    // focus the input
    const input = mulSelParent.querySelector("input");
    if (input) {
        input.focus();
        input.select();
    }
};

const setIsDisabled = (id, isDisabled) => {
    const fieldsetElement = document.querySelector(`#${id}`);
    if (fieldsetElement) {
        if (isDisabled) {
            fieldsetElement.setAttribute("disabled", isDisabled);
            fieldsetElement.querySelector("input").value = "";
        } else {
            fieldsetElement.removeAttribute("disabled");
        }
    }
};

// Based on the country,
// this function adds options in the
// .bbs-mulSel's menu.
const mulSel_createOpt_CountryState = (optionId) => {
    // optionId 1 == USA, 2 == Canada, 3 == Mexico

    // clear and disable other-countries input
    const otherCountryInput = document.querySelector("#otherCountries");
    otherCountryInput.setAttribute("disabled", "disabled");
    otherCountryInput.value = "";

    // clear and enable the city
    document.querySelector("#us_canada_mexico_city input").value = "";
    setIsDisabled("us_canada_mexico_city", false);

    const mulSel = document.querySelector("#countryState-mulSel");
    if (mulSel == null) return;

    // TODO:PT - low priority, the bootstrap dropdown is still opening
    // even if you have disabled the button using the filedset.
    // This is due to the data-bs-toggle="dropdown" set on a div and
    // not on a button.

    // enable state selection
    document.querySelector("#us_canada_mexico_state").removeAttribute("disabled");

    // Clear the existing multiseled tags
    mulSel.querySelector(".mulSel-tag-container").innerHTML = "";

    const optionContainer = mulSel.querySelector("ul.dropdown-menu");

    // clear the previous list
    optionContainer.innerHTML = "";

    // states e.g.
    // [{
    //   prst_StateId: 1,
    //   prst_State: "Alabama",
    //   prst_CountryId: 1,
    //   prst_Abbreviation: "AL",
    // }],

    // fiter the states for the selected optionId
    const filteredStates = states.filter(
        (state) => state.prst_CountryId == optionId,
    );

    // populate the state mulSel
    for (let i in filteredStates) {
        const outer = document.createElement("li");
        optionContainer.appendChild(outer);
        const option = document.createElement("button");
        outer.appendChild(option);

        const label = `${filteredStates[i].prst_State} (${filteredStates[i].prst_Abbreviation})`;

        outer.setAttribute(
            "onclick",
            `mulSel_onclickOpt_CountryState(event, "${filteredStates[i].prst_StateId}")`,
        );

        outer.setAttribute("data-mulSel_id", filteredStates[i].prst_StateId);
        outer.setAttribute("data-search_string", label);

        option.setAttribute("tabindex", "-1");
        option.setAttribute("class", "bbsButton bbsButton-menu-item dropdown-item");
        option.setAttribute("role", "option");
        option.setAttribute("type", "button");
        option.innerHTML = `
      <span class="text-label">${label}</span>
      <span class="msicon notranslate">check</span>
     `;
    }
};

// When you need to add tags from the
// .bbs-mulSel. call this function with the value,
// this will add the tags in the .mulSel-tag-container
// if it exits or append one in the mulSel
const mulSel_onclickOpt_CountryState = (event, optionId) => {
    // states e.g.
    // [{
    //   prst_StateId: 1,
    //   prst_State: "Alabama",
    //   prst_CountryId: 1,
    //   prst_Abbreviation: "AL",
    // }],

    // find the state
    const stateobject = states.find((state) => state.prst_StateId == optionId);

    event.stopPropagation();
    event.preventDefault();

    const mulSelParent = event.currentTarget.closest(".bbs-mulSel");

    const tagContainer = mulSel_getOrCreateTagContainer(mulSelParent);

    // check if there is any tag with that value exist in the parent
    const tagElement = tagContainer.querySelector(
        `button[data-mulSel_id="${optionId}"]`,
    );

    if (!tagElement) {
        // create the tag if it does not exists
        const newTag = document.createElement("button");
        newTag.setAttribute("class", "bbsButton bbsButton-tag-secondary small");
        newTag.setAttribute("data-mulSel_id", optionId);
        newTag.setAttribute("onclick", "mulSel_onclickTag(event)");
        newTag.innerHTML = `
    <span>${stateobject.prst_State}</span>
    <span class="msicon notranslate">clear</span>
    `;
        tagContainer.appendChild(newTag);

        // mark option as selected
        const menuoption = event.currentTarget.closest("li");
        menuoption.classList.add("selected");

    } else {
        // remove the tag element and mark the item non selected
        tagElement.remove();
        // mark option as unselected
        const menuoption = event.currentTarget.closest("li");
        menuoption.classList.remove("selected");

    }

    // update dropdown position
    const instance = bootstrap.Dropdown.getOrCreateInstance(
        mulSelParent.querySelector('[data-bs-toggle="dropdown"]'),
    );
    if (instance) {
        instance.update();
        // keep the dropdown open
        instance.show();
    }

    // focus the input
    const input = mulSelParent.querySelector("input");
    if (input) {
        input.focus();
        input.select();
    }

    // call refreshTerminalMarkets, if defined
    if (typeof refreshTerminalMarkets === "function") {
        refreshTerminalMarkets();
    }
};

const findTopLevelCommodityParent = (i) => {
    // [{
    //     "prcm_CommodityId": 537,
    //     "prcm_ParentId": 535,
    //     "prcm_Level": 5,
    //     "prcm_name": "Yellow",
    //     "prcm_commoditycode": "Yellow",
    //     "prcm_DisplayOrder": 4840,
    //     "prcm_FullName": "Yellow Tomato"
    // }],

    if (commodities[i].prcm_Level != 1) {
        const parentID = commodities[i].prcm_ParentId;
        const index = commodities.findIndex(
            (commodity) => commodity.prcm_CommodityId === parentID,
        );
        // top level not found...
        // continue recuursion
        return findTopLevelCommodityParent(index);
    } else {
        // found the TopLevetParent - Stop reccursion
        return i;
    }
};

const mulSel_createOpt_Commodities = (optionId) => {
    const mulSel = document.querySelector("#commodity-mulSel");
    if (mulSel == null) return;
    // TODO:PT - low priority, the bootstrap dropdown is still opening
    // even if you have disabled the button using the filedset.
    // This is due to the data-bs-toggle="dropdown" set on a div and
    // not on a button.

    // Clear the existing multiseled tags
    mulSel.querySelector(".mulSel-tag-container").innerHTML = "";

    const optionContainer = mulSel.querySelector("ul.dropdown-menu");

    // clear the previous list
    optionContainer.innerHTML = "";
    // populate the mulSel

    commodities.forEach((commodity, i) => {
        const topLevelParentIndex = findTopLevelCommodityParent(i);

        if (topLevelParentIndex == i) {
        }

        let name = commodity.prcm_FullName;

        let parentName = commodities[topLevelParentIndex].prcm_FullName;

        let allClass = "";
        const parent_CommodityId =
            commodities[topLevelParentIndex].prcm_CommodityId;

        let onclickFunction = `mulSel_onclickOpt_Commodities(event, "${commodity.prcm_CommodityId}", "${parent_CommodityId}")`;

        if (topLevelParentIndex == i) {
            // this is the TopLevelParent itself
            // parentName = "All " + parentName;
            name = "* All " + name;
            allClass = "tw-font-semibold";
            // onclickFunction += `; handleTopLevelCommoditySelection(event, ${commodity.prcm_CommodityId});`;
        }

        const outer = document.createElement("li");
        outer.setAttribute("data-mulSel_id", commodity.prcm_CommodityId);
        // set for all children the top level parent id
        if (topLevelParentIndex != i) {
            outer.setAttribute("data-mulSel_parentId", parent_CommodityId);
        }
        outer.setAttribute("data-search_string", `${name} ${parentName}`);
        outer.setAttribute("onclick", onclickFunction);

        const option = document.createElement("button");
        option.setAttribute("tabindex", "-1");
        option.setAttribute("class", "bbsButton bbsButton-menu-item dropdown-item");
        option.setAttribute("role", "option");
        option.setAttribute("type", "button");
        option.innerHTML = `
    <div class="tw-flex tw-gap-2">
    <span class="text-label ${allClass}">${name}</span>
    <span class="bbsButton bbsButton-tag-secondary smaller c-${parent_CommodityId}">${parentName}</span>
    </div>
    <span class="msicon notranslate">check</span>
    `;
        outer.appendChild(option);
        optionContainer.appendChild(outer);
    });
};
// call the above function
(() => {
    mulSel_createOpt_Commodities();
})();

// When you need to add tags from the
// .bbs-mulSel. call this function with the value,
// this will add the tags in the .mulSel-tag-container
// if it exits or append one in the mulSel
const mulSel_onclickOpt_Commodities = (event, optionId, parent_CommodityId) => {
    // find the commodity
    const commodity = commodities.find(
        (commodity) => commodity.prcm_CommodityId == optionId,
    );

    event.stopPropagation();
    event.preventDefault();

    const mulSelParent = event.currentTarget.closest(".bbs-mulSel");

    const tagContainer = mulSel_getOrCreateTagContainer(mulSelParent);

    // check if there is any tag with that value exist in the parent
    const tagElement = tagContainer.querySelector(
        `button[data-mulSel_id="${optionId}"]`,
    );
    // const tagClass = "c-" + commodities[topLevelParentIndex].prcm_CommodityId;

    if (!tagElement) {
        // create the tag if it does not exists
        const newTag = document.createElement("button");
        newTag.setAttribute(
            "class",
            `bbsButton bbsButton-tag-secondary small c-${parent_CommodityId}`,
        );
        newTag.setAttribute("data-mulSel_id", optionId);
        newTag.setAttribute("data-mulSel_parentId", parent_CommodityId);
        newTag.setAttribute("onclick", "mulSel_onclickTag(event)");

        const tagLabel =
            (commodity.prcm_CommodityId == parent_CommodityId
                ? "<strong>* All </strong>"
                : "") + commodity.prcm_FullName;

        newTag.innerHTML = `
    <span>${tagLabel}</span>
    <span class="msicon notranslate">clear</span>
    `;
        tagContainer.appendChild(newTag);

        // mark option as selected
        const menuoption = event.currentTarget.closest("li");
        menuoption.classList.add("selected");

        // Special case: the user selected a parent level
        if (optionId == parent_CommodityId) {
            // remove all the selected children
            const selectedchildren = mulSelParent.querySelectorAll(
                `li.selected[data-mulSel_parentId="${parent_CommodityId}"]`,
            );
            [...selectedchildren].forEach((htmlElement) => {
                htmlElement.click();
            });

            // disabled all the children
            const allchildren = mulSelParent.querySelectorAll(
                `li[data-mulSel_parentId="${parent_CommodityId}"]`,
            );

            [...allchildren].forEach((child) => {
                child.setAttribute("disabled", "disabled");
                child.querySelector("button").setAttribute("disabled", "disabled");
            });
        }
    } else {
        // remove the tag element and mark the item non selected
        tagElement.remove();
        // mark option as unselected
        const menuoption = event.currentTarget.closest("li");
        menuoption.classList.remove("selected");

        // Special case: the user unselected a parent level
        if (optionId == parent_CommodityId) {
            // enabled all the children
            const allchildren = mulSelParent.querySelectorAll(
                `li[data-mulSel_parentId="${parent_CommodityId}"]`,
            );

            [...allchildren].forEach((child) => {
                child.removeAttribute("disabled", "disabled");
                child.querySelector("button").removeAttribute("disabled");
            });
        }
    }

    // update dropdown position
    const instance = bootstrap.Dropdown.getOrCreateInstance(
        mulSelParent.querySelector('[data-bs-toggle="dropdown"]'),
    );
    if (instance) {
        instance.update();
        // keep the dropdown open
        instance.show();
    }

    // focus the input
    const input = mulSelParent.querySelector("input");
    if (input) {
        input.focus();
        input.select();
    }
};


const selectNoneCountry = (event) => {
    const otherCountryInput = document.querySelector("#otherCountries");
    otherCountryInput.setAttribute("disabled", "disabled");
    otherCountryInput.value = "";

    const stateSlector = document.querySelector("#us_canada_mexico_state");
    if (stateSlector) {
        stateSlector.setAttribute("disabled", "disabled");
        // Clear the existing multiseled tags
        stateSlector.querySelector(".mulSel-tag-container").innerHTML = "";
    }

    // disabled state and city selection
    const citySelector = document.querySelector("#us_canada_mexico_city");
    if (citySelector) {
        citySelector.setAttribute("disabled", "disabled");
        // Clear the existing multiseled tags
        citySelector.querySelector("input").value = "";
    }
};

// This is called when Other countries
// radio is selected.
const enableOtherCountriesInput = (id) => {
    selectNoneCountry();

    const otherCountrySelect = document.querySelector("#" + id);
    otherCountrySelect.removeAttribute("disabled");
    otherCountrySelect.innerHTML = "";

    // Populate other country selection list
    // const countries = [
    //   { prcn_CountryId: 1, prcn_Country: "USA" },
    // ]

    for (let i in countries) {
        // skip US, Canada and Mexico
        if (
            countries[i].prcn_CountryId == 1 ||
            countries[i].prcn_CountryId == 2 ||
            countries[i].prcn_CountryId == 3
        ) {
            continue;
        }

        const option = document.createElement("option");
        option.setAttribute("value", countries[i].prcn_CountryId);
        option.setAttribute("data-prcn_CountryId", countries[i].prcn_CountryId);
        option.innerHTML = countries[i].prcn_Country;

        otherCountrySelect.appendChild(option);
    }
    otherCountrySelect.focus();
    return otherCountrySelect;
};

const clearallsearch = () => {
    [...document.querySelectorAll(".search-criteria-group")].forEach(
        (htmlElement) => {
            htmlElement.remove();
        },
    );
};

const toggleZipcodeInput = (checked, id) => {
    const input = document.querySelector("#" + id);
    if (checked) {
        input.removeAttribute("disabled");
    } else {
        input.setAttribute("disabled", "disabled");
    }
};



// this function adds options in the
// .bbs-mulSel's menu.
const toggleAllCheckboxes = (isChecked, idThatContainsCheckboxes) => {
    [
        ...document.querySelectorAll(
            `#${idThatContainsCheckboxes}  input[type=checkbox]`,
        ),
    ].forEach((checkbox) => {
        checkbox.checked = isChecked;
    });
};

const toggleExpandCollapse = (button, idToOpenClose) => {
    const isCollapsed =
        button.querySelector(".msicon").innerHTML == "expand_more" ? true : false;
    if (isCollapsed) {
        button.querySelector(".text-label").innerHTML = "Collapse";
        button.querySelector(".msicon").innerHTML = "expand_less";
        document.getElementById(idToOpenClose).classList.remove("tw-hidden");
    } else {
        document.getElementById(idToOpenClose).classList.add("tw-hidden");
        button.querySelector(".text-label").innerHTML = "Expand";
        button.querySelector(".msicon").innerHTML = "expand_more";
    }

    // This is needed so .NET form does not automatically post back
    event.preventDefault();
};

const togglePartialExpandCollapse = (button, idToOpenClose) => {
    const isCollapsed =
        button.querySelector(".msicon").innerHTML == "expand_more" ? true : false;
    if (isCollapsed) {
        button.querySelector(".text-label").innerHTML = "Show less";
        button.querySelector(".msicon").innerHTML = "expand_less";
        document.getElementById(idToOpenClose).classList.remove("collapsed");
    } else {
        document.getElementById(idToOpenClose).classList.add("collapsed");
        button.querySelector(".text-label").innerHTML = "Show more";
        button.querySelector(".msicon").innerHTML = "expand_more";
    }

    // This is needed so .NET form does not automatically post back
    event.preventDefault();
};

const scrollX = (button, amount, idToscroll) => {
    document.getElementById(idToscroll).scrollLeft += amount;
};

const photoModal = document.getElementById("photoModal");
if (photoModal) {
    photoModal.addEventListener("show.bs.modal", (event) => {
        // Button that triggered the modal
        const button = event.relatedTarget;
        // Extract info from data-bs-* attributes
        const imgurl = button.getAttribute("data-bs-imgurl");
        // If necessary, you could initiate an Ajax request here
        // and then do the updating in a callback.

        // Update the modal's content.
        const img = photoModal.querySelector(".modal-body > img");
        if (img) {
            img.setAttribute("src", imgurl);
        }
    });
}

//Simulate real clicks for checkboxes to disable them as needed
function clickIfChecked(pID) {
    var cb = document.getElementById(pID);
    if (!cb.checked)
        return;

    clickForce(pID);
}

function clickForce(pID) {
    var cb = document.getElementById(pID);

    var event = new MouseEvent('click', {
        view: window,
        bubbles: true,
        cancelable: true
    });

    var cancelled = !cb.dispatchEvent(event);
}

function printCompanyProfile() {
    $('body').addClass('for-print');
    window.print();
    $('body').removeClass('for-print');
}

window.addEventListener("beforeprint", (event) => {
    $('body').addClass('for-print');
});

window.addEventListener("afterprint", (event) => {
    $('body').removeClass('for-print');
});
