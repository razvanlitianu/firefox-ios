import "resource://gre/modules/shared/Helpers.ios.mjs";
import { createFormLayoutFromRecord } from "resource://gre/modules/shared/addressFormLayout.js";

// TMP: This should be sent by swift localized ofc
const l10nStrings = {
  "autofill-add-address-title": "Add address",
  "autofill-manage-addresses-title": "Saved addresses",
  "autofill-address-given-name": "First Name",
  "autofill-address-additional-name": "Middle Name",
  "autofill-address-family-name": "Last Name",
  "autofill-address-name": "Name",
  "autofill-address-organization": "Organization",
  "autofill-address-street": "Street Address",
  "autofill-address-state": "State",
  "autofill-address-province": "Province",
  "autofill-address-city": "City",
  "autofill-address-country": "Country or Region",
  "autofill-address-zip": "ZIP Code",
  "autofill-address-postal-code": "Postal Code",
  "autofill-address-email": "Email",
  "autofill-address-tel": "Phone",
  "autofill-edit-address-title": "Edit address",
  "autofill-address-neighborhood": "Neighborhood",
  "autofill-address-village-township": "Village or Township",
  "autofill-address-island": "Island",
  "autofill-address-townland": "Townland",
  "autofill-address-district": "District",
  "autofill-address-county": "County",
  "autofill-address-post-town": "Post town",
  "autofill-address-suburb": "Suburb",
  "autofill-address-parish": "Parish",
  "autofill-address-prefecture": "Prefecture",
  "autofill-address-area": "Area",
  "autofill-address-do-si": "Do/Si",
  "autofill-address-department": "Department",
  "autofill-address-emirate": "Emirate",
  "autofill-address-oblast": "Oblast",
  "autofill-address-pin": "Pin",
  "autofill-address-eircode": "Eircode",
  "autofill-address-country-only": "Country",
  "autofill-cancel-button": "Cancel",
  "autofill-save-button": "Save",
};

window.init = (record) => {
  createFormLayoutFromRecord(
    document.querySelector("form"),
    record,
    l10nStrings
  );

  document.querySelectorAll("input,select,textarea").forEach((el) => {
    el.readOnly = true;
  });

  // Hacky way to size textareas
  // TODO: Fix this with a proper solution if possible
  document.querySelectorAll("textarea").forEach((el) => {
    el.rows = 2;
    el.addEventListener("input", () => {
      el.parentNode.dataset.value = el.value;
    });
  });
};

window.toggleEditMode = () => {
  const elements = document.querySelectorAll("input,select,textarea");
  elements.forEach((element) => {
    element.readOnly = false;
  });

  elements[0].focus();
};
