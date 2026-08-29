const formatSlot = (value) => new Intl.DateTimeFormat("ru-RU", {
  timeZone: "Europe/Moscow",
  hour: "2-digit",
  minute: "2-digit"
}).format(new Date(value));

const refreshSlots = async (dateField, slotsField) => {
  const date = dateField.value;
  if (!date) return;

  const bookingDateValue = document.querySelector("[data-booking-date-value]");
  if (bookingDateValue) bookingDateValue.value = date;

  slotsField.disabled = true;
  try {
    const params = new URLSearchParams({ service_id: dateField.dataset.serviceId, date });
    const response = await fetch(`/api/v1/availability?${params}`, {
      headers: { Accept: "application/json" }
    });
    if (!response.ok) throw new Error("Availability request failed");

    const { slots } = await response.json();
    slotsField.replaceChildren(new Option("Выберите время", ""));
    slots.forEach((slot) => slotsField.add(new Option(formatSlot(slot), slot)));
  } catch (_error) {
    slotsField.replaceChildren(new Option("Не удалось загрузить время", ""));
  } finally {
    slotsField.disabled = false;
  }
};

const initializeBookingSlots = () => {
  const dateField = document.querySelector("[data-booking-date]");
  const slotsField = document.querySelector("[data-booking-slots]");
  if (!dateField || !slotsField || dateField.dataset.slotsInitialized) return;

  dateField.dataset.slotsInitialized = "true";
  dateField.addEventListener("change", () => refreshSlots(dateField, slotsField));
};

document.addEventListener("turbo:load", initializeBookingSlots);
document.addEventListener("DOMContentLoaded", initializeBookingSlots);
