function toggleActiveState(elementArray) {
  if (elementArray.length > 0) {
    // Add a click event on each of them
    elementArray.forEach( el => {
      el.addEventListener('click', () => {
        // Get the target from the "data-target" attribute
        const target = el.dataset.target;
        const $target = document.getElementById(target);
        // toggle active state
        // el.classList.toggle('is-active');  // toggle element active state
        $target.classList.toggle('is-active');  // toggle data-target active state
      });
    });
  }
}

document.addEventListener('DOMContentLoaded', () => {
  // manage hamburger menu state
  // https://bulma.io/documentation/components/navbar/
  const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);
  toggleActiveState($navbarBurgers)
  // use active toggle for modals
  const $modalCallers = Array.prototype.slice.call(document.querySelectorAll('.modal-link'), 0);
  toggleActiveState($modalCallers)
  const $modalClosers = Array.prototype.slice.call(document.querySelectorAll('.modal-close'), 0);
  toggleActiveState($modalClosers)

});