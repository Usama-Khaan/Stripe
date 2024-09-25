document.addEventListener("DOMContentLoaded", function () {
  var stripeKey = document.getElementById("stripe-publishable-key").value;
  var stripe = Stripe(stripeKey);
  var elements = stripe.elements();

  var cardElement = elements.create('card');
  cardElement.mount('#card-element');

  var form = document.getElementById('payment-form');
  form.addEventListener('submit', function (event) {
    event.preventDefault();

    stripe.createToken(cardElement).then(function (result) {
      if (result.error) {
        var errorElement = document.getElementById('card-errors');
        errorElement.textContent = result.error.message;
      } else {
        var hiddenInput = document.createElement('input');
        hiddenInput.setAttribute('type', 'hidden');
        hiddenInput.setAttribute('name', 'stripeToken');
        hiddenInput.setAttribute('value', result.token.id);
        form.appendChild(hiddenInput);

        form.submit();
      }
    });
  });
});
